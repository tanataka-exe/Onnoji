public class PlaylistRepositoryImpl : PlaylistRepository, BasicRepositoryImpl {
    
    public PlaylistRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.conn = conn;
        this.res = res as XmlResourceManager;
    }
    
    public int get_next_playlist_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("playlist-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next artwork id!");
        }
    }

    public Gee.List<Playlist> select_by_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-id", "playlist-id-ge");
                param_name = "ge_playlist_id";
                debug("playlist select ge");
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-id", "playlist-id-le");
                param_name = "le_playlist_id";
                debug("playlist select le");
            } else {
                sql = res.get_string_with_params("playlist-select-by-id", "playlist-id-equals");
                param_name = "equals_playlist_id";
                debug("playlist select equals");
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-id", "playlist-id-gt");
            param_name = "gt_playlist_id";
            debug("playlist select gt");
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-id", "playlist-id-lt");
            param_name = "lt_playlist_id";
            debug("playlist select lt");
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug(sql);
        return fetch_playlists(sql, param_name, Values.of_int(playlist_id));
    }

    public Gee.List<Playlist> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-genre-id", "genre-id-ge");
                param_name = "ge_genre_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-genre-id", "genre-id-le");
                param_name = "le_genre_id";
            } else {
                sql = res.get_string_with_params("playlist-select-by-genre-id", "genre-id-equals");
                param_name = "equals_genre_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-genre-id", "genre-id-gt");
            param_name = "gt_genre_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-genre-id", "genre-id-lt");
            param_name = "lt_genre_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug(sql);
        return fetch_playlists(sql, param_name, Values.of_int(genre_id));
    }

    public Gee.List<Playlist> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-artist-id", "artist-id-ge");
                param_name = "ge_artist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-artist-id", "artist-id-le");
                param_name = "le_artist_id";
            } else {
                sql = res.get_string_with_params("playlist-select-by-artist-id", "artist-id-equals");
                param_name = "equals_artist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-artist-id", "artist-id-gt");
            param_name = "gt_artist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-artist-id", "artist-id-lt");
            param_name = "lt_artist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug(sql);
        return fetch_playlists(sql, param_name, Values.of_int(artist_id));
    }

    public Gee.List<Playlist> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-song-id", "song-id-ge");
                param_name = "ge_song_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("playlist-select-by-song-id", "song-id-le");
                param_name = "le_song_id";
            } else {
                sql = res.get_string_with_params("playlist-select-by-song-id", "song-id-equals");
                param_name = "equals_song_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-song-id", "song-id-gt");
            param_name = "gt_song_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("playlist-select-by-song-id", "song-id-lt");
            param_name = "lt_song_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug(sql);
        return fetch_playlists(sql, param_name, Values.of_int(song_id));
    }

    public Gee.List<Playlist> select_recently_requested(int min, int max, bool is_album) throws Error {
        return fetch_playlists(
            res.get_string("playlist-select-recently-requested"),
            "is_album", Values.of_string(is_album ? "1" : "0"),
            "min_limit", Values.of_int(min),
            "max_limit", Values.of_int(max)
        );
    }
    
    public Gee.List<Playlist> select_recently_registered(int min, int max, bool is_album) throws Error {
        return fetch_playlists(
            res.get_string("playlist-select-recently-registered"),
            "is_album", Values.of_string(is_album ? "1" : "0"),
            "min_limit", Values.of_int(min),
            "max_limit", Values.of_int(max)
        );
    }
    
    public bool delete_by_id(int playlist_id) throws Error { 
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("playlist-delete-by-id"), null),
            "playlist_id", Values.of_int(playlist_id)
        );
        return num_affected == 1;
    }
    
    public bool update_by_id(int playlist_id, SList<string> col_names, SList<Value?> col_values) throws Error {
        if (col_names.search<string>("update_datetime", (a, b) => a.collate(b)) == null) {
            col_names.append("update_datetime");
            col_values.append(Values.of_gda_timestamp(create_gda_timestamp_now_local()));
        }
        return conn.update_row_in_table_v(
            "playlist",
            "playlist_id",
            Values.of_int(playlist_id),
            col_names, col_values
        );
    }
    
    public bool insert(Playlist playlist, SqlInsertFlags flags = 0) throws Error {
        return conn.insert_row_into_table_v(
            "playlist",
            slist<string>("playlist_id", "playlist_name", "is_album", "creation_datetime"),
            slist<Value?>(
                Values.of_int(
                    GENERATE_NEXT_ID in flags ? get_next_playlist_id() : playlist.playlist_id
                ),
                Values.of_string(playlist.playlist_name),
                Values.of_string(playlist.is_album ? "1" : "0"),
                Values.of_gda_timestamp(playlist.creation_datetime)
            )
        );
    }

    public bool insert_link_to_song(Playlist playlist, Song song, int disc_number, int track_number) throws Error {
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
    
    public bool delete_link_to_song(Playlist playlist, Song song) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-playlist"), null),
            "song_id", Values.of_int(song.song_id),
            "playlist_id", Values.of_int(playlist.playlist_id)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to playlist");
        }
        return true;
    }
    
    public bool update_link_to_song(Playlist playlist, Song song, int disc_number, int track_number) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-update-link-to-playlist"), null),
            "song_id", Values.of_int(song.song_id),
            "playlist_id", Values.of_int(playlist.playlist_id),
            "disc_number", Values.of_int(disc_number),
            "track_number", Values.of_int(track_number)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to playlist");
        }
        return true;
    }
    
    private Gee.List<Playlist> fetch_playlists(string sql, ...) throws Error {
        var l = va_list();
        Gda.Statement stmt = conn.create_parser().parse_string(sql, null);
        Gda.Set params;
        stmt.get_parameters(out params);
        while (true) {
            string? param_name = l.arg();
            if (param_name == null) {
                break;
            }
            Value param_value = l.arg();
            params.get_holder(param_name).set_value(param_value);
        }
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Playlist> list = new Gee.ArrayList<Playlist>();
        
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new Playlist() {
                playlist_id = iter.get_value_at(0).get_int(),
                playlist_name = iter.get_value_at(1).get_string(),
                is_album = iter.get_value_at(2).get_string() == "1",
                creation_datetime = (Gda.Timestamp) iter.get_value_at(3).get_boxed(),
                update_datetime = (Gda.Timestamp) iter.get_value_at(4)?.get_boxed()
            });
        }
        return list;
    }
}
