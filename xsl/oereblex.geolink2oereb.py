import lxml.etree as ET
import os
import logging
import base64
from io import StringIO
from geolink2oereb.transform import run, unify_gathered, assign_uuids

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
log = logging.getLogger(__name__)

OEREB_KRM_MODEL = 'OeREBKRM_V2_0'

geolink_list_trafo_path = os.environ['GEOLINK_LIST_TRAFO_PATH']
xtf_path = os.environ['XTF_PATH']
result_file_path = os.environ['RESULT_FILE_PATH']
oereb_lex_host = os.environ['OEREBLEX_HOST']

theme_code = os.environ['THEME_CODE']
pyramid_oereb_config_path = os.environ['PYRAMID_OEREB_CONFIG_PATH']
section = os.environ['SECTION']
if section in ['', None]:
    section = 'pyramid_oereb'
source_class_path = os.environ['SOURCE_CLASS_PATH']
if source_class_path in ['', None]:
    source_class_path = 'geolink2oereb.lib.interfaces.pyramid_oereb.OEREBlexSourceCustom'
c2ctemplate_style = os.environ['C2CTEMPLATE_STYLE']
if c2ctemplate_style in ['', None, 'false', 'False']:
    c2ctemplate_style = False


def get_document_title(document):
    user_title = {}
    if document['doc.doctype'] == 'decree':
        for language in document['doc.title']:
            user_title[language] = f"{document['doc.title'][language]} ({document['file.title'][language]})"
    else:
        user_title = document['doc.title']

    return user_title


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
with open('/app/result/xslt_result.xml', 'wb+') as f:
    f.write(ET.tostring(transformed, pretty_print=True))

# unify links to download to prevent too long loading of redundant geolinks
processed_geolink_ids = []
result = ['<DATASECTION>']
gathered = []
mgdm_uuid_relation = {}
for child in transformed.getroot().getchildren():
    if child.attrib['mgdm_geolink_id'] not in processed_geolink_ids:
        log.debug(f"processing geolink id {child.attrib['mgdm_geolink_id']}")
        processed_geolink_ids.append(child.attrib['mgdm_geolink_id'])
        oereb_dokumente_aemter = run(
            child.attrib['mgdm_geolink_id'],
            theme_code,
            pyramid_oereb_config_path,
            section, source_class_path=source_class_path,
            c2ctemplate_style=c2ctemplate_style
        )
        dokumente = []
        for dokument, amt in oereb_dokumente_aemter:
            dokumente.append(dokument)
        mgdm_uuid_relation[child.attrib['mgdm_doc_id']] = dokumente
        gathered.extend(oereb_dokumente_aemter)
    else:
        log.debug(f"skipping geolink id {child.attrib['mgdm_geolink_id']}")
unique_dokumente, unique_aemter = unify_gathered(gathered)
uuid_dokumente, uuid_aemter = assign_uuids(unique_dokumente, unique_aemter)
for dokument in uuid_dokumente:
    output = StringIO()
    dokument.set_TID(f'dokument_{dokument.TID}')
    dokument.ZustaendigeStelle.set_REF(f'amt_{dokument.ZustaendigeStelle.REF}')
    dokument.export(output, 0, namespacedef_=None)
    strval = output.getvalue()
    output.close()
    result.append(strval)
for amt in uuid_aemter:
    output = StringIO()
    amt.set_TID(f'amt_{amt.TID}')
    amt.export(output, 0, namespacedef_=None)
    strval = output.getvalue()
    output.close()
    result.append(strval)
mgdm_uuid_relation_xml_structure = []
for key in mgdm_uuid_relation:
    mgdm_uuid_relation_xml_structure.append(f'<MgdmDoc REF="{key}">')
    for dokument in mgdm_uuid_relation[key]:
        if dokument in uuid_dokumente:
            mgdm_uuid_relation_xml_structure.append(
                f'  <OereblexDoc REF="{uuid_dokumente[uuid_dokumente.index(dokument)].TID}"/>'
            )
    mgdm_uuid_relation_xml_structure.append('</MgdmDoc>')
result.append('\n'.join(mgdm_uuid_relation_xml_structure))
result.append('</DATASECTION>')
open(result_file_path, "w+").write('\n'.join(result))
