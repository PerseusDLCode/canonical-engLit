<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- @org/@sample are lxml body-content noise, absent even in the
         already-cleaned plays; @default="false" on the header's
         sourceDesc/biblStruct/langUsage is standing corpus boilerplate
         (present in e.g. lr/shakespeare.lr.globe.xml) and left alone -->
    <xsl:template match="@org | @sample"/>

    <!-- lines restart at 1 for each poem -->
    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="n">
                <xsl:number level="any" count="tei:l" from="tei:div[@type='poem']"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <xsl:template match="tei:body/@xml:base">
        <xsl:attribute name="xml:base">urn:cts:engLit:shakespeare.pp.globe</xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="sequence" delim=":" match="div[@type='sequence']" use="@n"><citeStructure unit="poem" delim="." match="div[@type='poem']" use="@n"><citeStructure unit="line" delim="." match=".//l" use="@n"/></citeStructure></citeStructure></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
