<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Transfer @n from child lb[@ed='G'] to <l>, then drop all lb children -->
    <xsl:template match="tei:l">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@n) and @part = ('I', 'Y') and tei:lb[@ed='G']/@n">
                <xsl:attribute name="n" select="tei:lb[@ed='G']/@n"/>
            </xsl:if>
            <xsl:if test="not(@n) and not(@part) and tei:lb[@ed='G']/@n">
                <xsl:attribute name="n" select="tei:lb[@ed='G']/@n"/>
            </xsl:if>
            <xsl:apply-templates select="node() except tei:lb"/>
        </l>
    </xsl:template>
    
    <!-- Remove F1 TLNs everywhere else (outside <l>) -->
    <xsl:template match="tei:lb[@ed='F1']"/>
    
    <!-- Remove unnumbered Globe lb outside <l> -->
    <xsl:template match="tei:lb[@ed='G' and not(@n)]"/>
    
</xsl:stylesheet>