<xsl:stylesheet
    xmlns="http://www.interlis.ch/INTERLIS2.3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
    xmlns:ext="http://exslt.org/common"
    exclude-result-prefixes="ili ext"
    version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="catalog"/>
    <xsl:variable name="catalog_doc" select="document(concat('file://', $catalog))"/>
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
                    <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen" />
                    <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Amt"/>
                    <!-- <xsl:call-template name="supplement"/>-->
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen">
        <xsl:choose>
            <xsl:when test="$theme_code='ch.Grundwasserschutzzonen'">
                <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSZone"/>
                <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSZone"/>
                <xsl:call-template name="status">
                    <xsl:with-param name="nodes" select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSZone"/>
                </xsl:call-template>
                <xsl:for-each select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSZone[not(ili:Rechtsvorschrift/@REF = preceding::*/ili:Rechtsvorschrift/@REF)]">
                    <xsl:call-template name="dokument">
                        <xsl:with-param name="dokument_ref" select="ili:Rechtsvorschrift/@REF"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$theme_code='ch.Grundwasserschutzareale'">
                <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSAreal"/>
                <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSAreal"/>
                <xsl:call-template name="status">
                    <xsl:with-param name="nodes" select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSAreal"/>
                </xsl:call-template>
                <xsl:for-each select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSAreal[not(ili:Rechtsvorschrift/@REF = preceding::*/ili:Rechtsvorschrift/@REF)]">
                    <xsl:call-template name="dokument">
                        <xsl:with-param name="dokument_ref" select="ili:Rechtsvorschrift/@REF"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <!-- <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Dokument"/> -->

    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen/ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSZone">
        <!-- Reference to TID-->
        <xsl:variable name="rechtsstatus_ref_id" select="ili:Status/@REF"/>
        <!-- Reference to Baske ID-->
        <xsl:variable name="basket_id" select="../@BID"/>
        <!-- matching status node-->
        <xsl:variable name="status_node" select="../ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Status[@TID=$rechtsstatus_ref_id]"/>
        <!-- matching datenbestand node-->
        <xsl:variable name="datenbestand_node" select="../../../ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Datenbestand[ili:BasketId=$basket_id]"/>
        <!--<xsl:comment> LOG
            rechtsstatus_ref_id="<xsl:value-of select="$rechtsstatus_ref_id" />"
            basket_id="<xsl:value-of select="$basket_id" />"
        </xsl:comment>-->
        <!-- Laut Modelldokumentation Filterfunktion werden "provisorisch" elemente nicht übertragen - sind auch durch OeREBKRMtrsfr_V2_0 nicht unterstützt -->
        <xsl:if test="$status_node/ili:Rechtsstatus!='provisorisch'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
                <xsl:apply-templates select="$status_node/ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:choose>
                    <xsl:when test="$status_node/ili:Rechtskraftdatum">
                        <publiziertAb><xsl:value-of select="$status_node/ili:Rechtskraftdatum"/></publiziertAb>
                    </xsl:when>
                    <xsl:otherwise>
                        <publiziertAb><xsl:value-of select="$datenbestand_node/ili:Stand"/></publiziertAb>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Laut Modell wird publiziertBis nicht geführt-->
                <!--<xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>-->
                <xsl:call-template name="zustaendige_stelle">
                    <xsl:with-param name="basket_id" select="$basket_id"/>
                </xsl:call-template>
                <xsl:call-template name="legende_darstellungsdienst">
                    <xsl:with-param name="typ" select="./ili:Typ"/>
                    <xsl:with-param name="rechtsstatus" select="$status_node/ili:Rechtsstatus"/>
                </xsl:call-template>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
                <Flaeche>
                    <xsl:apply-templates select="./ili:Geometrie/ili:SURFACE" mode="copy-no-namespaces"/>
                </Flaeche>

                <xsl:apply-templates select="$status_node/ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:choose>
                    <xsl:when test="$status_node/ili:Rechtskraftdatum">
                        <publiziertAb><xsl:value-of select="$status_node/ili:Rechtskraftdatum"/></publiziertAb>
                    </xsl:when>
                    <xsl:otherwise>
                        <publiziertAb><xsl:value-of select="$datenbestand_node/ili:Stand"/></publiziertAb>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Laut Modell wird publiziertBis nicht geführt-->
                <!--<xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>-->
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@TID}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen/ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.GWSAreal">
        <!-- Reference to TID-->
        <xsl:variable name="rechtsstatus_ref_id" select="ili:Status/@REF"/>
        <!-- Reference to Baske ID-->
        <xsl:variable name="basket_id" select="../@BID"/>
        <!-- matching status node-->
        <xsl:variable name="status_node" select="../ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Status[@TID=$rechtsstatus_ref_id]"/>
        <!-- matching datenbestand node-->
        <xsl:variable name="datenbestand_node" select="../../../ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Datenbestand[ili:BasketId=$basket_id]"/>
        <!--<xsl:comment> LOG
            rechtsstatus_ref_id="<xsl:value-of select="$rechtsstatus_ref_id" />"
            basket_id="<xsl:value-of select="$basket_id" />"
        </xsl:comment>-->
        <!-- Laut Modelldokumentation Filterfunktion werden "provisorisch" elemente nicht übertragen - sind auch durch OeREBKRMtrsfr_V2_0 nicht unterstützt -->
        <xsl:if test="$status_node/ili:Rechtsstatus!='provisorisch'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{@TID}">
                <xsl:apply-templates select="$status_node/ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:choose>
                    <xsl:when test="$status_node/ili:Rechtskraftdatum">
                        <publiziertAb><xsl:value-of select="$status_node/ili:Rechtskraftdatum"/></publiziertAb>
                    </xsl:when>
                    <xsl:otherwise>
                        <publiziertAb><xsl:value-of select="$datenbestand_node/ili:Stand"/></publiziertAb>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Laut Modell wird publiziertBis nicht geführt-->
                <!--<xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>-->
                <xsl:call-template name="zustaendige_stelle">
                    <xsl:with-param name="basket_id" select="$basket_id"/>
                </xsl:call-template>
                <xsl:call-template name="legende_darstellungsdienst">
                    <xsl:with-param name="typ" select="./ili:Typ"/>
                    <xsl:with-param name="rechtsstatus" select="$status_node/ili:Rechtsstatus"/>
                </xsl:call-template>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
            <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie TID="geometrie_{@TID}">
                <Flaeche>
                    <xsl:apply-templates select="./ili:Geometrie/ili:SURFACE" mode="copy-no-namespaces"/>
                </Flaeche>

                <xsl:apply-templates select="$status_node/ili:Rechtsstatus" mode="copy-no-namespaces"/>
                <xsl:choose>
                    <xsl:when test="$status_node/ili:Rechtskraftdatum">
                        <publiziertAb><xsl:value-of select="$status_node/ili:Rechtskraftdatum"/></publiziertAb>
                    </xsl:when>
                    <xsl:otherwise>
                        <publiziertAb><xsl:value-of select="$datenbestand_node/ili:Stand"/></publiziertAb>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Laut Modell wird publiziertBis nicht geführt-->
                <!--<xsl:apply-templates select="./ili:publiziertBis" mode="copy-no-namespaces"/>-->
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{@TID}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
        </xsl:if>
    </xsl:template>

    <xsl:template name="status">
        <xsl:param name="nodes"/>
        <xsl:variable name="status_nodes" select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Status[@TID=$nodes/ili:Status/@REF][ili:Rechtsstatus!='provisorisch']"/>
        <xsl:variable name="status_nodes_count" select="count($status_nodes)"/>
        <xsl:choose>
            <xsl:when test="$status_nodes_count = 1">
                <xsl:call-template name="supplement">
                    <xsl:with-param name="status_node" select="$status_nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$status_nodes[not(ili:Rechtsstatus = preceding::*/ili:Rechtsstatus)]">
                    <xsl:call-template name="supplement">
                        <xsl:with-param name="status_node" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="supplement">
        <xsl:param name="status_node"/>
        <xsl:variable name="rechtsstatus" select="$status_node/ili:Rechtsstatus"/>
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
    </xsl:template>

    <xsl:template name="legende_darstellungsdienst">
        <xsl:param name="typ"/>
        <xsl:param name="rechtsstatus"/>
        <xsl:variable name="typ_artcode" select="concat($typ, '_', $rechtsstatus)" />


        <!--<xsl:comment> LOG
            typ_ref_id="<xsl:value-of select="$typ_ref_id" />"
            typ_artcode="<xsl:value-of select="$typ_artcode" />"
        </xsl:comment>-->
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
        <ZustaendigeStelle REF="AMT_{../../ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Datenbestand[ili:BasketId/text()=$basket_id]/ili:zustaendigeStelle/@REF}"/>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.MultilingualUri/ili:LocalisedText/ili:PlanerischerGewaesserschutz_V1_2.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:PlanerischerGewaesserschutz_V1_2.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Amt">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{./@TID}">
            <xsl:apply-templates select="ili:Name" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:AmtImWeb"/>
            <xsl:apply-templates select="ili:UID" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:Zeile1" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:Zeile2" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:Strasse" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:PLZ" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="ili:Ort" mode="copy-no-namespaces"/>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten/ili:PlanerischerGewaesserschutz_V1_2.TransferMetadaten.Amt/ili:AmtImWeb">
        <AmtImWeb>
            <xsl:apply-templates select="ili:PlanerischerGewaesserschutz_V1_2.MultilingualUri"/>
        </AmtImWeb>
    </xsl:template>

    <xsl:template name="dokument">
        <xsl:param name="dokument_ref"/>
        <xsl:comment> LOG
            dokument_ref="<xsl:value-of select="$dokument_ref"/>"
        </xsl:comment>
        <!-- Laut Modelldokumentation Filterfunktion werden "provisorisch" elemente nicht übertragen - sind auch durch OeREBKRMtrsfr_V2_0 nicht unterstützt -->
        <xsl:variable name="dokument_node" select="//ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Dokument[@TID=$dokument_ref][ili:Rechtsstatus!='provisorisch']"/>

        <xsl:variable name="mgdm_dokument_tid" select="$dokument_node/@TID"/>
        <!-- Reference to Baske ID-->
        <xsl:variable name="basket_id" select="$dokument_node/../@BID"/>
        <!-- comment, safe to delete:
        <xsl:comment> LOG
            mgdm_dokument_tid="<xsl:value-of select="$mgdm_dokument_tid" />"
            mgdm_typ_ref="<xsl:value-of select="$mgdm_typ_ref" />"
            mgdm_basket_id="<xsl:value-of select="$mgdm_basket_id" />"
            mgdm_amt="<xsl:value-of select="$mgdm_amt" />"
        </xsl:comment>
        -->
        <OeREBKRM_V2_0.Dokumente.Dokument TID="dokument_{$dokument_node/@TID}">
            <xsl:apply-templates select="$dokument_node/ili:Rechtsstatus" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:AuszugIndex" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:publiziertAb" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:OffizielleNr" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:Abkuerzung" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:Titel" mode="copy-no-namespaces"/>
            <xsl:apply-templates select="$dokument_node/ili:Typ" mode="copy-no-namespaces"/>
            <TextImWeb>
                <xsl:apply-templates select="$dokument_node/ili:TextImWeb/ili:PlanerischerGewaesserschutz_V1_2.MultilingualUri"/>
            </TextImWeb>
            <xsl:call-template name="zustaendige_stelle">
                <xsl:with-param name="basket_id" select="$basket_id"/>
            </xsl:call-template>
        </OeREBKRM_V2_0.Dokumente.Dokument>

    </xsl:template>
    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen/ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSZone">
        <xsl:variable name="dokument_ref" select="ili:Rechtsvorschrift/@REF"/>
        <!-- Laut Modelldokumentation Filterfunktion werden "provisorisch" elemente nicht übertragen - sind auch durch OeREBKRMtrsfr_V2_0 nicht unterstützt -->
        <xsl:if test="../ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Dokument[@TID=$dokument_ref]/ili:Rechtsstatus!='provisorisch'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{ili:GWSZone/@REF}"/>
                <Vorschrift REF="dokument_{$dokument_ref}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ili:PlanerischerGewaesserschutz_V1_2.GWSZonen/ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.RechtsvorschriftGWSAreal">
        <xsl:variable name="dokument_ref" select="ili:Rechtsvorschrift/@REF"/>
        <!-- Laut Modelldokumentation Filterfunktion werden "provisorisch" elemente nicht übertragen - sind auch durch OeREBKRMtrsfr_V2_0 nicht unterstützt -->
        <xsl:if test="../ili:PlanerischerGewaesserschutz_V1_2.GWSZonen.Dokument[@TID=$dokument_ref]/ili:Rechtsstatus!='provisorisch'">
            <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{ili:GWSAreal/@REF}"/>
                <Vorschrift REF="dokument_{$dokument_ref}"/>
            </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
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