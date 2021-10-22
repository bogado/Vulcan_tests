<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="utf-8"/>
<xsl:template match="/">
/* this file was generate, please do not change it */
#ifndef all_handles_hpp_included
#define all_handles_hpp_included

namespace vbl::traits {

// all handles
<xsl:apply-templates select="registry/types" />

template &lt;handles HANDLE&gt;
struct handle_traits {
	static constexpr auto has_parent = false;
};

<xsl:for-each select="registry/types/type[@category='handle' and @parent!='']">
template &lt;&gt;
struct handle_traits&lt;handles::<xsl:value-of select="substring-after(./name, 'Vk')"/>&gt; {
	static constexpr auto has_parent = true;
	static constexpr auto parent = handles::<xsl:value-of select="substring-after(@parent, 'Vk')"/>;
};
</xsl:for-each>
}

#endif
</xsl:template>
<xsl:template match="registry/types">
enum class handles {
	<xsl:apply-templates select="type[@category='handle']"/>
};
</xsl:template>
<xsl:template match="type">
	<xsl:value-of select="substring-after(name,'Vk')"/>
	<xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
<xsl:template match="type[@alias!='']">
	<xsl:value-of select="substring-after(@name,'Vk')"/> = <xsl:value-of select="substring-after(@alias,'Vk')"/>
	<xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
</xsl:stylesheet>
