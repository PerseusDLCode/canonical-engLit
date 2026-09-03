<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- lb milestones are removed; their global numbering (verified correct
         and sequential 1..1855) is reconstituted by plain document-order
         position on <l> itself. -->
    <xsl:template match="tei:lb"/>

    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="n">
                <xsl:number level="any" count="tei:l"/>
            </xsl:attribute>
            <xsl:apply-templates select="node() except tei:lb"/>
        </l>
    </xsl:template>

    <xsl:template match="tei:body/@xml:base">
        <xsl:attribute name="xml:base">urn:cts:engLit:shakespeare.luc.globe</xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="line" delim="." match=".//l[@n]" use="@n"/></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
