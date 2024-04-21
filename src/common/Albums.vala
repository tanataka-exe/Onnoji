public class Albums : Object {
    private unowned Sqlite.Database db;

    public Albums(Sqlite.Database db) {
        this.db = db;
    }

    public void register(AlbumData data) throws OnnojiError {
        string sql = "INSERT INTO ALBUMS (ALBUM_ID, ALBUM_NAME, ALBUM_ID_NAME) VALUES ($ALBUM_ID, $ALBUM_NAME, $ALBUM_ID_NAME);";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing insert album has failed.");
        }
        
        int param_position = stmt.bind_parameter_index("$ALBUM_ID");
        stmt.bind_text(param_position, data.id);
        
        param_position = stmt.bind_parameter_index("$ALBUM_NAME");
        stmt.bind_text(param_position, data.name);
        
        param_position = stmt.bind_parameter_index("$ALBUM_ID_NAME");
        stmt.bind_text(param_position, data.id_name);
        
        string expanded_sql = stmt.expanded_sql();
        print("  execute sql: %s\n", expanded_sql);
        string errmsg;
        ec = db.exec(expanded_sql, null, out errmsg);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(errmsg);
        }
    }
    
    public AlbumData? find_album_by_id(string album_id) throws OnnojiError {
        string sql = "SELECT ALBUM_NAME, ALBUM_ID_NAME FROM ALBUMS WHERE ALBUM_ID LIKE $ALBUM_ID || '%';";
        Sqlite.Statement stmt;
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$ALBUM_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Album.find_album_id param_position is less than 1");
        }
        stmt.bind_text(param_position, album_id);
        print("  execute sql: %s\n", stmt.expanded_sql());
        if (stmt.step() == Sqlite.ROW) {
            string album_name = stmt.column_text(0);
            string album_id_name = stmt.column_text(1);
            AlbumData data = new AlbumData();
            data.id = album_id;
            data.name = album_name;
            data.id_name = album_id_name;
            return data;
        } else {
            return null;
        }
    }

    public bool album_exists(string album_id) throws OnnojiError {
        string sql = "SELECT COUNT(*) FROM ALBUMS WHERE ALBUM_ID LIKE $ALBUM_ID || '%';";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_max_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$ALBUM_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Album.album_exists param_position is less than 1");
        }
        stmt.bind_text(param_position, album_id);
        print("  execute sql: %s\n", stmt.expanded_sql());
        int rows = stmt.data_count();
        while (stmt.step() == Sqlite.ROW) {
            rows = stmt.column_int(0);
        }
        return rows > 0;
    }
    
    public Gee.List<AlbumDataEx> find_by_genre_id(int genre_id) throws OnnojiError {
        return find_all(genre_id, 0, 0, 0, false);
    }
    
    public Gee.List<AlbumDataEx> find_by_artist_id(int artist_id, bool is_lazy) throws OnnojiError {
        return find_all(0, artist_id, 0, 0, is_lazy);
    }
    
    public Gee.List<AlbumDataEx> find_recently_created(int recent_creation_limit) throws OnnojiError {
        return find_all(0, 0, recent_creation_limit, 0, false);
    }
    
    public Gee.List<AlbumDataEx> find_recently_requested(int recent_request_limit) throws OnnojiError {
        return find_all(0, 0, 0, recent_request_limit, false);
    }
    
    public Gee.List<AlbumDataEx> find_all(int genre_id, int artist_id, int recent_creation_limit, int recent_request_limit,
            bool lazy) throws OnnojiError {
        string sql = "SELECT SUB_SONGS.ALBUM_ID, ALBUMS.ALBUM_NAME, ALBUMS.ALBUM_ID_NAME, "
                + "SUB_SONGS.CREATION_DATETIME, SUB_SONGS.LAST_REQUEST_DATETIME FROM "
                + "(SELECT ALBUM_ID, MAX(CREATION_DATETIME) AS CREATION_DATETIME, MAX(H.REQUEST_DATETIME) AS LAST_REQUEST_DATETIME "
                + "FROM SONGS S "
                + "LEFT OUTER JOIN HISTORY H ON S.SONG_ID = H.SONG_ID ";
        string[] where_clause = new string[0];
        if (genre_id > 0) {
            where_clause += "GENRE_ID = $GENRE_ID";
        }
        if (artist_id > 0) {
            if (lazy) {
                where_clause += "ARTIST_ID IN("
                        + "SELECT ARTIST_ID FROM ARTISTS WHERE ARTIST_NAME LIKE '%' || (SELECT ARTIST_NAME FROM ARTISTS WHERE ARTIST_ID = $ARTIST_ID) || '%'"
                        + ")";
            } else {
                where_clause += "ARTIST_ID = $ARTIST_ID";
            }
        }
        if (where_clause.length > 0) {
            sql += " WHERE " + string.joinv(" AND ", where_clause);
        }
        sql += " GROUP BY ALBUM_ID) SUB_SONGS INNER JOIN ALBUMS ON ALBUMS.ALBUM_ID = SUB_SONGS.ALBUM_ID ";
        if (recent_creation_limit > 0) {
            sql += "ORDER BY SUB_SONGS.CREATION_DATETIME DESC LIMIT $RECENT_CREATION;";
        } else if (recent_request_limit > 0) {
            sql += "ORDER BY SUB_SONGS.LAST_REQUEST_DATETIME DESC LIMIT $RECENT_REQUEST;";
        } else {
            sql += "ORDER BY ALBUMS.ALBUM_NAME;";
        }
        Sqlite.Statement stmt;
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_all has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$GENRE_ID");
        if (param_position > 0) {
            stmt.bind_int(param_position, genre_id);
        }
        param_position = stmt.bind_parameter_index("$ARTIST_ID");
        if (param_position > 0) {
            stmt.bind_int(param_position, artist_id);
        }
        param_position = stmt.bind_parameter_index("$RECENT_CREATION");
        if (param_position > 0) {
            stmt.bind_int(param_position, recent_creation_limit);
        }
        param_position = stmt.bind_parameter_index("$RECENT_REQUEST");
        if (param_position > 0){
            stmt.bind_int(param_position, recent_request_limit);
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        Gee.List<AlbumDataEx> list = new Gee.ArrayList<AlbumDataEx>();
        while (stmt.step() == Sqlite.ROW) {
            AlbumDataEx data = new AlbumDataEx();
            data.id = stmt.column_text(0);
            data.name = stmt.column_text(1);
            string creation_datetime_s = stmt.column_text(3);
            data.creation_datetime = SqliteUtils.from_sqldate(creation_datetime_s);
            string? last_request_datetime_s = stmt.column_text(4);
            if (last_request_datetime_s != null) {
                data.last_request_datetime = SqliteUtils.from_sqldate(last_request_datetime_s);
            }
            string sql2 = """
SELECT
    A.ARTIST_ID,
    A.ARTIST_NAME
FROM
    ARTISTS A
WHERE
    A.ARTIST_ID IN (
        SELECT
            S.ARTIST_ID
        FROM
            SONGS S
        WHERE
            S.ALBUM_ID = $ALBUM_ID
        GROUP BY
            S.ARTIST_ID
    )
""";
            Sqlite.Statement stmt2;
            ec = db.prepare_v2(sql2, sql2.length, out stmt2);
            if (ec != Sqlite.OK) {
                throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_all has failed ($(sql2))");
            }
            param_position = stmt2.bind_parameter_index("$ALBUM_ID");
            if (param_position < 1) {
                throw new OnnojiError.SQL_ERROR(@"Parameter position is invalid ($(param_position))");
            }
            stmt2.bind_text(param_position, data.id);
            data.artists = new Gee.ArrayList<ArtistData>();
            while (stmt2.step() == Sqlite.ROW) {
                ArtistData artist = new ArtistData();
                artist.id = stmt2.column_int(0);
                artist.name = stmt2.column_text(1);
                data.artists.add(artist);
            }
            
            string sql3 = """
SELECT
    S3.SONG_ID,
    S3.ARTWORK_FILE_PATH
FROM
    SONGS S3
INNER JOIN
    (
        SELECT
            S2.DISC_NUMBER,
            MIN(S2.TRACK_NUMBER) AS TRACK_NUMBER
        FROM
            SONGS S2
        WHERE
            S2.ALBUM_ID = $ALBUM_ID_2
          AND
            S2.DISC_NUMBER = (
                SELECT
                    MIN(S1.DISC_NUMBER) AS DISC_NUMBER
                FROM
                    SONGS S1
                WHERE
                    S1.ALBUM_ID = $ALBUM_ID_3
            )
    ) S4
ON
    S3.DISC_NUMBER = S4.DISC_NUMBER
  AND
    S3.TRACK_NUMBER = S4.TRACK_NUMBER
WHERE
    S3.ALBUM_ID = $ALBUM_ID_1
;""";
            Sqlite.Statement stmt3;
            ec = db.prepare_v2(sql3, sql3.length, out stmt3);
            if (ec != Sqlite.OK) {
                throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_all has failed ($(sql3))");
            }
            param_position = stmt3.bind_parameter_index("$ALBUM_ID_1");
            if (param_position < 1) {
                throw new OnnojiError.SQL_ERROR(@"Parameter position is invalid ($(param_position))");
            }
            stmt3.bind_text(param_position, data.id);
            param_position = stmt3.bind_parameter_index("$ALBUM_ID_2");
            if (param_position < 1) {
                throw new OnnojiError.SQL_ERROR(@"Parameter position is invalid ($(param_position))");
            }
            stmt3.bind_text(param_position, data.id);
            param_position = stmt3.bind_parameter_index("$ALBUM_ID_3");
            if (param_position < 1) {
                throw new OnnojiError.SQL_ERROR(@"Parameter position is invalid ($(param_position))");
            }
            stmt3.bind_text(param_position, data.id);
            if (stmt3.step() == Sqlite.ROW) {
                if (stmt3.column_type(1) != Sqlite.NULL) {
                    data.has_artwork = true;
                    data.first_artwork_file_path = stmt3.column_text(1);
                } else {
                    data.has_artwork = false;
                }
            }
            list.add(data);
        }
        return list;
    }
}

