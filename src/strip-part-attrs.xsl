<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Strip @part from <l>; preserve only meaningful values (I, M, F, Y) -->
    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@* except @part"/>
            <xsl:if test="@part = ('I', 'M', 'F', 'Y')">
                <xsl:attribute name="part" select="@part"/>
            </xsl:if>
            <xsl:apply-templates/>
        </l>
    </xsl:template>
    
    <!-- Strip @part from <p> entirely (deprecated in TEI P5) -->
    <xsl:template match="tei:p">
        <p xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@* except @part"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- @part="N" is the TEI default and carries no information; strip it -->
    <xsl:template match="(tei:lg | tei:div | tei:ab)/@part[. = 'N']"/>
</xsl:stylesheet>