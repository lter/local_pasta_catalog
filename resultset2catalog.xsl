<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="1.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:strip-space  elements="*"/>
    <xsl:template match="/">
        <xsl:for-each select="resultset"><h1>Data</h1>
            <table border="3"><tr><th>PackageId</th><th>Title</th><th>Keywords</th><th>Originators</th><th>Dates</th></tr>
        <xsl:for-each select="document">
            <xsl:element name="document">
                <tr><td><xsl:element name="a">
                    <xsl:attribute name="href">https://doi.org/<xsl:value-of select='substring(./doi,5)'/></xsl:attribute>
                    <xsl:value-of select="./packageid"/>
                </xsl:element>  
                    </td>
                    <td><xsl:value-of select="./title"/></td>
                    <td>
                    <xsl:for-each select="keywords">
                        <xsl:for-each select="keyword">
                        <xsl:value-of select="."/><xsl:text>; </xsl:text>   
                        </xsl:for-each>
                    </xsl:for-each>
                    </td><td>
                        <xsl:for-each select="authors">
                            <xsl:for-each select="author">
                                <xsl:value-of select="."/><xsl:text>; </xsl:text> 
                            </xsl:for-each>
                        </xsl:for-each>
                    </td><td>
                        <xsl:value-of select="./begindate"/> to 
                        <xsl:value-of select="./enddate"/>
                    </td>
                </tr>
            </xsl:element> 
        </xsl:for-each>
            </table> 
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
