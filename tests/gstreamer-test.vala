public class GStreamerTestContext : Object {
    public Moegi.MetadataReader get_moegi_metadata_reader() {
        return new Moegi.MetadataReader();
    }
    
    public Moegi.FileInfoAdapter get_moegi_file_info_adapter() {
        return new Moegi.FileInfoAdapter(get_moegi_metadata_reader());
    }
    
}

int main(string[] args) {
    set_print_handler(text => stdout.puts(text));
    set_printerr_handler(text => stderr.puts(text));
    Gst.init(ref args);
    var ctx = new GStreamerTestContext();
    
    if (args.length < 3) {
        printerr("Pleese specify the file path in the command line argument.\n");
        return 1;
    }
    
    string file_path = args[2];
    
    if (!FileUtils.test(file_path, FileTest.EXISTS)) {
        printerr("The specified file does not exist.\n");
        return 1;
    }
    
    int status = 0;
    
    try {
        switch (args[1]) {
          case "file_info":
            Moegi.FileInfoAdapter? adapter = ctx.get_moegi_file_info_adapter();

            bool res = test1(adapter, file_path);

            status = res ? 0 : 1;
            break;

          case "metadata":
            Moegi.MetadataReader? reader = ctx.get_moegi_metadata_reader();

            bool res = test2(reader, file_path);

            status = res ? 0 : 1;
            
            break;

          default:
            printerr("The first argument should be either \"file_info\" or \"metadata\"\n");
            status = 1;
            break;
        }
    } catch (Error e) {

        printerr("%s\n", e.message);

        status = 1;
    }

    return status;
}

bool test1(Moegi.FileInfoAdapter adapter, string file_path) throws Error {
    Moegi.FileInfo? info = adapter.read_metadata_from_path(file_path);
    if (info == null) {
        printerr("info what adapter has returned is null\n");
        return false;
    }
    print("%s\n", info.to_string());
    return true;
}

bool test2(Moegi.MetadataReader reader, string file_path) throws Error {
    File f = File.new_for_path(file_path);
    string real_path = f.get_path();
    reader.tag_found.connect((tag, value) => {
        print("tag \"%s\"", tag);
        string tag_lower = tag.down();
        switch (tag_lower) {

          case "duration":
            print("tag duration type = %s\n", value.type().name());
            print("tag duration hold uint = %s\n", value.holds(typeof(uint)).to_string());
            print("tag duration value = %u\n", value.get_uint());
            break;
            
          case "image":
            print("is image\n");
            break;
            
          default:
            if (value.holds(typeof(int))) {
                print(": %d\n", value.get_int());
            } else if (value.holds(typeof(int64))) {
                print(": %l\n", value.get_int64());
            } else if (value.holds(typeof(uint))) {
                print(": %u\n", value.get_uint());
            } else if (value.holds(typeof(uint64))) {
                print(": %u\n", (uint) value.get_uint64());
            } else if (value.holds(typeof(string))) {
                print(": %s\n", value.get_string());
            } else if (value.holds(typeof(Gst.DateTime))) {
                Gst.DateTime datetime = (Gst.DateTime)value.get_boxed();
                print(": %s\n", datetime.to_iso8601_string());
            }
            break;
        }
        
        return true;
    });
    reader.get_metadata(real_path);
    return true;
}
