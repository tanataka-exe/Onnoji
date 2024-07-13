public class ResponseJsonMaker : Object {
    public Json.Node object_node(Json.Object obj) {
        Json.Node node = new Json.Node(Json.NodeType.OBJECT);
        node.init_object(obj);
        return node;
    }

    public Json.Node array_node(Json.Array arr) {
        Json.Node node = new Json.Node(Json.NodeType.ARRAY);
        node.init_array(arr);
        return node;
    }

    public Json.Node named_array_node(string name, Json.Array arr) {
        Json.Object parent_obj = new Json.Object();
        parent_obj.set_array_member(name, arr);
        return object_node(parent_obj);
    }

    public Json.Node named_object_node(string name, Json.Object obj) {
        Json.Object parent_obj = new Json.Object();
        parent_obj.set_object_member(name, obj);
        return object_node(parent_obj);
    }

    public Json.Array empty_array() {
        return new Json.Array();
    }
    
    public Json.Object song_metadata_object(Song song) {
        Json.Object song_object = new Json.Object();
        song_object.set_int_member("songId", song.song_id);
        song_object.set_string_member("title", song.title);
        if (song.pub_date != 0) {
            song_object.set_int_member("pubDate", song.pub_date);
        } else {
            song_object.set_null_member("pubDate");
        }
        if (song.copyright != null) {
            song_object.set_string_member("copyright", song.copyright);
        } else {
            song_object.set_null_member("copyright");
        }
        if (song.comment != null) {
            song_object.set_string_member("comment", song.comment);
        } else {
            song_object.set_null_member("comment");
        }
        song_object.set_string_member("mimeType", song.mime_type);
        song_object.set_string_member("digest", song.digest);
        song_object.set_int_member("timeLengthMilliseconds", song.time_length_milliseconds);
        song_object.set_string_member("artists", OnnojiPaths.song_artists_url(song.song_id));
        song_object.set_string_member("genres", OnnojiPaths.song_genres_url(song.song_id));
        song_object.set_string_member("albums", OnnojiPaths.song_albums_url(song.song_id));
        song_object.set_string_member("playlists", OnnojiPaths.song_playlists_url(song.song_id));
        song_object.set_string_member("stream", OnnojiPaths.song_stream_url(song.song_id));
        song_object.set_string_member("artwork", OnnojiPaths.song_artwork_url(song.song_id));
        return song_object;
    }
    
    public Json.Array song_array(Gee.List<Song> songs) throws OnnojiError {
        Json.Array song_array = new Json.Array();
        foreach (Song song in songs) {
            song_array.add_object_element(song_metadata_object(song));
        }
        return song_array;
    }

    public Json.Array artwork_array(Gee.List<Artwork> artworks) throws OnnojiError {
        Json.Array artwork_array = new Json.Array();
        foreach (Artwork artwork in artworks) {
            artwork_array.add_string_element(OnnojiPaths.artwork_url(artwork.artwork_id));
        }
        return artwork_array;
    }

    public Json.Object playlist_object(Playlist playlist) {
        Json.Object obj = new Json.Object();
        if (playlist.is_album) {
            obj.set_int_member("albumId", playlist.playlist_id);
            obj.set_string_member("albumName", playlist.playlist_name);
        } else {
            obj.set_int_member("playlistId", playlist.playlist_id);
            obj.set_string_member("playlistName", playlist.playlist_name);
        }
        obj.set_boolean_member("isAlbum", playlist.is_album);
        obj.set_string_member("creationDatetime", format_gda_timestamp(playlist.creation_datetime, "%Y-%m-%d %H:%M:%S"));
        obj.set_string_member("updateDatetime", format_gda_timestamp(playlist.update_datetime, "%Y-%m-%d %H:%M:%S"));
        obj.set_string_member("artworks", OnnojiPaths.playlist_artworks_url(playlist.playlist_id));
        obj.set_string_member("artists", OnnojiPaths.playlist_artists_url(playlist.playlist_id));
        obj.set_string_member("genres", OnnojiPaths.playlist_genres_url(playlist.playlist_id));
        obj.set_string_member("songs", OnnojiPaths.playlist_songs_url(playlist.playlist_id));
        return obj;
    }
    
    public Json.Array playlist_array(Gee.List<Playlist> playlists) {
        Json.Array playlist_array = new Json.Array();
        foreach (Playlist playlist in playlists) {
            playlist_array.add_object_element(playlist_object(playlist));
        }
        return playlist_array;
    }

    public Json.Object artist_object(Artist artist) {
        Json.Object obj = new Json.Object();
        obj.set_int_member("artistId", artist.artist_id);
        obj.set_string_member("artistName", artist.artist_name);
        obj.set_string_member("albums", OnnojiPaths.artist_albums_url(artist.artist_id));
        obj.set_string_member("songs", OnnojiPaths.artist_songs_url(artist.artist_id));
        obj.set_string_member("genres", OnnojiPaths.artist_genres_url(artist.artist_id));
        return obj;
    }
    
    public Json.Array artist_array(Gee.List<Artist> artists) {
        Json.Array array = new Json.Array();
        foreach (Artist artist in artists) {
            array.add_object_element(artist_object(artist));
        }
        return array;
    }

    public Json.Object genre_object(Genre genre) {
        Json.Object obj = new Json.Object();
        obj.set_int_member("genreId", genre.genre_id);
        obj.set_string_member("genreName", genre.genre_name);
        obj.set_string_member("icon", OnnojiPaths.genre_icon_url(genre.genre_id));
        obj.set_string_member("albums", OnnojiPaths.genre_albums_url(genre.genre_id));
        obj.set_string_member("playlists", OnnojiPaths.genre_playlists_url(genre.genre_id));
        obj.set_string_member("artists", OnnojiPaths.genre_artists_url(genre.genre_id));
        return obj;
    }
    
    public Json.Array genre_array(Gee.List<Genre> genre_list) {
        Json.Array genre_array = new Json.Array();
        foreach (Genre genre in genre_list) {
            genre_array.add_object_element(genre_object(genre));
        }
        return genre_array;
    }
    
    public Json.Object success_object(string? message = null) {
        Json.Object obj = new Json.Object();
        obj.set_string_member("status", "success");
        if (message != null) {
            obj.set_string_member("message", message);
        }
        return obj;
    }

    public Json.Object failure_object(string? message = null) {
        Json.Object obj = new Json.Object();
        obj.set_string_member("status", "failure");
        if (message != null) {
            obj.set_string_member("message", message);
        }
        return obj;
    }
}
