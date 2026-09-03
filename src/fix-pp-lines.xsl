<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- Schmidt cites The Passionate Pilgrim by continuous global line
         number across the whole collection, not per-poem position;
         replaces the per-poem-restart @n added previously. The
         sequence/poem divisions stay as display structure but drop out
         of the citation path. -->
    <xsl:template match="tei:l[ancestor::tei:body]">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@* except @n"/>
            <xsl:attribute name="n">
                <xsl:number level="any" count="tei:l[ancestor::tei:body]"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="line" delim="." match=".//l[@n]" use="@n"/></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
