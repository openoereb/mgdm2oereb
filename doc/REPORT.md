# Festlegungen

## Grundlagen

MGDM2OEREB stützt sich auf die Definition von Modellen und Darstellungskatalogen welche durch den Bund vorgegeben
werden. Eine simple Verlinkung auf diese Resourcen führt zur Mehrdeutigkeit, falls diese Ressourcen ändern.
Eine Änderung hat überdies auch fast immer einen Einfluss auf die Transformationslogik. Deshalb werden die verwendeten
Resourcen hier statisch mit dem Repository verbunden. Ein Update mit gegebenenfalls Anpassungen an der
Transformationslogik muss manuell erfolgen.

## Ergänzende Daten

Daten, welche im MGDM fehlen müssen bereitgestellt werden. Für MGDM2OEREB wurde fesgelegt, dass dies über den bereits
bekannten mechanismus eines externen Kataloges passiert. Dieser muss die fehlenden Elemente bereits gemäss Modell
[ÖREB-Transferstruktur](./fed/OeREBKRMtrsfr_V2_0.ili) enthalten.

Damit die Konfiguration funktioniert muss ein Schema bei den Dateinamen eingehalten werden:

```bash
{model}.katalog.{katalog_name}.xml
```

Daraus ergibt sich beispielsweise für den Katalog des Darstellungsdienstes:
```bash
Planungszonen_V1_1.katalog.darstellungsdienst.xml
```

### Basket ID OeREBKRMtrsfr_V2_0

> **_Festlegung:_**
Als Basket ID wird im Zieldatensatz immer der Themenname verwendet.

Zum Beispiel:
```angular2html
ch.Planungszonen
```

### Darstellungsdienst

Der Darstellungsdienst ist in den MGDM nicht vorhanden. Für den kompletten Datensatz der per MGDM geliefert wird
kann exakt ein (1) Darstellungsdienst definiert werden.

### OEREBlex

#### Notice

Es gibt einige Unterschiede zwischen dem Modell welches ÖREBlex ausliefert wenn ein XMl zu einem GeoLink
abgerufen wird und dem Modell welches durch die ÖREB Transferstruktur verlangt wird. Das betrifft insbesondere
Dokumente welche in ÖREBlex als *notice* geführt werden. Diese werden durch die Transformation in den
Dokumenttyp *Hinweis* übersetzt. Eine notice kann aber im ÖREBlex weder ein publiziert_ab Datum noch eine
zuständige Stelle erhalten. Vergleiche hierzu auch die aktuelle Umsetzung [pyramid_oereb](https://github.com/openoereb/pyramid_oereb/blob/9134ae187f510bf171f23c0dacaec403fc732eb7/pyramid_oereb/contrib/data_sources/oereblex/sources/document.py#L163-L171)

> **_Festlegung:_**
MGDM2OEREB setzt als Datum den 01.01.1970 für den ÖREBlex Typ *notice*.

> **_Festlegung:_**
MGDM2OEREB setzt als zuständige Stelle '-' wenn ÖREBlex *authority* fehlt und Typ *notice* ist.

# Themenspezifische Festlegungen

## Kataster der belasteten Standorte v1.5

### Darstellungsdienst

Als Darstellungsdienst wird standardmässig der WMS von 
[geodienste.ch](https://geodienste.ch/db/kataster_belasteter_standorte_v1_5_0?) verwendet. Dies kann durch die
Lieferung eines angepassten [Kataloges](../xsl/KbS_V1_5.katalog.darstellungsdienst.xml) überschrieben werden. Es ist
darauf zu achten, dass ein Darstellungsdienst mehrsprachige Elemente enthält. Diese müssen vollständig vorhanden sein.

### Codetexte

Für KbS_V1_5 besteht ein [Katalog](https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5.xml) welcher das Modell ergänzt.
Dieser ist in MGDM2OEREB [integriert](../xsl/KbS_V1_5.katalog.code_texte.xml). Damit wird eine gewisse Stabilität
sichergestellt. Sollten sich durch den Bund verursachte Änderungen ergeben, so ist dieser Katalog manuell in MGDM2OEREB
zu aktualisieren.

## Planungszonen v1.1

### Darstellungsdienst

Als Darstellungsdienst wird standardmässig der WMS von 
[geodienste.ch](https://geodienste.ch/db/planungszonen_v1_1_0?) verwendet. Dies kann durch die Lieferung eines
angepassten [Kataloges](../xsl/ch.Planungszonen.v1_1.katalog.darstellungsdienst.xml) überschrieben werden. Es ist
darauf zu achten, dass ein Darstellungsdienst mehrsprachige Elemente enthält. Diese müssen vollständig vorhanden sein.

### Legendeneintrag Symbol

Die Legendeneinträge 1:1 aus dem MGDM abzuleiten ist nicht eindeutig. Der
[Darstellungskatalog](./fed/Planungszonen_V1_1/Darstellungskatalog-MGDM-ID-76-V1_1.xlsx) sieht die grafische
Unterscheidung in 3 Kategorien vor:
- Gemeinde
- Kanton
- andere

Das spiegelt sich auch im [MGDM](./fed/Planungszonen_V1_1/Planungszonen_V1_1.ili) durch die 'Festlegung_Stufe'
wider. Diese grafische Darstellung ist der Kern des ÖERBKatasters.
Die Zuordnung im MGDM aber ist diversifizierter und erlaubt den Transfer einer Bezeichnung zusätzlich zur
Stufenfestlegung. Damit ergibt sich ein Dilemma.

Wenn man, wie in der [Modelldokumentation](./fed/Planungszonen_V1_1/Planungszonen_Modelldokumentation-V1_1.pdf) in
Kapitel 10.2 vorgeschlagen, Typ.Bezeichnung vom MGDM in LegendeEintrag.LegendeText nach `OeREBKRMtrsfr_V2_0` überträgt,
ergibt sich grafisch eine Mehrdeutigkeit. Legendenelemente unterschiedlicher Bedeutung haben dasselbe Symbol aber
unterschiedliche Legendentexte.

> **_Festlegung:_**
MGDM2OEREB überträgt die Bezeichnung aus dem MGDM auf den Legendeneintrag im ÖREB. Damit erhält man eine optisch
mehrdeutige Legende, transportiert aber die Information.

Zu diesem Zweck exisitert ein [Katalog](../xsl/ch.Planungszonen.v1_1.katalog.legenden_eintrag.xml) mit
Legendeneinträgen welche die 3 genannten Stufen abbilden.

### Legendeneintrag Bezeichnung

Alle relevanten Teile im ÖREB-Modell sind mehrsprachig gehalten. Das trifft auch auf die Legendentexte zu. Die
Bezeichnung des Typs im MGDM der Planungszonen ist aber nicht mehrsprachig.

> **_Festlegung:_**
MGDM2OEREB nutzt die Bezeichnung aus dem MGDM und wrappt sie in ein mehrsprachiges Element. Dazu wird die Bezeichnung
aus dem MGDM in alle 4 Sprachen gewrappt. Damit verhindert man aufwändige und fehleranfällige Konfigurationen.

### Zuordnung Dokument => Eigentumsbeschränkung

Das Modell MGDM erlaubt die Zuordnung von Dokumenten zu TypPZ und zu Planungszone. Das ÖEREB-Modell erlaubt Dokumente
nur in Beziehung zur Eigentumsbeschränkung. Nicht aber direkt zur Geometrie.

> **_Festlegung:_**
MGDM2OEREB überträgt nur die Dokumente welche im MGDM TypPZ zugeordnet sind.


