# Build Image

```
docker build -t  mgdm2oereb-transformator:latest .
```

#Transformationen

## Kataster der belasteten Standorte

### v1.5 ÖREBlex (Kt. SH)

Example how to transform a kbs_v1_5 MGDM into OeREBKRMtrsfr_V2_0.

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="KbS_V1_5" \
  -e THEME_CODE="ch.BelasteteStandorte" \
  -e OEREBLEX_HOST="oereblex.sh.ch" \
  -e XTF_PATH="/app/data/kbs_v1_5.xtf" \
  -e OEREBLEX_CANTON="gr" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb
```

Be aware, that the packed test data might come out of sync to ÖREBlex. In this case download a newer Version
under: https://geodienste.ch/downloads/interlis/kataster_belasteter_standorte/SH/kataster_belasteter_standorte_v1_5_SH_lv95.zip

Unpack the contained xtf and replace it with the packed one.

### v1.5

TODO

## Planungszonen

### v1.1 ÖREBlex

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd)/result:/output \
  -v $(pwd)/xsl/planungszonen/v1.1.oereblex:/trafo \
  -e DOWNLOAD_URL="https://www.geodienste.ch/downloads/interlis/planungszonen/SH/planungszonen_v1_1_SH_lv95.zip" \
  mgdm2oereb-transformator:latest make clean download_mgdm unzip_mgdm clean_oereblex_xml oereblex2oereb_2_0_authorities oereblex2oereb_2_0_documents mgdm2oereb
```

### v1.1

TODO
