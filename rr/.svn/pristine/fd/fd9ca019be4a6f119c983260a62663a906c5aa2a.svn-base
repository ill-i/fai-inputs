<?xml version="1.0" encoding="UTF-8"?>

<!-- a stylesheet turning VOResource into the eudat-core
metadata schema

This is used here as an alternative to our oai_datacite hack.
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ri="http://www.ivoa.net/xml/RegistryInterface/v1.0"
    xmlns:vr="http://www.ivoa.net/xml/VOResource/v1.0"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:eudc="http://schema.eudat.eu/schema/kernel-1"
    xmlns:dachs="urn:dachs"
    version="1.0">

    <!-- ############################################## Global behaviour -->

    <xsl:output method="xml"/>

    <!-- Don't spill the content of unknown elements. -->
    <xsl:template match="text()"/>

    <xsl:template match="ri:Resource">
      <eudc:resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://schema.eudat.eu/schema/kernel-1
          http://docs.g-vo.org/schemata/eudat-core.xsd">
        <eudc:community>IVOA</eudc:community>
        <eudc:titles>
          <xsl:apply-templates select="title"/>
        </eudc:titles>
        <eudc:descriptions>
          <xsl:apply-templates select="content/description"/>
        </eudc:descriptions>
        <eudc:keywords>
          <xsl:apply-templates select="content/subject"/>
        </eudc:keywords>

        <eudc:identifiers>
			    <xsl:apply-templates select="identifier"/>
          <xsl:apply-templates select="altIdentifier"/>
		    </eudc:identifiers>

        <eudc:relatedIdentifiers>
				  <xsl:apply-templates select="content/referenceURL"/><!--
				  see template comment below for why this is commented out.
					<xsl:apply-templates select="content/relatedResource"/> -->
					<xsl:apply-templates select="content/source"/>
					<xsl:apply-templates select="capability"/>
				</eudc:relatedIdentifiers>

				<eudc:creators>
          <xsl:apply-templates select="curation/creator"/>
				</eudc:creators>
				<eudc:publishers>
	        <xsl:apply-templates select="curation/publisher"/>
				</eudc:publishers>
				<xsl:if test="curation/contributor">
				  <eudc:contributors>
	          <xsl:apply-templates select="curation/contributor"/>
				  </eudc:contributors>
				</xsl:if>
				<eudc:instruments>
	        <xsl:apply-templates select="instrument"/>
				</eudc:instruments>
        <eudc:publicationYear>
          <xsl:value-of select="substring-before(@created, '-')"/>
        </eudc:publicationYear>
        <eudc:rightsList>
            <xsl:apply-templates select="rights"/>
        </eudc:rightsList>
        <eudc:fundingReferences/>
				
      	<eudc:contacts>
      		<xsl:apply-templates select="curation/contact"/>
      	</eudc:contacts>

				<eudc:resourceTypes>
	        <xsl:call-template name="computeResourceType"/>
	      </eudc:resourceTypes>
        <xsl:apply-templates select="curation/version"/>
        <eudc:disciplines>
        	<eudc:discipline>astronomy</eudc:discipline>
        </eudc:disciplines>

        <xsl:apply-templates select="coverage"/>
      </eudc:resource>
    </xsl:template>


    <!-- ########################################### Individual elements

		For simple maintenance, keep these in rough order of application.
    -->

    <xsl:template match="title">
      <eudc:title><xsl:value-of select="."/></eudc:title>
    </xsl:template>

    <xsl:template match="description">
      <eudc:description>
        <xsl:value-of select="."/>
      </eudc:description>
    </xsl:template>

    <xsl:template match="subject">
      <eudc:keyword><xsl:value-of select="."/></eudc:keyword>
    </xsl:template>

    <xsl:template match="altIdentifier">
      <!-- for now, we only handle the DOI case for ri:Resource/identifier.
        Let's see if we want authors, too. -->
      <xsl:if test="starts-with(., 'doi:')">
        <eudc:identifier identifierType="DOI">http://doi.org/<xsl:value-of
          select="substring-after(., 'doi:')"/></eudc:identifier>
      </xsl:if>
    </xsl:template>

	  <xsl:template match="identifier">
		  <!-- We map the ivoid to a landing page formatter so people with
		  just a web browser get a suitable summary -->
		  <eudc:identifier identifierType="URL"
		    ><xsl:value-of select="concat(
		      'https://dc.g-vo.org/rr/q/lp/custom/',
		      substring(normalize-space(.), 7))"/></eudc:identifier>
	  </xsl:template>

    <xsl:template match="referenceURL">
      <!-- eudat-core, somewhat surprisingly, doesn't have a reference
      URL; we map it to a related identifier for now. -->
      <eudc:relatedIdentifier relatedIdentifierType="URL"
        ><xsl:value-of select="."/></eudc:relatedIdentifier>
    </xsl:template>

    <xsl:template match="relationship">
        <xsl:apply-templates>
            <xsl:with-param name="relationshipType">
                <xsl:choose>
                    <xsl:when test="relationshipType='mirror-of'"
                        >IsIdenticalTo</xsl:when>
                    <xsl:when test="relationshipType='derived-from'"
                        >IsDerivedFrom</xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ignore everything complex in TAPRegExt -->
    <xsl:template match="language"/>

    <!-- the following template isn't called right now because it makes
      no sense as long as eudat doesn't let us declare the type of the
      relationship. -->
    <xsl:template match="relatedResource[@ivo-id]">
        <xsl:param name="relationshipType"/>
        <xsl:if test="$relationshipType!=''">
            <eudc:relatedIdentifier>
							<xsl:attribute name="relatedIdentifierType">
                <xsl:value-of select="$relationshipType"/>
              </xsl:attribute
              ><xsl:value-of select="@ivo-id"/></eudc:relatedIdentifier>
        </xsl:if>
    </xsl:template>

    <xsl:template match="creator">
      <eudc:creator>
        <eudc:creatorName>
          <xsl:value-of select="name"/>
        </eudc:creatorName>
      </eudc:creator>
    </xsl:template>

    <xsl:template match="publisher">
      <eudc:publisher><xsl:value-of select="."/></eudc:publisher>
    </xsl:template>

    <xsl:template match="contributor">
      <eudc:contributor><xsl:value-of select="."/></eudc:contributor>
    </xsl:template>

    <xsl:template match="instrument">
      <eudc:instrument>
        <xsl:if test="starts-with(@altIdentifier, 'handle:')">
          <xsl:attribute name="instrumentIdentifierType">Handle</xsl:attribute>
          <xsl:attribute name="instrumentIdentifier"
            ><xsl:value-of select="substring-after(@altIdentifier, 'handle:')"
            /></xsl:attribute>
        </xsl:if>
      <xsl:value-of select="."/></eudc:instrument>
    </xsl:template>

    <xsl:template match="rights">
      <eudc:rights>
        <xsl:value-of select="."/>
      </eudc:rights>
      <xsl:if test="@rightsURI">
      	<eudc:rights>
         	<xsl:value-of select="@rightsURI"/>
        </eudc:rights>
      </xsl:if>
    </xsl:template>

    <xsl:template match="curation/contact">
       <eudc:contact>
         <xsl:value-of select="name"/>
         <xsl:if test="email">
           <xsl:text> &lt;</xsl:text>
           <xsl:value-of select="email"/>
           <xsl:text>&gt;</xsl:text>
         </xsl:if>
      </eudc:contact>
    </xsl:template>

    <xsl:template match="version">
      <eudc:version><xsl:value-of select="."/></eudc:version>
    </xsl:template>

    <xsl:template match="coverage">
      <!-- So far, we can only map temporal coverage, and that's a bit
      tricky because we can only add a temporalCoverages element if
      we actually have something to put in.  Hence this somewhat crooked
      logic -->
      <xsl:if test="temporal">
        <eudc:temporalCoverages>
          <xsl:apply-templates/>
        </eudc:temporalCoverages>
      </xsl:if>
    </xsl:template>

    <xsl:template match="temporal">
      <!-- this needs to dissect the MJD interval and make two child elements
      out of it, turning the MJD into an ISO string -->
      <eudc:temporalCoverage>
        <eudc:startDate format="ISO-8601">
          <xsl:call-template name="mjd-to-iso">
            <xsl:with-param name="mjd"
              select="substring-before(normalize-space(.), ' ')"/>
          </xsl:call-template>
        </eudc:startDate>
        <eudc:endDate format="ISO-8601">
          <xsl:call-template name="mjd-to-iso">
            <xsl:with-param name="mjd"
              select="substring-after(normalize-space(.), ' ')"/>
            </xsl:call-template>
        </eudc:endDate>
      </eudc:temporalCoverage>
    </xsl:template>

    <xsl:template match="interface">
      <!-- TODO: only WebBrowser-typed interfaces are relevant for b2find.
        We make relatedIndentifiers from them (by agreement with b2find).
        -->
      <xsl:if test="@xsi:type='vr:WebBrowser'">
        <eudc:relatedIdentifier relatedIdentifierType="URL"
          ><xsl:value-of select="accessURL[1]"/></eudc:relatedIdentifier>
      </xsl:if>
    </xsl:template>

    <xsl:template match="content/source[@format='bibcode']">
      <eudc:relatedIdentifier relatedIdentifierType="bibcode"
        ><xsl:value-of select="."/></eudc:relatedIdentifier>
    </xsl:template>

    <!-- ######################## named templates for more complex logic -->

    <xsl:template name="computeResourceType">
      <eudc:resourceType>
        <xsl:choose>
          <xsl:when test="@xsi:type='vs:DataService'
              or @xsi:type='vs:CatalogService'
              or @xsi:type='vs:CatalogResource'
              or @xsi:type='vs:DataResource'
              or @xsi:type='vs:TableService'
              or @xsi:type='vr:Service'"
            >Dataset</xsl:when>
          <xsl:when test="@xsi:type='vs:DataCollection'"
            >Collection</xsl:when>
          <xsl:when test="@xsi:type='vstd:Standard'"
            >Text</xsl:when>
          <xsl:otherwise>Other</xsl:otherwise>
        </xsl:choose>
      </eudc:resourceType>

      <!-- to guess what the service might be, we look at the first
      capability's standardID.  This is quite heuristic, but anything
      fancier is complicated given we have to come up with at most one
      term and we don't have case-insensitive comparisons in XPath. -->
      <xsl:variable name="normalizedID" select="translate(
        capability[@standardID]/@standardID,
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:variable name="baseID"
        select="substring-before($normalizedID, '#') or $normalizedID"/>

      <xsl:choose>
        <xsl:when
          test="$baseID='ivo://ivoa.net/std/conesearch'"
          ><eudc:resourceType>AstroObjects</eudc:resourceType></xsl:when>
        <xsl:when
          test="$baseID='ivo://ivoa.net/std/sia'"
          ><eudc:resourceType>AstroImage</eudc:resourceType></xsl:when>
        <xsl:when
          test="$baseID='ivo://ivoa.net/std/ssa'"
          ><eudc:resourceType>Spectrum</eudc:resourceType></xsl:when>
        <xsl:when
          test="$baseID='ivo://ivoa.net/std/slap'"
          ><eudc:resourceType>SpectralLines</eudc:resourceType></xsl:when>
        <xsl:when
          test="$baseID='ivo://ivoa.net/std/tap'"
          ><eudc:resourceType>AstroData</eudc:resourceType></xsl:when>
      </xsl:choose>

    </xsl:template>

    <xsl:template name="mjd-to-iso">
      <xsl:param name="mjd"/>
      <!-- this is too tedious in XSLT.  I'm deferring it to DaCHS for
        now; this means that this stylesheet will only work within DaCHS
        as long as you want to map temporal coverage. -->
       <xsl:value-of select="dachs:mjd-to-iso($mjd)"/>
    </xsl:template>
</xsl:stylesheet>


<!-- vim:et:sw=2:sta
-->
