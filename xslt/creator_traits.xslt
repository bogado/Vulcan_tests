<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text" encoding="utf-8"/>
<xsl:template match="/">
/* This file was generate, please do not change it */
#ifndef ALL_TRAITS_HPP_INCLUDED
#define ALL_TRAITS_HPP_INCLUDED

namespace vk_types {

// All handle types:
<xsl:apply-templates select="/registry/enums[@name='VkObjectType']/enum[@comment!='']"/>
// All struct types:
<xsl:apply-templates select="/registry/types/type[@category = 'struct' and member[position() = 1 and @values!='' and type='VkStructureType']]"/>

};

<xsl:apply-templates select="/registry/commands/command[starts-with(proto/name, 'vkCreate')]"/>

#endif
</xsl:template>

<xsl:template match="type[@category = 'struct' and member[position() = 1 and @values!='' and type='VkStructureType']]">
	// <xsl:value-of select="./@name"/> 
	static constexpr auto <xsl:value-of select="./@name"/>_id = ::vk::StructureType{<xsl:value-of select="member[1]/@values"/>};

	template &lt;&gt;
	struct vk_traits&lt;::vk::StructureType, <xsl:value-of select="./@name"/>_id&gt; {
		static constexpr auto name = std::string_view{"<xsl:value-of select="./@name"/>"};
		static constexpr auto id   = <xsl:value-of select="./@name"/>_id;
		using type     = decltype(id);
		using type_cpp = cpp_type&lt;<xsl:value-of select="./@name"/>_id&gt;;
		using type_c   = ::<xsl:value-of select="./@name"/>;
	};
</xsl:template>

<xsl:template match="enum">
	static constexpr auto <xsl:value-of select="./@comment"/>_id = ::vk::ObjectType{<xsl:value-of select="./@name"/>};

	template &lt;&gt;
	struct vk_traits&lt;::vk::ObjectType, <xsl:value-of select="./@comment"/>_id&gt; {
		static constexpr auto name = std::string_view{"<xsl:value-of select="./@comment"/>"};
		static constexpr auto id   = <xsl:value-of select="./@comment"/>_id;
		using type     = decltype(id);
		using type_cpp = cpp_type&lt;<xsl:value-of select="./@comment"/>_id&gt;;
		using type_c   = ::<xsl:value-of select="./@comment"/>;
	};
</xsl:template>

<xsl:template match="command">
template &lt;&gt; struct creator_traits&lt;vk_types::<xsl:value-of select="param[last()]/type"/>&gt; :
	details::creator_traits_impl&lt;vk_types::<xsl:value-of select="param[last()]/type"/>, vk_types::<xsl:value-of select="param[name='pCreateInfo']/type"/>, vk_types::<xsl:value-of select="param[1]/type"/>&gt; 
	{};
</xsl:template>


</xsl:stylesheet>
