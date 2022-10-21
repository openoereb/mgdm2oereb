<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
                version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="oereblex_output"/>
    <xsl:variable name="oereblexdata" select="document(concat('file://', $oereblex_output))"/>
    <xsl:param name="catalog"/>
    <xsl:variable name="catalog_doc" select="document(concat('file://', $catalog))"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="oereblex_host"/>
    <xsl:variable name="oereblex_url" select="concat($oereblex_host,'/api/geolinks/')"/>
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
                <OeREBKRMtrsfr_V2_0.Transferstruktur BID="{$theme_code}">
                    <xsl:apply-templates select="ili:Planungszonen_V1_1.Geobasisdaten"/>
                    <xsl:apply-templates
                            select="ili:Planungszonen_V1_1.TransferMetadaten/ili:Planungszonen_V1_1.TransferMetadaten.Amt"/>
                    <xsl:call-template name="supplement"/>
                    <xsl:copy-of select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Amt.Amt"/>
                    <xsl:copy-of select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Dokumente.Dokument"/>
                    <xsl:apply-templates select="ili:Planungszonen_V1_1.Rechtsvorschriften/ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument"/>
                    <xsl:apply-templates select="ili:Planungszonen_V1_1.Geobasisdaten/ili:Planungszonen_V1_1.Geobasisdaten.Geometrie_Dokument"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Geobasisdaten">
        <xsl:apply-templates select="ili:Planungszonen_V1_1.Geobasisdaten.Planungszone"/>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Geobasisdaten/ili:Planungszonen_V1_1.Geobasisdaten.Planungszone">
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
            <xsl:copy-of select="./ili:Rechtsstatus"/>
            <xsl:copy-of select="./ili:publiziertAb"/>
            <xsl:copy-of select="./ili:publiziertBis"/>
            <xsl:call-template name="zustaendige_stelle">
                <xsl:with-param name="basket_id" select="../@BID"/>
            </xsl:call-template>
            <xsl:call-template name="legende_darstellungsdienst">
                <xsl:with-param name="typ_ref_id" select="./ili:TypPZ/@REF"/>
            </xsl:call-template>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
            <Flaeche>
                <xsl:copy-of select="./ili:Geometrie/ili:SURFACE"/>
            </Flaeche>
            <xsl:copy-of select="./ili:Rechtsstatus"/>
            <xsl:copy-of select="./ili:publiziertAb"/>
            <xsl:copy-of select="./ili:publiziertBis"/>
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
                        <xsl:copy-of select="node()"/>
                    </OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ_ref_id"/>
        <xsl:variable name="typ_code" select="../ili:Planungszonen_V1_1.Geobasisdaten.Typ_Planungszone[@TID=$typ_ref_id]/ili:Festlegung_Stufe"/>
        <xsl:variable name="legende_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_code]/@TID"/>
        <xsl:variable name="darstellungsdienst_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_code]/ili:DarstellungsDienst/@REF"/>
        <Legende REF="{$legende_tid}"/>
        <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
    </xsl:template>

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="basket_id"/>
        <ZustaendigeStelle
                REF="AMT_{../../ili:Planungszonen_V1_1.TransferMetadaten/ili:Planungszonen_V1_1.TransferMetadaten.Datenbestand/ili:BasketID[@OID=$basket_id]/../ili:zustaendigeStelle/@REF}"/>
    </xsl:template>

    <xsl:template name="legende">
        <xsl:param name="typ_ref_id"/>
        <Legende
                REF="Legende_{../ili:Planungszonen_V1_1.Geobasisdaten.Typ_Planungszone[@TID=$typ_ref_id]/@TID}"/>
    </xsl:template>

    <xsl:template match="ili:Planungszonen_V1_1.MultilingualUri/ili:LocalisedText/ili:Planungszonen_V1_1.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:Planungszonen_V1_1.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:Planungszonen_V1_1.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:Planungszonen_V1_1.TransferMetadaten/ili:Planungszonen_V1_1.TransferMetadaten.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:copy-of select="./ili:Name"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template
            match="ili:Planungszonen_V1_1.TransferMetadaten/ili:Planungszonen_V1_1.TransferMetadaten.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:Planungszonen_V1_1.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Rechtsvorschriften">
        <xsl:apply-templates select="ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument"/>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Rechtsvorschriften/ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@TID"/>
        <xsl:variable name="mgdm_typ_pz_ref" select="../../ili:Planungszonen_V1_1.Geobasisdaten/ili:Planungszonen_V1_1.Geobasisdaten.TypPZ_Dokument[ili:Vorschrift/@REF=$mgdm_dokument_tid]/ili:TypPZ/@REF"/>
        <xsl:for-each select="../../ili:Planungszonen_V1_1.Geobasisdaten/ili:Planungszonen_V1_1.Geobasisdaten.Planungszone[ili:TypPZ/@REF=$mgdm_typ_pz_ref]">
            <xsl:variable name="mgdm_pz_tid" select="./@TID"/>
            <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
                <xsl:for-each select="./OereblexDoc">
                    <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                        <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_pz_tid}"/>
                        <Vorschrift REF="{./@REF}"/>
                    </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Geobasisdaten/ili:Planungszonen_V1_1.Geobasisdaten.Geometrie_Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="./ili:Dokument/@REF"/>
        <xsl:variable name="mgdm_pz_tid" select="./ili:Geometrie/@REF"/>
        <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
            <xsl:for-each select="./OereblexDoc">
                <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                    <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_pz_tid}"/>
                    <Vorschrift REF="{./@REF}"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
