<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

  <xsl:param name="schema-name" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"/>

  <xsl:output method="xml" indent="no"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="processing-instruction('xml-model')">
    <xsl:processing-instruction name="xml-model">
      <xsl:text>href="https://raw.githubusercontent.com/PerseusDLCode/perseus-schemas/main/</xsl:text>
      <xsl:value-of select="$schema-name"/>
      <xsl:text>.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
    </xsl:processing-instruction>
  </xsl:template>

</xsl:stylesheet>
