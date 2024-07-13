public class SongRepositoryImpl : SongRepository, BasicRepositoryImpl {

    public SongRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.conn = conn;
        this.res = res as XmlResourceManager;
    }
    
    public int get_next_song_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("song-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next artwork id!");
        }
    }

    public Gee.List<Song> select_by_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        switch (cond_type) {
          case STARTS_WITH:
            sql = res.get_string_with_params("song-select-by-id", "song-id-starts-with");
            param_name = "starts_with_song_id";
            break;
          case ENDS_WITH:
            sql = res.get_string_with_params("song-select-by-id", "song-id-ends-with");
            param_name = "ends_with_song_id";
            break;
          case INCLUDES:
            sql = res.get_string_with_params("song-select-by-id", "song-id-includes");
            param_name = "includes_song_id";
            break;
          case EQUALS:
          default:
            sql = res.get_string_with_params("song-select-by-id", "song-id-equals");
            param_name = "equals_song_id";
            break;
        }
        debug(sql);
        return fetch_songs(sql, param_name, Values.of_int(song_id));
    }

    public Gee.List<Song> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        switch (cond_type) {
          case STARTS_WITH:
            sql = res.get_string_with_params("song-select-by-playlist-id", "playlist-id-starts-with");
            param_name = "starts_with_playlist_id";
            break;
          case ENDS_WITH:
            sql = res.get_string_with_params("song-select-by-playlist-id", "playlist-id-ends-with");
            param_name = "ends_with_playlist_id";
            break;
          case INCLUDES:
            sql = res.get_string_with_params("song-select-by-playlist-id", "playlist-id-includes");
            param_name = "includes_playlist_id";
            break;
          case EQUALS:
          default:
            sql = res.get_string_with_params("song-select-by-playlist-id", "playlist-id-equals");
            param_name = "equals_playlist_id";
            break;
        }
        debug("%s (%s)", sql, param_name);
        return fetch_songs(sql, param_name, Values.of_int(playlist_id));
    }

    public Gee.List<Song> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type && GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-artist-id", "artist-id-ge");
            param_name = "ge_artist_id";
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-artist-id", "artist-id-gt");
            param_name = "gt_artist_id";
        } else if (EQUALS in cond_type && LESS_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-artist-id", "artist-id-le");
            param_name = "le_artist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-artist-id", "artist-id-lt");
            param_name = "lt_artist_id";
        } else if (EQUALS in cond_type) {
            sql = res.get_string_with_params("song-select-by-artist-id", "artist-id-equals");
            param_name = "equals_artist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_songs(sql, param_name, Values.of_int(artist_id));
    }

    public Gee.List<Song> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("song-select-by-genre-id", "genre-id-ge");
                param_name = "ge_genre_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("song-select-by-genre-id", "genre-id-le");
                param_name = "le_genre_id";
            } else {
                sql = res.get_string_with_params("song-select-by-genre-id", "genre-id-equals");
                param_name = "equals_genre_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-genre-id", "genre-id-gt");
            param_name = "gt_genre_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("song-select-by-genre-id", "genre-id-lt");
            param_name = "lt_genre_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_songs(sql, param_name, Values.of_int(genre_id));
    }

    public Gee.List<Song> select_recently_requested(int min, int max) throws Error {
        return fetch_songs(
            res.get_string("song-select-recently-requested"),
            "min_limit", Values.of_int(min),
            "max_limit", Values.of_int(max)
        );
    }
    
    public Gee.List<Song> select_recently_registered(int min, int max) throws Error {
        return fetch_songs(
            res.get_string("song-select-recently-registered"),
            "min_limit", Values.of_int(min),
            "max_limit", Values.of_int(max)
        );
    }
    
    private Gee.List<Song> fetch_songs(string sql, ...) throws Error {
        var l = va_list();
        Gda.Statement stmt = conn.create_parser().parse_string(sql, null);
        Gda.Set params;
        stmt.get_parameters(out params);
        while (true) {
            string? param_name = l.arg();
            if (param_name == null) {
                break;
            }
            Value? param_value = l.arg();
            params.get_holder(param_name).set_value(param_value);
        }
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Song> list = new Gee.ArrayList<Song>();
        
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new Song() {
                song_id = iter.get_value_at(0).get_int(),
                title = Values.extract_string_or_null(iter.get_value_at(1)),
                pub_date = iter.get_value_at(2).get_int(),
                copyright = Values.extract_string_or_null(iter.get_value_at(3)),
                comment = Values.extract_string_or_null(iter.get_value_at(4)),
                time_length_milliseconds = iter.get_value_at(5).get_int(),
                mime_type = Values.extract_string_or_null(iter.get_value_at(6)),
                digest = iter.get_value_at(7).get_string(),
                file_path = iter.get_value_at(8).get_string(),
                artwork_id = iter.get_value_at(9).get_int(),
                creation_datetime = (Gda.Timestamp) iter.get_value_at(10).get_boxed()
            });
        }
        return list;
    }

    public bool delete_by_id(int song_id) throws Error {
        int rows = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-by-id"), null),
            "song_id", Values.of_int(song_id)
        );
        if (rows > 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to song");
        }
        return rows == 1;
    }
    
    public bool update_by_id(int song_id, Gee.Map<string, Value?> params) throws Error {
        SList<string> names = new SList<string>();
        SList<Value?> values = new SList<Value?>();
        foreach (string key in params.keys) {
            names.append(key);
            values.append(params[key]);
        }
        return conn.update_row_in_table_v("song", "song_id", song_id, names, values);
    }

    public bool update_by_id_v(int song_id, SList<string> param_names, SList<Value?> param_values) throws Error {
        return conn.update_row_in_table_v("song", "song_id", song_id, param_names, param_values);
    }
    
    public bool insert(Song song, SqlInsertFlags flags) throws Error {
        return conn.insert_row_into_table_v(
            "song",
            slist<string>(
                "song_id",
                "title",
                "pub_date",
                "copyright",
                "comment",
                "time_length_milliseconds",
                "mime_type",
                "digest",
                "file_path",
                "artwork_id",
                "creation_datetime"
            ),
            slist<Value?>(
                GENERATE_NEXT_ID in flags ?
                    Values.of_int(get_next_song_id())
                    : Values.of_int(song.song_id),
                Values.of_string(song.title),
                Values.of_int(song.pub_date),
                Values.of_string(song.copyright),
                Values.of_string(song.comment),
                Values.of_uint(song.time_length_milliseconds),
                Values.of_string(song.mime_type),
                Values.of_string(song.digest),
                Values.of_string(song.file_path),
                Values.of_int(song.artwork_id),
                Values.of_gda_timestamp(song.creation_datetime)
            )
        );
    }
    
    public bool exists_link_to_playlist(Song song, Playlist playlist) throws Error {
        Gda.DataModel data = execute_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-select-link-to-playlist"), null),
            "song_id", Values.of_int(song.song_id),
            "playlist_id", Values.of_int(playlist.playlist_id)
        );
        return (data.get_n_rows() > 0);
    }
    
    public bool insert_link_to_playlist(Song song, Playlist playlist, int disc_number, int track_number) throws Error {
        return conn.insert_row_into_table_v(
            "song_playlist",
            slist<string>("song_id", "playlist_id", "disc_number", "track_number"),
            slist<Value?>(
                Values.of_int(song.song_id),
                Values.of_int(playlist.playlist_id),
                Values.of_int(disc_number),
                Values.of_int(track_number)
            )
        );
    }
    
    public bool update_link_to_playlist(Song song, Playlist playlist, int disc_number, int track_number) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-update-link-to-playlist"), null),
            "song_id", Values.of_int(song.song_id),
            "playlist_id", Values.of_int(playlist.playlist_id),
            "disc_number", Values.of_int(disc_number),
            "track_number", Values.of_int(track_number)
        );
        return num_affected == 1;
    }
    
    public bool delete_link_to_playlist(Song song, Playlist playlist) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-playlist"), null),
            "song_id", Values.of_int(song.song_id),
            "playlist_id", Values.of_int(playlist.playlist_id)
        );
        return num_affected == 1;
    }

    public bool exists_link_to_artist(Song song, Artist artist) throws Error {
        Gda.DataModel data = execute_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-select-link-to-artist"), null),
            "song_id", Values.of_int(song.song_id),
            "artist_id", Values.of_int(artist.artist_id)
        );
        return (data.get_n_rows() > 0);
    }
    
    public bool insert_link_to_artist(Song song, Artist artist) throws Error {
        return conn.insert_row_into_table_v(
            "song_artist",
            slist<string>("song_id", "artist_id"),
            slist<Value?>(Values.of_int(song.song_id), Values.of_int(artist.artist_id))
        );
    }
    
    public bool delete_link_to_artist(Song song, Artist artist) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-artist"), null),
            "song_id", Values.of_int(song.song_id),
            "artist_id", Values.of_int(artist.artist_id)
        );
        return num_affected == 1;
    }

    public bool exists_link_to_genre(Song song, Genre genre) throws Error {
        Gda.DataModel data = execute_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-select-link-to-genre"), null),
            "song_id", Values.of_int(song.song_id),
            "genre_id", Values.of_int(genre.genre_id)
        );
        return (data.get_n_rows() > 0);
    }
    
    public bool insert_link_to_genre(Song song, Genre genre) throws Error {
        return conn.insert_row_into_table_v(
            "song_genre",
            slist<string>("song_id", "genre_id"),
            slist<Value?>(Values.of_int(song.song_id), Values.of_int(genre.genre_id))
        );
    }
    
    public bool delete_link_to_genre(Song song, Genre genre) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-genre"), null),
            "song_id", Values.of_int(song.song_id),
            "genre_id", Values.of_int(genre.genre_id)
        );
        return num_affected == 1;
    }
}
