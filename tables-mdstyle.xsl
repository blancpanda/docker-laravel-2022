<?xml version="1.0" encoding="utf8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="http://sqlfairy.sourceforge.net/sqlfairy.xml">
<xsl:output method="text" encoding="utf8"/>

<xsl:template match="database"># テーブル定義 &lt;!-- <xsl:value-of select="@name"/> --&gt; &lt;!-- omit in toc --&gt;
<xsl:apply-templates select="table_structure" mode="toc"/>
<xsl:text>
</xsl:text>
<xsl:apply-templates select="table_structure"/>
</xsl:template>

<xsl:template match="table_structure" mode="toc">
- [<xsl:value-of select="@name"/>](#<xsl:value-of select="@name"/>)</xsl:template>

<xsl:template match="table_structure">
## <xsl:value-of select="@name"/>

テーブル名|コメント
--------|--------
<xsl:value-of select="@name"/>|<xsl:value-of select="options/@Comment"/>

&lt;span style="font-size: 1.25rem; font-weight: bold;"&gt;カラム&lt;/span&gt;

＃|カラム名|データ型|NULL|デフォルト値|主キー|Extra|コメント
|----|----|----|----|----|----|----|---|
<xsl:apply-templates select="field"/>
&lt;span style="font-size: 1.25rem; font-weight: bold;"&gt;インデックス&lt;/span&gt;

インデックス名|カラム|複合キー順序|NULL|UNIQ
----|----|----|----|----
<xsl:apply-templates select="key"/>
</xsl:template>

<xsl:template match="field">
<xsl:value-of select="position()"/>|<xsl:value-of select="@Field"/> |<xsl:value-of select="@Type"/>|<xsl:value-of select="@Null"/>|<xsl:choose><xsl:when test="@Default != ''"><xsl:value-of select="@Default"/></xsl:when><xsl:otherwise>n/a</xsl:otherwise></xsl:choose>|<xsl:choose><xsl:when test="@Key != ''"><xsl:value-of select="@Key"/></xsl:when><xsl:otherwise>n/a</xsl:otherwise></xsl:choose>|<xsl:choose><xsl:when test="@Extra != ''"><xsl:value-of select="@Extra"/></xsl:when><xsl:otherwise>n/a</xsl:otherwise></xsl:choose>| <xsl:value-of select="@Comment"/>|<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="key">
<xsl:value-of select="@Key_name"/>| <xsl:value-of select="@Column_name"/>|<xsl:value-of select="@Seq_in_index"/>|<xsl:choose><xsl:when test="@Null != ''"><xsl:value-of select="@Null"/></xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>|<xsl:choose><xsl:when test="@Non_unique = '0'">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>|<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>