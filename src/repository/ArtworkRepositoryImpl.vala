public class ArtworkRepositoryImpl : ArtworkRepository, BasicRepositoryImpl {

    public ArtworkRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.conn = conn;
        this.res = res as XmlResourceManager;
    }
    
    public int get_next_artwork_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("artwork-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next artwork id!");
        }
    }

    public Gee.List<Artwork> select_by_id(int artwork_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-id", "artwork-id-ge");
                param_name = "ge_artwork_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-id", "artwork-id-le");
                param_name = "le_artwork_id";
            } else {
                sql = res.get_string_with_params("artwork-select-by-id", "artwork-id-equals");
                param_name = "equals_artwork_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-id", "artwork-id-gt");
            param_name = "gt_artwork_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-id", "artwork-id-lt");
            param_name = "lt_artwork_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artworks(sql, param_name, Values.of_int(artwork_id));
    }

    public Gee.List<Artwork> select_by_digest(string digest, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        switch (cond_type) {
          case STARTS_WITH:
            sql = res.get_string_with_params("artwork-select-by-digest", "digest-starts-with");
            param_name = "starts_with_digest";
            break;
          case ENDS_WITH:
            sql = res.get_string_with_params("artwork-select-by-digest", "digest-ends-with");
            param_name = "ends_with_digest";
            break;
          case INCLUDES:
            sql = res.get_string_with_params("artwork-select-by-digest", "digest-includes");
            param_name = "includes_digest";
            break;
          case EQUALS:
          default:
            sql = res.get_string_with_params("artwork-select-by-digest", "digest-equals");
            param_name = "equals_digest";
            break;
        }
        return fetch_artworks(sql, param_name, Values.of_string(digest));
    }

    public Gee.List<Artwork> select_all() throws Error {
        return select_by_artist_id(0, GREATER_THAN | EQUALS);
    }
    
    public Gee.List<Artwork> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-artist-id", "artist-id-ge");
                param_name = "ge_artist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-artist-id", "artist-id-le");
                param_name = "le_artist_id";
            } else {
                sql = res.get_string_with_params("artwork-select-by-artist-id", "artist-id-equals");
                param_name = "equals_artist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-artist-id", "artist-id-gt");
            param_name = "gt_artist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-artist-id", "artist-id-lt");
            param_name = "lt_artist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artworks(sql, param_name, Values.of_int(artist_id));
    }
    
    public Gee.List<Artwork> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-song-id", "song-id-ge");
                param_name = "ge_song_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-song-id", "song-id-le");
                param_name = "le_song_id";
            } else {
                sql = res.get_string_with_params("artwork-select-by-song-id", "song-id-equals");
                param_name = "equals_song_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-song-id", "song-id-gt");
            param_name = "gt_song_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-song-id", "song-id-lt");
            param_name = "lt_song_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        debug(sql);
        return fetch_artworks(sql, param_name, Values.of_int(song_id));
    }
    
    public Gee.List<Artwork> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (EQUALS in cond_type) {
            if (GREATER_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-playlist-id", "playlist-id-ge");
                param_name = "ge_playlist_id";
            } else if (LESS_THAN in cond_type) {
                sql = res.get_string_with_params("artwork-select-by-playlist-id", "playlist-id-le");
                param_name = "le_playlist_id";
            } else {
                sql = res.get_string_with_params("artwork-select-by-playlist-id", "playlist-id-equals");
                param_name = "equals_playlist_id";
            }
        } else if (GREATER_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-playlist-id", "playlist-id-gt");
            param_name = "gt_playlist_id";
        } else if (LESS_THAN in cond_type) {
            sql = res.get_string_with_params("artwork-select-by-playlist-id", "playlist-id-lt");
            param_name = "lt_playlist_id";
        } else {
            throw new OnnojiError.SQL_ERROR("This condition is not selectable");
        }
        return fetch_artworks(sql, param_name, Values.of_int(playlist_id));
    }
    
    public bool update_by_id(int artwork_id, string new_path, string new_mime_type, string new_digest) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("artwork-update-by-id"), null),
            "artwork_id", Values.of_int(artwork_id),
            "new_path", Values.of_string(new_path),
            "new_mime_type", Values.of_string(new_mime_type),
            "new_digest", Values.of_string(new_digest)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying update statement to artwork");
        }
        return true;
    }
    
    public bool delete_by_id(int artwork_id) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("artwork-delete-by-id"), null),
            "artwork_id", Values.of_int(artwork_id)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying update statement to artwork");
        }
        return true;
    }

    public bool insert(Artwork artwork, SqlInsertFlags flags = 0) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("artwork-insert"), null),
            "artwork_id", (
                GENERATE_NEXT_ID in flags ? get_next_artwork_id() : Values.of_int(artwork.artwork_id)
            ),
            "artwork_file_path", Values.of_string(artwork.artwork_file_path),
            "mime_type", Values.of_string(artwork.mime_type),
            "digest", Values.of_string(artwork.digest)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying update statement to artwork");
        }
        return true;
    }
    
    private Gee.List<Artwork> fetch_artworks(string sql, string param_name, Value param_value) throws Error {
        debug("artwork select sql: %s", sql);
        if (param_value.holds(typeof(int))) {
            debug("artwork select param: %s = %d", param_name, param_value.get_int());
        } else if (param_value.holds(typeof(string))) {
            debug("artwork select param: %s = %s", param_name, param_value.get_string());
        }
        Gda.Statement stmt = conn.create_parser().parse_string(sql, null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder(param_name).set_value(param_value);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<Artwork> list = new Gee.ArrayList<Artwork>();
        
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new Artwork() {
                artwork_id = iter.get_value_at(0).get_int(),
                artwork_file_path = iter.get_value_at(1).get_string(),
                mime_type = iter.get_value_at(2).get_string(),
                digest = iter.get_value_at(3).get_string()
            });
        }
        return list;
    }
}
