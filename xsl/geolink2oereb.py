import lxml.etree as ET
import os
import logging
import base64
from geolink2oereb.transform import run

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

theme_code = os.environ['THEME_CODE']
pyramid_oereb_config_path = os.environ['PYRAMID_OEREB_CONFIG_PATH']
section = os.environ['SECTION']
source_class_path = os.environ.get(
    'SOURCE_CLASS_PATH',
    'geolink2oereb.lib.interfaces.pyramid_oereb.OEREBlexSourceCustom'
)
c2ctemplate_style = os.environ.get('C2CTEMPLATE_STYLE', False)

run(id, theme_code, pyramid_oereb_config_path, section, source_class_path=source_class_path, c2ctemplate_style=c2ctemplate_style)


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
result = []
for child in transformed.getroot().getchildren():
    documents = run(
        child.attrib['mgdm_geolink_id'],
        theme_code,
        pyramid_oereb_config_path,
        section, source_class_path=source_class_path,
        c2ctemplate_style=c2ctemplate_style
    )
    for document in documents:
        result.append(str(document))


open(result_file_path, "w+").write('\n'.join(result))
