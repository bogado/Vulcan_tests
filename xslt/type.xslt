<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="utf-8"/>
<xsl:include href="common.xslt"/>
<xsl:template match="/"><![CDATA[
/* this file was generate, please do not change it */
#ifndef all_type_hpp_included
#define all_type_hpp_included

#include <vulkan/vulkan_raii.hpp>

#include "platform.hpp"
#include "handle.hpp"

#include <array>
#include <variant>

namespace vbl::vk_traits {

struct vulkan_types {
	
	]]>
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'basetypes'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='basetype']"/>
</xsl:call-template>
using enum basetypes;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'bitmasks'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='bitmask']"/>
</xsl:call-template>
using enum bitmasks;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'handles'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='handle']"/>
</xsl:call-template>
using enum handles;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'enumerations'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='enum']"/>
</xsl:call-template>
using enum enumerations;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'structs'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='struct']"/>
</xsl:call-template>
using enum structs;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'unions'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='union']"/>
</xsl:call-template>
using enum unions;
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'functions'"/>
	<xsl:with-param name="selection" select="registry/types/type[@category='funcpointer']"/>
</xsl:call-template>
// No using here as those would clash with handles.

<![CDATA[
	using value_type = std::variant<basetypes, bitmasks, handles, enumerations, structs, unions, functions>;
	value_type value;

	template <std::convertible_to<value_type> TYPE>
	constexpr vulkan_types(TYPE val) : value {val} {}

	constexpr vulkan_types() = default;
 ]]>
};

}
		
#endif
</xsl:template>

<xsl:template mode="traits_definition" match="types/type">
</xsl:template>

<xsl:template mode="enum-definition" match="type[starts-with(@alias, 'Vk')]" priority="3">
	<xsl:apply-templates mode="name" select="."/> = <xsl:value-of select="substring-after(@alias, 'Vk')"/>
	<xsl:call-template name="list-separator"/>
</xsl:template>

<xsl:template mode="enum-definition" match="type" priority="3">
	<xsl:param name="name"/>
	<xsl:if test="$name"><xsl:value-of select="$name"/>::</xsl:if><xsl:apply-templates mode="name" select="."/><xsl:call-template name="list-separator"/>
</xsl:template>

<xsl:template mode="traits_instance" match="type">
	<xsl:param name="name"/>
	<xsl:apply-templates mode="enum-definition" select=".">
		<xsl:with-param name="name" select="$name"/>
	</xsl:apply-templates><xsl:call-template name="list-separator"/>
</xsl:template>

</xsl:stylesheet>
