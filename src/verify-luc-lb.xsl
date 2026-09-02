<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:variable name="lines" select="//tei:l"/>
        <xsl:text>total l: </xsl:text><xsl:value-of select="count($lines)"/><xsl:text>&#10;</xsl:text>
        <xsl:for-each select="$lines">
            <xsl:variable name="pos" select="position()"/>
            <xsl:variable name="preceding-lb" select="(preceding::tei:lb[@ed='G'])[last()]"/>
            <xsl:if test="not($preceding-lb) or xs:integer($preceding-lb/@n) != $pos" xmlns:xs="http://www.w3.org/2001/XMLSchema">
                <xsl:text>MISMATCH at l position </xsl:text><xsl:value-of select="$pos"/>
                <xsl:text> nearest preceding lb@n=</xsl:text><xsl:value-of select="$preceding-lb/@n"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>done&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
