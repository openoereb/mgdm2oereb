<xsl:stylesheet
        xmlns="http://www.interlis.ch/INTERLIS2.3"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
        exclude-result-prefixes="ili"
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
                    <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR"/>
                    <xsl:call-template name="supplement"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Amt.Amt" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Dokumente.Dokument" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.DokumentGewR"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR">
        <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR.GewR"/>
        <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR.Amt"/>
        <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR.Dokument"/>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.GewR">
        <xsl:if test="./ili:Verzicht/text()='false'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
                <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
                <xsl:call-template name="zustaendige_stelle">
                    <xsl:with-param name="gewaesserraum_tid" select="@TID"/>
                </xsl:call-template>
                <xsl:call-template name="legende_darstellungsdienst">
                    <xsl:with-param name="typ_ref_id" select="./ili:TypPZ/@REF"/>
                    <xsl:with-param name="rechtsstatus" select="./ili:Rechtsstatus"/>
                </xsl:call-template>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
                <Flaeche>
                    <xsl:apply-templates select="./ili:Geometrie/ili:SURFACE" mode="copy-no-namespaces"/>
                </Flaeche>
                <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@TID}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
        </xsl:if>
    </xsl:template>
    <xsl:template name="supplement">
        <!-- we select a unique node set with preceding of all ili:Rechtsstatus from MGDM Xtf and loop over it to use the ili:Rechtsstatus as a filter on the catalogue -->
        <xsl:for-each select="//ili:Gewaesserraum_V1_1.GewR.GewR/ili:Rechtsstatus[not(text() = (../preceding::ili:Gewaesserraum_V1_1.GewR.GewR/ili:Rechtsstatus))]">
            <xsl:variable name="rechtsstatus" select="."/>
            <xsl:for-each select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][contains(./ili:ArtCode, $rechtsstatus)]">
                <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{./@TID}">
                    <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
            </xsl:for-each>
            <xsl:for-each select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[contains(./ili:ArtCode, $rechtsstatus)]/ili:DarstellungsDienst[not(@REF = (preceding::*/@REF))]">
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
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ_ref_id"/>
        <xsl:param name="rechtsstatus"/>
        <xsl:variable name="typ_art_code" select="concat(substring($theme_code, 4), '_' , $rechtsstatus)"/> <!-- TODO: Find a better way to get the Legende code -->
        <!--<xsl:comment><xsl:value-of select="$typ_art_code"/></xsl:comment>-->
        <xsl:variable name="legende_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_art_code]/@TID"/>
        <xsl:variable name="darstellungsdienst_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_art_code]/ili:DarstellungsDienst/@REF"/>
        <Legende REF="{$legende_tid}"/>
        <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
    </xsl:template>

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="gewaesserraum_tid" />

        <!-- There can be multiple documents attached to one Waldreservat_Teilobjekt.
             Because only one Amt can be assigned to WR Teilobjekt, we're assured, that all attached documents belong to the same Amt.
             That's why choosing the [1] first one is ok. -->
        <xsl:variable name="dokument_ref" select="../../ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.DokumentGewR[ili:GewR/@REF = $gewaesserraum_tid]/ili:Dokument[1]/@REF"/>
        <xsl:variable name="amt_ref" select="../../ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.Dokument[@TID = $dokument_ref]/ili:Amt/@REF" />
        <!-- getting list of the Amts and select the first item for this moment [1] -->
        <xsl:variable name="distinct_amt" select="../../ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.Amt[@TID = $amt_ref][not(@TID = (preceding::*/@TID))][1]/@TID"/>
        <ZustaendigeStelle REF="AMT_{$distinct_amt}" />
    </xsl:template>

    <xsl:template name="legende">
        <xsl:param name="typ_ref_id"/>
        <Legende REF="Legende_{../ili:Gewaesserraum_V1_1.GewR.Typ_GewR[@TID=$typ_ref_id]/@TID}"/>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR.MultilingualUri/ili:LocalisedText/ili:Gewaesserraum_V1_1.GewR.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:Gewaesserraum_V1_1.GewR.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:apply-templates select="ili:Name" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:Gewaesserraum_V1_1.GewR.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <xsl:template match="ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@TID"/>
        <xsl:variable name="mgdm_typ_ref" select="../../ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.DokumentGewR[ili:Dokument/@REF=$mgdm_dokument_tid]/ili:GewR/@REF"/>
        <xsl:for-each select="../../ili:Gewaesserraum_V1_1.GewR/ili:Gewaesserraum_V1_1.GewR.GewR[@TID=$mgdm_typ_ref]">
            <xsl:variable name="mgdm_tid" select="./@TID"/>
            <xsl:if test="./ili:Verzicht/text()='false'">
                <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
                    <xsl:for-each select="./OereblexDoc">
                        <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                            <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                            <Vorschrift REF="{./@REF}"/>
                        </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="comment()| processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
</xsl:stylesheet>