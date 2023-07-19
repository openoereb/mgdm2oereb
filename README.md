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
    -e TARGET_BASKET_ID="ch.BelasteteStandorte" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.BelasteteStandorte.sh.mgdm_oereblex.v1_5.xtf" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate
```

Be aware, that the packed test data might come out of sync to ÖREBlex. In this case download a newer Version
under: https://geodienste.ch/downloads/interlis/kataster_belasteter_standorte/SH/kataster_belasteter_standorte_v1_5_SH_lv95.zip

Unpack the contained xtf and replace it with the packed one.

### v1.5

```bash
docker run \
    --rm \
    -ti \
    -u $(id -u):$(id -g) \
    -v $(pwd):/app \
    -e MODEL="KbS_V1_5" \
    -e THEME_CODE="ch.BelasteteStandorte" \
    -e TARGET_BASKET_ID="ch.BelasteteStandorte" \
    -e XTF_FILE="ch.BelasteteStandorte.sh.mgdm.v1_5.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
```
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
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e OEREBLEX_HOST="oereblex.gr.ch" \
    -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.xtf" \
    -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="gr" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate
```

##### geolink2oereb

Possibility to run the extraction of ÖREBlex documents with known and tested tools 
[pyramid_oereb](https://github.com/openoereb/pyramid_oereb) and 
[geolinkformatter](https://github.com/openoereb/geolink_formatter).

This saves a lot of configuration and takes all available and necessary languages into account.

The usage is similar to the other implementations. The configuration is done by environment variables.

A full example can be seen below:

```bash
docker run \
    --rm \
    -ti \
    -u $(id -u):$(id -g) \
    -v $(pwd):/app \
    -e MODEL="Planungszonen_V1_1" \
    -e THEME_CODE="ch.Planungszonen" \
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e OEREBLEX_HOST="oereblex.gr.ch" \
    -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.xtf" \
    -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
    -e PYRAMID_OEREB_CONFIG_PATH="/app/config_gr.yaml" \
    -e SECTION="pyramid_oereb" \
    -e SOURCE_CLASS_PATH="geolink2oereb.lib.interfaces.pyramid_oereb.OEREBlexSourceCustom" \
    -e C2CTEMPLATE_STYLE="False" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-geolink2oereb mgdm2oereb-oereblex validate
```

As you can see the call uses 4 additional environment variables:

- PYRAMID_OEREB_CONFIG_PATH => The absolute path to the pyramid_oereb configuration file
- SECTION (default: pyramid_oereb) => The section within the yaml file identifying the section where to find
  the pyramid_oereb configuration
- SOURCE_CLASS_PATH (default: geolink2oereb.lib.interfaces.pyramid_oereb.OEREBlexSourceCustom) => The source 
  used to extract pyramid_oereb document records from ÖREBlex. This can be pointed to something else to
  manipulate the behaviour (filtering of documents, adjustments of titles etc.). Be aware that the configured
  class need to be in the python path of mgdm2oereb (so in this example installed inside the container).
- C2CTEMPLATE_STYLE (default: False) => wether the C2C templating mechanism should be used or not.

All environment variables with default values may be omitted. So a call might look like this:

```bash
docker run \
    --rm \
    -ti \
    -u $(id -u):$(id -g) \
    -v $(pwd):/app \
    -e MODEL="Planungszonen_V1_1" \
    -e THEME_CODE="ch.Planungszonen" \
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e OEREBLEX_HOST="oereblex.gr.ch" \
    -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.xtf" \
    -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
    -e PYRAMID_OEREB_CONFIG_PATH="/app/config_gr.yaml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-geolink2oereb mgdm2oereb-oereblex validate
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
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e OEREBLEX_HOST="oereblex.gr.ch" \
    -e XTF_FILE="ch.Planungszonen.gr.mgdm_oereblex.v1_1.empty_zones.xtf" \
    -e CATALOG="ch.gr.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="gr" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate
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
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Planungszonen.sh.mgdm_oereblex.v1_1.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate
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
    -e TARGET_BASKET_ID="ch.Planungszonen" \
    -e XTF_FILE="ch.Planungszonen.sh.mgdm.v1_1.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
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
    -e TARGET_BASKET_ID="ch.tha.Nutzungsplanung" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Nutzungsplanung.sh.tha.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate 
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
    -e TARGET_BASKET_ID="ch.tha.Nutzungsplanung" \
    -e XTF_FILE="ch.Nutzungsplanung.sh.tha.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
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
    -e TARGET_BASKET_ID="ch.StatischeWaldgrenzen" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Waldgrenzen.sh.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate 
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
    -e TARGET_BASKET_ID="ch.StatischeWaldgrenzen" \
    -e XTF_FILE="ch.Waldgrenzen.sh.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
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
    -e TARGET_BASKET_ID="ch.tha.Laermempfindlichkeitsstufen" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Laermempfindlichkeitsstufen.sh.tha.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate 
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
    -e TARGET_BASKET_ID="ch.tha.Laermempfindlichkeitsstufen" \
    -e XTF_FILE="ch.Laermempfindlichkeitsstufen.sh.tha.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
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
    -e TARGET_BASKET_ID="ch.Grundwasserschutzzonen" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate 
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
    -e TARGET_BASKET_ID="ch.Grundwasserschutzzonen" \
    -e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
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
    -e TARGET_BASKET_ID="ch.Grundwasserschutzareale" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate 
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
    -e TARGET_BASKET_ID="ch.Grundwasserschutzareale" \
    -e XTF_FILE="ch.Planerischergewaesserschutz.sh.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
```

## Waldreservate

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
    -e TARGET_BASKET_ID="ch.Waldreservate" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Waldreservate.sh.mgdm_oereblex.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-oereblex validate
```

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
    -e TARGET_BASKET_ID="ch.Waldreservate" \
    -e XTF_FILE="ch.Waldreservate.sh.mgdm.v1_2.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
```

## Gewässerraum

### v1.1 ÖREBlex

#### SH


Aktuell funktioniert aktuell nicht, da die ÖREBlexdaten kaputt sind.
```bash
docker run \
    --rm \
    -ti \
    -u $(id -u):$(id -g) \
    -v $(pwd):/app \
    -e MODEL="Gewaesserraum_V1_1" \
    -e THEME_CODE="ch.Gewaesserraum" \
    -e TARGET_BASKET_ID="ch.Gewaesserraum" \
    -e OEREBLEX_HOST="oereblex.sh.ch" \
    -e XTF_FILE="ch.Gewaesserraum.sh.mgdm_oereblex.v1_1.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    -e OEREBLEX_CANTON="sh" \
    -e DUMMY_OFFICE_NAME="DUMMYOFFICE" \
    -e DUMMY_OFFICE_URL="https://google.ch" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb-prepare-oereblex-docs-native mgdm2oereb-oereblex validate
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
    -e TARGET_BASKET_ID="ch.Gewaesserraum" \
    -e XTF_FILE="ch.Gewaesserraum.sh.mgdm.v1_1.xtf" \
    -e CATALOG="ch.sh.OeREBKRMkvs_supplement.xml" \
    mgdm2oereb-transformator:latest make clean mgdm2oereb validate
```
