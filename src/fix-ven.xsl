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

    <!-- unwrap the single div[@type='section'] wrapping the whole body -->
    <xsl:template match="tei:div[@type='section']">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- top-level lg (children of the now-unwrapped section div) become stanzas -->
    <xsl:template match="tei:lg[parent::tei:div[@type='section']]">
        <lg xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">stanza</xsl:attribute>
            <xsl:attribute name="n" select="count(preceding-sibling::tei:lg) + 1"/>
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <xsl:template match="tei:body/@xml:base">
        <xsl:attribute name="xml:base">urn:cts:engLit:shakespeare.ven.globe</xsl:attribute>
    </xsl:template>

    <!-- no global line numbers exist for ven (out of scope here); address by
         stanza + in-stanza line position instead of the broken zero-match
         line-only citeStructure -->
    <xsl:template match="tei:refsDecl[@xml:id='CTS']">
        <refsDecl xmlns="http://www.tei-c.org/ns/1.0" n="CTS" xml:id="CTS"><citeStructure match="/TEI/text/body" use="@xml:base"><citeStructure unit="stanza" delim=":" match="lg[@type='stanza']" use="@n"><citeStructure unit="line" delim="." match=".//l" use="position()"/></citeStructure></citeStructure></refsDecl>
    </xsl:template>

</xsl:stylesheet>
