import lxml.etree as ET
import os
import requests
import uuid
import json
import logging
import base64

loglevel_config = os.environ.get('LOG_LEVEL')

if loglevel_config == 'error':
    log_level = logging.ERROR
elif loglevel_config == 'warning':
    log_level = logging.WARNING
elif loglevel_config == 'debug':
    log_level = logging.DEBUG
else:
    log_level = logging.INFO

logging.basicConfig(
    level=log_level,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

OEREB_KRM_MODEL = 'OeREBKRM_V2_0'

geolink_list_trafo_path = os.environ['GEOLINK_LIST_TRAFO_PATH']
xtf_path = os.environ['XTF_PATH']
result_file_path = os.environ['RESULT_FILE_PATH']
oereb_lex_host = os.environ['OEREBLEX_HOST']
dummy_office_name = os.environ['DUMMY_OFFICE_NAME']
dummy_office_url = os.environ['DUMMY_OFFICE_URL']


def extract_geolink_id(link):
    return link.split('/')[-1].split('.')[0]

def b64_from_string(input_string):
    b = base64.b64encode(bytes(input_string, 'utf-8'))
    return b.decode('utf-8')


# extract links from xslt
dom = ET.parse(xtf_path)
xslt = ET.parse(geolink_list_trafo_path)
transform = ET.XSLT(xslt)
transformed = transform(dom, oereblex_host=ET.XSLT.strparam(oereb_lex_host))

# unify links to download to prevent too long loading of redundant geolinks
oereblex_geolink_unique = {}
for child in transformed.getroot().getchildren():
    if child.attrib['mgdm_geolink_id'] not in oereblex_geolink_unique:
        oereblex_geolink_unique[child.attrib['mgdm_geolink_id']] = {}
        logging.info('LexlinkID {0} was added. '.format(child.attrib['mgdm_geolink_id']))
    else:
        logging.info('LexlinkID {0} was already present. Skipping...'.format(child.attrib['mgdm_geolink_id']))
    if child.attrib['mgdm_geolink_language'] not in oereblex_geolink_unique[child.attrib['mgdm_geolink_id']]:
        attributes = dict(child.attrib)
        # remove singular ID in favour of the join list match
        del attributes['mgdm_doc_id']
        # replace html with xml to get the xml api version of the lexlink
        attributes['mgdm_geolink'] = attributes['mgdm_geolink'].replace('html', 'xml')
        oereblex_geolink_unique[child.attrib['mgdm_geolink_id']][child.attrib['mgdm_geolink_language']] = attributes
        oereblex_geolink_unique[child.attrib['mgdm_geolink_id']][child.attrib['mgdm_geolink_language']]["mgdm_doc_ids"] = [child.attrib['mgdm_doc_id']]
        logging.info(
            'Language {} for LexlinkID {} was added.'.format(
                child.attrib['mgdm_geolink_language'],
                child.attrib['mgdm_geolink_id']
            )
        )
    else:
        oereblex_geolink_unique[child.attrib['mgdm_geolink_id']][child.attrib['mgdm_geolink_language']][
            "mgdm_doc_ids"].append(child.attrib['mgdm_doc_id'])
        logging.info(
            'Language {} for LexlinkID {} was already present. Skipping...'.format(
                child.attrib['mgdm_geolink_language'],
                child.attrib['mgdm_geolink_id']
            )
        )
counter = 0
count = len(oereblex_geolink_unique.keys())
logging.info("Start loading {} geolinks from {}".format(count, oereb_lex_host))
for geolink_id in oereblex_geolink_unique.keys():
    for language in oereblex_geolink_unique[geolink_id].keys():
        pointer = oereblex_geolink_unique[geolink_id][language]
        pointer['documents'] = []
        geolink = pointer["mgdm_geolink"]
        counter += 1
        logging.info("Downloading {} ({}/{})".format(geolink_id, counter, count))
        request = requests.get(geolink)
        if request.status_code < 200 and request.status_code > 299:
            raise IOError("Could download documents for {}".format(geolink))
        logging.info("Successfully downloaded from {}".format(geolink))
        xml = request.text.encode(request.encoding)
        oereblex_dom = ET.fromstring(xml)
        for child in oereblex_dom.getchildren():
            if child.tag == 'document':
                document_dom = child
                # comletely skip federal documents because they should be added via official
                # sources: https://models.geo.admin.ch/V_D/OeREB/OeREBKRM_V2_0_Gesetze.xml
                # TODO: add french identifier of federal docs
                filter_federal_documents = ['Bund', 'Cancelleria federale', 'Confederaziun']
                if document_dom.attrib.get('federal_level'):
                    if document_dom.attrib['federal_level'] in filter_federal_documents:
                        logging.info('Skipping document {} because it belongs to federal level'.format(
                            document_dom.attrib.get('id')
                        ))
                        continue
                document = dict(document_dom.attrib)
                document['files'] = []
                for child in document_dom.getchildren():
                    if child.tag == 'file':
                        file_dom = child
                        file = dict(file_dom.attrib)
                        if file['href'].startswith('/api/attachments'):
                            new_url = 'https://{}{}'.format(
                                oereb_lex_host,
                                file['href']
                            )
                            logging.info('Fixing URL because it was relative from "{}" to "{}"'.format(
                                file['href'],
                                new_url
                            ))
                            file['href'] = new_url
                        document['files'].append(file)
                pointer['documents'].append(document)

logging.info("full tree is:\n" + json.dumps(oereblex_geolink_unique, indent=2))

flattened_documents = {}

for geolink_id in oereblex_geolink_unique.keys():
    
    for language in oereblex_geolink_unique[geolink_id].keys():
        mgdm_doc_ids = oereblex_geolink_unique[geolink_id][language]['mgdm_doc_ids']
        mgdm_geolink = oereblex_geolink_unique[geolink_id][language]['mgdm_geolink']
        mgdm_geolink_id = oereblex_geolink_unique[geolink_id][language]['mgdm_geolink_id']
        for document in oereblex_geolink_unique[geolink_id][language]['documents']:

            for file in document['files']:
                if not flattened_documents.get(document['id']):
                    flattened_documents[document['id']] = {
                        "doc.authority": {
                            language: document.get('authority') or ""
                        },
                        "doc.authority_url": {
                            language: document.get('authority_url') or ""
                        },
                        "doc.category": document['category'],
                        "doc.doctype": document['doctype'],
                        "doc.enactment_date": document.get('enactment_date') or '1970-01-01',
                        "doc.federal_level": {
                            language: document.get('federal_level') or ''
                        },
                        "doc.id": document['id'],
                        "doc.number": {
                            language: document.get('number') or ''
                        },
                        "doc.title": {
                            language: document['title']
                        },
                        "file.category": file["category"],
                        "file.description": {
                            language: file.get("description") or ""
                        },
                        "file.href": {
                            language: file["href"]
                        },
                        "file.title": {
                            language: file["title"]
                        },
                        "mgdm.geolink_id": mgdm_geolink_id,
                        "mgdm.geolink": {
                            language: mgdm_geolink
                        },
                        "mgdm.tids": []
                    }
                for mgdm_doc_id in mgdm_doc_ids:
                    if mgdm_doc_id not in flattened_documents[document['id']]["mgdm.tids"]:
                        flattened_documents[document['id']]["mgdm.tids"].append(mgdm_doc_id)
                logging.info('Adding a new doc to flattened documents with id {0}.'.format(document['id']))
            else:
                flattened_documents[document['id']]["doc.authority"][language] = document.get('authority') or ""
                flattened_documents[document['id']]["doc.authority_url"][language] = document.get('authority_url') or ""
                flattened_documents[document['id']]["doc.federal_level"][language] = document.get('federal_level') or ''
                flattened_documents[document['id']]["doc.number"][language] = document.get('number') or ''
                flattened_documents[document['id']]["doc.title"][language] = document['title']
                flattened_documents[document['id']]["file.description"][language] = file.get("description") or ""
                flattened_documents[document['id']]["file.href"][language] = file["href"]
                flattened_documents[document['id']]["file.title"][language] = file["title"]
                for mgdm_doc_id in mgdm_doc_ids:
                    if mgdm_doc_id not in flattened_documents[document['id']]["mgdm.tids"]:
                        flattened_documents[document['id']]["mgdm.tids"].append(mgdm_doc_id)
                flattened_documents[document['id']]["mgdm.geolink"][language] = mgdm_geolink
                logging.info('Document ID {} already in flattened dict. Adding up...'.format(document['id']))

uuid_flattened_documents = {}
for key in flattened_documents:
    uuid_string = str(uuid.uuid4())
    uuid_flattened_documents[uuid_string] = flattened_documents[key]
    uuid_flattened_documents[uuid_string]["doc.id"] = uuid_string

flattened_documents = uuid_flattened_documents

unique_authorities = {}

for key in flattened_documents.keys():
    identifier = b64_from_string(json.dumps(flattened_documents[key]["doc.authority_url"]))
    flattened_documents[key]["doc.authority_id"] = identifier
    if identifier not in unique_authorities:
        unique_authorities[identifier] = {
            "authority_url": flattened_documents[key]["doc.authority_url"],
            "authority": flattened_documents[key]["doc.authority"]
        }
    del flattened_documents[key]["doc.authority_url"]
    del flattened_documents[key]["doc.authority"]

# resolve ambiquity between original docs from mgdm and docs delivered by oereblex
unique_join_mgdm_tid = {}

for key in flattened_documents.keys():
    for mgdm_tid in flattened_documents[key]["mgdm.tids"]:
        if mgdm_tid not in flattened_documents.keys():
            unique_join_mgdm_tid[mgdm_tid] = []
for join_key in unique_join_mgdm_tid.keys():
    for doc_key in flattened_documents.keys():
        if join_key in flattened_documents[doc_key]["mgdm.tids"]:
            unique_join_mgdm_tid[join_key].append(doc_key)


# assign real uuids to elements to have ili valid items in the end
uuid_authorities = {}

for auth_key in unique_authorities.keys():
    uuid_string = str(uuid.uuid4())
    uuid_authorities[uuid_string] = unique_authorities[auth_key]
    
    for doc_key in flattened_documents.keys():
        if auth_key == flattened_documents[doc_key]["doc.authority_id"]:
            flattened_documents[doc_key]["doc.authority_id"] = uuid_string

for key in flattened_documents:
    is_empty = []
    for language in flattened_documents[key]["doc.number"].keys():
        if flattened_documents[key]["doc.number"][language] == '':
            logging.info("Found an empty string for {}".format('.'.join([key, "doc.number", language])))
            is_empty.append('yes')
        else:
            logging.info("Found a string for {}".format('.'.join([key, "doc.number", language])))
            is_empty.append('no')
    if 'no' in is_empty:
        logging.info("Found string for official number in document {}. Not touching it...".format(key))
        continue
    logging.info("All official numbers of document {} are empty. Setting it to None...".format(key))
    flattened_documents[key]["doc.number"] = None

# check for dummy amt (it has empty name and emtpy url) and fix it to be ili valid
for auth_key in uuid_authorities.keys():
    is_dummy = []
    # check if all values are empty strings => only than its a dummy office
    for language_key in uuid_authorities[auth_key]["authority_url"].keys():
        if uuid_authorities[auth_key]["authority_url"][language_key] == '':
            logging.info("Found an empty string for {}".format('.'.join([auth_key, "authority_url", language_key])))
            is_dummy.append("dummy")
        else:
            is_dummy.append("not_dummy")
    for language_key in uuid_authorities[auth_key]["authority"].keys():
        if uuid_authorities[auth_key]["authority"][language_key] == '':
            logging.info("Found an empty string for {}".format('.'.join([auth_key, "authority", language_key])))
            is_dummy.append("dummy")
        else:
            is_dummy.append("not_dummy")
    # there was at least one element which had a value => we do not touch it
    if "not_dummy" in is_dummy:
        logging.info("Found 'not_dummy' in office {}. Not touching it...".format(auth_key))
        continue
    logging.info("We have a dummy office for {}. Inserting standard data...".format(auth_key))
    # there was no element with a value, we fill the dummy with provided standard values
    for language_key in uuid_authorities[auth_key]["authority_url"].keys():
        if uuid_authorities[auth_key]["authority_url"][language_key] == '':
            logging.info("adding standard authority_url for {}".format('.'.join([auth_key, "authority_url", language_key])))
            uuid_authorities[auth_key]["authority_url"][language_key] = dummy_office_url
    for language_key in uuid_authorities[auth_key]["authority"].keys():
        if uuid_authorities[auth_key]["authority"][language_key] == '':
            logging.info("adding standard authority for {}".format('.'.join([auth_key, "authority", language_key])))
            uuid_authorities[auth_key]["authority"][language_key] = dummy_office_name

# minimal fix URL of authority because it might not ili valid
for auth_key in uuid_authorities.keys():
    for language_key in uuid_authorities[auth_key]["authority_url"].keys():
        if not uuid_authorities[auth_key]["authority_url"][language_key].startswith('http'):
            new_url = 'https://{}'.format(uuid_authorities[auth_key]["authority_url"][language_key])
            logging.info("Fixing url from {} to {} for {}".format(
                uuid_authorities[auth_key]["authority_url"][language_key],
                new_url,
                '.'.join([auth_key, "authority_url", language_key]))
            )
            uuid_authorities[auth_key]["authority_url"][language_key] = new_url

logging.info("full tree is:\n" + json.dumps(flattened_documents, indent=2))
logging.info("full tree is:\n" + json.dumps(uuid_authorities, indent=2))
logging.info("full tree is:\n" + json.dumps(unique_join_mgdm_tid, indent=2))

def multilingual_text(parts):
    localized_text_root = ET.Element("LocalisedText")
    for language in parts.keys():
        localized_text = ET.Element("LocalisationCH_V1.LocalisedText")
        language_element = ET.Element("Language")
        language_element.text = language
        text_elemement = ET.Element("Text")
        if parts[language] is None or parts[language] == '':
            logging.info('Multilingual text element was empty in:\n {}'.format(json.dumps(parts, indent=2)))
        text_elemement.text = parts[language]
        localized_text.append(language_element)
        localized_text.append(text_elemement)
        localized_text_root.append(localized_text)
    multilingual_text = ET.Element("LocalisationCH_V1.MultilingualText")
    multilingual_text.append(localized_text_root)
    return multilingual_text

def multilingual_uri(parts):
    localized_text_root = ET.Element("LocalisedText")
    for language in parts.keys():
        localized_text = ET.Element("{}.LocalisedUri".format(OEREB_KRM_MODEL))
        language_element = ET.Element("Language")
        language_element.text = language
        text_elemement = ET.Element("Text")
        if parts[language] is None or parts[language] == '':
            logging.info('Multilingual uri element was empty in:\n {}'.format(json.dumps(parts, indent=2)))
        text_elemement.text = parts[language]
        localized_text.append(language_element)
        localized_text.append(text_elemement)
        localized_text_root.append(localized_text)
    multilingual_text = ET.Element("{}.MultilingualUri".format(OEREB_KRM_MODEL))
    multilingual_text.append(localized_text_root)
    return multilingual_text

root = ET.Element('DATASECTION')
for key in uuid_authorities.keys():
    amt = ET.Element("{}.Amt.Amt".format(OEREB_KRM_MODEL), TID="amt_{}".format(key))
    name = ET.Element("Name")
    name.append(multilingual_text(uuid_authorities[key]['authority']))
    amt.append(name)
    amt_im_web = ET.Element("AmtImWeb")
    amt_im_web.append(multilingual_uri(uuid_authorities[key]['authority_url']))
    amt.append(amt_im_web)
    root.append(amt)

for key in unique_join_mgdm_tid:
    mgdm_doc_element = ET.Element('MgdmDoc', REF=key)
    for doc_ref in unique_join_mgdm_tid[key]:
        mgdm_doc_element.append(ET.Element('OereblexDoc', REF="dokument_{}".format(doc_ref)))
    root.append(mgdm_doc_element)

document_index = 1
for key in flattened_documents:
    document_element = ET.Element('{}.Dokumente.Dokument'.format(OEREB_KRM_MODEL), TID="dokument_{}".format(key))
    root.append(document_element)
    # TODO: improve, to also get documents maybe not in inForce out of oereblex
    law_status_element = ET.Element('Rechtsstatus')
    law_status_element.text = 'inKraft'
    document_element.append(law_status_element)
    document_index_element = ET.Element('AuszugIndex')
    document_index_element.text = str(document_index)
    document_index += 1
    document_element.append(document_index_element)
    enactment_date_element = ET.Element('publiziertAb')
    enactment_date_element.text = flattened_documents[key]['doc.enactment_date']
    document_element.append(enactment_date_element)
    if flattened_documents[key]['doc.doctype'] == "decree":
        doctype = 'Rechtsvorschrift'
    elif flattened_documents[key]['doc.doctype'] == "edict":
        doctype = 'GesetzlicheGrundlage'
    elif flattened_documents[key]['doc.doctype'] == "notice":
        doctype = 'Hinweis'
    else:
        error_msg = 'Unbekannter Dokumenttyp original aus ÖREBlex war: {}'.format(flattened_documents[key]['doc.doctype'])
        logging.error(error_msg)
        raise ValueError(error_msg)
    doctype_element = ET.Element("Typ")
    doctype_element.text = doctype
    document_element.append(doctype_element)
    title_element = ET.Element("Titel")
    title_element.append(multilingual_text(flattened_documents[key]['doc.title']))
    document_element.append(title_element)
    if flattened_documents[key]['doc.number'] is not None:
        official_number_element = ET.Element("OffizielleNr")
        official_number_element.append(multilingual_text(flattened_documents[key]['doc.number']))
        document_element.append(official_number_element)
    text_at_web_element = ET.Element('TextImWeb')
    text_at_web_element.append(multilingual_uri(flattened_documents[key]['file.href']))
    document_element.append(text_at_web_element)
    document_element.append(
        ET.Element('ZustaendigeStelle', REF="amt_{}".format(flattened_documents[key]['doc.authority_id']))
    )

open(result_file_path, "wb+").write(ET.tostring(root, pretty_print=True))
