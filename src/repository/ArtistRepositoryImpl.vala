public class ArtistRepositoryImpl : ArtistRepository, BasicRepositoryImpl {
    
    public ArtistRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.res = res as XmlResourceManager;
        this.conn = conn;
    }

    public int get_next_artist_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("artist-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next artist id!");
        }
    }
    
    public Gee.List<Artist> select_all() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("artist-select-all"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);
        
        Gee.List<Artist> list = new Gee.ArrayList<Artist>();
        
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new Artist() {
                artist_id = iter.get_value_at(0).get_int(),
                artist_name = iter.get_value_at(1).get_string()
            });
        }
        return list;
    }
    
    public Gee.List<Artist> select_by_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-id", "artist-id-ge");
                param_name = "ge_artist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-id", "artist-id-le");
                param_name = "le_artist_id";
            } else {
                sql = res.get_string_with_params("artist-select-by-id", "artist-id-equals");
                param_name = "equals_artist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-id", "artist-id-gt");
            param_name = "gt_artist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-id", "artist-id-lt");
            param_name = "lt_artist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artists(sql, param_name, Values.of_int(artist_id));
    }
    
    public Gee.List<Artist> select_by_name(string artist_name, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        switch (cond_type) {
          case STARTS_WITH:
            sql = res.get_string_with_params("artist-select-by-name", "artist-name-starts-with");
            param_name = "starts_with_artist_name";
            break;
          case ENDS_WITH:
            sql = res.get_string_with_params("artist-select-by-name", "artist-name-ends-with");
            param_name = "ends_with_artist_name";
            break;
          case INCLUDES:
            sql = res.get_string_with_params("artist-select-by-name", "artist-name-includes");
            param_name = "includes_artist_name";
            break;
          case EQUALS:
          default:
            sql = res.get_string_with_params("artist-select-by-name", "artist-name-equals");
            param_name = "equals_artist_name";
            break;
        }
        return fetch_artists(sql, param_name, Values.of_string(artist_name));
    }
    
    public Gee.List<Artist> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-song-id", "song-id-ge");
                param_name = "ge_song_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-song-id", "song-id-le");
                param_name = "le_song_id";
            } else {
                sql = res.get_string_with_params("artist-select-by-song-id", "song-id-equals");
                param_name = "equals_song_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-song-id", "song-id-gt");
            param_name = "gt_song_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-song-id", "song-id-lt");
            param_name = "lt_song_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artists(sql, param_name, Values.of_int(song_id));
    }
    
    public Gee.List<Artist> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-genre-id", "genre-id-ge");
                param_name = "ge_genre_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-genre-id", "genre-id-le");
                param_name = "le_genre_id";
            } else {
                sql = res.get_string_with_params("artist-select-by-genre-id", "genre-id-equals");
                param_name = "equals_genre_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-genre-id", "genre-id-gt");
            param_name = "gt_genre_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-genre-id", "genre-id-lt");
            param_name = "lt_genre_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artists(sql, param_name, Values.of_int(genre_id));
    }
    
    public Gee.List<Artist> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-playlist-id", "playlist-id-ge");
                param_name = "ge_playlist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artist-select-by-playlist-id", "playlist-id-le");
                param_name = "le_playlist_id";
            } else {
                sql = res.get_string_with_params("artist-select-by-playlist-id", "playlist-id-equals");
                param_name = "equals_playlist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-playlist-id", "playlist-id-gt");
            param_name = "gt_playlist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artist-select-by-playlist-id", "playlist-id-lt");
            param_name = "lt_playlist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artists(sql, param_name, Values.of_int(playlist_id));
    }
    
    public bool delete_by_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artist-delete-by-id", "artist-id-ge");
                param_name = "ge_artist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artist-delete-by-id", "artist-id-le");
                param_name = "le_artist_id";
            } else {
                sql = res.get_string_with_params("artist-delete-by-id", "artist-id-equals");
                param_name = "equals_artist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artist-delete-by-id", "artist-id-gt");
            param_name = "gt_artist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artist-delete-by-id", "artist-id-lt");
            param_name = "lt_artist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not deleteable");
        }
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(sql, null),
            param_name, Values.of_int(artist_id)
        );
        if (num_affected > 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to artist");
        }
        return num_affected == 1;
    }
    
    public bool update_by_id(int artist_id, string new_artist_name) throws Error {
        string sql = res.get_string_with_params("artist-update-by-id");
        bool result = conn.update_row_in_table_v(
            "artist", "artist_id", Values.of_int(artist_id),
            slist<string>("artist_name"), slist<Value?>(Values.of_string(new_artist_name))
        );
        return result;
    }
    
    public bool insert(Artist artist, SqlInsertFlags flags) throws Error {
        return conn.insert_row_into_table_v(
            "artist",
            slist<string>("artist_id", "artist_name"),
            slist<Value?>(
                Values.of_int(
                    GENERATE_NEXT_ID in flags ? get_next_artist_id() : artist.artist_id
                ),
                Values.of_string(artist.artist_name)
            )
        );
    }

    public bool insert_link_to_song(Artist artist, Song song) throws Error {
        return conn.insert_row_into_table_v(
            "song_artist",
            slist<string>("song_id", "artist_id"),
            slist<Value?>(
                Values.of_int(song.song_id), Values.of_int(artist.artist_id)
            )
        );
    }
    
    public bool delete_link_to_song(Artist artist, Song song) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-artist"), null),
            "song_id", Values.of_int(song.song_id),
            "artist_id", Values.of_int(artist.artist_id)
        );
        if (num_affected > 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying update statement to artist");
        }
        return num_affected == 1;
    }
    
    private Gee.List<Artist> fetch_artists(string sql, string param_name, Value param_value) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(sql, null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder(param_name).set_value(param_value);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Artist> list = new Gee.ArrayList<Artist>();
        
        if (model.get_n_rows() == 0) {
            debug("Got 0 recourd (genres selected by song id)");
            return list;
        }
        
        var iter = model.create_iter();
        
        while (iter.move_next()) {
            list.add(new Artist() {
                artist_id = iter.get_value_at(0).get_int(),
                artist_name = iter.get_value_at(1).get_string()
            });
        }
        return list;
    }
}
