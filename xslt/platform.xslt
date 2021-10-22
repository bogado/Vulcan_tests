<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="utf-8"/>
<xsl:include href="common.xslt"/>
<xsl:template match="/">
/* this file was generate, please do not change it */
#ifndef all_platforms_hpp_included
#define all_platforms_hpp_included

#include &lt;string_view&gt;
#include &lt;array&gt;

namespace vbl::vk_traits {

//all platforms:
<xsl:call-template name="enumeration">
	<xsl:with-param name="name" select="'platforms'"/>
	<xsl:with-param name="selection" select="registry/platforms/platform"/>
	<xsl:with-param name="first-item">any</xsl:with-param>
	<xsl:with-param name="first-detail">std::pair{ platforms::any, true }</xsl:with-param>
</xsl:call-template>
<xsl:apply-templates mode="traits" select="/registry/platforms/platform"/>
}
#endif
</xsl:template>

<xsl:template mode="traits_instance" match="platform">
std::pair{ platforms::<xsl:value-of select="./@name"/>,  
#ifdef <xsl:value-of select="./@protect"/>
true
#else
false
#endif
} <xsl:call-template name="list-separator"/>
</xsl:template>

<xsl:template mode="enum-definition" match="platform" priority="1">
	<xsl:value-of select="@name"/>
	<xsl:call-template name="list-separator"/>
</xsl:template>

</xsl:stylesheet>
