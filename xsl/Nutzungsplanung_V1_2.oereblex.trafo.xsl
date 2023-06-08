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
                    <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.Geobasisdaten" />
                    <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.TransferMetadaten/ili:Nutzungsplanung_V1_2.TransferMetadaten.Amt"/>
                    <xsl:call-template name="supplement"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Amt.Amt" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Dokumente.Dokument" mode="copy-no-namespaces"/>
                    <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.Rechtsvorschriften/ili:Nutzungsplanung_V1_2.Rechtsvorschriften.Dokument"/>
                    <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Geometrie_Dokument"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.Geobasisdaten">
        <xsl:for-each select="ili:Nutzungsplanung_V1_2.Geobasisdaten.Grundnutzung_Zonenflaeche">
            <xsl:call-template name="eigentumsbeschraenkung_und_geometrie"/>
        </xsl:for-each>
        <xsl:for-each select="ili:Nutzungsplanung_V1_2.Geobasisdaten.Ueberlagernde_Festlegung">
            <xsl:call-template name="eigentumsbeschraenkung_und_geometrie"/>
        </xsl:for-each>
        <xsl:for-each select="ili:Nutzungsplanung_V1_2.Geobasisdaten.Objektbezogene_Festlegung">
            <xsl:call-template name="eigentumsbeschraenkung_und_geometrie"/>
        </xsl:for-each>
        <xsl:for-each select="ili:Nutzungsplanung_V1_2.Geobasisdaten.Linienbezogene_Festlegung">
            <xsl:call-template name="eigentumsbeschraenkung_und_geometrie"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="eigentumsbeschraenkung_und_geometrie">
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
            <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
            <xsl:call-template name="zustaendige_stelle">
                <xsl:with-param name="basket_id" select="substring-before(../@BID,'.geobasisdaten')"/>
            </xsl:call-template>
            <xsl:call-template name="legende_darstellungsdienst">
                <xsl:with-param name="typ_ref_id" select="./ili:Typ/@REF"/>
                <xsl:with-param name="rechtsstatus" select="./ili:Rechtsstatus"/>
            </xsl:call-template>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
            <xsl:if test="./ili:Geometrie/ili:SURFACE"> <!-- for Grundnutzung_Zonenflaeche.Geometrie and Ueberlagernde_Festlegung.Geometrie -->
                <Flaeche>
                    <xsl:apply-templates select="./ili:Geometrie/ili:SURFACE" mode="copy-no-namespaces"/>
                </Flaeche>
            </xsl:if>
            <xsl:if test="./ili:Geometrie/ili:POLYLINE"> <!-- for Linienbezogene_Festlegung.Geometrie -->
                <Linie>
                    <xsl:apply-templates select="./ili:Geometrie/ili:POLYLINE" mode="copy-no-namespaces"/>
                </Linie>
            </xsl:if>
            <xsl:if test="./ili:Geometrie/ili:COORD"> <!-- for Objektbezogene_Festlegung.Geometrie -->
                <Punkt>
                    <xsl:apply-templates select="./ili:Geometrie/ili:COORD" mode="copy-no-namespaces"/>
                </Punkt>
            </xsl:if>
            <xsl:apply-templates select="./ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>
            <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@TID}"/>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
    </xsl:template>

    <xsl:template name="supplement">
        <xsl:for-each select="//ili:Nutzungsplanung_V1_2.Geobasisdaten/*/ili:Rechtsstatus[not(. = (../preceding-sibling::*/ili:Rechtsstatus))]">
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

    <xsl:template name="zustaendige_stelle">
        <xsl:param name="basket_id"/>
        <ZustaendigeStelle REF="AMT_{../../ili:Nutzungsplanung_V1_2.TransferMetadaten[substring-before(@BID, '.transfermetadaten')=$basket_id]/ili:Nutzungsplanung_V1_2.TransferMetadaten.Datenbestand/ili:zustaendigeStelle/@REF}"/>
    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ_ref_id"/>
        <xsl:param name="rechtsstatus"/> <!-- Not used now - wait for fixed catalog with rechtsstatus data -->
        <xsl:variable name="typ_art_code" select="../ili:Nutzungsplanung_V1_2.Geobasisdaten.Typ[@TID=$typ_ref_id]/ili:Code"/> <!-- Gemeinde code included -->

        <!-- ArtCodes in catalog are now without the rechtsstatus identifier - we're pairing the raw Code directly to ArtCode now.
        After rechtsstatus identifier is added to the catalog, add the rechtsstatus here. Should work similar like Planugszonen Legende pairing -->

        <xsl:comment> LOG
            typ_ref_id="<xsl:value-of select="$typ_ref_id" />"
            typ_art_code="<xsl:value-of select="$typ_art_code" />"
            rechtsstatus="<xsl:value-of select="$rechtsstatus"/>"
        </xsl:comment>

        <xsl:variable name="legende_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=concat($typ_art_code, '_', $rechtsstatus)]/@TID"/>
        <xsl:variable name="darstellungsdienst_tid" select="$catalog_doc//ili:TRANSFER/ili:DATASECTION/ili:OeREBKRMlegdrst_V2_0.Transferstruktur/ili:OeREBKRMlegdrst_V2_0.Transferstruktur.LegendeEintrag[ili:Thema=$theme_code][ili:ArtCode=concat($typ_art_code, '_', $rechtsstatus)]/ili:DarstellungsDienst/@REF"/>
        <Legende REF="{$legende_tid}"/>
        <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.MultilingualUri/ili:LocalisedText/ili:Nutzungsplanung_V1_2.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:Nutzungsplanung_V1_2.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.TransferMetadaten/ili:Nutzungsplanung_V1_2.TransferMetadaten.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:apply-templates select="ili:Name" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.TransferMetadaten/ili:Nutzungsplanung_V1_2.TransferMetadaten.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.Rechtsvorschriften">
        <xsl:apply-templates select="ili:Nutzungsplanung_V1_2.Rechtsvorschriften.Dokument"/>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.Rechtsvorschriften/ili:Nutzungsplanung_V1_2.Rechtsvorschriften.Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="@TID"/>
        <xsl:variable name="mgdm_typ_ref" select="../../ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Typ_Dokument[ili:Dokument/@REF=$mgdm_dokument_tid]/ili:Typ/@REF"/>
        <xsl:for-each select="../../ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Grundnutzung_Zonenflaeche[ili:Typ/@REF=$mgdm_typ_ref]">
            <xsl:call-template name="hinweis_vorschrift">
                <xsl:with-param name="mgdm_dokument_tid" select="$mgdm_dokument_tid"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="../../ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Ueberlagernde_Festlegung[ili:Typ/@REF=$mgdm_typ_ref]">
            <xsl:call-template name="hinweis_vorschrift">
                <xsl:with-param name="mgdm_dokument_tid" select="$mgdm_dokument_tid"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="../../ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Objektbezogene_Festlegung[ili:Typ/@REF=$mgdm_typ_ref]">
            <xsl:call-template name="hinweis_vorschrift">
                <xsl:with-param name="mgdm_dokument_tid" select="$mgdm_dokument_tid"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="../../ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Linienbezogene_Festlegung[ili:Typ/@REF=$mgdm_typ_ref]">
            <xsl:call-template name="hinweis_vorschrift">
                <xsl:with-param name="mgdm_dokument_tid" select="$mgdm_dokument_tid"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="hinweis_vorschrift">
        <xsl:param name="mgdm_dokument_tid"/>
        <xsl:variable name="mgdm_tid" select="./@TID"/>
        <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
            <xsl:for-each select="./OereblexDoc">
                <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                    <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                    <Dokument REF="{./@REF}"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="ili:Nutzungsplanung_V1_2.Geobasisdaten/ili:Nutzungsplanung_V1_2.Geobasisdaten.Geometrie_Dokument">
        <xsl:variable name="mgdm_dokument_tid" select="./ili:Dokument/@REF"/>
        <xsl:variable name="mgdm_tid" select="./ili:Geometrie/@REF"/>
        <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc[@REF=$mgdm_dokument_tid]">
            <xsl:for-each select="./OereblexDoc">
                <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                    <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                    <Vorschrift REF="{./@REF}"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
            </xsl:for-each>
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