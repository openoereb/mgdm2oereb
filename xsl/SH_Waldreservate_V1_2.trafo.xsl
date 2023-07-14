<xsl:stylesheet
    xmlns="http://www.interlis.ch/INTERLIS2.3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
    exclude-result-prefixes="ili"
    version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="catalog"/>
    <xsl:variable name="catalog_doc" select="document(concat('file://', $catalog))"/>
    <xsl:param name="xsl_path"/>
    <xsl:variable name="code_texte_doc" select="document(concat('file://', $xsl_path, '/', 'SH_Waldreservate_Catalogues_V1_2.xml'))"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="target_basket_id"/>
    <xsl:template match="/ili:TRANSFER/ili:DATASECTION">
        <TRANSFER xmlns="http://www.interlis.ch/INTERLIS2.3">
            <HEADERSECTION SENDER="mgdm2oereb" VERSION="2.3">
                <MODELS>
                    <MODEL NAME="CoordSys" VERSION="2015-11-24" URI="https://www.interlis.ch/models"/>
                    <MODEL NAME="CatalogueObjects_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="CatalogueObjectTrees_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="InternationalCodes_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Localisation_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="LocalisationCH_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Dictionaries_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="DictionariesCH_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="Units" VERSION="2012-02-20" URI="https://www.interlis.ch/models"/>
                    <MODEL NAME="OeREBKRM_V2_0" VERSION="2021-04-14" URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                    <MODEL NAME="CHAdminCodes_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="AdministrativeUnits_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="AdministrativeUnitsCH_V1" VERSION="2011-08-30" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="GeometryCHLV03_V1" VERSION="2015-11-12" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="GeometryCHLV95_V1" VERSION="2015-11-12" URI="https://www.geo.admin.ch"/>
                    <MODEL NAME="OeREBKRMkvs_V2_0" VERSION="2021-04-14" URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                    <MODEL NAME="OeREBKRMtrsfr_V2_0" VERSION="2021-04-14" URI="https://models.geo.admin.ch/V_D/OeREB/"/>
                </MODELS>
            </HEADERSECTION>
            <DATASECTION>
                <OeREBKRMtrsfr_V2_0.Transferstruktur BID="{$target_basket_id}">
                    <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate"/>
                    <xsl:call-template name="supplement"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate">
        <!-- <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate.Waldreservat"/> -->
        <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate.Waldreservat_Teilobjekt"/>
        <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate.Amt"/>
        <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate.Dokument"/>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Waldreservat_Teilobjekt">
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
            <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
            <xsl:call-template name="zustaendige_stelle">
                <xsl:with-param name="wr_teilobjekt_tid" select="@TID"/>
            </xsl:call-template>
            <xsl:call-template name="legende_darstellungsdienst">
                <xsl:with-param name="typ_ref_id" select="./ili:MCPFE_Class/ili:SH_Waldreservate_V1_2.Codelisten.MCPFE_Class_CatRef/ili:Reference/@REF"/>
                <xsl:with-param name="rechtsstatus" select="./ili:Rechtsstatus"/>
            </xsl:call-template>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
            <Flaeche>
                <xsl:apply-templates select="./ili:Geo_Obj/ili:SURFACE" mode="copy-no-namespaces"/>
            </Flaeche>
            <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
            <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@TID}"/>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
    </xsl:template>

    <xsl:template name="supplement">
        <xsl:for-each select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code]">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{./@TID}">
                <xsl:copy-of select="node()"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
        </xsl:for-each>
        <xsl:for-each select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag/ili:DarstellungsDienst[not(@REF = (preceding::*/@REF))]">
            <xsl:sort select="@REF"/>
            <xsl:variable name="darstellungsdienst_tid" select="@REF"/>
            <xsl:variable name="darstellungsdienst_thema" select="../ili:Thema"/>
            <xsl:if test="$theme_code = $darstellungsdienst_thema">
                <xsl:for-each select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.DarstellungsDienst[@TID=$darstellungsdienst_tid]">
                    <OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst TID="{$darstellungsdienst_tid}">
                        <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
                    </OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="wr_teilobjekt_tid" />

        <!-- There can be multiple documents attached to one Waldreservat_Teilobjekt.
             Because only one Amt can be assigned to WR Teilobjekt, we're assured, that all attached documents belong to the same Amt.
             That's why choosing the [1] first one is ok. -->
        <xsl:variable name="dokument_ref" select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.DokumentWaldreservat[ili:Waldreservat_Teilobjekt/@REF = $wr_teilobjekt_tid]/ili:Dokument[1]/@REF"/>
        <xsl:variable name="amt_ref" select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Dokument[@TID = $dokument_ref]/ili:Amt/@REF" />
        <!-- getting list of the Amts and select the first item for this moment [1] -->
        <xsl:variable name="distinct_amt" select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Amt[@TID = $amt_ref][not(@TID = (preceding::*/@TID))][1]/@TID"/>
        <ZustaendigeStelle REF="AMT_{$distinct_amt}" />

    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ_ref_id"/>
        <xsl:param name="rechtsstatus"/>

        <xsl:variable name="typ_code" select="$code_texte_doc//ili:TRANSFER/ili:DATASECTION/ili:SH_Waldreservate_V1_2.Codelisten/ili:SH_Waldreservate_V1_2.Codelisten.MCPFE_Class_Catalogue[@TID=$typ_ref_id]/ili:Code"/>
        <xsl:variable name="typ_artcode" select="concat($typ_code, '_', $rechtsstatus)" />

        <xsl:variable name="legende_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_artcode]/@TID"/>
        <xsl:variable name="darstellungsdienst_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_artcode]/ili:DarstellungsDienst/@REF"/>

        <xsl:if test="$legende_tid">
            <Legende REF="{$legende_tid}"/>
        </xsl:if>
        <xsl:if test="$darstellungsdienst_tid">
            <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate.MultilingualUri/ili:LocalisedText/ili:SH_Waldreservate_V1_2.Waldreservate.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:SH_Waldreservate_V1_2.Waldreservate.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:apply-templates select="./ili:Name" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:SH_Waldreservate_V1_2.Waldreservate.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <xsl:template match="ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@TID"/>
        <xsl:variable name="mgdm_waldreservat_teilobjekt_ref" select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.DokumentWaldreservat[ili:Dokument/@REF=$mgdm_dokument_tid]/ili:Waldreservat_Teilobjekt/@REF"/>
        <xsl:variable name="amt_ref" select="ili:Amt/@REF" />
        <xsl:variable name="distinct_mgdm_amt" select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Amt[@TID = $amt_ref][not(@TID = (preceding::*/@TID))][1]/@TID"/>
        <OeREBKRM_V2_0.Dokumente.Dokument TID="dokument_{./@TID}">
            <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:AuszugIndex" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:OffizielleNr" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:Abkuerzung" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:Titel" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:Typ" mode="copy-no-namespaces"/>
            <TextImWeb>
                <xsl:apply-templates select="ili:TextImWeb/ili:SH_Waldreservate_V1_2.Waldreservate.MultilingualUri"/>
            </TextImWeb>
            <ZustaendigeStelle REF="AMT_{$distinct_mgdm_amt}"/>
        </OeREBKRM_V2_0.Dokumente.Dokument>
        <xsl:for-each select="../../ili:SH_Waldreservate_V1_2.Waldreservate/ili:SH_Waldreservate_V1_2.Waldreservate.Waldreservat_Teilobjekt[@TID=$mgdm_waldreservat_teilobjekt_ref]">
            <xsl:variable name="mgdm_tid" select="./@TID"/>
            <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                <Vorschrift REF="dokument_{$mgdm_dokument_tid}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="comment()| processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>
