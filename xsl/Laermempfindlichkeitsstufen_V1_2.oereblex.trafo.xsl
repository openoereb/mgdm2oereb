<xsl:stylesheet
    xmlns="http://www.interlis.ch/INTERLIS2.3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
    exclude-result-prefixes="ili"
    version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="oereblex_output"/>
    <xsl:param name="oereblexdata" select="document(concat('file://',$oereblex_output))"/>
    <xsl:param name="catalog"/>
    <xsl:variable name="catalog_doc" select="document(concat('file://', $catalog))"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="target_basket_id"/>
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
                <OeREBKRMtrsfr_V2_0.Transferstruktur BID="{$target_basket_id}">
                    <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten" />
                    <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten/ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten.Amt"/>
                    <xsl:call-template name="supplement"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Amt.Amt" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Dokumente.Dokument" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften/ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften.Dokument"/>
                    <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Geometrie_Dokument"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten">
        <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Laermempfindlichkeit_Zonenflaeche"/>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Laermempfindlichkeit_Zonenflaeche">
        <xsl:variable name="typ_ref_id" select="./ili:Typ/@REF"/>
        <xsl:variable name="typ_node" select="../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Typ[@TID=$typ_ref_id]"/>
        <!--<xsl:comment> LOG
            typ_ref_id="<xsl:value-of select="$typ_ref_id" />"
            code="<xsl:value-of select="$typ_node/ili:Code/text()" />"
        </xsl:comment>-->
        <xsl:if test="$typ_node/ili:Code/text()!='Keine_ES'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
                <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
                <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
                <xsl:call-template name="zustaendige_stelle">
                    <xsl:with-param name="basket_id" select="../@BID"/>
                </xsl:call-template>
                <xsl:call-template name="legende_darstellungsdienst">
                    <xsl:with-param name="typ_ref_id" select="./ili:Typ/@REF"/>
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
        <xsl:for-each select="//ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/*/ili:Rechtsstatus[not(. = (../preceding-sibling::*/ili:Rechtsstatus))]">
            <xsl:variable name="rechtsstatus" select="."/>
            <xsl:comment> LOG
                rechtsstatus="<xsl:value-of select="." />"
            </xsl:comment>
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
        <!-- TODO: Umbau so wie bei nicht-oereb-lex-->
        <xsl:param name="typ_ref_id"/> <!-- WG Typ referenced from Waldgrenze_Linie -->
        <xsl:param name="rechtsstatus"/>
        <xsl:variable name="typ_artcode" select="concat(../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Typ[@TID=$typ_ref_id]/ili:Code, '_', $rechtsstatus)" /> <!-- 0 = ausserhalb_Bauzonen, 1 = in_Bauzonen -->

        <!-- comment, safe to delete: -->
        <xsl:comment> LOG
            typ_ref_id="<xsl:value-of select="$typ_ref_id" />"
            typ_artcode="<xsl:value-of select="$typ_artcode" />"
        </xsl:comment>
        <xsl:variable name="legende_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_artcode]/@TID"/>
        <xsl:variable name="darstellungsdienst_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=$typ_artcode]/ili:DarstellungsDienst/@REF"/>
        <xsl:if test="$legende_tid">
            <Legende REF="{$legende_tid}"/>
        </xsl:if>
        <xsl:if test="$darstellungsdienst_tid">
            <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="basket_id"/>
        <ZustaendigeStelle
                REF="AMT_{../../ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten/ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten.Datenbestand[ili:BasketID/@OID=$basket_id]/ili:ZustaendigeStelle/@REF}"/>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.MultilingualUri/ili:LocalisedText/ili:Laermempfindlichkeitsstufen_V1_2.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:Laermempfindlichkeitsstufen_V1_2.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten/ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:apply-templates select="ili:Name" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten/ili:Laermempfindlichkeitsstufen_V1_2.TransferMetadaten.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften">
        <xsl:apply-templates select="ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften.Dokument"/>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften/ili:Laermempfindlichkeitsstufen_V1_2.Rechtsvorschriften.Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@TID"/>
        <xsl:variable name="mgdm_typ_ref"
                      select="../../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Typ_Dokument[ili:Dokument/@REF=$mgdm_dokument_tid]/ili:Typ/@REF"/>
        <!-- comment, safe to delete: -->
        <xsl:comment> LOG
            mgdm_dokument_tid="<xsl:value-of select="$mgdm_dokument_tid" />"
            mgdm_typ_ref="<xsl:value-of select="$mgdm_typ_ref" />"
        </xsl:comment>

        <xsl:for-each select="../../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Laermempfindlichkeit_Zonenflaeche[ili:Typ/@REF=$mgdm_typ_ref]">
            <xsl:call-template name="hinweis_vorschrift">
                <xsl:with-param name="mgdm_dokument_tid" select="$mgdm_dokument_tid"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="hinweis_vorschrift">
        <xsl:param name="mgdm_dokument_tid"/>
        <xsl:variable name="mgdm_tid" select="./@TID"/>

        <!-- comment, safe to delete: --> <xsl:comment>Template "hinweis_vorschrift" called.</xsl:comment>

        <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
            <xsl:for-each select="./OereblexDoc">
                <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                    <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                    <Vorschrift REF="{./@REF}"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten/ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Geometrie_Dokument">

        <!-- comment, safe to delete: --> <xsl:comment>Template Geometrie_Dokument matched.</xsl:comment>

        <xsl:variable name="mgdm_dokument_tid" select="./ili:Dokument/@REF"/>
        <xsl:variable name="mgdm_tid" select="./ili:Geometrie/@REF"/>
        <xsl:variable name="typ_ref_id" select="../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Laermempfindlichkeit_Zonenflaeche[@TID=$mgdm_tid]/ili:Typ/@REF"/>
        <xsl:variable name="typ_node" select="../ili:Laermempfindlichkeitsstufen_V1_2.Geobasisdaten.Typ[@TID=$typ_ref_id]"/>
        <xsl:if test="$typ_node/ili:Code/text()!='Keine_ES'">
            <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
                <xsl:for-each select="./OereblexDoc">
                    <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                        <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                        <Vorschrift REF="{./@REF}"/>
                    </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
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