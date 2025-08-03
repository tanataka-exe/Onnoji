public class ResourceManager : Object {
    private string content;
    private Gee.Map<string, string> map;
    
    public ResourceManager.for_uri(string uri) throws Error {
        StringBuilder sb = new StringBuilder();
        Regex comment_regex = new Regex("#.*$");
        File f = File.new_for_uri(uri);
        DataInputStream s = new DataInputStream(f.read());
        this.map = new Gee.HashMap<string, string>();
        string? line = null;
        while ((line = s.read_line()) != null) {
            sb.append(line).append("\n");
            line = comment_regex.replace(line, line.length, 0, "");
            if (line.length > 0 && line.index_of("=") > 0) {
                string[] words = line.split("=", 2);
                if (words.length == 2) {
                    this.map[words[0].strip()] = words[1].strip();
                }
            }
        }
        content = sb.str;
    }
    
    public virtual string? get_string(string id) throws Error {
        return this.map[id];
    }
    
    public string get_content() {
        return content;
    }
}
