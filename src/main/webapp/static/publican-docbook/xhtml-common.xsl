<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
		xmlns:exsl="http://exslt.org/common"
		xmlns:xtext="xalan://com.nwalsh.xalan.Text"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:stext="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.TextFactory"
		xmlns:simg="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.ImageIntrinsics" 
		xmlns:ximg="xalan://com.nwalsh.xalan.ImageIntrinsics" 
                xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
                xmlns:xtbl="com.nwalsh.xalan.Table"
                xmlns:ptbl="http://nwalsh.com/xslt/ext/xsltproc/python/Table"
		xmlns:perl="urn:perl"
		xmlns:sverb="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Verbatim"
		xmlns:xverb="xalan://com.nwalsh.xalan.Verbatim"
		version="1.0"
		exclude-result-prefixes="sverb xverb xlink exsl stext xtext simg ximg"
		extension-element-prefixes="stext xtext perl ptbl xtbl stbl"
>



<!-- Admonition Graphics -->
<xsl:param name="admon.graphics" select="1"/>
<xsl:param name="admon.style" select="''"/>
<xsl:param name="admon.graphics.path">/docbuilder-tests/static/brand/Common/images</xsl:param>
<xsl:param name="callout.graphics.path"><xsl:value-of select="$admon.graphics.path"/></xsl:param>

<xsl:param name="package" select="''"/>

<xsl:param name="ignore.image.scaling" select="0"/>

<xsl:param name="chunker.output.doctype-public" select="'-//W3C//DTD XHTML 1.0 Strict//EN'"/>
<xsl:param name="chunker.output.doctype-system" select="'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'"/>
<xsl:param name="chunker.output.encoding" select="'UTF-8'"/>
<xsl:param name="chunker.output.indent" select="'no'"/>
<xsl:param name="html.longdesc.link" select="0"/>
<xsl:param name="html.longdesc" select="0"/>
<xsl:param name="html.longdesc.embed" select="1"/>
<xsl:param name="html.stylesheet"><xsl:if test="$embedtoc = 0 ">/docbuilder-tests/static/brand/Common/css/default.css</xsl:if></xsl:param>
<xsl:param name="html.stylesheet.type" select="'text/css'"/>
<xsl:param name="html.stylesheet.print"><xsl:if test="$embedtoc = 0 ">/docbuilder-tests/static/brand/Common/css/print.css</xsl:if></xsl:param>
<xsl:param name="html.cleanup" select="0"/>
<xsl:param name="html.ext" select="'.html'"/>
<xsl:output method="xml" indent="yes"/>
<xsl:param name="highlight.source" select="1"/>
<xsl:param name="use.extensions" select="0"/>
<xsl:param name="tablecolumns.extension">1</xsl:param>

<xsl:param name="qanda.in.toc" select="0"/>
<xsl:param name="segmentedlist.as.table" select="1"/>
<xsl:param name="othercredit.like.author.enabled" select="0"/>
<xsl:param name="email.delimiters.enabled">0</xsl:param>

<xsl:param name="generate.id.attributes" select="0"/>
<xsl:param name="make.graphic.viewport" select="0"/>
<xsl:param name="use.embed.for.svg" select="0"/>

<!-- TOC -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>

<xsl:param name="generate.toc">
set toc
book toc
article nop
chapter toc
qandadiv toc
qandaset toc
sect1 nop
sect2 nop
sect3 nop
sect4 nop
sect5 nop
section toc
part toc
</xsl:param>

<xsl:param name="suppress.navigation" select="0"/>
<xsl:param name="suppress.header.navigation" select="0"/>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>
<xsl:param name="css.decoration" select="0"/>
<xsl:param name="ulink.target"/>
<xsl:param name="table.cell.border.style"/>

<!-- BUGBUG 

	There is a bug where inserting elements in to the body level
	of xhtml will add xmlns="" to the tag. This is invalid xhtml.
	To overcome this I added:
		xmlns="http://www.w3.org/1999/xhtml"
	to the outer most tag. This gets stripped by the parser, resulting
	in valid xhtml ... go figure.
-->

<!--
From: xhtml/admon.xsl
Reason: remove tables
Version: 1.72.0
-->
<xsl:template name="graphical.admonition">
	<xsl:variable name="admon.type">
		<xsl:choose>
			<xsl:when test="local-name(.)='note'">Note</xsl:when>
			<xsl:when test="local-name(.)='warning'">Warning</xsl:when>
			<xsl:when test="local-name(.)='important'">Important</xsl:when>
			<xsl:otherwise>Note</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="alt">
		<xsl:call-template name="gentext">
			<xsl:with-param name="key" select="$admon.type"/>
		</xsl:call-template>
	</xsl:variable>

	<div xmlns="http://www.w3.org/1999/xhtml">
		<xsl:apply-templates select="." mode="class.attribute"/>
			<xsl:if test="$admon.style != ''">
				<xsl:attribute name="style">
					<xsl:value-of select="$admon.style"/>
				</xsl:attribute>
			</xsl:if>

	                <xsl:call-template name="common.html.attributes"/>
			<xsl:if test="$admon.textlabel != 0 or title">
				<div class="admonition_header">
					<p>
						<strong><xsl:apply-templates select="." mode="object.title.markup"/></strong>
					</p>
				</div>
			</xsl:if>
		<div class="admonition">
		<xsl:apply-templates/>
		</div>
	</div>
</xsl:template>

<!--
From: xhtml/lists.xsl
Reason: Remove invalid type attribute from ol
Version: 1.72.0
-->
<xsl:template match="substeps">
	<xsl:variable name="numeration">
		<xsl:call-template name="procedure.step.numeration"/>
	</xsl:variable>
	<ol xmlns="http://www.w3.org/1999/xhtml" class="{$numeration}">
		<xsl:call-template name="anchor"/>
		<xsl:apply-templates/>
	</ol>
</xsl:template>

<!--
From: xhtml/lists.xsl
Reason: Remove invalid type, start & compact attributes from ol, use role as class
Version: 1.72.0
-->
<xsl:template match="orderedlist">
	<div xmlns="http://www.w3.org/1999/xhtml">
		<xsl:call-template name="common.html.attributes"/>
		<xsl:apply-templates select="." mode="class.attribute"/>
		<xsl:call-template name="anchor"/>
		<xsl:if test="title">
			<xsl:call-template name="formal.object.heading"/>
		</xsl:if>
<!-- Preserve order of PIs and comments -->
		<xsl:apply-templates select="*[not(self::listitem or self::title or self::titleabbrev)] |
                                      comment()[not(preceding-sibling::listitem)] |
									  processing-instruction()[not(preceding-sibling::listitem)]"/>
		<ol>
          <xsl:if test="@role">
            <xsl:apply-templates select="." mode="class.attribute">
              <xsl:with-param name="class" select="@role"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:if test="@numeration">
            <xsl:apply-templates select="." mode="class.attribute">
              <xsl:with-param name="class" select="@numeration"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:apply-templates select="listitem | comment()[preceding-sibling::listitem] | processing-instruction()[preceding-sibling::listitem]"/>
		</ol>
	</div>
</xsl:template>

<!--
From: xhtml/lists.xsl
Reason: Remove invalid type, start & compact attributes from ol
Version: 1.72.0
-->
<xsl:template match="procedure">
	<xsl:variable name="param.placement" select="substring-after(normalize-space($formal.title.placement), concat(local-name(.), ' '))"/>

	<xsl:variable name="placement">
		<xsl:choose>
			<xsl:when test="contains($param.placement, ' ')">
				<xsl:value-of select="substring-before($param.placement, ' ')"/>
			</xsl:when>
			<xsl:when test="$param.placement = ''">before</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$param.placement"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

<!-- Preserve order of PIs and comments -->
	<xsl:variable name="preamble" select="*[not(self::step or self::title or self::titleabbrev)] |comment()[not(preceding-sibling::step)]	|processing-instruction()[not(preceding-sibling::step)]"/>
	<div xmlns="http://www.w3.org/1999/xhtml">
		<xsl:apply-templates select="." mode="class.attribute"/>
		<xsl:call-template name="common.html.attributes"/>
		<xsl:call-template name="anchor">
			<xsl:with-param name="conditional">
				<xsl:choose>
					<xsl:when test="title">0</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="title and $placement = 'before'">
			<xsl:call-template name="formal.object.heading"/>
		</xsl:if>
		<xsl:apply-templates select="$preamble"/>
		<xsl:choose>
			<xsl:when test="count(step) = 1">
				<ul>
					<xsl:apply-templates select="step |comment()[preceding-sibling::step] |processing-instruction()[preceding-sibling::step]"/>
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<ol>
					<xsl:attribute name="class">
						<xsl:value-of select="substring($procedure.step.numeration.formats,1,1)"/>
					</xsl:attribute>
					<xsl:apply-templates select="step |comment()[preceding-sibling::step] |processing-instruction()[preceding-sibling::step]"/>
				</ol>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="title and $placement != 'before'">
			<xsl:call-template name="formal.object.heading"/>
		</xsl:if>
	</div>
</xsl:template>

<!--
From: xhtml/graphics.xsl
Reason:  Remove html markup (align)
Version: 1.72.0
-->
<xsl:template name="longdesc.link">
	<xsl:param name="longdesc.uri" select="''"/>

	<xsl:variable name="this.uri">
	<xsl:call-template name="make-relative-filename">
		<xsl:with-param name="base.dir" select="$base.dir"/>
			<xsl:with-param name="base.name">
				<xsl:call-template name="href.target.uri"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="href.to">
		<xsl:call-template name="trim.common.uri.paths">
			<xsl:with-param name="uriA" select="$longdesc.uri"/>
			<xsl:with-param name="uriB" select="$this.uri"/>
			<xsl:with-param name="return" select="'A'"/>
		</xsl:call-template>
	</xsl:variable>
	<div xmlns="http://www.w3.org/1999/xhtml" class="longdesc-link">
		<br/>
		<span class="longdesc-link">
			<xsl:text>[</xsl:text>
			<a href="{$href.to}">D</a>
			<xsl:text>]</xsl:text>
		</span>
	</div>
</xsl:template>

<!--
From: xhtml/docbook.xsl
Reason: Remove inline style for draft mode
Version: 1.72.0
-->
<xsl:template name="head.content">
	<xsl:param name="node" select="."/>
	<xsl:param name="title">
		<xsl:apply-templates select="$node" mode="object.title.markup.textonly"/>
	</xsl:param>

	<title xmlns="http://www.w3.org/1999/xhtml" >
		<xsl:copy-of select="$title"/>
	</title>

	<xsl:if test="$html.stylesheet != ''">
		<xsl:call-template name="output.html.stylesheets">
			<xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="$html.stylesheet.print != ''">
         <link rel="stylesheet" media="print">
            <xsl:attribute name="href">
              <xsl:value-of select="$html.stylesheet.print"/>
            </xsl:attribute>
            <xsl:if test="$html.stylesheet.type != ''">
              <xsl:attribute name="type">
                <xsl:value-of select="$html.stylesheet.type"/>
              </xsl:attribute>
           </xsl:if>
         </link>
        </xsl:if>

	<xsl:if test="$link.mailto.url != ''">
		<link rev="made" href="{$link.mailto.url}"/>
	</xsl:if>

	<xsl:if test="$html.base != ''">
		<base href="{$html.base}"/>
	</xsl:if>

	<meta xmlns="http://www.w3.org/1999/xhtml" name="generator">
		<xsl:attribute name="content">
			<xsl:text>publican </xsl:text><xsl:value-of select="$publican.version"/>
		</xsl:attribute>
	</meta>

	<meta xmlns="http://www.w3.org/1999/xhtml" name="package">
		<xsl:attribute name="content">
			<xsl:copy-of select="$package"/>
		</xsl:attribute>
	</meta>
	<xsl:if test="$generate.meta.abstract != 0">
		<xsl:variable name="info" select="(articleinfo |bookinfo |prefaceinfo |chapterinfo |appendixinfo |sectioninfo |sect1info |sect2info |sect3info |sect4info |sect5info |referenceinfo |refentryinfo |partinfo |info |docinfo)[1]"/>
		<xsl:if test="$info and $info/abstract">
			<meta xmlns="http://www.w3.org/1999/xhtml" name="description">
				<xsl:attribute name="content">
					<xsl:for-each select="$info/abstract[1]/*">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:if test="position() &lt; last()">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:attribute>
			</meta>
		</xsl:if>
	</xsl:if>
      <xsl:if test="$embedtoc != 0 ">
          <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:value-of select="$tocpath"/>/../common/<xsl:value-of select="$langpath"/>/pressgang-ccms-static/brand/Common/css/menu.css</xsl:attribute></link>
          <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:value-of select="$tocpath"/>/../menu.css</xsl:attribute></link>
          <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:value-of select="$tocpath"/>/../print.css</xsl:attribute><xsl:attribute name="media">print</xsl:attribute></link>
        <xsl:if test="$brand != 'common'">
          <link rel="stylesheet" type="text/css"><xsl:attribute name="href"><xsl:value-of select="$tocpath"/>/../<xsl:value-of select="$brand"/>/<xsl:value-of select="$langpath"/>/pressgang-ccms-static/brand/Common/css/menu.css</xsl:attribute></link>
	</xsl:if>
          <script type="text/javascript"><xsl:attribute name="src"><xsl:value-of select="$tocpath"/>/../jquery-1.7.1.min.js</xsl:attribute></script>
          <script type="text/javascript"><xsl:attribute name="src"><xsl:value-of select="$tocpath"/>/labels.js</xsl:attribute></script>
          <script type="text/javascript"><xsl:attribute name="src"><xsl:value-of select="$tocpath"/>/../toc.js</xsl:attribute></script>
          <script type="text/javascript">
          <xsl:if test="$web.type = ''">
		current_book = '<xsl:copy-of select="$pop_name"/>';
		current_version = '<xsl:copy-of select="$pop_ver"/>';
		current_product = '<xsl:copy-of select="$pop_prod"/>';
	   </xsl:if>
          <xsl:if test="$web.type != ''">
		current_book = '';
		current_version = '';
	   </xsl:if>
                toc_path = '<xsl:value-of select="$tocpath"/>';
		loadMenu();
          </script>
      </xsl:if>

	<xsl:apply-templates select="." mode="head.keywords.content"/>
</xsl:template>

<!--
From: xhtml/docbook.xsl
Reason: Add css class for draft mode
Version: 1.72.0
-->
<xsl:template name="body.attributes">
	<xsl:if test="starts-with($writing.mode, 'rl')">
		<xsl:attribute name="dir">rtl</xsl:attribute>
	</xsl:if>
	<xsl:variable name="class">
		<xsl:if test="($draft.mode = 'yes' or ($draft.mode = 'maybe' and (ancestor-or-self::set | ancestor-or-self::book | ancestor-or-self::article)[1]/@status = 'draft'))">
			<xsl:value-of select="ancestor-or-self::*[@status][1]/@status"/><xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="$embedtoc != 0">
			<xsl:text>toc_embeded </xsl:text>
		</xsl:if>
       		<xsl:if test="$desktop != 0">
		  <xsl:text>desktop </xsl:text>
		</xsl:if>
	</xsl:variable>
        <xsl:if test="$class != ''">
	  <xsl:attribute name="class">
		<xsl:value-of select="$class"/>
	  </xsl:attribute>
	</xsl:if>
</xsl:template>

<!--
From: xhtml/docbook.xsl
Reason: Add confidential to footer
Version: 1.72.0
-->
<xsl:template name="user.footer.content">
	<xsl:param name="node" select="."/>
	<xsl:if test="$confidential = '1'">
		<div xmlns="http://www.w3.org/1999/xhtml" class="confidential">
			<xsl:value-of select="$confidential.text"/>
		</div>
	</xsl:if>
	<xsl:if test="$embedtoc != 0">
		<div id="site_footer"></div>
		<script type="text/javascript">
			$("#site_footer").load("<xsl:value-of select="$tocpath"/>/../footer.html");
		</script>
	</xsl:if>
</xsl:template>

<!--
From: xhtml/block.xsl
Reason:  default class (otherwise) to formalpara
Version: 1.72.0
-->
<xsl:template match="formalpara">
	<xsl:call-template name="paragraph">
		<xsl:with-param name="class">
			<xsl:choose>
				<xsl:when test="@role and $para.propagates.style != 0">
					<xsl:value-of select="@role"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>formalpara</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="content">
			<xsl:apply-templates/>
		</xsl:with-param>
	</xsl:call-template>
	<!--xsl:apply-templates/-->
</xsl:template>

<!--
From: xhtml/block.xsl
Reason:  h5 instead of <b>, remove default title end punctuation
Version: 1.72.0
-->
<xsl:template match="formalpara/title|formalpara/info/title">
	<xsl:variable name="titleStr">
			<xsl:apply-templates/>
	</xsl:variable>
	<div xmlns="http://www.w3.org/1999/xhtml" class="title">
		<xsl:copy-of select="$titleStr"/>
	</div>
</xsl:template>

<!--
From: xhtml/lists.xsl
Reason:  use role as class
Version: 1.72.0
-->
<xsl:template match="itemizedlist">
  <div xmlns="http://www.w3.org/1999/xhtml">
    <xsl:call-template name="common.html.attributes"/>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:call-template name="anchor"/>
    <xsl:if test="title">
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>

    <!-- Preserve order of PIs and comments -->
    <xsl:apply-templates select="*[not(self::listitem or self::title or self::titleabbrev)] |
								  comment()[not(preceding-sibling::listitem)] |
								  processing-instruction()[not(preceding-sibling::listitem)]"/>
    <ul>
      <xsl:if test="@role">
        <xsl:apply-templates select="." mode="class.attribute">
          <xsl:with-param name="class" select="@role"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$css.decoration != 0">
        <xsl:attribute name="type">
          <xsl:call-template name="list.itemsymbol"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:if test="@spacing='compact'">
        <xsl:attribute name="compact">
          <xsl:value-of select="@spacing"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="listitem | comment()[preceding-sibling::listitem] | processing-instruction()[preceding-sibling::listitem]"/>
    </ul>
  </div>
</xsl:template>

<!--
From: xhtml/xref.xsl
Reason:  use role as class
Version: 1.72.0
-->
<xsl:template match="ulink" name="ulink">
  <xsl:param name="url" select="@url"/>
  <xsl:variable name="link">
    <a xmlns="http://www.w3.org/1999/xhtml">
      <xsl:if test="@id or @xml:id">
        <xsl:attribute name="id">
          <xsl:value-of select="(@id|@xml:id)[1]"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="href"><xsl:value-of select="$url"/></xsl:attribute>
      <xsl:if test="$ulink.target != ''">
        <xsl:attribute name="target">
          <xsl:value-of select="$ulink.target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@role">
        <xsl:apply-templates select="." mode="class.attribute">
          <xsl:with-param name="class" select="@role"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(child::node())=0">
          <xsl:value-of select="$url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:variable>
  <xsl:copy-of select="$link"/>
</xsl:template>


<xsl:template match="*" mode="class.attribute">
  <xsl:param name="class" select="local-name(.)"/>
  <!-- permit customization of class attributes -->
  <!-- Use element name by default -->
  <xsl:attribute name="class">
    <!--xsl:value-of select="$class"/-->
    <xsl:apply-templates select="." mode="class.value">
      <xsl:with-param name="class" select="$class"/>
    </xsl:apply-templates>
    <xsl:if test="@role">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@role"/>
    </xsl:if>
  </xsl:attribute>
</xsl:template>

<!--
From: xhtml/graphics.xsl
Reason:  allow long descr to be inline
Version: 1.72.0
-->
<xsl:template match="imagedata">
  <xsl:variable name="filename">
    <xsl:call-template name="mediaobject.filename">
      <xsl:with-param name="object" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@format='linespecific'">
      <xsl:choose>
        <xsl:when test="$use.extensions != '0'                         and $textinsert.extension != '0'">
          <xsl:choose>
            <xsl:when test="element-available('stext:insertfile')">
              <stext:insertfile href="{$filename}" encoding="{$textdata.default.encoding}"/>
            </xsl:when>
            <xsl:when test="element-available('xtext:insertfile')">
              <xtext:insertfile href="{$filename}"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message terminate="yes">
                <xsl:text>No insertfile extension available.</xsl:text>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <a xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad" href="{$filename}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="longdesc.uri">
        <xsl:call-template name="longdesc.uri">
          <xsl:with-param name="mediaobject" select="ancestor::imageobject/parent::*"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="phrases" select="ancestor::mediaobject/textobject[phrase]                             |ancestor::inlinemediaobject/textobject[phrase]                             |ancestor::mediaobjectco/textobject[phrase]"/>

      <xsl:call-template name="process.image">
        <xsl:with-param name="alt">
          <xsl:apply-templates select="$phrases[not(@role) or @role!='tex'][1]"/>
        </xsl:with-param>
        <xsl:with-param name="longdesc">
          <xsl:call-template name="write.longdesc">
            <xsl:with-param name="mediaobject" select="ancestor::imageobject/parent::*"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:if test="$html.longdesc != 0 and $html.longdesc.link != 0                     and ancestor::imageobject/parent::*/textobject[not(phrase)]">
        <xsl:call-template name="longdesc.link">
          <xsl:with-param name="longdesc.uri" select="$longdesc.uri"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$html.longdesc.embed != 0 and ancestor::imageobject/parent::*/textobject[not(phrase)]">
        <div xmlns="http://www.w3.org/1999/xhtml" class="longdesc">
            <xsl:for-each select="ancestor::imageobject/parent::*/textobject[not(phrase)]">
              <xsl:apply-templates select="./*"/>
            </xsl:for-each>
        </div>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
From: xhtml/qandaset.xsl
Reason: No stinking tables
Version: 1.72.0
-->
<xsl:template name="qandaset">
  <div class="qandaset">
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates />
  </div>
</xsl:template>

<xsl:template name="process.qandaset">
  <div class="qandaset">
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates />
  </div>
</xsl:template>

<xsl:template match="qandadiv">
  <xsl:variable name="preamble" select="*[local-name(.) != 'title'                                           and local-name(.) != 'titleabbrev'                                           and local-name(.) != 'qandadiv'                                           and local-name(.) != 'qandaentry']"/>

  <xsl:if test="blockinfo/title|info/title|title">
    <div class="qandadiv">
        <xsl:apply-templates select="(blockinfo/title|info/title|title)[1]"/>
    </div>
  </xsl:if>

  <xsl:variable name="toc">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'toc'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="(contains($toc.params, 'toc') and $toc != '0') or $toc = '1'">
    <div class="toc">
        <xsl:call-template name="process.qanda.toc"/>
    </div>
  </xsl:if>
  <xsl:if test="$preamble">
    <div class="preamble">
        <xsl:apply-templates select="$preamble"/>
    </div>
  </xsl:if>
  <div>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates select="qandadiv|qandaentry"/>
  </div>
</xsl:template>

<xsl:template match="qandaentry">
  <div>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="question">
  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()] /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="label.content">
    <xsl:apply-templates select="." mode="label.markup"/>
    <xsl:if test="$deflabel = 'number' and not(label)">
      <xsl:apply-templates select="." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:variable>
  <div>
    <xsl:apply-templates select="." mode="class.attribute"/>
      <xsl:call-template name="anchor">
        <xsl:with-param name="node" select=".."/>
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <!--xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template-->
      <xsl:if test="string-length($label.content) &gt; 0">
        <div class="label">
          <xsl:copy-of select="$label.content"/>
        </div>
      </xsl:if>
    <div class="data">
      <xsl:apply-templates/>
    </div>
  </div>
</xsl:template>

<xsl:template match="answer">
  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()] /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:variable name="answer.label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:if test="string-length($answer.label) &gt; 0">
      <div class="label">
        <xsl:copy-of select="$answer.label"/>
      </div>
    </xsl:if>
     <div class="data">
       <xsl:apply-templates />
     </div>
   </div>
</xsl:template>

<!--

BUGBUG callout code blows up highlight if the span contains a newline
because it has to parse lines one by one to place the gfx

-->
<xsl:template match="perl_Alert | perl_BaseN | perl_BString | perl_Char | perl_Comment | perl_DataType | perl_DecVal | perl_Error | perl_Float | perl_Function | perl_IString | perl_Keyword | perl_Operator | perl_Others | perl_RegionMarker | perl_Reserved | perl_String | perl_Variable | perl_Warning ">
  <xsl:variable name="name">
    <xsl:value-of select="local-name(.)"/>
  </xsl:variable>
  <xsl:variable name="content">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="contains($content,'&#xA;')">
      <span><xsl:attribute name="class"><xsl:value-of select="$name"/></xsl:attribute><xsl:value-of select="substring-before($content,'&#xA;')"/></span><xsl:text>
</xsl:text>
      <span><xsl:attribute name="class"><xsl:value-of select="$name"/></xsl:attribute><xsl:value-of select="substring-after($content,'&#xA;')"/></span>
    </xsl:when>
    <xsl:otherwise>
      <span><xsl:attribute name="class"><xsl:value-of select="$name"/></xsl:attribute><xsl:value-of select="$content"/></span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="productnumber" mode="book.titlepage.recto.auto.mode">
<xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
</xsl:template>

<xsl:template match="productname" mode="titlepage.mode">
  <span>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates mode="titlepage.mode"/>
  </span>
</xsl:template>

<xsl:template match="productnumber" mode="titlepage.mode">
  <span>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates mode="titlepage.mode"/>
  </span>
</xsl:template>

<xsl:template match="productname" mode="book.titlepage.recto.auto.mode">
<xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
</xsl:template>

<xsl:template match="orgdiv" mode="titlepage.mode">
  <xsl:if test="preceding-sibling::*[1][self::orgname]">
    <xsl:text> </xsl:text>
  </xsl:if>
  <span>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates mode="titlepage.mode"/>
  </span>
</xsl:template>

<xsl:template match="orgname" mode="titlepage.mode">
  <span>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates mode="titlepage.mode"/>
  </span>
</xsl:template>

<xsl:template name="book.titlepage.recto">
  <xsl:choose>
    <xsl:when test="bookinfo/productname">
	<div class="producttitle" xsl:use-attribute-sets="book.titlepage.recto.style">
	  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/productname"/>
	  <xsl:text> </xsl:text>
	  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/productnumber"/>
	</div>
    </xsl:when>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/title"/>
    </xsl:when>
    <xsl:when test="info/title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/title"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="title"/>
    </xsl:when>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="bookinfo/subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="titlepage.mode" select="bookinfo/edition"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/author"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/othercredit"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/othercredit"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/releaseinfo"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/releaseinfo"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/copyright"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/copyright"/>
  <!--hr/-->
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/legalnotice"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/legalnotice"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/pubdate"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/pubdate"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/revision"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/revision"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/revhistory"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/revhistory"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="bookinfo/abstract"/>
  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="info/abstract"/>
</xsl:template>

<xsl:template match="legalnotice" mode="titlepage.mode">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="$generate.legalnotice.link != 0">
      <xsl:variable name="filename">
        <xsl:call-template name="make-relative-filename">
          <xsl:with-param name="base.dir" select="$base.dir"/>
	  <xsl:with-param name="base.name">
            <xsl:apply-templates mode="chunk-filename" select="."/>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="title">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:variable>

      <xsl:variable name="href">
        <xsl:apply-templates mode="chunk-filename" select="."/>
      </xsl:variable>

      <a href="{$href}"><xsl:copy-of select="$title"/></a>

      <xsl:call-template name="write.chunk">
        <xsl:with-param name="filename" select="$filename"/>
        <xsl:with-param name="quiet" select="$chunk.quietly"/>
        <xsl:with-param name="content">
        <xsl:call-template name="user.preroot"/>
          <html>
            <head>
              <xsl:call-template name="system.head.content"/>
              <xsl:call-template name="head.content"/>
              <xsl:call-template name="user.head.content"/>
            </head>
            <body>
              <xsl:call-template name="body.attributes"/>
              <div>
                <xsl:apply-templates select="." mode="class.attribute"/>
                <xsl:apply-templates mode="titlepage.mode"/>
              </div>
            </body>
          </html>
          <xsl:value-of select="$chunk.append"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="class.attribute"/>
        <a id="{$id}"/>
	<h1 class="legalnotice">
    <xsl:call-template name="gentext">
      <xsl:with-param name="key">LegalNotice</xsl:with-param>
    </xsl:call-template>
	</h1>
        <xsl:apply-templates mode="titlepage.mode"/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="chapter/title" mode="titlepage.mode" priority="2">
  <xsl:call-template name="component.title">
    <xsl:with-param name="node" select="ancestor::chapter[1]"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="section/title|section/info/title|sectioninfo/title" mode="titlepage.mode" priority="2">
  <xsl:call-template name="section.title"/>
</xsl:template>

<xsl:template match="edition" mode="titlepage.mode">
  <p>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'Edition'"/>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>
    <xsl:apply-templates mode="titlepage.mode"/>
  </p>
</xsl:template>

<xsl:template name="article.titlepage.recto">
  <xsl:choose>
    <xsl:when test="articleinfo/productname">
	<div class="producttitle" xsl:use-attribute-sets="book.titlepage.recto.style">
	  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="articleinfo/productname"/>
	  <xsl:text> </xsl:text>
	  <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="articleinfo/productnumber"/>
	</div>
    </xsl:when>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="articleinfo/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/title"/>
    </xsl:when>
    <xsl:when test="artheader/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/title"/>
    </xsl:when>
    <xsl:when test="info/title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/title"/>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="title"/>
    </xsl:when>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="articleinfo/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/subtitle"/>
    </xsl:when>
    <xsl:when test="artheader/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/subtitle"/>
    </xsl:when>
    <xsl:when test="info/subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/subtitle"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/corpauthor"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/authorgroup"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/author"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/othercredit"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/releaseinfo"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/copyright"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/legalnotice"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/pubdate"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/pubdate"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/pubdate"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revision"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/abstract"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/abstract"/>
</xsl:template>

<!--
From: xhtml/block.xsl
Reason:  make para use a div since using P makes a bunch of nested block tags output invalid XHTML
Version: 1.72.0
-->

<xsl:template name="paragraph">
  <xsl:param name="class" select="''"/>
  <xsl:param name="content"/>

  <xsl:variable name="p">
    <div class="para">
      <xsl:call-template name="dir"/>
      <xsl:if test="$class != ''">
        <xsl:apply-templates select="." mode="class.attribute">
          <xsl:with-param name="class" select="$class"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="@id or @xml:id">
        <xsl:attribute name="id">
          <xsl:value-of select="(@id|@xml:id)[1]"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
    </div>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$html.cleanup != 0">
      <xsl:call-template name="unwrap.p">
        <xsl:with-param name="p" select="$p"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$p"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
From: xhtml/block.xsl
Reason:  make para use a div since using P makes a bunch of nested block tags output invalid XHTML
Version: 1.72.0
-->
<xsl:template match="simpara">
  <!-- see also listitem/simpara in lists.xsl -->
  <div class="para">
    <xsl:if test="@role and $para.propagates.style != 0">
      <xsl:apply-templates select="." mode="class.attribute">
        <xsl:with-param name="class" select="@role"/>
      </xsl:apply-templates>
    </xsl:if>

    <xsl:call-template name="anchor"/>
    <p/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="collab" mode="titlepage.mode">
</xsl:template>

<xsl:template match="funcprototype">
  <xsl:variable name="html-style">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="ancestor::funcsynopsis//processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'funcsynopsis-style'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="style">
    <xsl:choose>
      <xsl:when test="$html-style != ''">
        <xsl:value-of select="$html-style"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$funcsynopsis.style"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<!--
  <xsl:variable name="tabular-p"
                select="$funcsynopsis.tabular.threshold &gt; 0
                        and string-length(.) &gt; $funcsynopsis.tabular.threshold"/>
-->

  <xsl:variable name="tabular-p" select="false()"/>

  <xsl:choose>
    <xsl:when test="$style = 'kr' and $tabular-p">
      <xsl:apply-templates select="." mode="kr-tabular"/>
    </xsl:when>
    <xsl:when test="$style = 'kr'">
      <xsl:apply-templates select="." mode="kr-nontabular"/>
    </xsl:when>
    <xsl:when test="$style = 'ansi' and $tabular-p">
      <xsl:apply-templates select="." mode="ansi-tabular"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="ansi-nontabular"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="process.image">
  <!-- When this template is called, the current node should be  -->
  <!-- a graphic, inlinegraphic, imagedata, or videodata. All    -->
  <!-- those elements have the same set of attributes, so we can -->
  <!-- handle them all in one place.                             -->
  <xsl:param name="tag" select="'img'"/>
  <xsl:param name="alt"/>
  <xsl:param name="longdesc"/>

  <!-- The HTML img element only supports the notion of content-area
       scaling; it doesn't support the distinction between a
       content-area and a viewport-area, so we have to make some
       compromises.

       1. If only the content-area is specified, everything is fine.
          (If you ask for a three inch image, that's what you'll get.)

       2. If only the viewport-area is provided:
          - If scalefit=1, treat it as both the content-area and
            the viewport-area. (If you ask for an image in a five inch
            area, we'll make the image five inches to fill that area.)
          - If scalefit=0, ignore the viewport-area specification.

          Note: this is not quite the right semantic and has the additional
          problem that it can result in anamorphic scaling, which scalefit
          should never cause.

       3. If both the content-area and the viewport-area is specified
          on a graphic element, ignore the viewport-area.
          (If you ask for a three inch image in a five inch area, we'll assume
           it's better to give you a three inch image in an unspecified area
           than a five inch image in a five inch area.

       Relative units also cause problems. As a general rule, the stylesheets
       are operating too early and too loosely coupled with the rendering engine
       to know things like the current font size or the actual dimensions of
       an image. Therefore:

       1. We use a fixed size for pixels, $pixels.per.inch

       2. We use a fixed size for "em"s, $points.per.em

       Percentages are problematic. In the following discussion, we speak
       of width and contentwidth, but the same issues apply to depth and
       contentdepth

       1. A width of 50% means "half of the available space for the image."
          That's fine. But note that in HTML, this is a dynamic property and
          the image size will vary if the browser window is resized.

       2. A contentwidth of 50% means "half of the actual image width". But
          the stylesheets have no way to assess the image's actual size. Treating
          this as a width of 50% is one possibility, but it produces behavior
          (dynamic scaling) that seems entirely out of character with the
          meaning.

          Instead, the stylesheets define a $nominal.image.width
          and convert percentages to actual values based on that nominal size.

       Scale can be problematic. Scale applies to the contentwidth, so
       a scale of 50 when a contentwidth is not specified is analagous to a
       width of 50%. (If a contentwidth is specified, the scaling factor can
       be applied to that value and no problem exists.)

       If scale is specified but contentwidth is not supplied, the
       nominal.image.width is used to calculate a base size
       for scaling.

       Warning: as a consequence of these decisions, unless the aspect ratio
       of your image happens to be exactly the same as (nominal width / nominal height),
       specifying contentwidth="50%" and contentdepth="50%" is NOT going to
       scale the way you expect (or really, the way it should).

       Don't do that. In fact, a percentage value is not recommended for content
       size at all. Use scale instead.

       Finally, align and valign are troublesome. Horizontal alignment is now
       supported by wrapping the image in a <div align="{@align}"> (in block
       contexts!). I can't think of anything (practical) to do about vertical
       alignment.
  -->

  <xsl:variable name="width-units">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="@width">
        <xsl:call-template name="length-units">
          <xsl:with-param name="length" select="@width"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(@depth) and $default.image.width != ''">
        <xsl:call-template name="length-units">
          <xsl:with-param name="length" select="$default.image.width"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="@width">
        <xsl:choose>
          <xsl:when test="$width-units = '%'">
            <xsl:value-of select="@width"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@width"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="not(@depth) and $default.image.width != ''">
        <xsl:value-of select="$default.image.width"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scalefit">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="@contentwidth or @contentdepth">0</xsl:when>
      <xsl:when test="@scale">0</xsl:when>
      <xsl:when test="@scalefit"><xsl:value-of select="@scalefit"/></xsl:when>
      <xsl:when test="$width != '' or @depth">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scale">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">1.0</xsl:when>
      <xsl:when test="@contentwidth or @contentdepth">1.0</xsl:when>
      <xsl:when test="@scale">
        <xsl:value-of select="@scale div 100.0"/>
      </xsl:when>
      <xsl:otherwise>1.0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'graphic'                       or local-name(.) = 'inlinegraphic'">
        <!-- handle legacy graphic and inlinegraphic by new template --> 
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- imagedata, videodata, audiodata -->
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="output_filename">
    <xsl:choose>
      <xsl:when test="$embedtoc != 0 and contains($filename, 'Common_Content')">
        <xsl:value-of select=" concat($tocpath, '/../', $brand, '/',$langpath)"/>
        <xsl:value-of select="substring-after($filename, 'Common_Content')"/>
      </xsl:when>
      <xsl:when test="@entityref">
        <xsl:value-of select="$filename"/>
      </xsl:when>
      <!--
        Moved test for $keep.relative.image.uris to template below:
            <xsl:template match="@fileref">
      -->
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="img.src.path.pi">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="../processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'img.src.path'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="filename.for.graphicsize">
    <xsl:choose>
      <xsl:when test="$img.src.path.pi != ''">
        <xsl:value-of select="concat($img.src.path.pi, $filename)"/>
      </xsl:when>
      <xsl:when test="$img.src.path != '' and                       $graphicsize.use.img.src.path != 0 and                       $tag = 'img' and                       not(starts-with($filename, '/')) and                       not(contains($filename, '://'))">
        <xsl:value-of select="concat($img.src.path, $filename)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="realintrinsicwidth">
    <!-- This funny compound test works around a bug in XSLTC -->
    <xsl:choose>
      <xsl:when test="$use.extensions != 0 and $graphicsize.extension != 0">
        <xsl:choose>
          <xsl:when test="function-available('simg:getWidth')">
            <xsl:value-of select="simg:getWidth(simg:new($filename.for.graphicsize),                                                 $nominal.image.width)"/>
          </xsl:when>
          <xsl:when test="function-available('ximg:getWidth')">
            <xsl:value-of select="ximg:getWidth(ximg:new($filename.for.graphicsize),                                                 $nominal.image.width)"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="intrinsicwidth">
    <xsl:choose>
      <xsl:when test="$realintrinsicwidth = 0">
       <xsl:value-of select="$nominal.image.width"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$realintrinsicwidth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="intrinsicdepth">
    <!-- This funny compound test works around a bug in XSLTC -->
    <xsl:choose>
      <xsl:when test="$use.extensions != 0 and $graphicsize.extension != 0">
        <xsl:choose>
          <xsl:when test="function-available('simg:getDepth')">
            <xsl:value-of select="simg:getDepth(simg:new($filename.for.graphicsize),                                                 $nominal.image.depth)"/>
          </xsl:when>
          <xsl:when test="function-available('ximg:getDepth')">
            <xsl:value-of select="ximg:getDepth(ximg:new($filename.for.graphicsize),                                                 $nominal.image.depth)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nominal.image.depth"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nominal.image.depth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="contentwidth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="@contentwidth">
        <xsl:variable name="units">
          <xsl:call-template name="length-units">
            <xsl:with-param name="length" select="@contentwidth"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$units = '%'">
            <xsl:variable name="cmagnitude">
              <xsl:call-template name="length-magnitude">
                <xsl:with-param name="length" select="@contentwidth"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$intrinsicwidth * $cmagnitude div 100.0"/>
            <xsl:text>px</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@contentwidth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$intrinsicwidth"/>
        <xsl:text>px</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scaled.contentwidth">
    <xsl:if test="$contentwidth != ''">
      <xsl:variable name="cwidth.in.points">
        <xsl:call-template name="length-in-points">
          <xsl:with-param name="length" select="$contentwidth"/>
          <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
          <xsl:with-param name="em.size" select="$points.per.em"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$cwidth.in.points div 72.0 * $pixels.per.inch * $scale"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="html.width">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="$width-units = '%'">
        <xsl:value-of select="$width"/>
      </xsl:when>
      <xsl:when test="$width != ''">
        <xsl:variable name="width.in.points">
          <xsl:call-template name="length-in-points">
            <xsl:with-param name="length" select="$width"/>
            <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
            <xsl:with-param name="em.size" select="$points.per.em"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="round($width.in.points div 72.0 * $pixels.per.inch)"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="contentdepth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="@contentdepth">
        <xsl:variable name="units">
          <xsl:call-template name="length-units">
            <xsl:with-param name="length" select="@contentdepth"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$units = '%'">
            <xsl:variable name="cmagnitude">
              <xsl:call-template name="length-magnitude">
                <xsl:with-param name="length" select="@contentdepth"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$intrinsicdepth * $cmagnitude div 100.0"/>
            <xsl:text>px</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@contentdepth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$intrinsicdepth"/>
        <xsl:text>px</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scaled.contentdepth">
    <xsl:if test="$contentdepth != ''">
      <xsl:variable name="cdepth.in.points">
        <xsl:call-template name="length-in-points">
          <xsl:with-param name="length" select="$contentdepth"/>
          <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
          <xsl:with-param name="em.size" select="$points.per.em"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$cdepth.in.points div 72.0 * $pixels.per.inch * $scale"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="depth-units">
    <xsl:if test="@depth">
      <xsl:call-template name="length-units">
        <xsl:with-param name="length" select="@depth"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="depth">
    <xsl:if test="@depth">
      <xsl:choose>
        <xsl:when test="$depth-units = '%'">
          <xsl:value-of select="@depth"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="length-spec">
            <xsl:with-param name="length" select="@depth"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="html.depth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"/>
      <xsl:when test="$depth-units = '%'">
        <xsl:value-of select="$depth"/>
      </xsl:when>
      <xsl:when test="@depth and @depth != ''">
        <xsl:variable name="depth.in.points">
          <xsl:call-template name="length-in-points">
            <xsl:with-param name="length" select="$depth"/>
            <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
            <xsl:with-param name="em.size" select="$points.per.em"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="round($depth.in.points div 72.0 * $pixels.per.inch)"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="viewport">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="local-name(.) = 'inlinegraphic'                       or ancestor::inlinemediaobject                       or ancestor::inlineequation">0</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$make.graphic.viewport"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<!--
  <xsl:message>=====================================
scale: <xsl:value-of select="$scale"/>, <xsl:value-of select="$scalefit"/>
@contentwidth <xsl:value-of select="@contentwidth"/>
$contentwidth <xsl:value-of select="$contentwidth"/>
scaled.contentwidth: <xsl:value-of select="$scaled.contentwidth"/>
@width: <xsl:value-of select="@width"/>
width: <xsl:value-of select="$width"/>
html.width: <xsl:value-of select="$html.width"/>
@contentdepth <xsl:value-of select="@contentdepth"/>
$contentdepth <xsl:value-of select="$contentdepth"/>
scaled.contentdepth: <xsl:value-of select="$scaled.contentdepth"/>
@depth: <xsl:value-of select="@depth"/>
depth: <xsl:value-of select="$depth"/>
html.depth: <xsl:value-of select="$html.depth"/>
align: <xsl:value-of select="@align"/>
valign: <xsl:value-of select="@valign"/></xsl:message>
-->

  <xsl:variable name="scaled" select="@width|@depth|@contentwidth|@contentdepth                         |@scale|@scalefit"/>

  <xsl:variable name="img">
    <xsl:choose>
      <xsl:when test="@format = 'SVG' and $svg.object != 0">
        <object data="{$output_filename}" type="image/svg+xml">
          <xsl:call-template name="process.image.attributes">
            <!--xsl:with-param name="alt" select="$alt"/ there's no alt here-->
            <xsl:with-param name="html.depth" select="$html.depth"/>
            <xsl:with-param name="html.width" select="$html.width"/>
            <xsl:with-param name="longdesc" select="$longdesc"/>
            <xsl:with-param name="scale" select="$scale"/>
            <xsl:with-param name="scalefit" select="$scalefit"/>
            <xsl:with-param name="scaled.contentdepth" select="$scaled.contentdepth"/>
            <xsl:with-param name="scaled.contentwidth" select="$scaled.contentwidth"/>
            <xsl:with-param name="viewport" select="$viewport"/>
          </xsl:call-template>
          <xsl:if test="@align">
            <xsl:attribute name="align">
                <xsl:choose>
                  <xsl:when test="@align = 'center'">middle</xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@align"/>
                  </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$use.embed.for.svg != 0">
            <embed src="{$output_filename}" type="image/svg+xml">
              <xsl:call-template name="process.image.attributes">
                <!--xsl:with-param name="alt" select="$alt"/ there's no alt here -->
                <xsl:with-param name="html.depth" select="$html.depth"/>
                <xsl:with-param name="html.width" select="$html.width"/>
                <xsl:with-param name="longdesc" select="$longdesc"/>
                <xsl:with-param name="scale" select="$scale"/>
                <xsl:with-param name="scalefit" select="$scalefit"/>
                <xsl:with-param name="scaled.contentdepth" select="$scaled.contentdepth"/>
                <xsl:with-param name="scaled.contentwidth" select="$scaled.contentwidth"/>
                <xsl:with-param name="viewport" select="$viewport"/>
              </xsl:call-template>
            </embed>
          </xsl:if>
<!-- Added this line to fix object breaking IE7 BZ #486501 -->
          <xsl:text> </xsl:text><xsl:value-of select="$alt"/>
        </object>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$tag}" namespace="http://www.w3.org/1999/xhtml">
         <xsl:if test="$tag = 'img' and ../../self::imageobjectco">
           <xsl:variable name="mapname">
             <xsl:call-template name="object.id">
               <xsl:with-param name="object" select="../../areaspec"/>
             </xsl:call-template>
           </xsl:variable>
           <xsl:choose>
             <xsl:when test="$scaled">
              <!-- It might be possible to handle some scaling; needs -->
              <!-- more investigation -->
              <xsl:message>
                <xsl:text>Warning: imagemaps not supported </xsl:text>
                <xsl:text>on scaled images</xsl:text>
              </xsl:message>
             </xsl:when>
             <xsl:otherwise>
              <xsl:attribute name="border">0</xsl:attribute>
              <xsl:attribute name="usemap">
                <xsl:value-of select="concat('#', $mapname)"/>
              </xsl:attribute>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:if>

          <xsl:attribute name="src">
             <!-- PRESSGANG - Display a placeholder if $placeholderImg = 1 -->
              <xsl:choose>
              <xsl:when test="$placeholderImg != 1">
                <xsl:choose>
                 <xsl:when test="$img.src.path != '' and                            $tag = 'img' and                              not(starts-with($output_filename, '/')) and                            not(contains($output_filename, '://'))">
                   <xsl:value-of select="$img.src.path"/>
                 </xsl:when>
                </xsl:choose>
                <xsl:value-of select="$output_filename"/>
                 </xsl:when>
              <xsl:otherwise>
              data:;base64,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
              </xsl:otherwise>
      </xsl:choose>
          </xsl:attribute>

          <xsl:if test="@align">
            <xsl:attribute name="align">
              <xsl:choose>
                <xsl:when test="@align = 'center'">middle</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@align"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>

          <xsl:call-template name="process.image.attributes">
            <xsl:with-param name="alt">
              <xsl:choose>
                <xsl:when test="$alt != ''">
                  <xsl:copy-of select="$alt"/>
                </xsl:when>
                <xsl:when test="ancestor::figure">
                  <xsl:value-of select="normalize-space(ancestor::figure/title)"/>
                </xsl:when>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="html.depth" select="$html.depth"/>
            <xsl:with-param name="html.width" select="$html.width"/>
            <xsl:with-param name="longdesc" select="$longdesc"/>
            <xsl:with-param name="scale" select="$scale"/>
            <xsl:with-param name="scalefit" select="$scalefit"/>
            <xsl:with-param name="scaled.contentdepth" select="$scaled.contentdepth"/>
            <xsl:with-param name="scaled.contentwidth" select="$scaled.contentwidth"/>
            <xsl:with-param name="viewport" select="$viewport"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bgcolor">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="../processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'background-color'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="use.viewport" select="$viewport != 0                         and ($html.width != ''                              or ($html.depth != '' and $depth-units != '%')                              or $bgcolor != ''                              or @valign)"/>

  <xsl:choose>
    <xsl:when test="$use.viewport">
      <table border="0" summary="manufactured viewport for HTML img" cellspacing="0" cellpadding="0">
        <xsl:if test="$html.width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="$html.width"/>
          </xsl:attribute>
        </xsl:if>
        <tr>
          <xsl:if test="$html.depth != '' and $depth-units != '%'">
            <!-- don't do this for percentages because browsers get confused -->
            <xsl:choose>
              <xsl:when test="$css.decoration != 0">
                <xsl:attribute name="style">
                  <xsl:text>height: </xsl:text>
                  <xsl:value-of select="$html.depth"/>
                  <xsl:text>px</xsl:text>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="height">
                  <xsl:value-of select="$html.depth"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <td>
            <xsl:if test="$bgcolor != ''">
              <xsl:choose>
                <xsl:when test="$css.decoration != 0">
                  <xsl:attribute name="style">
                    <xsl:text>background-color: </xsl:text>
                    <xsl:value-of select="$bgcolor"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="bgcolor">
                    <xsl:value-of select="$bgcolor"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:if test="@align">
              <xsl:attribute name="align">
                <xsl:value-of select="@align"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
              <xsl:attribute name="valign">
                <xsl:value-of select="@valign"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$img"/>
          </td>
        </tr>
      </table>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$img"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="$tag = 'img' and ../../self::imageobjectco and not($scaled)">
    <xsl:variable name="mapname">
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="../../areaspec"/>
      </xsl:call-template>
    </xsl:variable>

    <map name="{$mapname}">
      <xsl:for-each select="../../areaspec//area">
        <xsl:variable name="units">
          <xsl:choose>
            <xsl:when test="@units = 'other' and @otherunits">
              <xsl:value-of select="@otherunits"/>
            </xsl:when>
            <xsl:when test="@units">
              <xsl:value-of select="@units"/>
            </xsl:when>
            <!-- areaspec|areaset/area -->
            <xsl:when test="../@units = 'other' and ../@otherunits">
              <xsl:value-of select="../@otherunits"/>
            </xsl:when>
            <xsl:when test="../@units">
              <xsl:value-of select="../@units"/>
            </xsl:when>
            <!-- areaspec/areaset/area -->
            <xsl:when test="../../@units = 'other' and ../../@otherunits">
              <xsl:value-of select="../@otherunits"/>
            </xsl:when>
            <xsl:when test="../../@units">
              <xsl:value-of select="../../@units"/>
            </xsl:when>
            <xsl:otherwise>calspair</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
 
        <xsl:choose>
          <xsl:when test="$units = 'calspair' or                           $units = 'imagemap'">
            <xsl:variable name="coords" select="normalize-space(@coords)"/>

            <area shape="rect">
              <xsl:variable name="linkends">
                <xsl:choose>
                  <xsl:when test="@linkends">
                    <xsl:value-of select="normalize-space(@linkends)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="normalize-space(../@linkends)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
 
              <xsl:variable name="href">
                <xsl:choose>
                  <xsl:when test="@xlink:href">
                    <xsl:value-of select="@xlink:href"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="../@xlink:href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
 
              <xsl:choose>
                <xsl:when test="$linkends != ''">
                  <xsl:variable name="linkend">
                    <xsl:choose>
                      <xsl:when test="contains($linkends, ' ')">
                        <xsl:value-of select="substring-before($linkends, ' ')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$linkends"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="target" select="key('id', $linkend)[1]"/>
                 
                  <xsl:if test="$target">
                    <xsl:attribute name="href">
                      <xsl:call-template name="href.target">
                        <xsl:with-param name="object" select="$target"/>
                      </xsl:call-template>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="$href != ''">
                  <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                  </xsl:attribute>
                </xsl:when>
              </xsl:choose>
 
              <xsl:if test="alt">
                <xsl:attribute name="alt">
                  <xsl:value-of select="alt[1]"/>
                </xsl:attribute>
              </xsl:if>
 
              <xsl:attribute name="coords">
                <xsl:choose>
                  <xsl:when test="$units = 'calspair'">

                    <xsl:variable name="p1" select="substring-before($coords, ' ')"/>
                    <xsl:variable name="p2" select="substring-after($coords, ' ')"/>
         
                    <xsl:variable name="x1" select="substring-before($p1,',')"/>
                    <xsl:variable name="y1" select="substring-after($p1,',')"/>
                    <xsl:variable name="x2" select="substring-before($p2,',')"/>
                    <xsl:variable name="y2" select="substring-after($p2,',')"/>
         
                    <xsl:variable name="x1p" select="$x1 div 100.0"/>
                    <xsl:variable name="y1p" select="$y1 div 100.0"/>
                    <xsl:variable name="x2p" select="$x2 div 100.0"/>
                    <xsl:variable name="y2p" select="$y2 div 100.0"/>
         
         <!--
                    <xsl:message>
                      <xsl:text>units: </xsl:text>
                      <xsl:value-of select="$units"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="$x1p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$y1p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$x2p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$y2p"/><xsl:text>, </xsl:text>
                    </xsl:message>
         
                    <xsl:message>
                      <xsl:text>      </xsl:text>
                      <xsl:value-of select="$intrinsicwidth"/>
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="$intrinsicdepth"/>
                    </xsl:message>
         
                    <xsl:message>
                      <xsl:text>      </xsl:text>
                      <xsl:value-of select="$units"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of 
                            select="round($x1p * $intrinsicwidth div 100.0)"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($intrinsicdepth
                                       - ($y2p * $intrinsicdepth div 100.0))"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($x2p * 
                                            $intrinsicwidth div 100.0)"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($intrinsicdepth
                                       - ($y1p * $intrinsicdepth div 100.0))"/>
                    </xsl:message>
         -->
                    <xsl:value-of select="round($x1p * $intrinsicwidth div 100.0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="round($intrinsicdepth                                         - ($y2p * $intrinsicdepth div 100.0))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="round($x2p * $intrinsicwidth div 100.0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="round($intrinsicdepth                                       - ($y1p * $intrinsicdepth div 100.0))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$coords"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </area>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Warning: only calspair or </xsl:text>
              <xsl:text>otherunits='imagemap' supported </xsl:text>
              <xsl:text>in imageobjectco</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </map>
  </xsl:if>
</xsl:template>

<xsl:template match="tgroup" name="tgroup">
  <xsl:if test="not(@cols) or @cols = '' or string(number(@cols)) = 'NaN'">
    <xsl:message terminate="yes">
      <xsl:text>Error: CALS tables must specify the number of columns.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:variable name="summary">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'table-summary'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="cellspacing">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'cellspacing'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="cellpadding">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="processing-instruction('dbhtml')[1]"/>
      <xsl:with-param name="attribute" select="'cellpadding'"/>
    </xsl:call-template>
  </xsl:variable>

  <table>
    <xsl:choose>
      <!-- If there's a textobject/phrase for the table summary, use it -->
      <xsl:when test="../textobject/phrase">
        <xsl:attribute name="summary">
          <xsl:value-of select="../textobject/phrase"/>
        </xsl:attribute>
      </xsl:when>

      <!-- If there's a <?dbhtml table-summary="foo"?> PI, use it for
           the HTML table summary attribute -->
      <xsl:when test="$summary != ''">
        <xsl:attribute name="summary">
          <xsl:value-of select="$summary"/>
        </xsl:attribute>
      </xsl:when>

      <!-- Otherwise, if there's a title, use that -->
      <xsl:when test="../title">
        <xsl:attribute name="summary">
          <xsl:value-of select="string(../title)"/>
        </xsl:attribute>
      </xsl:when>

      <!-- Otherwise, forget the whole idea -->
      <xsl:otherwise><!-- nevermind --></xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$cellspacing != '' or $html.cellspacing != ''">
      <xsl:attribute name="cellspacing">
        <xsl:choose>
          <xsl:when test="$cellspacing != ''">
            <xsl:value-of select="$cellspacing"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$html.cellspacing"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="$cellpadding != '' or $html.cellpadding != ''">
      <xsl:attribute name="cellpadding">
        <xsl:choose>
          <xsl:when test="$cellpadding != ''">
            <xsl:value-of select="$cellpadding"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$html.cellpadding"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="../@pgwide=1 or local-name(.) = 'entrytbl'">
      <xsl:attribute name="width">100%</xsl:attribute>
    </xsl:if>
<!--
snip border rubbish. BZ #875967
-->
    <xsl:variable name="colgroup">
      <colgroup>
        <xsl:call-template name="generate.colgroup">
          <xsl:with-param name="cols" select="@cols"/>
        </xsl:call-template>
      </colgroup>
    </xsl:variable>

    <xsl:variable name="explicit.table.width">
      <xsl:call-template name="dbhtml-attribute">
        <xsl:with-param name="pis" select="../processing-instruction('dbhtml')[1]"/>
        <xsl:with-param name="attribute" select="'table-width'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="table.width">
      <xsl:choose>
        <xsl:when test="$explicit.table.width != ''">
          <xsl:value-of select="$explicit.table.width"/>
        </xsl:when>
        <xsl:when test="$default.table.width = ''">
          <xsl:text>100%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default.table.width"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$default.table.width != ''                   or $explicit.table.width != ''">
      <xsl:attribute name="width">
        <xsl:choose>
          <xsl:when test="contains($table.width, '%')">
            <xsl:value-of select="$table.width"/>
          </xsl:when>
          <xsl:when test="$use.extensions != 0                           and $tablecolumns.extension != 0">
            <xsl:choose>
              <xsl:when test="function-available('stbl:convertLength')">
                <xsl:value-of select="stbl:convertLength($table.width)"/>
              </xsl:when>
              <xsl:when test="function-available('xtbl:convertLength')">
                <xsl:value-of select="xtbl:convertLength($table.width)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">
                  <xsl:text>No convertLength function available.</xsl:text>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$table.width"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$use.extensions != 0                       and $tablecolumns.extension != 0">
        <xsl:choose>
          <xsl:when test="function-available('stbl:adjustColumnWidths')">
            <xsl:copy-of select="stbl:adjustColumnWidths($colgroup)"/>
          </xsl:when>
          <xsl:when test="function-available('xtbl:adjustColumnWidths')">
            <xsl:copy-of select="xtbl:adjustColumnWidths($colgroup)"/>
          </xsl:when>
          <xsl:when test="function-available('ptbl:adjustColumnWidths')">
            <xsl:copy-of select="ptbl:adjustColumnWidths($colgroup)"/>
          </xsl:when>
        <xsl:when test="function-available('perl:adjustColumnWidths')">
          <xsl:copy-of select="perl:adjustColumnWidths($table.width, $colgroup)"/>
        </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>No adjustColumnWidths function available.</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$colgroup"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="thead"/>
    <xsl:apply-templates select="tfoot"/>
    <xsl:apply-templates select="tbody"/>

    <xsl:if test=".//footnote">
      <tbody class="footnotes">
        <tr>
          <td colspan="{@cols}">
            <xsl:apply-templates select=".//footnote" mode="table.footnote.mode"/>
          </td>
        </tr>
      </tbody>
    </xsl:if>
  </table>
</xsl:template>

<xsl:template match="programlistingco|screenco">
  <xsl:variable name="verbatim" select="programlisting|screen"/>

  <xsl:choose>
    <xsl:when test="$use.extensions != '0' and $callouts.extension != '0'">
      <xsl:variable name="rtf">
        <xsl:apply-templates select="$verbatim">
          <xsl:with-param name="suppress-numbers" select="'1'"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:variable name="rtf-with-callouts">
        <xsl:choose>
          <xsl:when test="function-available('sverb:insertCallouts')">
            <xsl:copy-of select="sverb:insertCallouts(areaspec,$rtf)"/>
          </xsl:when>
          <xsl:when test="function-available('xverb:insertCallouts')">
            <xsl:copy-of select="xverb:insertCallouts(areaspec,$rtf)"/>
          </xsl:when>
          <xsl:when test="function-available('perl:insertCallouts')">
            <xsl:copy-of select="perl:insertCallouts(areaspec,exsl:node-set($rtf))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>No insertCallouts function is available.</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$verbatim/@linenumbering = 'numbered'                         and $linenumbering.extension != '0'">
          <div>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:call-template name="number.rtf.lines">
              <xsl:with-param name="rtf" select="$rtf-with-callouts"/>
              <xsl:with-param name="pi.context" select="programlisting|screen"/>
            </xsl:call-template>
            <xsl:apply-templates select="calloutlist"/>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:copy-of select="$rtf-with-callouts"/>
            <xsl:apply-templates select="calloutlist"/>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="common.html.attributes"/>
        <xsl:apply-templates/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="co" name="co">
  <!-- Support a single linkend in HTML -->
  <xsl:variable name="targets" select="key('id', @linkends)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:choose>
    <xsl:when test="$target">
      <a>
        <xsl:apply-templates select="." mode="common.html.attributes"/>
        <xsl:if test="@id or @xml:id">
          <xsl:attribute name="id">
            <xsl:value-of select="(@id|@xml:id)[1]"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$target"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:apply-templates select="." mode="callout-bug"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="callout-bug"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="co" mode="callout-bug">
  <xsl:call-template name="callout-bug">
    <xsl:with-param name="conum">
      <xsl:number count="co" level="any" from="programlisting|screen|literallayout|synopsis" format="1"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="callout-bug">
  <xsl:param name="conum" select="1"/>

  <xsl:choose>
    <xsl:when test="$callout.graphics != 0                     and $conum &lt;= $callout.graphics.number.limit">
      <img class="callout" src="{$callout.graphics.path}{$conum}{$callout.graphics.extension}" alt="{$conum}" border="0">
        <xsl:if test="@id or @xml:id">
          <xsl:attribute name="id">
            <xsl:value-of select="(@id|@xml:id)[1]"/>
          </xsl:attribute>
        </xsl:if>
      </img>
    </xsl:when>
    <xsl:when test="$callout.unicode != 0                     and $conum &lt;= $callout.unicode.number.limit">
      <xsl:choose>
        <xsl:when test="$callout.unicode.start.character = 10102">
          <xsl:choose>
            <xsl:when test="$conum = 1">&#10102;</xsl:when>
            <xsl:when test="$conum = 2">&#10103;</xsl:when>
            <xsl:when test="$conum = 3">&#10104;</xsl:when>
            <xsl:when test="$conum = 4">&#10105;</xsl:when>
            <xsl:when test="$conum = 5">&#10106;</xsl:when>
            <xsl:when test="$conum = 6">&#10107;</xsl:when>
            <xsl:when test="$conum = 7">&#10108;</xsl:when>
            <xsl:when test="$conum = 8">&#10109;</xsl:when>
            <xsl:when test="$conum = 9">&#10110;</xsl:when>
            <xsl:when test="$conum = 10">&#10111;</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Don't know how to generate Unicode callouts </xsl:text>
            <xsl:text>when $callout.unicode.start.character is </xsl:text>
            <xsl:value-of select="$callout.unicode.start.character"/>
          </xsl:message>
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$conum"/>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$conum"/>
      <xsl:text>)</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="number.rtf.lines">
  <xsl:param name="rtf" select="''"/>
  <xsl:param name="pi.context" select="."/>

  <!-- Save the global values -->
  <xsl:variable name="global.linenumbering.everyNth" select="$linenumbering.everyNth"/>

  <xsl:variable name="global.linenumbering.separator" select="$linenumbering.separator"/>

  <xsl:variable name="global.linenumbering.width" select="$linenumbering.width"/>

  <!-- Extract the <?dbhtml linenumbering.*?> PI values -->
  <xsl:variable name="pi.linenumbering.everyNth">
    <xsl:call-template name="pi.dbhtml_linenumbering.everyNth">
      <xsl:with-param name="node" select="$pi.context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="pi.linenumbering.separator">
    <xsl:call-template name="pi.dbhtml_linenumbering.separator">
      <xsl:with-param name="node" select="$pi.context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="pi.linenumbering.width">
    <xsl:call-template name="pi.dbhtml_linenumbering.width">
      <xsl:with-param name="node" select="$pi.context"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Construct the 'in-context' values -->
  <xsl:variable name="linenumbering.everyNth">
    <xsl:choose>
      <xsl:when test="$pi.linenumbering.everyNth != ''">
        <xsl:value-of select="$pi.linenumbering.everyNth"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$global.linenumbering.everyNth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="linenumbering.separator">
    <xsl:choose>
      <xsl:when test="$pi.linenumbering.separator != ''">
        <xsl:value-of select="$pi.linenumbering.separator"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$global.linenumbering.separator"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="linenumbering.width">
    <xsl:choose>
      <xsl:when test="$pi.linenumbering.width != ''">
        <xsl:value-of select="$pi.linenumbering.width"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$global.linenumbering.width"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="linenumbering.startinglinenumber">
    <xsl:choose>
      <xsl:when test="$pi.context/@startinglinenumber">
        <xsl:value-of select="$pi.context/@startinglinenumber"/>
      </xsl:when>
      <xsl:when test="$pi.context/@continuation='continues'">
        <xsl:variable name="lastLine">
          <xsl:choose>
            <xsl:when test="$pi.context/self::programlisting">
              <xsl:call-template name="lastLineNumber">
                <xsl:with-param name="listings" select="preceding::programlisting[@linenumbering='numbered']"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pi.context/self::screen">
              <xsl:call-template name="lastLineNumber">
                <xsl:with-param name="listings" select="preceding::screen[@linenumbering='numbered']"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pi.context/self::literallayout">
              <xsl:call-template name="lastLineNumber">
                <xsl:with-param name="listings" select="preceding::literallayout[@linenumbering='numbered']"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pi.context/self::address">
              <xsl:call-template name="lastLineNumber">
                <xsl:with-param name="listings" select="preceding::address[@linenumbering='numbered']"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pi.context/self::synopsis">
              <xsl:call-template name="lastLineNumber">
                <xsl:with-param name="listings" select="preceding::synopsis[@linenumbering='numbered']"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>Unexpected verbatim environment: </xsl:text>
                <xsl:value-of select="local-name($pi.context)"/>
              </xsl:message>
              <xsl:value-of select="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$lastLine + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="function-available('sverb:numberLines')">
      <xsl:copy-of select="sverb:numberLines($rtf)"/>
    </xsl:when>
    <xsl:when test="function-available('xverb:numberLines')">
      <xsl:copy-of select="xverb:numberLines($rtf)"/>
    </xsl:when>
    <xsl:when test="function-available('perl:numberLines')">
      <xsl:copy-of select="perl:numberLines($linenumbering.startinglinenumber, $rtf)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes">
        <xsl:text>No numberLines function available.</xsl:text>
      </xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ONLY add title attribute if there is an alt text -->
<!-- Generate a title attribute for the context node -->
<xsl:template match="*" mode="html.title.attribute">
  <xsl:variable name="is.title">
    <xsl:call-template name="gentext.template.exists">
      <xsl:with-param name="context" select="'title'"/>
      <xsl:with-param name="name" select="local-name(.)"/>
      <xsl:with-param name="lang">
        <xsl:call-template name="l10n.language"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="is.title-numbered">
    <xsl:call-template name="gentext.template.exists">
      <xsl:with-param name="context" select="'title-numbered'"/>
      <xsl:with-param name="name" select="local-name(.)"/>
      <xsl:with-param name="lang">
        <xsl:call-template name="l10n.language"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="is.title-unnumbered">
    <xsl:call-template name="gentext.template.exists">
      <xsl:with-param name="context" select="'title-unnumbered'"/>
      <xsl:with-param name="name" select="local-name(.)"/>
      <xsl:with-param name="lang">
        <xsl:call-template name="l10n.language"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="has.title.markup">
    <xsl:apply-templates select="." mode="title.markup">
      <xsl:with-param name="verbose" select="0"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="gentext.title">
    <xsl:if test="$has.title.markup != '???TITLE???' and                   ($is.title != 0 or                   $is.title-numbered != 0 or                   $is.title-unnumbered != 0)">
      <xsl:apply-templates select="." mode="object.title.markup.textonly"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <!--xsl:when test="string-length($gentext.title) != 0">
      <xsl:attribute name="title">
        <xsl:value-of select="$gentext.title"/>
      </xsl:attribute>
    </xsl:when-->
    <!-- Fall back to alt if available -->
    <xsl:when test="alt">
      <xsl:attribute name="title">
        <xsl:value-of select="normalize-space(alt)"/>
      </xsl:attribute>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="book.titlepage.separator">
</xsl:template>

<xsl:template name="reference.titlepage.separator">
</xsl:template>

<xsl:template name="article.titlepage.separator">
</xsl:template>

<xsl:template name="set.titlepage.separator">
</xsl:template>

<xsl:template match="footnote">
  <xsl:variable name="href">
    <xsl:text>#ftn.</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
  </xsl:variable>

      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
  <a href="{$href}">
    <xsl:apply-templates select="." mode="class.attribute"/>
    <sup>
      <xsl:apply-templates select="." mode="class.attribute"/>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
<!-- MOVED UP BZ #
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
-->
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="." mode="footnote.number"/>
      <xsl:text>]</xsl:text>
    </sup>
  </a>
</xsl:template>

</xsl:stylesheet>
