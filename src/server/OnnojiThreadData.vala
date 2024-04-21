public class OnnojiThreadData : Object {
    public Soup.Server server { get; set; }
    public Soup.Message msg { get; set; }
    public string path { get; set; }
    public GLib.HashTable<string, string>? query { get; set; }
    public Soup.ClientContext client { get; set; }
    public unowned Sqlite.Database db { get; set; }
    public Songs songs { get; set; }
    public Genres genres { get; set; }
    public Artists artists { get; set; }
    public Albums albums { get; set; }
    public History history { get; set; }
    public MusicDataProducer producer { get; set; }
    public signal void completed();
    private bool syntax_ok;
    private int response_status;
    private uint8[]? response_body;
    private string mime_type;
    private bool used;
    
    construct {
        used = false;
    }
    
    public uint run()
            requires(server != null && msg != null && path != null && client != null && db != null && songs != null
                    && genres != null && artists != null && albums != null && history != null && producer != null
                    && used == false) {
        used = true;
        string[] paths = path.split("/");

        // DEBUG
        print("Request: %s://%s:%u%s\n", msg.uri.get_scheme(), msg.uri.get_host(), msg.uri.get_port(), path);

        syntax_ok = true;
        response_status = 200;
        response_body = null;
        mime_type = "application/json";
        
        // DEBUG
        response_body = "{\"message\": \"Success!\"}".data;
        
        if (paths.length >= 4 && paths[2] == "v1") {
            try {
                switch (paths[3]) {
                  case "song":
                    do_get_song();
                    break;
                  case "meta":
                    do_get_meta();
                    break;
                  case "artwork":
                    do_get_artwork();
                    break;
                  case "icon":
                    do_get_icon();
                    break;
                  case "list":
                    if (paths.length >= 5) {
                        switch (paths[4]) {
                          case "songs":
                            do_get_list_songs();
                            break;
                          case "albums":
                            do_get_list_albums();
                            break;
                          case "artists":
                            do_get_list_artists();
                            break;
                          case "genres":
                            do_get_list_genres();
                            break;
                          default:
                            syntax_ok = false;
                            break;
                        }
                    } else {
                        syntax_ok = false;
                    }
                    break;
                  case "add":
                    if (paths.length >= 5) {
                        switch (paths[4]) {
                          case "history":
                            do_add_history();
                            break;
                        }
                    }
                    break;
                  default:
                    syntax_ok = false;
                    break;
                }
            } catch (OnnojiError e) {
                stderr.printf(@"OnnojiError: $(e.message)\n");
                response_status = 500;
            }
            
            if (msg.request_headers.get_one("origin") != null) {
                msg.response_headers.append("Access-Control-Allow-Origin", msg.request_headers.get_one("origin"));
            }

            if (syntax_ok) {
                msg.set_response(mime_type, Soup.MemoryUse.COPY, response_body);
                msg.status_code = response_status;
            } else {
                msg.status_code = 500;
            }
        } else {
            msg.status_code = 500;
        }
        completed();
        return msg.status_code;
    }
    
    private void do_get_song() throws OnnojiError {
        string song_id;
        if (has_query_id(query, out song_id)) {
            SongData song = producer.query_song_by_id_lazy(song_id, out response_status);
            if (response_status == 200) {
                try {
                    FileUtils.get_data(song.file_path, out response_body);
                } catch (FileError e) {
                    throw new OnnojiError.FILE_ERROR(e.message);
                }
                mime_type = song.mime_type;
            }
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_add_history() throws OnnojiError {
        string song_id;
        if (has_query_id(query, out song_id)) {
            SongData song = producer.query_song_by_id_lazy(song_id, out response_status);
            if (response_status == 200) {
                var hist_data = new HistoryData();
                {
                    hist_data.song_id = song.song_id;
                    hist_data.request_datetime = new DateTime.now_local();
                }
                history.register(hist_data);
                response_body = "{ \"result\": \"OK\" }".data;
                mime_type = "application/json";
            }
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_get_meta() throws OnnojiError {
        string song_id;
        if (has_query_id(query, out song_id)) {
            Json.Node? response_json = producer.assemble_metadata(song_id, msg.uri, out response_status);
            if (response_status == 200) {
                response_body = Json.to_string(response_json, false).data;
                mime_type = "application/json";
            }
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_get_artwork() throws OnnojiError {
        string artwork_id;
        if (has_query_id(query, out artwork_id)) {
            SongData? song = producer.query_artwork_by_id_lazy(artwork_id, out response_status);
            if (response_status != 200) {
                return;
            }
            if (song == null || song.artwork_file_path == null) {
                response_status = 404;
                return;
            }
            File artwork_file = File.new_for_path(song.artwork_file_path);
            try {
                GLib.FileInfo? artwork_file_info = artwork_file.query_info("standard::*", 0);
                string artwork_mime_type = artwork_file_info.get_content_type();
                FileUtils.get_data(song.artwork_file_path, out response_body);
                mime_type = artwork_mime_type;
            } catch (FileError e) {
                throw new OnnojiError.FILE_ERROR(e.message);
            } catch (GLib.Error e) {
                throw new OnnojiError.FILE_ERROR(e.message);
            }
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_get_icon() throws OnnojiError {
        int genre_id = 0;
        if (has_query_genre(query, out genre_id)) {
            try {
                File genre_icon_file = File.new_for_path(@"/srv/music/data/icons/genre/$(genre_id).jpg");
                GLib.FileInfo genre_icon_file_info = genre_icon_file.query_info("standard::*", 0);
                string genre_icon_mime_type = genre_icon_file_info.get_content_type();
                FileUtils.get_data(genre_icon_file.get_path(), out response_body);
                mime_type = genre_icon_mime_type;
            } catch (FileError e) {
                throw new OnnojiError.FILE_ERROR(e.message);
            } catch (GLib.Error e) {
                throw new OnnojiError.FILE_ERROR(e.message);
            }
        } else {
            syntax_ok = false;
        }
    }

    private void do_get_list_songs() throws OnnojiError {
        string? album_id = null;
        int artist_id = 0;
        if (has_query_album(query, out album_id) || has_query_artist(query, out artist_id)) {
            Json.Node? response_json = producer.assemble_songs(album_id, artist_id,
                    msg.uri, out response_status);
            if (response_status != 200) {
                return;
            }
            response_body = Json.to_string(response_json, false).data;
            mime_type = "application/json";
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_get_list_albums() throws OnnojiError {
        int genre_id = 0, artist_id = 0, recent_creation_limit = 0, recent_request_limit = 0;
        Json.Node? response_json = null;
        if (has_query_genre(query, out genre_id)) {
            response_json = producer.assemble_albums_by_genre_id(genre_id, msg, out response_status);
        } else if (has_query_artist(query, out artist_id)) {
            bool is_lazy = query != null && query.contains("lazy");
            response_json = producer.assemble_albums_by_artist_id(artist_id, is_lazy, msg, out response_status);
        } else if (has_query_recent_creation(query, out recent_creation_limit)) {
            response_json = producer.assemble_albums_recently_created(recent_creation_limit, msg, out response_status);
        } else if (has_query_recent_request(query, out recent_request_limit)) {
            response_json = producer.assemble_albums_recently_requested(recent_request_limit, msg, out response_status);
        } else {
            syntax_ok = false;
            return;
        }
        if (response_status != 200 || response_json == null) {
            return;
        }
        response_body = Json.to_string(response_json, false).data;
        mime_type = "application/json";
    }
    
    private void do_get_list_artists() throws OnnojiError {
        int genre_id = 0;
        string? album_id = null;
        if (has_query_genre(query, out genre_id) || has_query_album(query, out album_id)) {
            Json.Node? response_json = producer.assemble_artists(genre_id, album_id, out response_status);
            if (response_status != 200) {
                return;
            }
            response_body = Json.to_string(response_json, false).data;
            mime_type = "application/json";
        } else {
            syntax_ok = false;
        }
    }
    
    private void do_get_list_genres() throws OnnojiError {
        Json.Node? response_json = producer.assemble_genres(msg);
        response_body = Json.to_string(response_json, false).data;
        mime_type = "application/json";
    }
    
    private static bool has_query_id(GLib.HashTable<string, string>? query, out string? id) throws OnnojiError {
        if (query == null || !query.contains("id") || query["id"].length < ID_LENGTH) {
            id = null;
            return false;
        }
        print("query[id] => %s\n", query["id"]);
        id = query["id"];
        return true;
    }

    private static bool has_query_album(GLib.HashTable<string, string>? query, out string? album_id) throws OnnojiError {
        if (query == null || !query.contains("album") || query["album"].length < ID_LENGTH) {
            album_id = null;
            return false;
        }
        print("query[id] => %s\n", query["album"]);
        album_id = query["album"];
        return true;
    }

    private static bool has_query_recent_creation(GLib.HashTable<string, string>? query, out int recent_creation_limit) {
        if (query == null || !query.contains("recent_creation") || !is_number_text(query["recent_creation"])) {
            recent_creation_limit = 0;
            return false;
        }
        recent_creation_limit = int.parse(query["recent_creation"]);
        return true;
    }

    private static bool has_query_recent_request(GLib.HashTable<string, string>? query, out int recent_request_limit) {
        if (query == null || !query.contains("recent_request") || !is_number_text(query["recent_request"])) {
            recent_request_limit = 0;
            return false;
        }
        recent_request_limit = int.parse(query["recent_request"]);
        return true;
    }

    private static bool has_query_genre(GLib.HashTable<string, string>? query, out int genre_id) {
        if (query == null || !query.contains("genre") || !is_number_text(query["genre"])) {
            genre_id = 0;
            return false;
        }
        genre_id = int.parse(query["genre"]);
        return true;
    }

    private static bool has_query_artist(GLib.HashTable<string, string>? query, out int artist_id) {
        if (query == null || !query.contains("artist") || !is_number_text(query["artist"])) {
            artist_id = 0;
            return false;
        }
        artist_id = int.parse(query["artist"]);
        return true;
    }
    
    private static bool is_number_text(string text) {
        for (int i = 0; i < text.length; i++) {
            if (!text[i].isdigit()) {
                return false;
            }
        }
        return true;
    }
}
