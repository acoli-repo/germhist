<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- koebler-html to 2-col tsv word list, target language specified as parameter, by default Modern German (nhd.) -->
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="tgt">nhd.</xsl:param>

    <xsl:template match="/">
        <xsl:text># </xsl:text>
        <xsl:value-of select="//title/text()[1]"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="$tgt"/>
        <!--xsl:text>&#9;orig</xsl:text-->      <!-- skip original entry -->
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="//body/br/following-sibling::b[1]">
            <xsl:variable name="lexent" select="text()[1]"/>
            <xsl:variable name="fullgloss" select="following-sibling::text()[1]"/>
            <xsl:if test="contains($fullgloss,concat(' ',$tgt,' '))">
                <xsl:variable name="lexent-short" select="normalize-space(replace(replace($lexent,'\([^\)]*\)',''),'\*',''))"/>
                <xsl:variable name="tgtgloss" select="normalize-space(replace(replace(substring-after($fullgloss,concat(' ',$tgt,' ')),' *[,;\(].*',''),'[„“]',''))"/>
                <xsl:value-of select="$lexent-short"/>
                <xsl:text>&#9;</xsl:text>
                <xsl:value-of select="$tgtgloss"/>
                
                <!-- skip original entry -->
                <!--xsl:text>&#9;&lt;b&gt;</xsl:text>
                <xsl:value-of select="$lexent"/>
                <xsl:text>&lt;/b&gt;</xsl:text>
                <xsl:value-of select="normalize-space($fullgloss)"/-->
                
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
