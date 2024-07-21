public class Onnoji : GLib.Object {

    private static int thread_count = 0;
    
    public static async void handle_music_request_async(OnnojiThreadData thread_data) throws GLib.Error {
        thread_data.completed.connect(() => {
            Idle.add(handle_music_request_async.callback);
        });
        if (thread_count > 100) {
            Timeout.add(100, () => {
                if (thread_count > 100) {
                    return Source.CONTINUE;
                } else {
                    handle_music_request_async.callback();
                    return Source.REMOVE;
                }
            });
            yield;
        }
        thread_count++;
        debug("The current number of threads is %d\n", thread_count);
        Thread<uint> thread = new Thread<uint>.try(null, thread_data.run);
        yield;
        thread.join();
        thread_count--;
    }

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
                OnnojiThreadData thread_data = context.get_onnoji_thread_data();
                thread_data.server = server;
                thread_data.msg = msg;
                thread_data.path = path;
                thread_data.query = query;
                thread_data.client = client;
                handle_music_request_async.begin(thread_data, (res, obj) => {
                    try {
                        handle_music_request_async.end(obj);
                        server.unpause_message(msg);
                    } catch (GLib.Error e) {
                        thread_data.msg.status_code = 500;
                    }
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
