<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- @xml:lang values here are already known (eng, la); anything else is unexpected -->
    <xsl:template match="@xml:lang[. = 'eng']">
        <xsl:attribute name="xml:lang">en</xsl:attribute>
    </xsl:template>

    <xsl:template match="@xml:lang[not(. = ('eng', 'la'))]">
        <xsl:message terminate="yes">Unexpected @xml:lang value: <xsl:value-of select="."/></xsl:message>
    </xsl:template>

</xsl:stylesheet>
