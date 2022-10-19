<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ili="http://www.interlis.ch/INTERLIS2.3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="oereblex_host"/>
    <xsl:variable name="oereblex_url" select="concat($oereblex_host,'/api/geolinks/')"/>
    <xsl:template match="/ili:TRANSFER/ili:DATASECTION">
        <DATASECTION>
            <xsl:apply-templates select="ili:Planungszonen_V1_1.Rechtsvorschriften/ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument"/>
        </DATASECTION>
    </xsl:template>
    <xsl:template match="ili:Planungszonen_V1_1.Rechtsvorschriften/ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument">
        <xsl:variable name="mgdm_original_tid" select="./@TID"/>
        <xsl:apply-templates select="./ili:TextImWeb/ili:Planungszonen_V1_1.MultilingualUri/ili:LocalisedText/ili:Planungszonen_V1_1.LocalisedUri">
            <xsl:with-param name="doc_tid" select="$mgdm_original_tid"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="/ili:TRANSFER/ili:DATASECTION/ili:Planungszonen_V1_1.Rechtsvorschriften/ili:Planungszonen_V1_1.Rechtsvorschriften.Dokument/ili:TextImWeb/ili:Planungszonen_V1_1.MultilingualUri/ili:LocalisedText/ili:Planungszonen_V1_1.LocalisedUri">
        <xsl:param name="doc_tid"/>
        <xsl:variable name="geolink_url_id" select="substring-before(substring-after(./ili:Text, $oereblex_url), '.')"/>
        <xsl:variable name="geolink" select="./ili:Text"/>
        <geolink mgdm_doc_id="{$doc_tid}" mgdm_geolink="{$geolink}" mgdm_geolink_language="{./ili:Language}" mgdm_geolink_id="{$geolink_url_id}"/>
    </xsl:template>
</xsl:stylesheet>
