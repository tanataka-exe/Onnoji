public class GenreRepositoryImpl : GenreRepository, BasicRepositoryImpl {

    public GenreRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.conn = conn;
        this.res = res as XmlResourceManager;
    }
    
    public int get_next_genre_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("genre-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next genre id!");
        }
    }

    public Gee.List<Genre> select_all() throws Error {
        debug("select_all");
        return select_by_id(0, GREATER_THAN | EQUALS);
    }

    public Gee.List<Genre> select_by_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("genre-select-by-id", "genre-id-ge");
                param_name = "ge_genre_id";
                debug("genre select ge");
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("genre-select-by-id", "genre-id-le");
                param_name = "le_genre_id";
                debug("genre select le");
            } else {
                sql = res.get_string_with_params("genre-select-by-id", "genre-id-equals");
                param_name = "equals_genre_id";
                debug("genre select equals");
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("genre-select-by-id", "genre-id-gt");
            param_name = "gt_genre_id";
            debug("genre select gt");
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("genre-select-by-id", "genre-id-lt");
            param_name = "lt_genre_id";
            debug("genre select lt");
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug("genre select sql: %s", sql);
        debug("genre param name: %s", param_name);
        debug("genre param value %d", genre_id);
        return fetch_genres(sql, param_name, Values.of_int(genre_id));
    }

    public Gee.List<Genre> select_by_name(string genre_name, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        switch (cond_type) {
          case STARTS_WITH:
            sql = res.get_string_with_params("genre-select-by-name", "genre-name-starts-with");
            param_name = "starts_with_genre_name";
            break;
          case ENDS_WITH:
            sql = res.get_string_with_params("genre-select-by-name", "genre-name-ends-with");
            param_name = "ends_with_genre_name";
            break;
          case INCLUDES:
            sql = res.get_string_with_params("genre-select-by-name", "genre-name-includes");
            param_name = "includes_genre_name";
            break;
          case EQUALS:
          default:
            sql = res.get_string_with_params("genre-select-by-name", "genre-name-equals");
            param_name = "equals_genre_name";
            break;
        }
        return fetch_genres(sql, param_name, Values.of_string(genre_name));
    }

    public Gee.List<Genre> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("genre-select-by-artist-id"), null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder("artist_id").set_value(Values.of_int(artist_id));
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Genre> list = new Gee.ArrayList<Genre>();

        if (model.get_n_rows() == 0) {
            debug("Got 0 recourd (genres selected by artist id)");
            return list;
        }
        
        for (var iter = model.create_iter(); iter.move_next();) {
            list.add(new Genre() {
                genre_id = iter.get_value_at(0).get_int(),
                genre_name = iter.get_value_at(1).get_string()
            });
        }
        return list;
    }
    
    public Gee.List<Genre> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("genre-select-by-song-id"), null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder("song_id").set_value(Values.of_int(song_id));
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Genre> list = new Gee.ArrayList<Genre>();

        if (model.get_n_rows() == 0) {
            debug("Got 0 recourd (genres selected by song id)");
            return list;
        }
        
        for (var iter = model.create_iter(); iter.move_next();) {
            list.add(new Genre() {
                genre_id = iter.get_value_at(0).get_int(),
                genre_name = iter.get_value_at(1).get_string()
            });
        }
        return list;
    }
    
    public Gee.List<Genre> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("genre-select-by-playlist-id"), null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder("playlist_id").set_value(Values.of_int(playlist_id));
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Genre> list = new Gee.ArrayList<Genre>();

        if (model.get_n_rows() == 0) {
            debug("Got 0 recourd (genres selected by playlist id)");
            return list;
        }
        
        for (var iter = model.create_iter(); iter.move_next();) {
            list.add(new Genre() {
                genre_id = iter.get_value_at(0).get_int(),
                genre_name = iter.get_value_at(1).get_string()
            });
        }
        return list;
    }
    
    public bool delete_by_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("genre-delete-by-id"), null),
            "genre_id", Values.of_int(genre_id)
        );
        if (num_affected > 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to genre");
        }
        if (num_affected == 0) {
            throw new OnnojiError.SQL_ERROR("No rows are affected when applying delete statement to genre");
        }
        return true;
    }
    
    public bool update_by_id(int genre_id, SList<string> col_names, SList<Value?> col_values) throws Error {
        return conn.update_row_in_table_v(
            "genre",
            "genre_id", Values.of_int(genre_id),
            col_names, col_values
        );
        /*
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("genre-update-by-id"), null),
            "genre_id", Values.of_int(genre_id),
            "new_name", Values.of_string(new_genre_name),
            "new_path", Values.of_string(new_file_path)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying update statement to genre");
        }
        return true;
        */
    }
    
    public bool insert(Genre genre, SqlInsertFlags flags = 0) throws Error {
        return conn.insert_row_into_table_v(
            "genre",
            slist<string>("genre_id", "genre_name", "genre_file_path"),
            slist<Value?>(
                Values.of_int(
                    GENERATE_NEXT_ID in flags ? get_next_genre_id() : genre.genre_id
                ),
                Values.of_string(genre.genre_name),
                Values.of_string(genre.genre_file_path)
            )
        );
    }

    public bool insert_link_to_song(Genre genre, Song song) throws Error {
        return conn.insert_row_into_table_v(
            "song_genre",
            slist<string>("song_id", "genre_id"),
            slist<Value?>(
                Values.of_int(song.song_id),
                Values.of_int(genre.genre_id)
            )
        );
    }
    
    public bool delete_link_to_song(Genre genre, Song song) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("song-delete-link-to-genre"), null),
            "song_id", Values.of_int(song.song_id),
            "genre_id", Values.of_int(genre.genre_id)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to song_genre");
        }
        return true;
    }

    private Gee.List<Genre> fetch_genres(string sql, string param_name, Value param_value) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(sql, null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder(param_name).set_value(param_value);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Genre> list = new Gee.ArrayList<Genre>();
        
        if (model.get_n_rows() == 0) {
            debug("Got 0 recourd (genres selected by song id)");
            return list;
        }
        
        var iter = model.create_iter();
        
        while (iter.move_next()) {
            list.add(new Genre() {
                genre_id = iter.get_value_at(0).get_int(),
                genre_name = iter.get_value_at(1).get_string(),
                genre_file_path = iter.get_value_at(2).get_string()
            });
        }
        return list;
    }
}
