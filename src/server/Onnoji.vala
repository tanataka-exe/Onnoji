public class Onnoji : Soup.Server {
    //public const string[] accepted_hosts = {"neoarch", "192.168.10.105", "localhost"};
    public static Sqlite.Database db;
    public static Songs songs;
    public static Genres genres;
    public static Artists artists;
    public static Albums albums;
    public static History history;
    public static MusicDataProducer producer;
    
    public Onnoji() {
        Object(port: 8888);
        assert(this != null);
        add_handler("/music", (server, msg, path, query, client) => {
            handle_music_request.begin(server, msg, path, query, client, (res, obj) => {
                server.unpause_message(msg);
            });
            server.pause_message(msg);
        });
        add_handler("/", handle_other_request);
    }
    
    private async void handle_music_request(
            Soup.Server server, Soup.Message msg, string path, GLib.HashTable<string, string>? query,
            Soup.ClientContext client) {
        try {
            OnnojiThreadData thread_data = new OnnojiThreadData() {
                server = server,
                msg = msg,
                path = path,
                query = query,
                client = client,
                db = db,
                songs = songs,
                genres = genres,
                artists = artists,
                albums = albums,
                history = history,
                producer = producer
            };
            thread_data.completed.connect(() => {
                Idle.add(handle_music_request.callback);
            });
            Thread<uint> thread = new Thread<uint>.try(null, thread_data.run);
            yield;
            thread.join();
        } catch (GLib.Error e) {
            msg.status_code = 500;
        }
    }
    
    private static void handle_other_request(
            Soup.Server server, Soup.Message msg, string path, GLib.HashTable? query,
            Soup.ClientContext client) {
        msg.response_headers.append("Access-Control-Allow-Origin", "http://neoarch");
        msg.set_response("application/json", Soup.MemoryUse.COPY,
                "{\"message\": \"Failure!\"}".data);
        msg.status_code = 404;
    }
    
    public static int main(string[] args) {
        set_print_handler((text) => stdout.puts(text));
        Gst.init(ref args);
        int ec = Sqlite.Database.open("/srv/music/data/music.db", out db);
        if (ec != Sqlite.OK) {
            return 1;
        }
        songs = new Songs(db);
        genres = new Genres(db);
        artists = new Artists(db);
        albums = new Albums(db);
        history = new History(db);
        producer = new MusicDataProducer() {
            db = db,
            songs = songs,
            albums = albums,
            genres = genres,
            artists = artists,
            history = history
        };
        Onnoji server = new Onnoji();
        server.run();
        return 0;
    }
}
