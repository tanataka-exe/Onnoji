public class ResourceTestContext : Object {

    private static ResourceTestContext? instance;
    
    private ResourceManager? resource;
    private XmlResourceManager? xml_resource;

    private ResourceTestContext() {}
    
    public static ResourceTestContext get_instance() {
        if (instance == null) {
            instance = new ResourceTestContext();
        }
        return instance;
    }
    
    public ResourceManager get_resource_manager() throws Error {
        if (resource == null) {
            resource = new ResourceManager.for_uri("resource:///local/asusturn/onnoji/main/application.properties");
        }
        return resource;
    }
    
    public XmlResourceManager get_xml_resource_manager() throws Error {
        if (xml_resource == null) {
            xml_resource = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
        }
        return xml_resource;
    }


}
