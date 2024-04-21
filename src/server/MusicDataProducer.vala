public class MusicDataProducer : Object {
    public unowned Sqlite.Database db;
    public unowned Songs songs;
    public unowned Albums albums;
    public unowned Genres genres;
    public unowned Artists artists;
    public unowned History history;
    
    public SongData? query_song_by_id_lazy(string song_id, out int response_status) throws OnnojiError {
        SongData? song = null;
        bool song_exists = songs.song_exists_lazy(song_id);
        if (song_exists) {
            stdout.puts("song_exists\n");
            SongData? _song = songs.find_by_id_lazy(song_id);
            if (_song != null) {
                stdout.puts("song is found\n");
                song = (owned) _song;
                response_status = 200;
            } else {
                response_status = 404;
            }
        } else {
            response_status = 404;
        }
        return song;
    }

    public SongData? query_artwork_by_id_lazy(string artwork_id, out int response_status) throws OnnojiError {
        SongData? song = songs.find_by_artwork_id_lazy(artwork_id);
        if (song != null) {
            stdout.puts("artwork is found\n");
            response_status = 200;
            return song;
        } else {
            response_status = 404;
            return null;
        }
    }
    
    private Moegi.MetadataReader meta_reader;
    
    public Json.Node? assemble_metadata(string song_id, Soup.URI req_uri, out int response_status) 
            throws OnnojiError {
        int res;
        SongData song = query_song_by_id_lazy(song_id, out res);
        if (res != 200) {
            response_status = res;
            return null;
        } else {
            response_status = res;
        }
        GenreData? genre = genres.find_genre_by_id(song.genre_id);
        ArtistData? artist = artists.find_artist_by_id(song.artist_id);
        AlbumData? album = albums.find_album_by_id(song.album_id);
        string song_url = OnnojiUtils.make_song_url(req_uri, song.song_id);
        string artwork_url = OnnojiUtils.make_artwork_url(req_uri, song.artwork_file_path);

        if (meta_reader == null) {
            meta_reader = new Moegi.MetadataReader();
        }
        Gee.Map<string, string> metadata_map = new Gee.HashMap<string, string>();
        print("get metadata of %s", song.title);
        meta_reader.tag_found.connect((tag, value) => {
            print(@"    $(tag.down()) => $(value.type_name())\n");
            if (value.holds(typeof(string))) {
                metadata_map[tag.down()] = value.get_string();
            } else if (value.holds(typeof(uint))) {
                metadata_map[tag.down()] = value.get_uint().to_string();
            } else if (value.holds(typeof(Gst.DateTime))) {
                Gst.DateTime datetime = (Gst.DateTime) value.get_boxed();
                metadata_map[tag.down()] = datetime.to_iso8601_string();
            }
            return true;
        });
        try {
            meta_reader.get_metadata(song.file_path);
        } catch (Moegi.Error e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        } catch (GLib.Error e) {
            throw new OnnojiError.OTHER_ERROR(e.message);
        }

        Json.Node? response_json = ResponseJsonMaker.make_song_metadata(song,
                artist, album, genre, song_url, artwork_url, metadata_map);
        return response_json;
    }

    public Json.Node? assemble_songs(string? album_id, int artist_id, Soup.URI req_uri, out int response_status)
            throws OnnojiError {
        Gee.List<Gee.Map<string, string>> song_list = songs.map_find_all(album_id, artist_id);
        if (song_list.size == 0) {
            response_status = 404;
            return null;
        }
        response_status = 200;
        return ResponseJsonMaker.make_songs(song_list, req_uri);
    }
    
    public Json.Node? assemble_albums_by_genre_id(int genre_id, Soup.Message msg, out int response_status) throws OnnojiError {
        Gee.List<AlbumDataEx> album_list = albums.find_by_genre_id(genre_id);
        if (album_list.size == 0) {
            response_status = 404;
            return null;
        }
        GenreData? genre = genres.find_genre_by_id(genre_id);
        response_status = 200;
        return ResponseJsonMaker.make_albums(album_list, genre, null, msg);
    }
    
    public Json.Node? assemble_albums_by_artist_id(int artist_id, bool is_lazy, Soup.Message msg, out int response_status) throws OnnojiError {
        Gee.List<AlbumDataEx> album_list = albums.find_by_artist_id(artist_id, is_lazy);
        if (album_list.size == 0) {
            response_status = 404;
            return null;
        }
        ArtistData? artist = artists.find_artist_by_id(artist_id);
        response_status = 200;
        return ResponseJsonMaker.make_albums(album_list, null, artist, msg);
    }
    
    public Json.Node? assemble_albums_recently_created(int recently_created_limit, Soup.Message msg, out int response_status) throws OnnojiError {
        Gee.List<AlbumDataEx> album_list = albums.find_recently_created(recently_created_limit);
        if (album_list.size == 0) {
            response_status = 404;
            return null;
        }
        response_status = 200;
        return ResponseJsonMaker.make_albums(album_list, null, null, msg);
    }
    
    public Json.Node? assemble_albums_recently_requested(int recently_requested_limit, Soup.Message msg, out int response_status) throws OnnojiError {
        Gee.List<AlbumDataEx> album_list = albums.find_recently_requested(recently_requested_limit);
        if (album_list.size == 0) {
            response_status = 404;
            return null;
        }
        response_status = 200;
        return ResponseJsonMaker.make_albums(album_list, null, null, msg);
    }
    
    public Json.Node? assemble_artists(int genre_id, string? album_id, out int response_status)
            throws OnnojiError {
        Gee.List<ArtistData> artist_list = artists.find_all(genre_id, album_id);
        GenreData? genre = genre_id > 0 ? genres.find_genre_by_id(genre_id) : null;
        AlbumData? album = album_id != null ? albums.find_album_by_id(album_id) : null;
        if (artist_list.size == 0) {
            response_status = 404;
            return null;
        }
        response_status = 200;
        return ResponseJsonMaker.make_artists(artist_list, genre, album);
    }
    
    public Json.Node? assemble_genres(Soup.Message msg) throws OnnojiError {
        Gee.List<GenreData> genre_list = genres.find_all();
        return ResponseJsonMaker.make_genres(genre_list, msg);
    }
}
