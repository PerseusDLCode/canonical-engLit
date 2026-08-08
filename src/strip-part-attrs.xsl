<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="@part = ('I', 'M', 'F', 'Y')">
                <xsl:attribute name="part"><xsl:value-of select="@part"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </l>
    </xsl:template>

    <!-- @part="N" is the TEI default and carries no information; strip it -->
    <xsl:template match="tei:p/@part[. = 'N']"/>
</xsl:stylesheet>