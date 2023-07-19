<xsl:stylesheet
        xmlns="http://www.interlis.ch/INTERLIS2.3"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
        exclude-result-prefixes="ili"
        version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="xsl_path"/>
    <xsl:variable name="darstellungsdienst_doc" select="document(concat('file://', $xsl_path, '/', 'KbS_V1_5.katalog.darstellungsdienst.xml'))"/>
    <xsl:variable name="code_texte_doc" select="document(concat('file://', $xsl_path, '/', 'KbS_V1_5.katalog.code_texte.xml'))"/>
    <xsl:variable name="darstellungsdienst_tid"
                  select="$darstellungsdienst_doc//DATASECTION/OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst[1]/@TID"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="target_basket_id"/>
    <xsl:param name="rechts_status" select="'inKraft'"/>
    <xsl:param name="dokument_typ" select="'Rechtsvorschrift'"/>
    <xsl:template match="/ili:TRANSFER/ili:DATASECTION">
        <TRANSFER xmlns="http://www.interlis.ch/INTERLIS2.3">
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
                <OeREBKRMtrsfr_V2_0.Transferstruktur BID="{$target_basket_id}">
                    <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte"/>
                    <xsl:for-each
                            select="$code_texte_doc//ili:TRANSFER/ili:DATASECTION/ili:KbS_V1_5.Codelisten/ili:KbS_V1_5.Codelisten.StatusAltlV_Definition">
                        <xsl:if test="./ili:Symbol_Punkt">
                            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{@TID}_Punkt">
                                <LegendeText>
                                    <xsl:apply-templates
                                            select="./ili:Definition/ili:LocalisationCH_V1.MultilingualText"
                                            mode="copy-no-namespaces"/>
                                </LegendeText>
                                <ArtCode>
                                    <xsl:value-of select="./ili:Code"/>
                                </ArtCode>
                                <ArtCodeliste>https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5_20211015.xml</ArtCodeliste>
                                <Symbol>
                                    <xsl:apply-templates select="./ili:Symbol_Punkt/ili:BINBLBOX"
                                                         mode="copy-no-namespaces"/>
                                </Symbol>
                                <Thema>
                                    <xsl:value-of select="$theme_code"/>
                                </Thema>
                                <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
                            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
                        </xsl:if>
                        <xsl:if test="./ili:Symbol_Flaeche">
                            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{@TID}_Flaeche">
                                <LegendeText>
                                    <xsl:apply-templates
                                            select="./ili:Definition/ili:LocalisationCH_V1.MultilingualText"
                                            mode="copy-no-namespaces"/>
                                </LegendeText>
                                <ArtCode>
                                    <xsl:value-of select="./ili:Code"/>
                                </ArtCode>
                                <ArtCodeliste>https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5_20211015.xml</ArtCodeliste>
                                <Symbol>
                                    <xsl:apply-templates select="./ili:Symbol_Flaeche/ili:BINBLBOX"
                                                         mode="copy-no-namespaces"/>
                                </Symbol>
                                <Thema>
                                    <xsl:value-of select="$theme_code"/>
                                </Thema>
                                <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
                            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:apply-templates
                            select="$darstellungsdienst_doc//DATASECTION/OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst[1]"
                            mode="copy-no-namespaces"/>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte">
        <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte.ZustaendigkeitKataster"/>
        <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte.Belasteter_Standort"/>
    </xsl:template>

    <xsl:template
            match="ili:KbS_V1_5.Belastete_Standorte/ili:KbS_V1_5.Belastete_Standorte.ZustaendigkeitKataster">
        <OeREBKRM_V2_0.Amt.Amt TID="AMT_{@TID}">
            <Name>
                <xsl:apply-templates
                        select="./ili:Zustaendige_Behoerde/ili:LocalisationCH_V1.MultilingualText"
                        mode="copy-no-namespaces"/>
            </Name>
            <AmtImWeb>
                <xsl:apply-templates select="./ili:URL_Behoerde/ili:KbS_V1_5.Belastete_Standorte.MultilingualUri"/>
            </AmtImWeb>
            <xsl:apply-templates select="ili:UID" mode="copy-no-namespaces"/>

        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template
            match="ili:KbS_V1_5.Belastete_Standorte/ili:KbS_V1_5.Belastete_Standorte.Belasteter_Standort">
        <xsl:variable name="eigentumsbeschraenkung_tid" select="./@TID"/>
        <xsl:variable name="geometry_publiziert_ab" select="./ili:Ersteintrag"/>
        <xsl:call-template name="belasteter_standort">
            <xsl:with-param name="eigentumsbeschraenkung_tid" select="$eigentumsbeschraenkung_tid"/>
        </xsl:call-template>
        <xsl:call-template name="geometrie">
            <xsl:with-param name="eigentumsbeschraenkung_tid" select="$eigentumsbeschraenkung_tid"/>
            <xsl:with-param name="geometry_publiziert_ab" select="$geometry_publiziert_ab"/>
        </xsl:call-template>
        <xsl:call-template name="dokument">
            <xsl:with-param name="standort_node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dokument">
        <xsl:param name="standort_node"/>
        <xsl:variable name="zustaendigkeit_node" select="//ili:KbS_V1_5.Belastete_Standorte.ZustaendigkeitKataster[@TID=$standort_node/ili:ZustaendigkeitKataster/@REF]"/>
        <OeREBKRM_V2_0.Dokumente.Dokument TID="dokument_{$standort_node/@TID}">
            <Rechtsstatus>
                <xsl:value-of select="$rechts_status"/>
            </Rechtsstatus>
            <publiziertAb>
                <xsl:value-of select="$standort_node/ili:Ersteintrag"/>
            </publiziertAb>
            <Titel>
                <LocalisationCH_V1.MultilingualText>
                    <LocalisedText>
                        <LocalisationCH_V1.LocalisedText>
                            <Language>de</Language>
                            <Text>
                                <xsl:value-of select="$standort_node/ili:Katasternummer"/>
                            </Text>
                        </LocalisationCH_V1.LocalisedText>
                        <LocalisationCH_V1.LocalisedText>
                            <Language>fr</Language>
                            <Text>
                                <xsl:value-of select="$standort_node/ili:Katasternummer"/>
                            </Text>
                        </LocalisationCH_V1.LocalisedText>
                        <LocalisationCH_V1.LocalisedText>
                            <Language>it</Language>
                            <Text>
                                <xsl:value-of select="$standort_node/ili:Katasternummer"/>
                            </Text>
                        </LocalisationCH_V1.LocalisedText>
                        <LocalisationCH_V1.LocalisedText>
                            <Language>rm</Language>
                            <Text>
                                <xsl:value-of select="$standort_node/ili:Katasternummer"/>
                            </Text>
                        </LocalisationCH_V1.LocalisedText>
                        <LocalisationCH_V1.LocalisedText>
                            <Language>en</Language>
                            <Text>
                                <xsl:value-of select="$standort_node/ili:Katasternummer"/>
                            </Text>
                        </LocalisationCH_V1.LocalisedText>
                    </LocalisedText>
                </LocalisationCH_V1.MultilingualText>
            </Titel>
            <Typ>
                <xsl:value-of select="$dokument_typ"/>
            </Typ>
            <AuszugIndex>1</AuszugIndex>
            <!-- Die Reihenfolge OR Verknüpfung hier wurde einfach aus der Modelldokumentation -> Filterfunktion übernommen -->
            <xsl:choose>
                <xsl:when test="$standort_node/ili:URL_Standort">
                    <TextImWeb>
                        <xsl:apply-templates select="$standort_node/ili:URL_Standort/ili:KbS_V1_5.Belastete_Standorte.MultilingualUri"/>
                    </TextImWeb>
                </xsl:when>
                <xsl:when test="$zustaendigkeit_node/ili:URL_Kataster">
                    <TextImWeb>
                        <xsl:apply-templates select="$zustaendigkeit_node/ili:URL_Kataster/ili:KbS_V1_5.Belastete_Standorte.MultilingualUri"/>
                    </TextImWeb>
                </xsl:when>
                <xsl:when test="$standort_node/ili:URL_KbS_Auszug">
                    <TextImWeb>
                        <xsl:apply-templates select="$standort_node/ili:URL_KbS_Auszug/ili:KbS_V1_5.Belastete_Standorte.MultilingualUri"/>
                    </TextImWeb>
                </xsl:when>
            </xsl:choose>
            <ZustaendigeStelle REF="AMT_{$standort_node/ili:ZustaendigkeitKataster/@REF}"/>
        </OeREBKRM_V2_0.Dokumente.Dokument>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
            <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$standort_node/@TID}"/>
            <Vorschrift REF="dokument_{$standort_node/@TID}"/>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
    </xsl:template>

    <xsl:template name="belasteter_standort">
        <xsl:param name="eigentumsbeschraenkung_tid"/>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung
                TID="eigentumsbeschraenkung_{$eigentumsbeschraenkung_tid}">
            <Rechtsstatus>
                <xsl:value-of select="$rechts_status"/>
            </Rechtsstatus>
            <publiziertAb>
                <xsl:value-of select="./ili:Ersteintrag"/>
            </publiziertAb>
            <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
            <Legende REF="Legende_{./ili:StatusAltlV}_Flaeche"/>
            <ZustaendigeStelle REF="AMT_{./ili:ZustaendigkeitKataster/@REF}"/>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung>
    </xsl:template>

    <xsl:template name="geometrie">
        <xsl:param name="eigentumsbeschraenkung_tid"/>
        <xsl:param name="geometry_publiziert_ab"/>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie
                TID="geometrie_{$eigentumsbeschraenkung_tid}">


            <xsl:if test="./ili:Geo_Lage_Polygon">
                <xsl:for-each
                        select="./ili:Geo_Lage_Polygon/ili:KbS_V1_5.Belastete_Standorte.MultiPolygon/ili:Polygones">
                    <Flaeche>
                        <xsl:apply-templates
                                select="./ili:KbS_V1_5.Belastete_Standorte.PolygonStructure/ili:Polygon/ili:SURFACE"
                                mode="copy-no-namespaces"/>
                    </Flaeche>
                    <Rechtsstatus>
                        <xsl:value-of select="$rechts_status"/>
                    </Rechtsstatus>
                    <publiziertAb>
                        <xsl:value-of select="$geometry_publiziert_ab"/>
                    </publiziertAb>
                    <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$eigentumsbeschraenkung_tid}"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="./ili:Geo_Lage_Punkt">
                <!-- TODO IMPLEMENT POINT CORRECTLY-->
                <Punkt>
                    NOT IMPLEMENTED YET
                </Punkt>
                <Rechtsstatus>
                    <xsl:value-of select="$rechts_status"/>
                </Rechtsstatus>
                <publiziertAb>
                    <xsl:value-of select="$geometry_publiziert_ab"/>
                </publiziertAb>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$eigentumsbeschraenkung_tid}"/>
            </xsl:if>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte.MultilingualUri/ili:LocalisedText/ili:KbS_V1_5.Belastete_Standorte.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:KbS_V1_5.Belastete_Standorte.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
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
