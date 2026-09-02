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

    <!-- flatten the single div[@type='poem'] wrapper -->
    <xsl:template match="tei:div[@type='poem']">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- top-level lg (children of the now-unwrapped poem div) become stanzas -->
    <xsl:template match="tei:lg[parent::tei:div[@type='poem']]">
        <lg xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">stanza</xsl:attribute>
            <xsl:attribute name="n" select="count(preceding-sibling::tei:lg) + 1"/>
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <!-- lines are numbered continuously from 1, not restarting at stanza breaks -->
    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="n">
                <xsl:number level="any" count="tei:l"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <xsl:template match="tei:body/@xml:base">
        <xsl:attribute name="xml:base">urn:cts:engLit:shakespeare.lc.globe</xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="stanza" delim=":" match="lg[@type='stanza']" use="@n"><citeStructure unit="line" delim="." match=".//l" use="@n"/></citeStructure></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
