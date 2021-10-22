<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="utf-8"/>
<xsl:include href="common.xslt"/>
<xsl:template match="/">
/* this file was generate, please do not change it */
#ifndef all_extensions_hpp_included
#define all_extensions_hpp_included

#include "platform.hpp"
#include "type.hpp"
<![CDATA[

#include <vulkan/vulkan.hpp>

#include <array>
#include <span>
#include <string_view>
]]>
namespace vbl::vk_traits {

enum class extensions;

//all extensions: 
<xsl:call-template name="enumeration">
	<xsl:with-param name="name">extensions</xsl:with-param>
	<xsl:with-param name="selection" select="/registry/extensions/extension[./@supported='vulkan']"/>
</xsl:call-template>

}
#endif
</xsl:template>

<xsl:template mode="enum-definition" match="extensions/extension[starts-with(@name, 'VK_')]">
		<xsl:variable name="extension_name" select="substring-after(@name,'VK_')"/>
		<xsl:choose>
			<xsl:when test="$extension_name != ''">
				<xsl:value-of select="$extension_name"/> = <xsl:value-of select="./@number"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@name"/> = <xsl:value-of select="./@number"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="list-separator"/>
</xsl:template>

<xsl:template mode="traits_definition" match="extensions/extension[starts-with(@name, 'VK_')]">
<xsl:if test="position() = 1"><![CDATA[
struct extension_traits {
	const std::string_view name;
	const platforms platform;
	const std::span<const vulkan_types> defined_types;
};

template <auto... values>
requires (std::convertible_to<decltype(values), vulkan_types> && ... && true )
constexpr auto types_set = std::array { vulkan_types{values}... };

]]></xsl:if>
</xsl:template>

<xsl:template mode="traits_instance" match="extensions/extension[starts-with(@name, 'VK_')]" priority="2">
	std::pair {
	extensions::<xsl:value-of select="substring-after(@name, 'VK_')"/>,
	extension_traits {
		std::string_view{"<xsl:value-of select="@name"/>"},
<xsl:choose>
	<xsl:when test="./@platform != ''">
		platforms::<xsl:value-of select="@platform"/>
	</xsl:when>
	<xsl:otherwise>
		platforms::any
	</xsl:otherwise>
	</xsl:choose>,
	<xsl:choose>
		<xsl:when test="count(require/type) > 0">
			<![CDATA[
			{ types_set<]]>
			<xsl:apply-templates mode="name-list" select="require/type">
				<xsl:with-param name="prefix">vulkan_types::</xsl:with-param>
			</xsl:apply-templates>
			<![CDATA[>]]> }
		</xsl:when>
		<xsl:otherwise>{}</xsl:otherwise>
	</xsl:choose>} }<xsl:call-template name="list-separator"/>

</xsl:template>

<xsl:template mode="name" match="extension/require/type[starts-with(@name, 'PFN_vk')]" priority="100">
	functions::<xsl:value-of select="substring-after(@name, 'PFN_vk')"></xsl:value-of>
</xsl:template>

</xsl:stylesheet>
