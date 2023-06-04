# Wie benutzt man das?

Es gibt 2 Wege diese Basisbibliothek zu nutzen:

1. Per fertigem Docker Image.
1. Direkt aus dem Sourcecode.

Das Projekt bietet Testdatensätze. Diese sind von den Kantonen Schaffhausen und Graubünden bereitgestellt
worden und sollen nur Demonstrationszwecken dienen:

- [MGDM belastete Standorte v1.5 SH](data/ch.BelasteteStandorte.sh.mgdm_oereblex.v1_5.xtf)
- [MGDM Planungszonen v1.1 SH mit Dokumenten aus ÖREBlex](data/ch.Planungszonen.sh.mgdm_oereblex.v1_1.xtf)
- [MGDM belastete Standorte v1.5 SH](data/ch.Planungszonen.sh.mgdm.v1_1.xtf)
- [MGDM Planungszonen v1.1 GR mit Dokumenten aus ÖREBlex](data/ch.Planungszonen.gr.mgdm_oereblex.v1_1.xtf)

# Per fertigem Docker Image

TODO

# Direkt aus dem Sourcecode

## Projekt holen

```
git clone https://github.com/openoereb/mgdm2oereb.git
```

in den neuen Ordner wechseln:

```
cd mgdm2oereb
```
> **_HINWEIS:_**
Alle folgenden Befehle setzen voraus, dass man sich im Projektordner befindet!

## Docker Image lokal erstellen

```
docker build -t  mgdm2oereb-transformator:latest .
```

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
  -e XTF_FILE="ch.BelasteteStandorte.sh.mgdm_oereblex.v1_5.xtf" \
  -e OEREBLEX_CANTON="gr" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```

Be aware, that the packed test data might come out of sync to ÖREBlex. In this case download a newer Version
under: https://geodienste.ch/downloads/interlis/kataster_belasteter_standorte/SH/kataster_belasteter_standorte_v1_5_SH_lv95.zip

Unpack the contained xtf and replace it with the packed one.

### v1.5

TODO

## Planungszonen

### v1.1 ÖREBlex

#### GR

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Planungszonen_V1_1" \
  -e THEME_CODE="ch.Planungszonen" \
  -e OEREBLEX_HOST="oereblex.gr.ch" \
  -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.xtf" \
  -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
  -e OEREBLEX_CANTON="gr" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```
**special test with empty zones (it should not output any legendentries nor view services**

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Planungszonen_V1_1" \
  -e THEME_CODE="ch.Planungszonen" \
  -e OEREBLEX_HOST="oereblex.gr.ch" \
  -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.empty_zones.xtf" \
  -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
  -e OEREBLEX_CANTON="gr" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Planungszonen_V1_1" \
  -e THEME_CODE="ch.Planungszonen" \
  -e OEREBLEX_HOST="oereblex.sh.ch" \
  -e XTF_FILE="ch.Planungszonen.sh.mgdm_oereblex.v1_1.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  -e OEREBLEX_CANTON="sh" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```

Frische Daten können hier heruntergeladen werden:
https://geodienste.ch/downloads/interlis/planungszonen/SH/planungszonen_v1_1_SH_lv95.zip

### v1.1

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Planungszonen_V1_1" \
  -e THEME_CODE="ch.Planungszonen" \
  -e XTF_FILE="ch.Planungszonen.sh.mgdm.v1_1.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Nutzungsplanung

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="Nutzungsplanung_V1_2" \
-e THEME_CODE="ch.Nutzungsplanung" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Nutzungsplanung.sh.tha.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex 
```

### v1.2

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Nutzungsplanung_V1_2" \
  -e THEME_CODE="ch.Nutzungsplanung" \
  -e XTF_FILE="ch.Nutzungsplanung.sh.tha.mgdm.v1_2.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Statische Waldgrenzen

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="Waldgrenzen_V1_2" \
-e THEME_CODE="ch.StatischeWaldgrenzen" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Waldgrenzen.sh.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex 
```

### v1.2

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="Waldgrenzen_V1_2" \
-e THEME_CODE="ch.StatischeWaldgrenzen" \
-e XTF_FILE="ch.Waldgrenzen.sh.mgdm.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Lärmempfindlichkeitsstufen

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="Laermempfindlichkeitsstufen_V1_2" \
-e THEME_CODE="ch.Laermempfindlichkeitsstufen" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Laermempfindlichkeitsstufen.sh.tha.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex 
```

### v1.2

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="Laermempfindlichkeitsstufen_V1_2" \
-e THEME_CODE="ch.Laermempfindlichkeitsstufen" \
-e XTF_FILE="ch.Laermempfindlichkeitsstufen.sh.tha.mgdm.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Planerischer Gewässerschutz - Grundwasserschutzzonen

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="PlanerischerGewaesserschutz_V1_2" \
-e THEME_CODE="ch.Grundwasserschutzzonen" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex 
```

### v1.2

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="PlanerischerGewaesserschutz_V1_2" \
-e THEME_CODE="ch.Grundwasserschutzzonen" \
-e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Planerischer Gewässerschutz - Grundwasserschutzareale

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="PlanerischerGewaesserschutz_V1_2" \
-e THEME_CODE="ch.Grundwasserschutzareale" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex 
```

### v1.2

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="PlanerischerGewaesserschutz_V1_2" \
-e THEME_CODE="ch.Grundwasserschutzareale" \
-e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
mgdm2oereb-transformator:latest make clean mgdm2oereb
```

## Waldreservate

### v1.2

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="SH_Waldreservate_V1_2" \
  -e THEME_CODE="ch.Waldreservate" \
  -e XTF_FILE="ch.Waldreservate.sh.mgdm.v1_2.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  mgdm2oereb-transformator:latest make clean mgdm2oereb
```

### v1.2 ÖREBlex

#### SH

```bash
docker run \
--rm \
-ti \
-u $(id -u):$(id -g) \
-v $(pwd):/app \
-e MODEL="SH_Waldreservate_V1_2" \
-e THEME_CODE="ch.Waldreservate" \
-e OEREBLEX_HOST="oereblex.sh.ch" \
-e XTF_FILE="ch.Waldreservate.sh.mgdm_oereblex.v1_2.xtf" \
-e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
-e OEREBLEX_CANTON="sh" \
-e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
-e DUMMY_OFFICE_URL="https://google.ch" \
mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```

## Gewässerraum

### v1.1 ÖREBlex

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Gewaesserraum_V1_1" \
  -e THEME_CODE="ch.Gewaesserraum" \
  -e OEREBLEX_HOST="oereblex.sh.ch" \
  -e XTF_FILE="ch.Gewaesserraum.sh.mgdm_oereblex.v1_1.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  -e OEREBLEX_CANTON="sh" \
  -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
  -e DUMMY_OFFICE_URL="https://google.ch" \
  mgdm2oereb-transformator:latest make clean clean_oereblex_xml mgdm2oereb-oereblex
```

### v1.1

#### SH

```bash
docker run \
  --rm \
  -ti \
  -u $(id -u):$(id -g) \
  -v $(pwd):/app \
  -e MODEL="Gewaesserraum_V1_1" \
  -e THEME_CODE="ch.Gewaesserraum" \
  -e XTF_FILE="ch.Gewaesserraum.sh.mgdm.v1_1.xtf" \
  -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
  mgdm2oereb-transformator:latest make clean mgdm2oereb
```