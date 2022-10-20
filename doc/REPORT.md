# Festlegungen

## Grundlagen

MGDM2OEREB stützt sich auf die Definition von Modellen und Darstellungskatalogen welche durch den Bund
vorgegeben werden. Eine simple Verlinkung auf diese Resourcen führt zur Mehrdeutigkeit, falls diese Ressourcen
ändern. Eine Änderung hat überdies auch fast immer einen Einfluss auf die Transformationslogik. Deshalb werden
die verwendeten Resourcen hier statisch mit dem Repository verbunden. Ein Update mit gegebenenfalls
Anpassungen an der Transformationslogik muss manuell erfolgen.

## Ergänzende Daten

Daten, welche im MGDM fehlen müssen bereitgestellt werden. Für MGDM2OEREB wurde festgelegt, dass dies über den
bereits bekannten Mechanismus eines externen Kataloges passiert. Dieser muss die fehlenden Elemente bereits
gemäss Modell [ÖREB-Transferstruktur](./fed/OeREBKRMtrsfr_V2_0.ili) enthalten.

Damit die Konfiguration funktioniert muss ein Schema bei den Dateinamen eingehalten werden:

```bash
{model}.katalog.{katalog_name}.xml
```

Daraus ergibt sich beispielsweise für den Katalog des Darstellungsdienstes:
```bash
Planungszonen_V1_1.katalog.darstellungsdienst.xml
```

## Basket ID OeREBKRMtrsfr_V2_0

> **_Festlegung:_**
Als Basket ID wird im Zieldatensatz immer der Themenname verwendet.

Zum Beispiel:
```angular2html
ch.Planungszonen
```

## Darstellungsdienst

Der Darstellungsdienst ist in den MGDM nicht vorhanden. Für den kompletten Datensatz der per MGDM geliefert
wird kann exakt ein (1) Darstellungsdienst definiert werden.

## OEREBlex

### Notice

Es gibt einige Unterschiede zwischen dem Modell welches ÖREBlex ausliefert, wenn ein XMl zu einem GeoLink
abgerufen wird und dem Modell, welches durch die ÖREB Transferstruktur verlangt wird. Das betrifft
insbesondere Dokumente welche in ÖREBlex als *notice* geführt werden. Diese werden durch die Transformation in
den Dokumenttyp *Hinweis* übersetzt. Eine notice kann aber im ÖREBlex weder ein publiziert_ab Datum noch eine
zuständige Stelle erhalten. Vergleiche hierzu auch die aktuelle Umsetzung
[pyramid_oereb](https://github.com/openoereb/pyramid_oereb/blob/9134ae187f510bf171f23c0dacaec403fc732eb7/pyramid_oereb/contrib/data_sources/oereblex/sources/document.py#L163-L171)

> **_Festlegung:_**
MGDM2OEREB setzt als Datum den 01.01.1970 für den ÖREBlex Typ *notice*.

> **_Festlegung:_**
> MGDM2OEREB setzt als Namen der zuständigen Stelle den Wert aus dem Parameter *DUMMY_OFFICE_NAME* wenn
> ÖREBlex *authority* fehlt und Typ *notice* ist.

> **_Festlegung:_**
> MGDM2OEREB setzt als URL der zuständigen Stelle den Wert aus dem Parameter *DUMMY_OFFICE_URL* wenn ÖREBlex
> *authority_url* fehlt und Typ *notice* ist.

> **_Festlegung:_**
> MGDM2OEREB ersetzt die Werte *authority_url* und *authority* nur, wenn beide leer sind.

### Reduzierung geolinks

Ein geolink kann im MGDM mehrfach vorkommen. Als einzigartige ID (URI) muss der Inhalt des geolinks aber nur
einmal heruntergeladen werden. Da der Download aller geolinks im Gesamtprozess am längsten dauert, müssen
diese vereinigt werden.

> **_Festlegung:_**
MGDM2OEREB erstellt aus allen geolinks vom MGDM eine DISTINCT Liste und lädt diese herunter.

### Korrektur geolink

Die geolinks aus dem MGDM zeigen oft auf die HTML-Repräsentation. Diese ist durch MGDM2OEREB nicht verwendbar.
Stattdessen muss die XML-Repräsentation verwendet werden.

> **_Festlegung:_**
> MGDM2OEREB korrigiert alle geolinks, um sicherzustellen, dass die XML-Repräsentation heruntergeladen wird.
> Dazu wird *.html* im geolink mit *.xml* ersetzt.

### Fehler beim Download

Der Downloadprozess kann in Abhängigkeit der Anzahl geolinks viel Zeit in Anspruch nehmen. Dabei kann es zu
Fehlern kommen.

> **_Festlegung:_**
> MGDM2OEREB bricht den kompletten Prozess ab, wenn es zu einem Fehler beim Download von geolinks kommt.

### Bundesdokumente

ÖREBlex beinhaltet in den geolinks Rechtsdokumente auf Bundesstufe. Wie in OeREBKRMtrsfr_V2_0 definiert, sind
diese auf Themenebene im ÖREBKataster nicht mehr nötig.

> **_Festlegung:_**
> MGDM2OEREB ignoriert alle Dokumente welche im geolink unter dem Attribut *federal_level* einen der folgenden
> Werte enthalten: *Bund*, *Cancelleria federale*, *Confederaziun*.

### Korrektur relative Dokumentlink

ÖREBlex beinhaltet für manche Dokumente relative Links. Diese sind im Resultat der Transformation nicht mehr
auflösbar.

> **_Festlegung:_**
> MGDM2OEREB erweitert relative Links mit dem Parameter *OEREBLEX_HOST* der beim Aufruf übergeben wird.

### Auflösung Mehrdeutigkeit innerhalb ÖREBlex

geolinks können sich inhaltlich überschneiden. Das bedeutet, dass Dokumente in mehreren geolinks enthalten
sein können. Auch wenn OeREBKRMtrsfr_V2_0 dies unterstützen würde führt das an die Grenze der Lesbarkeit des
Trafo-Resultats. Das meint nicht die menschliche Lesbarkeit, sondern die maschinelle Lesbarkeit. Würde die
Mehrdeutigkeit nicht aufgelöst, würde der Umfang des Resultats in der Grösse explodieren.

> **_Festlegung:_**
> MGDM2OEREB löst die Mehrdeutigkeit zwischen Dokumenten auf und liefert pro identifizierbarem ÖREBlex
> Dokument exakt ein ÖREBDokument-Objekt.

> **_Festlegung:_**
> MGDM2OEREB löst die Mehrdeutigkeit zwischen Ämtern auf und liefert pro identifizierbarem ÖREBlex
> Amt exakt ein ÖREBAmt-Objekt.

### Auflösung Mehrsprachigkeit

Jeder geolink kann aus Sicht MGDM genau eine Sprache beinhalten. Das bedeutet, dass für 2 Sprachen 2 geolinks
heruntergeladen werden müssen. So sind dann Dokumente in der Anzahl der Sprachen abzugleichen und aufzulösen.

> **_Festlegung:_**
> MGDM2OEREB löst die Mehrsprachigkeit zwischen geolinks auf und liefert pro identifizierbarem ÖREBlex
> Dokument exakt ein ÖREBDokument-Objekt.

> **_Festlegung:_**
> MGDM2OEREB transportiert die Sprache aus dem MGDM ins ÖREBlex und zurück bis ins OeREBKRMtrsfr_V2_0.

> **_Festlegung:_**
> MGDM2OEREB ignoriert die Informationen zu Sprachen aus ÖREBlex. Stattdessen nutzt es die Sprache aus dem
> MGDM. Eine Auflösung der Mehrdeutigkeit ist sonst nicht möglich.

### ILI OID und Auflösung

OeREBKRMtrsfr_V2_0 verlangt als Identifikator von Objekten OIDs.

> **_Festlegung:_**
> MGDM2OEREB stellt sicher, dass IDs aus dem MGDM durch ÖREBlex transportiert werden und im Anschluss im
> Resultat aufgelöst werden können.

> **_Festlegung:_**
> MGDM2OEREB erstellt eigene UUIDs und ersetzt die Verknüpfungen im Resultat. Alte TIDs aus dem MGDM sind dann
> im Resultat nicht mehr enthalten.

### Auflösung Mehrdeutigkeit MGDM Dokument zu ÖREBlex Dokument

Es besteht eine Mehrdeutigkeit zwischen den Dokumenten im MGDM und im ÖREBlex.

> **_Festlegung:_**
> MGDM2OEREB löst die Mehrdeutigkeit über die originale MGDM Dokument TID und die das Attribut *id* aus dem
> geolink.

### Ämter

Jedem Dokument muss im OeREBKRMtrsfr_V2_0 eine zuständige Stelle zugeordnet sein.

> **_Festlegung:_**
> MGDM2OEREB erzeugt für die Ämter aus den geolinks eigene ÖREB-Objekte. Eine Verknüpfung mit Ämtern aus
> dem MGDM ist nicht möglich, da saubere Identifikatoren fehlen.

### Leere mehrsprachige Werte

ÖREBlex kann in geolinks leere Werte enthalten. Besonders ist dies der Fall beim Attribut *number*. Durch
die Trennung der Sprachen in unterschiedliche Links muss diesem Umstand besondere Beachtung geschenkt werden.

> **_Festlegung:_**
> MGDM2OEREB erkennt einen Wert nur als "leer" an, wenn er in allen Sprachen leer ist. Das kann später aber
> zu Fehlern bei der ili-Validierung führen.

### Korrektur Amts URL

ÖREBlex erlaubt nicht valide URLs im Attribut *authority_url*.

> **_Festlegung:_**
> MGDM2OEREB versucht durch eine minimale Korrektur den häufigsten Fehler zu umgehen. Es wird geprüft, ob eine
> URL mit *http* beginnt und falls nicht, wird der URL ein *https://* vorangestellt. Eine URl *www.test.ch*
> wird in *https://www.test.ch* umgewandelt.

### Rechtsstatus von Dokumenten

ÖREBlex liefert keine Information über den Rechtsstatus.

> **_Festlegung:_**
> MGDM2OEREB setzt für alle Dokumente den Rechtsstatus *inKraft*.

### Typ von Dokumenten

ÖREBlex liefert eigene Dokumenttypen im Attribut *doctype*.

> **_Festlegung:_**
> MGDM2OEREB setzt die Dokumenttypen wie folgt:
> *decree* => *Rechtsvorschrift*, *edict* => *GesetzlicheGrundlage*, *notice* => *Hinweis*.

> **_Festlegung:_**
> MGDM2OEREB bricht den kompletten Prozess ab, wenn ein unbekannter Dokumenttyp erkannt wird.

# Themenspezifische Festlegungen

## Kataster der belasteten Standorte v1.5

### Darstellungsdienst

Als Darstellungsdienst wird standardmässig der WMS von 
[geodienste.ch](https://geodienste.ch/db/kataster_belasteter_standorte_v1_5_0?) verwendet. Dies kann durch die
Lieferung eines angepassten [Kataloges](../xsl/KbS_V1_5.katalog.darstellungsdienst.xml) überschrieben werden.
Es ist darauf zu achten, dass ein Darstellungsdienst mehrsprachige Elemente enthält. Diese müssen vollständig
vorhanden sein.

### Codetexte

Für KbS_V1_5 besteht ein [Katalog](https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5.xml) welcher das Modell
ergänzt. Dieser ist in MGDM2OEREB [integriert](../xsl/KbS_V1_5.katalog.code_texte.xml). Damit wird eine
gewisse Stabilität sichergestellt. Sollten sich durch den Bund verursachte Änderungen ergeben, so ist dieser
Katalog manuell in MGDM2OEREB zu aktualisieren.

## Planungszonen v1.1

### Darstellungsdienst

Als Darstellungsdienst wird standardmässig der WMS von 
[geodienste.ch](https://geodienste.ch/db/planungszonen_v1_1_0?) verwendet. Dies kann durch die Lieferung eines
angepassten [Kataloges](../xsl/ch.Planungszonen.v1_1.katalog.darstellungsdienst.xml) überschrieben werden. Es
ist darauf zu achten, dass ein Darstellungsdienst mehrsprachige Elemente enthält. Diese müssen vollständig
vorhanden sein.

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

Wenn man, wie in der
[Modelldokumentation](./fed/Planungszonen_V1_1/Planungszonen_Modelldokumentation-V1_1.pdf) in
Kapitel 10.2 vorgeschlagen, Typ.Bezeichnung vom MGDM in LegendeEintrag.LegendeText nach `OeREBKRMtrsfr_V2_0`
überträgt, ergibt sich grafisch eine Mehrdeutigkeit. Legendenelemente unterschiedlicher Bedeutung haben
dasselbe Symbol aber unterschiedliche Legendentexte.

> **_Festlegung:_**
> MGDM2OEREB überträgt die Bezeichnung aus dem MGDM auf den Legendeneintrag im ÖREB. Damit erhält man eine
> optisch mehrdeutige Legende, transportiert aber die Information.

Zu diesem Zweck exisitert ein [Katalog](../xsl/ch.Planungszonen.v1_1.katalog.legenden_eintrag.xml) mit
Legendeneinträgen welche die 3 genannten Stufen abbilden.

### Legendeneintrag Bezeichnung

Alle relevanten Teile im ÖREB-Modell sind mehrsprachig gehalten. Das trifft auch auf die Legendentexte zu. Die
Bezeichnung des Typs im MGDM der Planungszonen ist aber nicht mehrsprachig.

> **_Festlegung:_**
> MGDM2OEREB nutzt die Bezeichnung aus dem MGDM und wrappt sie in ein mehrsprachiges Element. Dazu wird die
> Bezeichnung aus dem MGDM in alle 4 Sprachen gewrappt. Damit verhindert man aufwändige und fehleranfällige
> Konfigurationen.

### Zuordnung Dokument => Eigentumsbeschränkung

Das Modell MGDM erlaubt die Zuordnung von *Dokument* => *TypPZ* und *Dokument* => *Planungszone*.
Das ÖEREB-Modell erlaubt Dokumente nur in Beziehung zur Eigentumsbeschränkung.
Nicht aber direkt zur Geometrie.

> **_Festlegung:_**
> MGDM2OEREB überträgt sowohl die Dokumente von *TypPZ*, als auch Dokumente von *Planungszone* aus dem MGDM
> zur Eigentumsbeschränkung im OeREBKRMtrsfr_V2_0. **ACHTUNG**: Eine Auflösung von Mehrdeutigkeiten die
> entstehen können, wenn im MGDM dieselben Dokumente *TypPZ* UND *Planungszone* zugeordnet sind, findet nicht
> statt.
