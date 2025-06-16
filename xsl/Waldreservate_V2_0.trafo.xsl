<!--
We load all namespaces we want to deal with into the stylesheet. This is something like import xyz in JAVA or
Python. The namespace is the URL. This URL does not have to exist really. It's only an identifier which has to
match and be unique. The match has to be with the data you want to transform and the xsl. Every namespace can
have a short identifier to make it easier to use it in the XSL.
-->
<xsl:stylesheet
        xmlns="http://www.interlis.ch/INTERLIS2.3"
        xmlns:geom="http://www.interlis.ch/geometry/1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:ili="http://www.interlis.ch/xtf/2.4/INTERLIS"
        xmlns:ili24_l10n_ch="http://www.interlis.ch/xtf/2.4/LocalisationCH_V2"
        xmlns:ili24_l10n="http://www.interlis.ch/xtf/2.4/Localisation_V2"
        xmlns:Waldreservate_V2_0="http://www.interlis.ch/xtf/2.4/Waldreservate_V2_0"
        xmlns:ili23="http://www.interlis.ch/INTERLIS2.3" xmlns:xsd="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="ili Waldreservate_V2_0 xsl geom ili23 ili24_l10n_ch ili24_l10n"
        version="1.0"
>
    <!--
    here we can adjust the output a bit. See https://www.w3.org/TR/xslt-10/#output for details.
    -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <!--
    We define a parameter which can be passed with the processor call: xsltproc \-\-stringparam catalog /a/b/path/catalog.xml
    -->
    <xsl:param name="catalog"/>
    <!--
    We load the file content of the path out of the variable onto another variable for later use in our XSL
    -->
    <xsl:variable name="catalog_doc" select="document(concat('file://', $catalog))"/>
    <xsl:param name="xsl_path"/>
    <!--
    We load the federal catalogue of the waldreservate model
    -->
    <xsl:variable name="code_texte_doc" select="document(concat('file:/', $xsl_path, '/', 'Waldreservate_V2_0.catalogues.xml'))"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="target_basket_id"/>
    <!--
    First template definition is the entrypoint into the tree. This is important. In this case we directly
    start at the root '/' and subsequently match only the datasection, since there is the data we are
    interested in.
    We can say: Here our routine starts...

    We construct our ili23 ÖREB Transfer structure here.
    -->
    <xsl:template match="/">
        <TRANSFER>
            <HEADERSECTION SENDER="mgdm2oereb" VERSION="2.3">
                <MODELS>
                    <MODEL NAME="CoordSys" VERSION="2015-11-24" URI="https://www.interlis.ch/models"/>
                    <MODEL NAME="CatalogueObjects_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="CatalogueObjectTrees_V1" VERSION="2011-08-30"
                           URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="InternationalCodes_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Localisation_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="LocalisationCH_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Dictionaries_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="DictionariesCH_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Units" VERSION="2012-02-20" URI="https://www.interlis.ch/models"/>
                    <MODEL NAME="OeREBKRM_V2_0" VERSION="2021-04-14"
                           URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                    <MODEL NAME="CHAdminCodes_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="AdministrativeUnits_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="AdministrativeUnitsCH_V1" VERSION="2011-08-30"
                           URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="GeometryCHLV03_V1" VERSION="2015-11-12" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="GeometryCHLV95_V1" VERSION="2015-11-12" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="OeREBKRMkvs_V2_0" VERSION="2021-04-14"
                           URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                    <MODEL NAME="OeREBKRMtrsfr_V2_0" VERSION="2021-04-14"
                           URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                </MODELS>
            </HEADERSECTION>
            <DATASECTION>
                <!--
                We wrap everything into the root element of OeREBKRMtrsfr_V2_0.Transferstruktur assigning the
                desired basket id (this is passed as a param via the processor).
                -->
                <OeREBKRMtrsfr_V2_0.Transferstruktur BID="{$target_basket_id}">
                    <!--
                    Into the datasection we will load all the objects we find in the MGDM datasection.

                    INFO: Mind the different cases between ili2.4 and ili2.3!
                    -->
                    <xsl:apply-templates select="ili:transfer/ili:datasection"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>
    <xsl:template match="ili:transfer/ili:datasection">
        <xsl:apply-templates select="Waldreservate_V2_0:Waldreservate"/>
        <!--
        integrate catalogue objects for legend items
        -->
        <xsl:call-template name="supplement"/>
    </xsl:template>

    <xsl:template match="Waldreservate_V2_0:Waldreservate">
        <xsl:apply-templates select="Waldreservate_V2_0:Waldreservat_Teilobjekt"/>
        <xsl:apply-templates select="Waldreservate_V2_0:Amt"/>
        <xsl:apply-templates select="Waldreservate_V2_0:Dokument"/>
    </xsl:template>

    <xsl:template match="Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Waldreservat_Teilobjekt">
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@ili:tid}">
            <xsl:apply-templates select="./Waldreservate_V2_0:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertBis" mode="copy-no-namespaces"/>
            <xsl:call-template name="zustaendige_stelle">
                <xsl:with-param name="wr_teilobjekt_tid" select="@ili:tid"/>
            </xsl:call-template>
            <xsl:call-template name="legende_darstellungsdienst">
                <xsl:with-param name="typ_ref_id" select="./Waldreservate_V2_0:MCPFE_Class/@ili:ref"/>
                <xsl:with-param name="rechtsstatus" select="./Waldreservate_V2_0:Rechtsstatus"/>
            </xsl:call-template>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@ili:tid}">
            <Flaeche>
                <xsl:call-template name="convert-to-uppercase">
                    <xsl:with-param name="node" select="./Waldreservate_V2_0:Geo_Obj/geom:surface"/>
                </xsl:call-template>
            </Flaeche>
            <xsl:apply-templates select="./Waldreservate_V2_0:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertBis" mode="copy-no-namespaces"/>
            <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@ili:tid}"/>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
    </xsl:template>

    <xsl:template name="supplement">
        <xsl:for-each
                select="$catalog_doc//ili23:TRANSFER/ili23:DATASECTION/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili23:Thema=$theme_code]">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{./@TID}">
                <Symbol>
                  <BINBLBOX><xsd:value-of select="./ili23:Symbol/ili23:BINBLBOX"/></BINBLBOX>
                </Symbol>
                <xsl:apply-templates select="ili23:LegendeText" mode="copy-no-namespaces"/>
                <ArtCode><xsl:value-of select="./ili23:ArtCode"/></ArtCode>
                <ArtCodeliste><xsl:value-of select="./ili23:ArtCodeliste"/></ArtCodeliste>
                <Thema><xsl:value-of select="./ili23:Thema"/></Thema>
                <DarstellungsDienst REF="{./ili23:DarstellungsDienst/@REF}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
        </xsl:for-each>
        <xsl:for-each
                select="$catalog_doc//ili23:TRANSFER/ili23:DATASECTION/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag/ili23:DarstellungsDienst[not(@REF = (preceding::*/@REF))]">
            <xsl:sort select="@REF"/>
            <xsl:variable name="darstellungsdienst_tid" select="@REF"/>
            <xsl:variable name="darstellungsdienst_thema" select="../ili23:Thema"/>
            <xsl:if test="$theme_code = $darstellungsdienst_thema">
                <xsl:for-each
                        select="$catalog_doc//ili23:TRANSFER/ili23:DATASECTION/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur.DarstellungsDienst[@TID=$darstellungsdienst_tid]">
                    <OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst TID="{$darstellungsdienst_tid}">
                        <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
                    </OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="wr_teilobjekt_tid"/>

        <!-- There can be multiple documents attached to one Waldreservat_Teilobjekt.
             Because only one Amt can be assigned to WR Teilobjekt, we're assured, that all attached documents belong to the same Amt.
             That's why choosing the [1] first one is ok. -->
        <xsl:variable name="dokument_ref"
                      select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:DokumentWaldreservat[Waldreservate_V2_0:Waldreservat_Teilobjekt/@ili:ref = $wr_teilobjekt_tid]/Waldreservate_V2_0:Dokument[1]/@ili:ref"/>
        <xsl:variable name="amt_ref"
                      select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Dokument[@ili:tid = $dokument_ref]/Waldreservate_V2_0:Amt/@ili:ref"/>
        <!-- getting list of the Amts and select the first item [1] -->
        <xsl:variable name="distinct_amt"
                      select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Amt[@ili:tid = $amt_ref][not(@ili:tid = (preceding::*/@ili:tid))][1]/@ili:tid"/>

        <!--<xsl:message>TO: <xsl:value-of select="$wr_teilobjekt_tid"/> AMT: <xsl:value-of select="$amt_ref"/> DOC: <xsl:value-of select="$dokument_ref"/></xsl:message>-->
        <xsl:if test="$distinct_amt">
            <ZustaendigeStelle REF="AMT_{$distinct_amt}"/>
        </xsl:if>

    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ_ref_id"/>
        <xsl:param name="rechtsstatus"/>

        <xsl:variable name="typ_code"
                      select="$code_texte_doc//ili:transfer/ili:datasection/Waldreservate_V2_0:Codelisten/Waldreservate_V2_0:MCPFE_Class_Catalogue[@ili:tid=$typ_ref_id]/Waldreservate_V2_0:Code"/>
        <xsl:variable name="typ_artcode" select="concat($typ_code, '_', $rechtsstatus)"/>
        <xsl:variable name="legende_tid"
                      select="string($catalog_doc//ili23:TRANSFER/ili23:DATASECTION/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili23:Thema=$theme_code][ili23:ArtCode=$typ_artcode]/@TID)"/>
        <xsl:variable name="darstellungsdienst_tid"
                      select="$catalog_doc/ili23:TRANSFER/ili23:DATASECTION/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur/ili23:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili23:Thema=$theme_code][ili23:ArtCode=$typ_artcode]/ili23:DarstellungsDienst/@REF"/>
        <!--
        <xsl:message>ArtCode: <xsl:value-of select="$typ_artcode"/></xsl:message>
        <xsl:message>  Legende TID: <xsl:value-of select="$legende_tid"/></xsl:message>
        <xsl:message>  Darstellungsdienst TID: <xsl:value-of select="$darstellungsdienst_tid"/></xsl:message>
        -->
        <xsl:if test="$legende_tid">
            <Legende REF="{$legende_tid}"/>
        </xsl:if>
        <xsl:if test="$darstellungsdienst_tid">
            <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
        </xsl:if>
    </xsl:template>

    <!--
    This we set because the multilingual and localized uris are part of the oereb
    schema in interlis 2.3
    -->
    <xsl:template match="ili24_l10n_ch:MultilingualUri/ili24_l10n:LocalisedText/ili24_l10n_ch:LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili24_l10n:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili24_l10n:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili24_l10n_ch:MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili24_l10n:LocalisedText/ili24_l10n_ch:LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili24_l10n_ch:MultilingualText">
        <LocalisationCH_V1.MultilingualText>
            <LocalisedText>
                <xsl:apply-templates select="ili24_l10n:LocalisedText/ili24_l10n_ch:LocalisedText"/>
            </LocalisedText>
        </LocalisationCH_V1.MultilingualText>
    </xsl:template>

    <xsl:template match="ili24_l10n_ch:MultilingualText/ili24_l10n:LocalisedText/ili24_l10n_ch:LocalisedText">
        <LocalisationCH_V1.LocalisedText>
            <Language>
                <xsl:value-of select="./ili24_l10n:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili24_l10n:Text"/>
            </Text>
        </LocalisationCH_V1.LocalisedText>
    </xsl:template>

    <xsl:template match="Waldreservate_V2_0:Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@ili:tid}">
            <Name>
                <xsl:apply-templates select="Waldreservate_V2_0:Name"/>
            </Name>
            <xsl:apply-templates select="Waldreservate_V2_0:AmtImWeb"/>
            <xsl:apply-templates select="Waldreservate_V2_0:UID" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:Zeile1" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:Zeile2" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:Strasse" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:Hausnr" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:PLZ" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="Waldreservate_V2_0:Ort" mode="copy-no-namespaces"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Amt/Waldreservate_V2_0:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili24_l10n_ch:MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <!--
    Template snippet to match the documents in the MGDM.
    -->
    <xsl:template match="Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@ili:tid"/>
        <xsl:variable name="mgdm_waldreservat_teilobjekt_ref"
                      select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:DokumentWaldreservat[Waldreservate_V2_0:Dokument/@ili:ref=$mgdm_dokument_tid]/Waldreservate_V2_0:Waldreservat_Teilobjekt/@ili:ref"/>
        <xsl:variable name="amt_ref" select="Waldreservate_V2_0:Amt/@ili:ref"/>
        <xsl:variable name="distinct_mgdm_amt"
                      select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Amt[@ili:tid = $amt_ref][not(@ili:tid = (preceding::*/@ili:tid))][1]/@ili:tid"/>
        <OeREBKRM_V2_0.Dokumente.Dokument TID="dokument_{./@ili:tid}">
            <xsl:apply-templates select="./Waldreservate_V2_0:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:AuszugIndex" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./Waldreservate_V2_0:publiziertBis" mode="copy-no-namespaces"/>
            <OffizielleNr>
                <xsl:apply-templates select="./Waldreservate_V2_0:OffizielleNr"/>
            </OffizielleNr>
            <xsl:apply-templates select="./Waldreservate_V2_0:Abkuerzung" mode="copy-no-namespaces"/>
            <Titel>
                <xsl:apply-templates select="./Waldreservate_V2_0:Titel"/>
            </Titel>

            <xsl:apply-templates select="./Waldreservate_V2_0:Typ" mode="copy-no-namespaces"/>
            <TextImWeb>
                <!--
                TextImWeb is a multilingual URI which need to be transformed to fit into the target model.
                -->
                <xsl:apply-templates select="Waldreservate_V2_0:TextImWeb/ili24_l10n_ch:MultilingualUri"/>
            </TextImWeb>
            <ZustaendigeStelle REF="AMT_{$distinct_mgdm_amt}"/>
        </OeREBKRM_V2_0.Dokumente.Dokument>
        <!--
        For every document we find, we also add the references to the Teilobjekt, since we know already the
        correct reference
        -->
        <xsl:for-each
                select="../../Waldreservate_V2_0:Waldreservate/Waldreservate_V2_0:Waldreservat_Teilobjekt[@ili:tid=$mgdm_waldreservat_teilobjekt_ref]">
            <xsl:variable name="mgdm_tid" select="./@ili:tid"/>
            <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                <Vorschrift REF="dokument_{$mgdm_dokument_tid}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
        </xsl:for-each>
    </xsl:template>

    <!--
    Copies all subelements of a node into a new node. It removes the namespaces from each node by using
    `local-name()`.
    -->
    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="comment()| processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>

    <!--
    Template to convert all subelement names of a node into ALLCAPS (ili23).
    We need that for the Geometry part.
     -->
    <xsl:template name="convert-to-uppercase">
        <xsl:param name="node"/>

        <!-- Deciding the new name -->
        <xsl:variable name="lower-name" select="local-name($node)"/>
        <xsl:variable name="mapped-name">
            <xsl:choose>
                <!--
                We rename the element "exterior" to "BOUNDARY", in ILI23 the first boundary of a surface is
                the exterior.
                -->
                <xsl:when test="$lower-name = 'exterior'">BOUNDARY</xsl:when>
                <!--
                We rename the element "interior" to "BOUNDARY", in ILI23 all following boundaries are
                interiors or holes of that surface.
                -->
                <xsl:when test="$lower-name = 'interior'">BOUNDARY</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                            select="translate($lower-name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$mapped-name}">
            <xsl:for-each select="$node/node()">
                <xsl:choose>
                    <xsl:when test="self::node()[local-name()]">
                        <xsl:call-template name="convert-to-uppercase">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>

</xsl:stylesheet>
