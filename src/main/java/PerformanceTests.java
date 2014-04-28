import javax.annotation.Resource;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.transaction.UserTransaction;
import javax.ws.rs.GET;
import javax.ws.rs.Path;

import org.jboss.pressgang.ccms.model.StringConstants;
import org.jboss.pressgang.ccms.model.Topic;
import org.jboss.pressgang.ccms.model.contentspec.CSNode;
import org.jboss.pressgang.ccms.model.utils.EnversUtilities;
import org.jboss.pressgang.ccms.utils.common.DocBookUtilities;
import org.jboss.pressgang.ccms.utils.common.XMLUtilities;
import org.jboss.pressgang.ccms.utils.constants.CommonConstants;
import org.jboss.pressgang.ccms.utils.structures.DocBookVersion;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

@Path("/")
@RequestScoped
public class PerformanceTests {
    private static final Logger log = LoggerFactory.getLogger(PerformanceTests.class);

    private static final Integer EMPTY_TOPIC_STRING_CONSTANT = 31;
    private static final Integer INVALID_TOPIC_STRING_CONSTANT = 33;
    private static final String TOPIC = "<section>\n" +
            "\t<!-- Author email: lcarlon@redhat.com -->\n" +
            "\t<!-- Created: 6th April 2011-->\n" +
            "\t<!-- Original source: Author -->\n" +
            "\t<!-- Audience knowledge: Writer -->\n" +
            "\t<title>About Managed Domains</title>\n" +
            "\t<para>\n" +
            "\t\tA managed domain is one of two operating modes for a JBoss EAP 6 instance. It is a mode to manage multiple instances of " +
            "JBoss EAP 6 from a single point of control.\n" +
            "\t</para>\n" +
            "\t<para>\n" +
            "\t\tA collection of servers that are centrally managed are known as members of a domain. All the JBoss EAP 6 instances in " +
            "the domain share a common management policy. A domain consists of one <firstterm>domain controller</firstterm>, " +
            "one or more <firstterm>host controller(s)</firstterm>, and zero or more server groups per host.\n" +
            "\t</para>\n" +
            "\t<para>\n" +
            "\t\tA domain controller is the central point from which the domain is controlled. It ensures that each server is configured " +
            "according to the management policy of the domain. The domain controller is also a host controller. A host controller is a " +
            "physical or a virtual host on which the <filename>domain.sh</filename> or <filename>domain.bat</filename> script is run. " +
            "Unlike the domain controller, the host controllers are configured to delegate domain management tasks to it. The host " +
            "controller on each host interacts with the domain controller to control the lifecycle of the application server instances " +
            "running on its host and to assist the domain controller to manage them. Each host can contain multiple server groups. A " +
            "server group is a set of server instances, which has JBoss EAP 6 installed on it and are managed and configured as one. " +
            "Since the domain controller manages the configuration and applications deployed onto server groups, " +
            "each server in a server group shares the same configuration and deployments.\n" +
            "\t</para>\n" +
            "\t<para>\n" +
            "\t\tIt is possible for a domain controller, a single host controller, and multiple servers to run within the same instance " +
            "of JBoss EAP 6, on the same physical system. Host controllers are tied to specific physical (or virtual) hosts. You can run " +
            "multiple host controllers on the same hardware if you use different configurations, so that the ports and other resources do" +
            " not conflict.\n" +
            "\t</para>\n" +
            "\t<para condition=\"blah\">\n" +
            "\t\tSome conditional para that should be removed...\n" +
            "\t</para>\n" +
            "\t<figure>\n" +
            "\t\t<title>Graphical Representation of a Managed Domain</title>\n" +
            "\t\t<mediaobject>\n" +
            "\t\t\t<imageobject>\n" +
            "\t\t\t\t<imagedata align=\"center\" fileref=\"images/62.png\" width=\"666px\"/>\n" +
            "\t\t\t</imageobject>\n" +
            "\t\t\t<textobject>\n" +
            "\t\t\t\t<phrase> A managed domain with one domain controller, three host controllers, " +
            "and three server groups. Servers are members of server groups, and may be located on any of the host controllers in the " +
            "domain.</phrase>\n" +
            "\t\t\t</textobject>\n" +
            "\t\t</mediaobject>\n" +
            "\t</figure>\n" +
            "</section>";

    public static double TEST_TIME_SEC = 60.0;

    @Inject
    protected EntityManager entityManager;
    @Resource
    protected UserTransaction userTransaction;

    @GET
    @Path("all")
    public void all() {
        transformOnly();
        transformAndManipulateBasic();
        transformAndManipulate();
        entities();
    }

    @GET
    @Path("transformOnly")
    public String transformOnly() {
        log.info("Starting the \"transformOnly\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;
        while (endTime > System.currentTimeMillis()) {
            try {
                final Document doc = XMLUtilities.convertStringToDocument(TOPIC);
            } catch (Exception e) {

            }
            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"transformOnly\" test");

        return retValue;
    }

    @GET
    @Path("transformAndManipulateBasic")
    public String transformAndManipulateBasic() {
        log.info("Starting the \"transformAndManipulateBasic\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;

        final String conditions = "test";
        final Integer format = CommonConstants.DOCBOOK_50;
        final Boolean includeTitle = false;

        while (endTime > System.currentTimeMillis()) {
            try {
                final Document doc = XMLUtilities.convertStringToDocument(TOPIC);

                // Wrap this topic up for rendering if needed
                DocBookUtilities.wrapForRendering(doc);

                // Some xml formats need namespace info added to the document element
                DocBookUtilities.addNamespaceToDocElement(DocBookVersion.getVersionFromId(format), doc);

                // Remove the title if requested
                if (includeTitle != null && !includeTitle.booleanValue()) {
                    XMLUtilities.removeChildrenOfType(doc.getDocumentElement(), "title");
                }

                // Resolve the injections in the XML
                InjectionResolver.resolveInjections(entityManager, format, doc,
                        "/pressgang-ccms/rest/1/topic/get/xml/" + InjectionResolver.HOST_URL_ID_TOKEN + "/xslt+xml");


                // Process any conditions
                DocBookUtilities.processConditions(conditions, doc);

                // convert back to a string for final processing
                final String processedXml = XMLUtilities.convertDocumentToString(doc);
            } catch (Exception e) {

            }
            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"transformAndManipulateBasic\" test");

        return retValue;
    }

    @GET
    @Path("transformAndManipulate")
    public String transformAndManipulate() {
        log.info("Starting the \"transformAndManipulate\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;

        final String conditions = "test";
        final Integer format = CommonConstants.DOCBOOK_50;
        final DocBookVersion version = DocBookVersion.DOCBOOK_50;
        final Boolean includeTitle = false;
        final String entities = null;

        while (endTime > System.currentTimeMillis()) {
            try {
                final Document doc = XMLUtilities.convertStringToDocument(TOPIC);

                // Make sure all the required entities are in place
                if (!DocBookUtilities.allEntitiesAccountedFor(doc, version, entities)) {
                    continue;
                }

                // Wrap this topic up for rendering if needed
                DocBookUtilities.wrapForRendering(doc);

                // Some xml formats need namespace info added to the document element
                DocBookUtilities.addNamespaceToDocElement(version, doc);

                // Remove the title if requested
                if (includeTitle != null && !includeTitle.booleanValue()) {
                    XMLUtilities.removeChildrenOfType(doc.getDocumentElement(), "title");
                }

                // Resolve the injections in the XML
                InjectionResolver.resolveInjections(entityManager, format, doc,
                        "/pressgang-ccms/rest/1/topic/get/xml/" + InjectionResolver.HOST_URL_ID_TOKEN + "/xslt+xml");

                // Process any conditions
                DocBookUtilities.processConditions(conditions, doc);

                // convert back to a string for final processing
                final String processedXml = XMLUtilities.convertDocumentToString(doc);

                // convert the xml back to a string, remove the preamble, and replace any standard entities
                final String fixedXML = XMLUtilities.removePreamble(processedXml);
            } catch (Exception e) {

            }
            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"transformAndManipulate\" test");

        return retValue;
    }

    @GET
    @Path("etag")
    public String etag() {
        log.info("Starting the \"etag\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;
        Integer revision = null;
        Boolean includeTitle = true;
        String condition = "test";
        String baseUrl = "http://localhost/";
        String entities = "<!ENTITY blah \"blah blah\">";

        while (endTime > System.currentTimeMillis()) {
            int id = (int) (count + 1);
            final CSNode csNode = entityManager.find(CSNode.class, id);

            // Get a random topic to simulate it
            Integer topicId = (int) count + 10000;
            final Topic topic = entityManager.find(Topic.class, topicId);

            // TODO We probably should find a better way to do this, but there should be very little missing topics/nodes in the defined
            // range
            if (topic != null && csNode != null) {
                final String eTagValue = topicId + ":" +
                        (revision != null ? revision.toString() : EnversUtilities.getLatestRevision(entityManager,
                                topic).toString()) + ":" +
                        (includeTitle == null ? true : false) + ":" +
                        (condition == null ? "".hashCode() : condition.hashCode()) + ":" +
                        csNode.getEntityId() + ":" +
                        (baseUrl == null ? "".hashCode() : baseUrl.hashCode()) + ":" +
                        (entities == null ? "".hashCode() : entities.hashCode());
            }
            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"etag\" test");

        return retValue;
    }

    @GET
    @Path("full")
    public String full() {
        log.info("Starting the \"full\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;
        Integer revision = null;
        Boolean includeTitle = true;
        String condition = "test";
        String baseUrl = "http://localhost/";
        String entities = "<!ENTITY blah \"blah blah\">";

        while (endTime > System.currentTimeMillis()) {
            int id = (int) (count + 1);
            final CSNode csNode = entityManager.find(CSNode.class, id);

            // Get a random topic to simulate it
            Integer topicId = (int) count + 10000;
            final Topic topic = entityManager.find(Topic.class, topicId);

            // TODO We probably should find a better way to do this, but there should be very little missing topics/nodes in the defined
            // range
            if (topic != null && csNode != null) {
                final String eTagValue = topicId + ":" +
                        (revision != null ? revision.toString() : EnversUtilities.getLatestRevision(entityManager,
                                topic).toString()) + ":" +
                        (includeTitle == null ? true : false) + ":" +
                        (condition == null ? "".hashCode() : condition.hashCode()) + ":" +
                        csNode.getEntityId() + ":" +
                        (baseUrl == null ? "".hashCode() : baseUrl.hashCode()) + ":" +
                        (entities == null ? "".hashCode() : entities.hashCode());
            }

            addXSLToTopicXML(null, TOPIC, "", CommonConstants.DOCBOOK_45, true, condition, entities, baseUrl);

            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"full\" test");

        return retValue;
    }

    @GET
    @Path("entities")
    public String entities() {
        log.info("Starting the \"entities\" test");
        long time = System.currentTimeMillis();
        long endTime = (long) (time + TEST_TIME_SEC * 1000);
        double count = 0;

        while (endTime > System.currentTimeMillis()) {
            int id = (int) count + 10000;
            final Topic topic = entityManager.find(Topic.class, id);

            // Load the tags to simulate something that would be needed
            if (topic != null) {
                topic.getTags();
            }
            count++;
        }

        final String retValue = "Number of operations per second: " + (count / TEST_TIME_SEC);
        log.info("    " + retValue);
        log.info("Finished the \"entities\" test");

        return retValue;
    }

    protected String addXSLToTopicXML(final String xmlErrors, final String xml, final String title, final Integer format,
            final Boolean includeTitle, final String conditions, final String entities, final String baseUrl) {

        final String XSL_STYLESHEET = "<?xml-stylesheet type='text/xsl' href='/pressgang-ccms-static/publican-docbook/html-single-diff" +
                ".xsl'?>";
        final String fixedTitle = includeTitle == null || includeTitle ? title : "";
        final DocBookVersion version = DocBookVersion.getVersionFromId(format);

        // Check the XML is not empty
        if (xml == null || xml.trim().length() == 0) {
            String emptyXMLPlaceholder = "";
            try {
                final String emptyXMLRaw = entityManager.find(StringConstants.class, EMPTY_TOPIC_STRING_CONSTANT).getConstantValue();
                final Document emptyXMLDoc = XMLUtilities.convertStringToDocument(emptyXMLRaw, true);

                if (emptyXMLDoc != null) {
                    XMLUtilities.setChildrenContent(emptyXMLDoc.getDocumentElement(), "title", fixedTitle, true);
                    final String xmlString = XMLUtilities.removePreamble(XMLUtilities.convertDocumentToString(emptyXMLDoc, true));
                    emptyXMLPlaceholder = XSL_STYLESHEET + "\n" +
                            "<!DOCTYPE " + emptyXMLDoc.getDocumentElement().getNodeName() + "[]>\n" +
                            xmlString;
                }

            } catch (final Exception ex) {
                // do nothing - the string constants are not valid xml
            }

            return emptyXMLPlaceholder;
        }

        // Generate the invalid XML placeholder
        String invalidXMLPlaceholder = "";
        try {
            final String invalidXMLRaw = entityManager.find(StringConstants.class, INVALID_TOPIC_STRING_CONSTANT).getConstantValue();
            final Document invalidXMLDoc = XMLUtilities.convertStringToDocument(invalidXMLRaw, true);

            if (invalidXMLDoc != null) {
                XMLUtilities.setChildrenContent(invalidXMLDoc.getDocumentElement(), "title", fixedTitle, true);
                final String xmlString = XMLUtilities.removePreamble(XMLUtilities.convertDocumentToString(invalidXMLDoc, true));
                invalidXMLPlaceholder = XSL_STYLESHEET + "\n" +
                        "<!DOCTYPE " + invalidXMLDoc.getDocumentElement().getNodeName() + "[]>\n" +
                        xmlString;
            }
        } catch (final Exception ex) {
            // do nothing - the string constants are not valid xml
        }

        if (xmlErrors != null && xmlErrors.trim().length() != 0) {
            return invalidXMLPlaceholder;
        }

        // Attempt to convert the XML, and throw an exception if there is an issue
        try {
            final Document xmlDoc = XMLUtilities.convertStringToDocument(xml, true);

            /*
                Make sure all the required entities are in place
             */
            if (!DocBookUtilities.allEntitiesAccountedFor(xmlDoc, version, entities)) {
                return invalidXMLPlaceholder;
            }

            // Wrap this topic up for rendering if needed
            DocBookUtilities.wrapForRendering(xmlDoc);

            // Some xml formats need namespace info added to the document element
            DocBookUtilities.addNamespaceToDocElement(DocBookVersion.getVersionFromId(format), xmlDoc);

            // Resolve the injections in the XML
            InjectionResolver.resolveInjections(entityManager, format, xmlDoc,
                    baseUrl == null ? "/pressgang-ccms/rest/1/topic/get/xml/" + InjectionResolver.HOST_URL_ID_TOKEN + "/xslt+xml" :
                            baseUrl);

            // Remove the title if requested
            if (includeTitle != null && !includeTitle.booleanValue()) {
                XMLUtilities.removeChildrenOfType(xmlDoc.getDocumentElement(), "title");
            }

            // Process any conditions
            DocBookUtilities.processConditions(conditions, xmlDoc);

            // convert back to a string for final processing
            final String processedXml = XMLUtilities.convertDocumentToString(xmlDoc);

            // convert the xml back to a string and remove the preamble
            final String fixedXML = XMLUtilities.removePreamble(processedXml);

            // Add the stylesheet info
            final StringBuilder retValue = new StringBuilder(XSL_STYLESHEET + "\n");

            final StringBuilder entitiesCombined = new StringBuilder();
            if (version == DocBookVersion.DOCBOOK_45 || version == DocBookVersion.DOCBOOK_50) {
                entitiesCombined.append(DocBookUtilities.DOCBOOK_ENTITIES_STRING);
            }
            if (entities != null) {
                if (!entities.isEmpty()) {
                    entitiesCombined.append("\n");
                }
                entitiesCombined.append(entities);
            }

            // Build the doctype declaration
            retValue.append(
                    DocBookUtilities.buildDocBookDoctype(version, xmlDoc.getDocumentElement().getNodeName(), entitiesCombined.toString(),
                            false) + "\n");
            retValue.append(fixedXML);

            return retValue.toString();
        } catch (final SAXException ex) {
            return invalidXMLPlaceholder;
        } catch (final DOMException ex) {
            return invalidXMLPlaceholder;
        }
    }
}
