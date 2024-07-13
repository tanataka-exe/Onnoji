using GXml;

public class XmlResourceManager : ResourceManager {
    private string uri;
    private DomDocument? xml;
    
    public XmlResourceManager.for_uri(string uri) throws GLib.Error {
        this.uri = uri;
        xml = new XDocument.from_uri(uri);
    }

    public override string? get_string(string id) throws GLib.Error {
        return get_string_with_params(id);
    }

    public string? get_string_with_params(string id, ...) throws GLib.Error {
        var l = va_list();

        DomElement? element = (xml.get_element_by_id(id) as XNode).clone_node(true) as DomElement;
        
        if (element == null) {
            throw new OnnojiError.RESOURCE_ERROR("this resource was not found!");
        }
        
        DomNodeList list = element.query_selector_all("replacement");
        bool is_empty = false;
        for (int i = 0; i < list.length; i++) {
            DomNode? n_child = list.item(i);
            if (!(n_child is DomElement)) {
                continue;
            }
            
            string? replacement_id = l.arg<string?>();
            if (replacement_id != null) {
                
                DomElement? e_replacement = xml.get_element_by_id(replacement_id);
                if (e_replacement == null) {
                    break;
                }

                string s_replacement = e_replacement.text_content;
                DomNode n_replacement = xml.create_text_node(s_replacement);

                DomNode? n_parent = n_child.parent_node;
                n_parent.replace_child(n_replacement, n_child);

            } else {
                
                DomNode n_replacement = xml.create_text_node(n_child.text_content);

                DomNode? n_parent = n_child.parent_node;
                n_parent.replace_child(n_replacement, n_child);
            }
        }
        
        return get_text_content(element);
    }
    
    private string get_text_content(GXml.DomElement element) {
        return element.text_content;
    }
}
