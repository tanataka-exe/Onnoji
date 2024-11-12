public class Onnoji : GLib.Object {

    public static int main(string[] args) {
        
        // default print handler can't print utf-8 characters then it replace the other one.
        
        set_print_handler((text) => stdout.puts(text));
        set_printerr_handler((text) => stderr.puts(text));
        
        // Initialize Gstreamer library
        
        Gst.init(ref args);

        // Initialize Gda library
        
        Gda.init();
        
        try {
            // Create a context object (The dependency resolver)
            
            ApplicationContext context = RealApplicationContext.get_instance();
            
            // Get the server object
            
            Soup.Server server = context.get_server();
            
            // handle music request
            
            server.add_handler("/api", (server, msg, path, query, client) => {
                OnnojiActionHandler thread_data = context.get_onnoji_action_handler();
                thread_data.server = server;
                thread_data.msg = msg;
                thread_data.path = path;
                thread_data.query = query;
                thread_data.client = client;
                thread_data.run.begin((x, y) => {
                    server.unpause_message(msg);
                });
                server.pause_message(msg);
            });
            
            // handle other requests
            
            server.add_handler("/", (server, msg, path, query, client) => {
                msg.response_headers.append("Access-Control-Allow-Origin", "http://localhost:3000");
                msg.set_response("application/json", Soup.MemoryUse.COPY,
                        "{\"message\": \"Failure!\"}".data);
                msg.status_code = 404;
            });
            
            // Server starts.
            
            (new MainLoop()).run();
            
            return 0;
        } catch (Error e) {
            printerr("ERROR: %s (%d)\n", e.message, e.code);
            return -1;
        }
    }
}
