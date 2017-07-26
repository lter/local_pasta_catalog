<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="1.0">
    <xsl:output method="text"/>
    <xsl:strip-space  elements="*"/>
<xsl:template match="/">
<xsl:for-each select="resultset">PackageId,Title,Keywords,Originators,startDate,endDate,doi
<xsl:for-each select="document">
<xsl:value-of select="./packageid"/><xsl:text>,"</xsl:text><xsl:value-of select="./title"/><xsl:text>","</xsl:text>
                    <xsl:for-each select="keywords">
                        <xsl:for-each select="keyword">
                        <xsl:value-of select="."/><xsl:text>; </xsl:text>   
                        </xsl:for-each>
                    </xsl:for-each><xsl:text>","</xsl:text>
                        <xsl:for-each select="authors">
                            <xsl:for-each select="author">
                                <xsl:value-of select="."/><xsl:text>; </xsl:text> 
                            </xsl:for-each>
                        </xsl:for-each><xsl:text>",</xsl:text>
          
            <xsl:value-of select="./begindate"/><xsl:text>,</xsl:text><xsl:value-of select="./enddate"/><xsl:text>,</xsl:text> 
            <xsl:value-of select="./doi"/><xsl:text>
</xsl:text>
        </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
