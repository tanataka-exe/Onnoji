public class OnnojiThreadData : Object {
    
    /*
     * constants
     */
     
    private const string METHOD_GET = "GET";
    private const string METHOD_POST = "POST";
    
    /*
     * public properties
     */
    
    public Soup.Server server { get; set; }
    public Soup.Message msg { get; set; }
    public string path { get; set; }
    public GLib.HashTable<string, string>? query { get; set; }
    public Soup.ClientContext client { get; set; }
    public MusicDataProducer producer { get; construct set; }
    public string access_control_allow_origin { get; construct set; }
    
    /*
     * signals
     */
    
    public signal void completed();

    /*
     * private fields
     */
     
    private int response_status;
    private uint8[]? response_body;
    private string mime_type;
    private bool used;

    /*
     * constructor
     */
     
    construct {
        used = false;
    }
    
    /*
     * main method
     */
    
    /**
     * main method of this object.
     */
    public uint run()
            requires(server != null
                    && msg != null
                    && path != null
                    && client != null
                    && producer != null
                    && used == false) {
        used = true;
        // DEBUG
        print("Request: %s %s\n", msg.method, path);
        
        string method = msg.method.ascii_up();
        
        try {
            /*
             * path matching and request handling.
             */
            if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/stream")) {

                if (method == METHOD_GET) {
                    do_get_song_stream(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/metadata")) {

                if (method == METHOD_GET) {
                    do_get_song_metadata(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/artwork")) {

                if (method == METHOD_GET) {
                    do_get_song_artwork(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/artists")) {

                if (method == METHOD_GET) {
                    do_get_song_artists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/albums")) {

                if (method == METHOD_GET) {
                    do_get_song_albums(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/song/[song_id]/playlists")) {

                if (method == METHOD_GET) {
                    do_get_song_playlists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/artwork/[artwork_id]")) {

                if (method == METHOD_GET) {
                    do_get_artwork(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }

            } else if (OnnojiPaths.match_path(path, "/api/v2/playlists")) {
                
                if (method == METHOD_GET) {
                    do_get_all_playlists(false);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist")) {
                
                if (method == METHOD_POST) {
                    do_post_playlist();
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/albums")) {

                if (method == METHOD_GET) {
                    do_get_all_playlists(true);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/album")) {

                if (method == METHOD_POST) {
                    do_post_album();
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]/songs")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]/songs")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist_songs(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]/genres")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]/genres")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist_genres(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]/artists")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]/artists")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist_artists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]/artworks")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]/artworks")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist_artworks(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/playlist/[playlist_id]/artwork")
                    || OnnojiPaths.match_path(path, "/api/v2/album/[album_id]/artwork")) {
                
                if (method == METHOD_GET) {
                    do_get_playlist_artwork(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/artist/[artist_id]")) {
                
                if (method == METHOD_GET) {
                    do_get_artist(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/artist/[artist_id]/albums")) {
                
                if (method == METHOD_GET) {
                    do_get_artist_albums(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/artist/[artist_id]/playlists")) {
                
                if (method == METHOD_GET) {
                    do_get_artist_playlists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/artist/[artist_id]/genres")) {
                
                if (method == METHOD_GET) {
                    do_get_artist_genres(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/artist/[artist_id]/songs")) {
                
                if (method == METHOD_GET) {
                    do_get_artist_songs(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/genres")) {
                
                if (method == METHOD_GET) {
                    do_get_genres();
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/genre/[genre_id]/icon")) {
                
                if (method == METHOD_GET) {
                    do_get_genre_icon(int.parse(path.split("/")[4]));
                } else if (method == METHOD_POST) {
                    do_post_genre_icon(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/genre/[genre_id]/playlists")) {
                
                if (method == METHOD_GET) {
                    do_get_genre_playlists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/genre/[genre_id]/albums")) {
                
                if (method == METHOD_GET) {
                    do_get_genre_albums(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/genre/[genre_id]/artists")) {
                
                if (method == METHOD_GET) {
                    do_get_genre_artists(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/history/[song_id]")) {
                
                if (method == METHOD_POST) {
                    do_post_history(int.parse(path.split("/")[4]));
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-requested/[min-max]/songs")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_requested_songs(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-requested/[min-max]/playlists")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_requested_playlists(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-requested/[min-max]/albums")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_requested_albums(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-registered/[min-max]/songs")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_registered_songs(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-registered/[min-max]/playlists")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_registered_playlists(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else if (OnnojiPaths.match_path(path, "/api/v2/recently-registered/[min-max]/albums")) {
                
                if (method == METHOD_GET) {
                    do_get_recently_registered_albums(path.split("/")[4]);
                } else {
                    msg.status_code = 405;
                }
                
            } else {
                
                debug("no matched path exist!");
                
                msg.status_code = 404;
                
            }
        } catch (OnnojiError e) {
            stderr.printf(@"OnnojiError: $(e.message)\n");
            msg.status_code = 500;
        }

        msg.response_headers.append("Access-Control-Allow-Origin", access_control_allow_origin);

        completed();
        return msg.status_code;
    }
    
    private void set_service_response(int status_code, ServiceResponse? res) {
        if (res != null) {
            msg.status_code = status_code;
            msg.set_response(res.mime_type, Soup.MemoryUse.COPY, res.data);
        } else {
            msg.status_code = 404;
        }
    }
    
    /*
     * request handlers
     */
     
    /**
     * GET /api/v2/song/[song_id]/stream
     */
    private void do_get_song_stream(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_stream(song_id);
        set_service_response(200, res);
    }
    
    /**
     * POST /api/v2/history/[song_id]
     */
    private void do_post_history(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }
        
        debug("history post");

        var res = producer.register_song_history(song_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/song/[song_id]/metadata
     */
    private void do_get_song_metadata(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_metadata(song_id);
        set_service_response(200, res);
    }

    /**
     * GET /api/v2/song/[song_id]/artwork
     */
    private void do_get_song_artwork(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_artwork(song_id);
        if (res != null) {
            set_service_response(200, res);
        } else {
            msg.set_redirect(303, "/api/v2/artwork/0");
        }
    }
     
    /**
     * GET /api/v2/song/[song_id]/artists
     */
    private void do_get_song_artists(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_artists(song_id);
        set_service_response(200, res);
    }
     
    /**
     * GET /api/v2/song/[song_id]/albums
     */
    private void do_get_song_albums(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_albums(song_id);
        set_service_response(200, res);
    }
     
    /**
     * GET /api/v2/song/[song_id]/playlists
     */
    private void do_get_song_playlists(int song_id) throws OnnojiError {

        if (!is_song_id_valid(song_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_song_playlists(song_id);
        set_service_response(200, res);
    }
     
    /**
     * GET /api/v2/artwork/[artwork_id]
     */
    private void do_get_artwork(int artwork_id) throws OnnojiError {

        if (artwork_id == 0) {
            debug("query artwork default");
            var res = producer.query_artwork_default();
            set_service_response(200, res);
        } else {
            var res = producer.query_artwork(artwork_id);
            if (res != null) {
                set_service_response(200, res);;
            } else {
                msg.status_code = 302;
                msg.response_headers.append("Location", OnnojiPaths.artwork_url(0));
            }
        }

    }
    
    /**
     * GET /api/v2/[playlist/album]
     */
    private void do_get_all_playlists(bool is_album) throws OnnojiError {
        msg.status_code = 404;
    }
    
    /**
     * POST /api/v2/playlist
     */
    private void do_post_playlist() throws OnnojiError {
        msg.status_code = 405;
    }

    /**
     * POST /api/v2/genre/[genre_id]/icon
     */
    private void do_post_genre_icon(int genre_id) {
        try {
            Soup.Multipart multipart = new Soup.Multipart.from_message(this.msg.request_headers, this.msg.request_body);
            int part_number = multipart.get_length();
            string guid = DBus.generate_guid();
            for (int i = 0; i < part_number; i++) {
                unowned Soup.MessageHeaders headers;
                unowned Soup.Buffer buffer;
                multipart.get_part(i, out headers, out buffer);
                // ディスポジション (ファイル名など) を取得する。

                string disposition_str;
                HashTable<string, string> disposition;
                headers.get_content_disposition(out disposition_str, out disposition);

                if (disposition["name"] == "uploaded-file") {
                    HashTable<string, string> part_content_type_attributes;
                    string part_mime_type = headers.get_content_type(out part_content_type_attributes);
                    string part_file_dir = "/tmp/" + guid;
                    string part_file_path = part_file_dir + "/" + disposition["filename"];
                    File tmp_dir = File.new_for_path(part_file_dir);
                    if (!tmp_dir.query_exists()) {
                        tmp_dir.make_directory();
                    }
                    try {
                        // マルチパートのボディをファイルに出力する

                        FileUtils.set_data(part_file_path, buffer.data);

                        var res = producer.register_genre_icon(genre_id, part_file_path);

                        set_service_response(200, res);

                        return;

                    } catch (FileError e) {

                        printerr("ERROR (FileError): %s\n", e.message);

                        break;
                    }
                }
            }
        } catch (Error e) {
            printerr("ERROR: %s\n", e.message);
        }
        set_service_response(500, null);
    }
    
    /**
     * POST /api/v2/album
     */
    private void do_post_album() throws OnnojiError {
        Soup.Multipart multipart = new Soup.Multipart.from_message(this.msg.request_headers, this.msg.request_body);
        int part_number = multipart.get_length();
        string? album_title = null;
        string guid = DBus.generate_guid();
        File tmpDir = File.new_for_path("/tmp/" + guid);
        tmpDir.make_directory(null);
        Gee.List<PostFileData> file_list = new Gee.ArrayList<PostFileData>();
        debug("do post request: %d part of multipart message was found!", part_number);

        for (int i = 0; i < part_number; i++) {

            // マルチパートのヘッダとボディを取得する

            unowned Soup.MessageHeaders headers;
            unowned Soup.Buffer buffer;
            multipart.get_part(i, out headers, out buffer);

            // ディスポジション (ファイル名など) を取得する。

            string disposition_str;
            HashTable<string, string> disposition;
            headers.get_content_disposition(out disposition_str, out disposition);

            if (disposition["name"] == "album-title") {

                album_title = ((string) buffer.data).substring(0, (int) buffer.length);
            
            } else if (disposition["name"] == "uploaded-file") {

                HashTable<string, string> part_content_type_attributes;
                string part_mime_type = headers.get_content_type(out part_content_type_attributes);
                string part_file_path = "/tmp/" + guid + "/" + disposition["filename"];
                try {

                    // マルチパートのボディをファイルに出力する

                    FileUtils.set_data(part_file_path, buffer.data);
                    
                    // 書き込みに成功したら、ファイルをリストに追加する。
                    
                    file_list.add(new PostFileData() {
                        mime_type = part_mime_type,
                        file_path = part_file_path,
                        file_name = disposition["filename"]
                    });

                } catch (FileError e) {

                    printerr("ERROR (FileError): %s\n", e.message);

                }
            } else {
                debug("unsupported disposition was found: %s", disposition["name"]);
            }
        }
        
        if (album_title == null) {
            msg.status_code = 500;
            return;
        }
        
        var res = producer.register_playlist_with_songs(album_title, file_list);
        set_service_response(200, res);
    }
    
    /**
     * POST/api/v2/playlist
     */
    private void do_get_playlist(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_by_id(playlist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/playlist/[playlist_id]/songs
     */
    private void do_get_playlist_songs(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_songs(playlist_id);
        set_service_response(200, res);
    }

    /**
     * GET /api/v2/playlist/[playlist_id]/genres
     */
    private void do_get_playlist_genres(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_genres(playlist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/playlist/[playlist_id]/artists
     */
    private void do_get_playlist_artists(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_artists(playlist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/playlist/[playlist_id]/artworks
     */
    private void do_get_playlist_artworks(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_artworks(playlist_id);
        if (res != null) {
            set_service_response(200, res);
        } else {
            msg.set_redirect(303, "/api/v2/artwork/0");
        }
    }
    
    /**
     * GET /api/v2/playlist/[playlist_id]/artworks
     */
    private void do_get_playlist_artwork(int playlist_id) throws OnnojiError {

        if (!is_playlist_id_valid(playlist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_playlist_artwork(playlist_id);
        if (res != null) {
            set_service_response(200, res);
        } else {
            msg.set_redirect(303, "/api/v2/artwork/0");
        }
    }
    
    /**
     * GET /api/v2/artist/[artist_id]
     */
    private void do_get_artist(int artist_id) throws OnnojiError {

        if (!is_artist_id_valid(artist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_artist(artist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/artist/[artist_id]/songs
     */
    private void do_get_artist_songs(int artist_id) throws OnnojiError {

        if (!is_artist_id_valid(artist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_artist_songs(artist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/artist/[artist_id]/albums
     */
    private void do_get_artist_albums(int artist_id) throws OnnojiError {

        if (!is_artist_id_valid(artist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_artist_albums(artist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/artist/[artist_id]/playlists
     */
    private void do_get_artist_playlists(int artist_id) throws OnnojiError {

        if (!is_artist_id_valid(artist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_artist_playlists(artist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/artist/[artist_id]/playlists
     */
    private void do_get_artist_genres(int artist_id) throws OnnojiError {

        if (!is_artist_id_valid(artist_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_artist_genres(artist_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/genres
     */
    private void do_get_genres() throws OnnojiError {
        var res = producer.query_genres();
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/genre/[genre_id]/icon
     */
    private void do_get_genre_icon(int genre_id) throws OnnojiError {

        if (!is_genre_id_valid(genre_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_genre_icon(genre_id);
        set_service_response(200, res);
    }

    /**
     * GET /api/v2/genre/[genre_id]/playlists
     */
    private void do_get_genre_playlists(int genre_id) throws OnnojiError {
        
        if (!is_genre_id_valid(genre_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_genre_playlists(genre_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/genre/[genre_id]/albums
     */
    private void do_get_genre_albums(int genre_id) throws OnnojiError {
        
        if (!is_genre_id_valid(genre_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_genre_albums(genre_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/genre/[genre_id]/artists
     */
    private void do_get_genre_artists(int genre_id) throws OnnojiError {
        
        if (!is_genre_id_valid(genre_id)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_genre_artists(genre_id);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-requested/[min-max]/songs
     */
    private void do_get_recently_requested_songs(string min_max) throws OnnojiError {

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_requested_songs(min, max);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-requested/[min-max]/albums
     */
    private void do_get_recently_requested_albums(string min_max) throws OnnojiError {

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_requested_playlists(min, max, true);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-requested/[min-max]/playlist
     */
    private void do_get_recently_requested_playlists(string min_max) throws OnnojiError {

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_requested_playlists(min, max, false);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-registered/[min-max]/songs
     */
    private void do_get_recently_registered_songs(string min_max) throws OnnojiError {

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_registered_songs(min, max);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-registered/[min-max]/albums
     */
    private void do_get_recently_registered_albums(string min_max) throws OnnojiError {
        
        debug("get recently registered albums");

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            debug("get recently registered failed becaused of parameter format");
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            debug("get recently registered failed becaused of parameter validation");
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_registered_playlists(min, max, true);
        set_service_response(200, res);
    }
    
    /**
     * GET /api/v2/recently-registered/[min-max]/playlists
     */
    private void do_get_recently_registered_playlists(string min_max) throws OnnojiError {

        int min, max;
        if (!get_min_max_parameter(min_max, out min, out max)) {
            msg.status_code = 404;
            return;
        }

        if (!is_min_max_valid(min, max)) {
            msg.status_code = 404;
            return;
        }

        var res = producer.query_recently_registered_playlists(min, max, false);
        set_service_response(200, res);
    }

    /*
     * validators
     */
     
    private bool is_song_id_valid(int song_id) {
        return song_id > 0;
    }
    
    private bool is_playlist_id_valid(int playlist_id) {
        return playlist_id > 0;
    }
    
    private bool is_genre_id_valid(int genre_id) {
        return genre_id > 0;
    }
    
    private bool is_artist_id_valid(int artist_id) {
        return artist_id > 0;
    }
    
    private bool is_artwork_id_valid(int artwork_id) {
        return artwork_id > 0;
    }
    
    private bool is_min_max_valid(int min, int max) {
        return (
            (min > 0 && max > 0)
            && (min < max)
        );
    }
    
    /*
     * other functions
     */
     
    private bool get_min_max_parameter(string min_max, out int min, out int max) {
        string[] parts = min_max.split("-");
        if (parts.length == 2) {
            min = int.parse(parts[0]);
            max = int.parse(parts[1]);
            return true;
        } else {
            return false;
        }
    }
}
