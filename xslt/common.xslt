<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="enumeration">
		<xsl:param name="name"/>
		<xsl:param name="selection"/>
		<xsl:param name="first-item"/>
		<xsl:param name="first-detail"/>
		enum class <xsl:value-of select="$name"/> {
		<xsl:if test="$first-item"><xsl:value-of select="$first-item"/>,</xsl:if>
		<xsl:apply-templates mode="enum-definition" select="$selection"/>
		};

		<xsl:apply-templates mode="traits_definition" select="$selection"/>

		static constexpr auto all_<xsl:value-of select="$name"/> = std::array {
		<xsl:if test="$first-detail"><xsl:value-of select="$first-detail"/>,</xsl:if>
		<xsl:apply-templates mode='traits_instance' select="$selection"><xsl:with-param name="name" select="$name"></xsl:with-param></xsl:apply-templates>
		};
	</xsl:template>

	<xsl:template name="list-separator">
		<xsl:if test="position() != last()">,</xsl:if><xsl:text>
</xsl:text>
	</xsl:template>

	<xsl:template mode="enum-definition" match="name" priority="1">
		<xsl:value-of select="."/>
		<xsl:call-template name="list-separator"/>
	</xsl:template>

	<xsl:template mode="name" match="type[name != '']" priority="5">
		<xsl:value-of select="name"/>
	</xsl:template>

	<xsl:template mode="name" match="type[starts-with(name, 'PFN_vk')]" priority="10">
		<xsl:value-of select="substring-after(name, 'PFN_vk')"/>
	</xsl:template>

	<xsl:template mode="name" match="type[@name != '' and not(starts-with(@name, 'Vk'))]" priority="10">
		<xsl:value-of select="@name"/>
	</xsl:template>

	<xsl:template mode="name" match="type[starts-with(@name, 'Vk')]" priority="10">
		<xsl:value-of select="substring-after(@name, 'Vk')"/>
	</xsl:template>

	<xsl:template mode="name" match="type[starts-with(name, 'Vk')]" priority="10">
		<xsl:value-of select="substring-after(name, 'Vk')"/>
	</xsl:template>

	<xsl:template mode="cpp-name" match="type" priority="2">
		::xv::<xsl:apply-templates mode="name" select="."/>
	</xsl:template>

	<xsl:template mode="name-list" match="*">
		<xsl:param name="prefix"/>
		<xsl:value-of select="$prefix"/><xsl:apply-templates mode="name" select="."/><xsl:call-template name="list-separator"/>
	</xsl:template>
</xsl:stylesheet>
