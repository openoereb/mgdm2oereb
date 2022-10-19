<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
                version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="oereblexdata" select="document('file:///app/result/oereblex.xml')"/>
    <xsl:param name="darstellungsdienst_doc" select="document('file:///app/xsl/KbS_V1_5.katalog.darstellungsdienst.xml')"/>
    <xsl:param name="code_texte_doc" select="document('file:///app/xsl/KbS_V1_5.katalog.code_texte.xml')"/>
    <xsl:variable name="darstellungsdienst_tid" select="$darstellungsdienst_doc//DATASECTION/OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst[1]/@TID"/>
    <xsl:param name="theme_code"/>
    <xsl:param name="oereblex_host"/>
    <xsl:param name="rechts_status" select="'inKraft'"/>
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
                    <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte"/>
                    <xsl:for-each
                            select="$code_texte_doc//ili:TRANSFER/ili:DATASECTION/ili:KbS_V1_5.Codelisten/ili:KbS_V1_5.Codelisten.StatusAltlV_Definition">
                        <xsl:if test="./ili:Symbol_Punkt">
                            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{@TID}_Punkt">
                                <LegendeText>
                                    <xsl:copy-of select="./ili:Definition/ili:LocalisationCH_V1.MultilingualText"/>
                                </LegendeText>
                                <ArtCode>
                                    <xsl:value-of select="./ili:Code"></xsl:value-of>
                                </ArtCode>
                                <ArtCodeliste>https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5_20211015.xml</ArtCodeliste>
                                <Symbol>
                                    <xsl:copy-of select="./ili:Symbol_Punkt/ili:BINBLBOX"/>
                                </Symbol>
                                <Thema><xsl:value-of select="$theme_code"/></Thema>
                                <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
                            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
                        </xsl:if>
                        <xsl:if test="./ili:Symbol_Flaeche">
                            <OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag TID="{@TID}_Flaeche">
                                <LegendeText>
                                    <xsl:copy-of select="./ili:Definition/ili:LocalisationCH_V1.MultilingualText"/>
                                </LegendeText>
                                <ArtCode>
                                    <xsl:value-of select="./ili:Code"></xsl:value-of>
                                </ArtCode>
                                <ArtCodeliste>https://models.geo.admin.ch/BAFU/KbS_Codetexte_V1_5_20211015.xml</ArtCodeliste>
                                <Symbol>
                                    <xsl:copy-of select="./ili:Symbol_Flaeche/ili:BINBLBOX"/>
                                </Symbol>
                                <Thema><xsl:value-of select="$theme_code"/></Thema>
                                <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
                            </OeREBKRMtrsfr_V2_0.Transferstruktur.LegendeEintrag>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:copy-of select="$darstellungsdienst_doc//DATASECTION/OeREBKRMtrsfr_V2_0.Transferstruktur.DarstellungsDienst[1]"/>
                    <xsl:copy-of select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Amt.Amt"/>
                    <xsl:copy-of select="$oereblexdata//DATASECTION/OeREBKRM_V2_0.Dokumente.Dokument"/>
                    <xsl:for-each select="$oereblexdata//DATASECTION/MgdmDoc">
                        <xsl:variable name="mgdm_tid" select="./@REF"/>
                        <xsl:for-each select="./OereblexDoc">
                            <OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$mgdm_tid}"/>
                                <Vorschrift REF="{./@REF}"/>
                            </OeREBKRMtrsfr_V2_0.Transferstruktur.HinweisVorschrift>
                        </xsl:for-each>
                    </xsl:for-each>
                </OeREBKRMtrsfr_V2_0.Transferstruktur>
            </DATASECTION>
        </TRANSFER>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte">
        <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte.ZustaendigkeitKataster"/>
        <xsl:apply-templates select="ili:KbS_V1_5.Belastete_Standorte.Belasteter_Standort"/>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte/ili:KbS_V1_5.Belastete_Standorte.ZustaendigkeitKataster">
        <OeREBKRM_V2_0.Amt.Amt TID="amt_{@TID}">
            <Name>
                <xsl:copy-of
                        select="./ili:Zustaendige_Behoerde/ili:LocalisationCH_V1.MultilingualText"/>
            </Name>
            <AmtImWeb>
                <xsl:apply-templates select="ili:KbS_V1_5.MultilingualUri"/>
            </AmtImWeb>
        </OeREBKRM_V2_0.Amt.Amt>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.Belastete_Standorte/ili:KbS_V1_5.Belastete_Standorte.Belasteter_Standort">
        <xsl:variable name="eigentumsbeschraenkung_tid" select="./@TID"/>
        <xsl:variable name="geometry_publiziert_ab" select="./ili:Ersteintrag"/>
        <xsl:call-template name="belasteter_standort">
            <xsl:with-param name="eigentumsbeschraenkung_tid" select="$eigentumsbeschraenkung_tid"/>
        </xsl:call-template>
        <xsl:call-template name="geometrie">
            <xsl:with-param name="eigentumsbeschraenkung_tid" select="$eigentumsbeschraenkung_tid"/>
            <xsl:with-param name="geometry_publiziert_ab" select="$geometry_publiziert_ab"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="belasteter_standort">
        <xsl:param name="eigentumsbeschraenkung_tid"/>
        <OeREBKRMtrsfr_V2_0.Transferstruktur.Eigentumsbeschraenkung TID="eigentumsbeschraenkung_{$eigentumsbeschraenkung_tid}">
            <Rechtsstatus><xsl:value-of select="$rechts_status"/></Rechtsstatus>
            <publiziertAb>
                <xsl:value-of select="./ili:Ersteintrag"/>
            </publiziertAb>
            <DarstellungsDienst REF="{$darstellungsdienst_tid}"/>
            <Legende REF="Legende_{./ili:StatusAltlV}_Flaeche"/>
            <ZustaendigeStelle REF="amt_{./ili:ZustaendigkeitKataster/@REF}"/>
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
                        <xsl:copy-of select="./ili:KbS_V1_5.Belastete_Standorte.PolygonStructure/ili:Polygon/ili:SURFACE"/>
                    </Flaeche>
                    <Rechtsstatus><xsl:value-of select="$rechts_status"/></Rechtsstatus>
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
                <Rechtsstatus><xsl:value-of select="$rechts_status"/></Rechtsstatus>
                <publiziertAb>
                    <xsl:value-of select="$geometry_publiziert_ab"/>
                </publiziertAb>
                <Eigentumsbeschraenkung REF="eigentumsbeschraenkung_{$eigentumsbeschraenkung_tid}"/>
        </xsl:if>
        </OeREBKRMtrsfr_V2_0.Transferstruktur.Geometrie>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.MultilingualUri/ili:LocalisedText/ili:KbS_V1_5.LocalisedUri">
        <OeREBKRM_V2_0.LocalisedUri>
            <Language>
                <xsl:value-of select="./ili:Language"/>
            </Language>
            <Text>
                <xsl:value-of select="./ili:Text"/>
            </Text>
        </OeREBKRM_V2_0.LocalisedUri>
    </xsl:template>

    <xsl:template match="ili:KbS_V1_5.MultilingualUri">
        <OeREBKRM_V2_0.MultilingualUri>
            <LocalisedText>
                <xsl:apply-templates select="ili:LocalisedText/ili:Planungszonen_V1_1.LocalisedUri"/>
            </LocalisedText>
        </OeREBKRM_V2_0.MultilingualUri>
    </xsl:template>
</xsl:stylesheet>
