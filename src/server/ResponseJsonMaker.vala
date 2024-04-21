public class ResponseJsonMaker : Object {
    public static Json.Node make_song_metadata(SongData data, ArtistData? artist, AlbumData? album, GenreData? genre,
            string song_url, string artwork_url, Gee.Map<string, string> metadata_map) {
        Json.Node song_metadata_json = new Json.Node(Json.NodeType.OBJECT);
        Json.Object song_object = new Json.Object();
        song_metadata_json.init_object(song_object);
        
        song_object.set_string_member("id", data.song_id);
        song_object.set_string_member("title", data.title);
        song_object.set_int_member("artist_id", data.artist_id);
        if (artist != null) {
            song_object.set_string_member("artist_name", artist.name);
        } else {
            song_object.set_null_member("artist_name");
        }
        song_object.set_int_member("genre_id", data.genre_id);
        if (genre != null) {
            song_object.set_string_member("genre_name", genre.name);
        } else {
            song_object.set_null_member("genre_name");
        }
        song_object.set_string_member("album_id", data.album_id);
        if (album != null) {
            song_object.set_string_member("album_name", album.name);
        } else {
            song_object.set_null_member("album_name");
        }
        song_object.set_int_member("disc_number", data.disc_number);
        song_object.set_int_member("track_number", data.track_number);
        song_object.set_int_member("pub_date", data.pub_date);
        if (data.copyright != null) {
            song_object.set_string_member("copyright", data.copyright);
        } else {
            song_object.set_null_member("copyright");
        }
        if (data.comment != null) {
            song_object.set_string_member("comment", data.comment);
        } else {
            song_object.set_null_member("comment");
        }
        song_object.set_string_member("time_length", data.time_length.to_string());
        song_object.set_string_member("mime_type", data.mime_type);
        song_object.set_string_member("data_url", song_url);
        song_object.set_string_member("artwork_url", artwork_url);
        song_object.set_string_member("creation_datetime", data.creation_datetime.format_iso8601());
        Json.Object metadata_object = new Json.Object();
        foreach (var key in metadata_map.keys) {
            metadata_object.set_string_member(key, metadata_map[key]);
        }
        song_object.set_object_member("metadata", metadata_object);
        return song_metadata_json;
    }
    
    public static Json.Node make_songs(Gee.List<Gee.Map<string, string>> songs, Soup.URI req_uri)
            throws OnnojiError {
        Json.Node songs_json = new Json.Node(OBJECT);
        Json.Object root_object = new Json.Object();
        Json.Array song_array = new Json.Array();
        foreach (Gee.Map<string, string> data in songs) {
            Json.Object song_object = new Json.Object();
            if (!data.has_key("SONG_ID")) {
                throw new OnnojiError.LOGICAL_ERROR("SONG_ID must be set");
            }
            song_object.set_string_member("song_id", data["SONG_ID"].substring(0, ID_LENGTH));
            song_object.set_string_member("title", data["TITLE"]);
            if (data["ARTIST_ID"] == "0") {
                song_object.set_null_member("artist_id");
                song_object.set_null_member("artist_name");
            } else {
                song_object.set_int_member("artist_id", int.parse(data["ARTIST_ID"]));
                song_object.set_string_member("artist_name", data["ARTIST_NAME"]);
            }
            if (data["GENRE_ID"] == "0") {
                song_object.set_null_member("genre_id");
                song_object.set_null_member("genre_name");
            } else {
                song_object.set_int_member("genre_id", int.parse(data["GENRE_ID"]));
                song_object.set_string_member("genre_name", data["GENRE_NAME"]);
            }
            if (data.has_key("ALBUM_ID")) {
                song_object.set_string_member("album_id", data["ALBUM_ID"].substring(0, ID_LENGTH));
                song_object.set_string_member("album_name", data["ALBUM_NAME"]);
            } else {
                song_object.set_null_member("album_id");
                song_object.set_null_member("album_name");
            }
            song_object.set_int_member("disc_number", int.parse(data["DISC_NUMBER"]));
            song_object.set_int_member("track_number", int.parse(data["TRACK_NUMBER"]));
            song_object.set_int_member("pub_date", int.parse(data["PUB_DATE"]));
            song_object.set_string_member("copyright", data["COPYRIGHT"]);
            song_object.set_string_member("comment", data["COMMENT"]);
            song_object.set_string_member("time_length", data["TIME_LENGTH"]);
            song_object.set_string_member("mime_type", data["MIME_TYPE"]);

            string file_url = OnnojiUtils.make_song_url(req_uri, data["SONG_ID"]);
            song_object.set_string_member("file_url", file_url);

            if (data.has_key("ARTWORK_FILE_PATH")) {
                string artwork_url = OnnojiUtils.make_artwork_url(req_uri, data["ARTWORK_FILE_PATH"]);
                song_object.set_string_member("artwork_url", artwork_url);
            } else {
                song_object.set_null_member("artwork_url");
            }
            
            string creation_datetime = data["CREATION_DATETIME"];
            song_object.set_string_member("creation_datetime", SqliteUtils.sqldate_to_jsondate(creation_datetime));
                        
            song_array.add_object_element(song_object);
        }
        root_object.set_array_member("songs", song_array);
        songs_json.init_object(root_object);
        return songs_json;
    }

    public static Json.Node make_albums(Gee.List<AlbumDataEx> album_list, GenreData? genre, ArtistData? artist, Soup.Message msg) {
        Json.Node albums_json = new Json.Node(OBJECT);
        Json.Object root_object = new Json.Object();
        if (genre != null) {
            root_object.set_int_member("genre_id", genre.id);
            root_object.set_string_member("genre_name", genre.name);
        }
        if (artist != null) {
            root_object.set_int_member("artist_id", artist.id);
            root_object.set_string_member("artist_name", artist.name);
        }
        Json.Array album_array = new Json.Array();
        for (int i = 0; i < album_list.size; i++) {
            Json.Object album_object = new Json.Object();
            album_object.set_string_member("album_id", album_list[i].id.substring(0, ID_LENGTH));
            album_object.set_string_member("album_name", album_list[i].name);
            Json.Array artist_array = new Json.Array();
            for (int j = 0; j < album_list[i].artists.size; j++) {
                Json.Object artist_object = new Json.Object();
                artist_object.set_int_member("artist_id", album_list[i].artists[j].id);
                artist_object.set_string_member("artist_name", album_list[i].artists[j].name);
                artist_array.add_object_element(artist_object);
            }
            album_object.set_array_member("artists", artist_array);
            if (album_list[i].has_artwork) {
                album_object.set_string_member("album_artwork",
                        OnnojiUtils.make_artwork_url(msg.uri, album_list[i].first_artwork_file_path));
            } else {
                album_object.set_null_member("album_artwork");
            }
            if (album_list[i].creation_datetime != null) {
                album_object.set_string_member("creation_datetime", album_list[i].creation_datetime.format_iso8601());
            } else {
                album_object.set_null_member("creation_datetime");
            }
            if (album_list[i].last_request_datetime != null) {
                album_object.set_string_member("last_request_datetime", album_list[i].last_request_datetime.format_iso8601());
            } else {
                album_object.set_null_member("last_request_datetime");
            }
            album_array.add_object_element(album_object);
        }
        root_object.set_array_member("albums", album_array);
        albums_json.set_object(root_object);
        return albums_json;
    }

    public static Json.Node make_artists(Gee.List<ArtistData> artist_list, GenreData? genre, AlbumData? album) {
        Json.Node artists_json = new Json.Node(OBJECT);
        Json.Object root_object = new Json.Object();
        Json.Array artist_array = new Json.Array();
        if (genre != null) {
            root_object.set_int_member("genre_id", genre.id);
            root_object.set_string_member("genre_name", genre.name);
        }
        if (album != null) {
            root_object.set_string_member("album_id", album.id);
            root_object.set_string_member("album_name", album.name);
        }
        for (int i = 0; i < artist_list.size; i++) {
            Json.Object artist_object = new Json.Object();
            artist_object.set_int_member("artist_id", artist_list[i].id);
            artist_object.set_string_member("artist_name", artist_list[i].name);
            artist_array.add_object_element(artist_object);
        }
        root_object.set_array_member("artists", artist_array);
        artists_json.set_object(root_object);
        return artists_json;
    }
    
    public static Json.Node make_genres(Gee.List<GenreData> genre_list, Soup.Message msg) {
        Json.Node genres_json = new Json.Node(OBJECT);
        Json.Object root_object = new Json.Object();
        Json.Array genre_array = new Json.Array();
        for (int i = 0; i < genre_list.size; i++) {
            Json.Object genre_object = new Json.Object();
            genre_object.set_int_member("genre_id", genre_list[i].id);
            genre_object.set_string_member("genre_name", genre_list[i].name);
            genre_object.set_string_member("icon", OnnojiUtils.make_genre_icon_url(msg.uri, genre_list[i].id));
            genre_array.add_object_element(genre_object);
        }
        root_object.set_array_member("genres", genre_array);
        genres_json.set_object(root_object);
        return genres_json;
    }
}
