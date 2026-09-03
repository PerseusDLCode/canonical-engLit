<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- type sonnet -> poem; @n from roman to sequential arabic where it is
         actually a roman numeral (the "dedication" div's @n is left as is);
         <head> keeps the roman numeral text unchanged -->
    <xsl:template match="tei:div[@type='sonnet']">
        <div xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@* except (@type, @n)"/>
            <xsl:attribute name="type">poem</xsl:attribute>
            <xsl:choose>
                <xsl:when test="matches(@n, '^[IVXLCDM]+$', 'i')">
                    <xsl:attribute name="n">
                        <xsl:number level="any" count="tei:div[@type='sonnet'][matches(@n,'^[IVXLCDM]+$','i')]"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="n" select="@n"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- lines restart at 1 for each sonnet -->
    <xsl:template match="tei:l[parent::tei:div[@type='sonnet']]">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="n" select="count(preceding-sibling::tei:l) + 1"/>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <xsl:template match="tei:body/@xml:base">
        <xsl:attribute name="xml:base">urn:cts:engLit:shakespeare.son.globe</xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="poem" delim=":" match="div[@type='poem']" use="@n"><citeStructure unit="line" delim="." match=".//l" use="@n"/></citeStructure></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
