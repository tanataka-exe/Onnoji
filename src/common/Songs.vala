public class Songs : Object {
    private unowned Sqlite.Database db;

    public Songs(Sqlite.Database db) {
        this.db = db;
    }
    
    public void register(SongData data) throws OnnojiError {
        string sql = "INSERT INTO SONGS ("
                + "SONG_ID, TITLE, ARTIST_ID, GENRE_ID, ALBUM_ID, DISC_NUMBER, TRACK_NUMBER, PUB_DATE, "
                + "COPYRIGHT, COMMENT, TIME_LENGTH, MIME_TYPE, FILE_PATH, ARTWORK_FILE_PATH, CREATION_DATETIME) "
                + "VALUES ($SONG_ID, $TITLE, $ARTIST_ID, $GENRE_ID, $ALBUM_ID, $DISC_NUMBER, $TRACK_NUMBER, "
                + "$PUB_DATE, $COPYRIGHT, $COMMENT, $TIME_LENGTH, $MIME_TYPE, $FILE_PATH, $ARTWORK_FILE_PATH, "
                + "$CREATION_DATETIME)";

        Sqlite.Statement stmt;
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR("Songs register preparing is failed");
        }
        
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.song_id);
        
        param_position = stmt.bind_parameter_index("$TITLE");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.title);
        
        param_position = stmt.bind_parameter_index("$ARTIST_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_int(param_position, data.artist_id);
        
        param_position = stmt.bind_parameter_index("$GENRE_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_int(param_position, data.genre_id);
        
        param_position = stmt.bind_parameter_index("$ALBUM_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.album_id);
        
        param_position = stmt.bind_parameter_index("$DISC_NUMBER");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_int((int) param_position, data.disc_number);
        
        param_position = stmt.bind_parameter_index("$TRACK_NUMBER");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_int((int) param_position, data.track_number);
        
        param_position = stmt.bind_parameter_index("$PUB_DATE");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_int((int) param_position, data.pub_date);
        
        param_position = stmt.bind_parameter_index("$COMMENT");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.comment);
        
        param_position = stmt.bind_parameter_index("$TIME_LENGTH");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.time_length.to_string());
        
        param_position = stmt.bind_parameter_index("$MIME_TYPE");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.mime_type);

        param_position = stmt.bind_parameter_index("$FILE_PATH");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.file_path);
        
        param_position = stmt.bind_parameter_index("$ARTWORK_FILE_PATH");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, data.artwork_file_path);
        
        param_position = stmt.bind_parameter_index("$CREATION_DATETIME");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Songs.register param position is invalid");
        }
        stmt.bind_text(param_position, SqliteUtils.to_sqldate(data.creation_datetime));
        
        string expanded_sql = stmt.expanded_sql();
        print("  execute sql: %s\n", expanded_sql);
        string errmsg;
        ec = db.exec(expanded_sql, null, out errmsg);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"SqlError: $(errmsg)");
        }
    }

    public bool song_exists(string song_id) throws OnnojiError {
        Sqlite.Statement stmt;
        const string sql = "SELECT COUNT(*) FROM Songs WHERE song_id = $SONG_ID;";
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        assert(param_position > 0);
        stmt.bind_text(param_position, song_id);
        print("  execute sql: %s\n", stmt.expanded_sql());

        int rows = 0;
        while (stmt.step() == Sqlite.ROW) {
            rows = stmt.column_int(0);
        }
        print("song exists count %d\n", rows);
        return rows > 0;
    }
    
    public bool song_exists_lazy(string song_id_part) throws OnnojiError {
        Sqlite.Statement stmt;
        const string sql = "SELECT COUNT(*) FROM Songs WHERE song_id LIKE $SONG_ID || '%';";
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        assert(param_position > 0);
        stmt.bind_text(param_position, song_id_part);
        print("  execute sql: %s\n", stmt.expanded_sql());

        int rows = 0;
        while (stmt.step() == Sqlite.ROW) {
            rows = stmt.column_int(0);
        }
        print("song exists count %d\n", rows);
        return rows > 0;
    }

    public SongData? find_by_id(string song_id_part) throws OnnojiError {
        Sqlite.Statement stmt;
        const string sql = """
SELECT SONG_ID, TITLE, ARTIST_ID, GENRE_ID, ALBUM_ID, DISC_NUMBER, TRACK_NUMBER, PUB_DATE,
COPYRIGHT, COMMENT, TIME_LENGTH, MIME_TYPE, FILE_PATH, ARTWORK_FILE_PATH, CREATION_DATETIME 
FROM Songs WHERE song_id = $SONG_ID;
""";

        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        assert(param_position > 0);
        stmt.bind_text(param_position, song_id_part);
        print("  execute sql: %s\n", stmt.expanded_sql());

        SongData data = new SongData();
        if (stmt.step() == Sqlite.ROW) {
            transfer_data(stmt, data);
        }
        return data;
    }

    public SongData? find_by_id_lazy(string song_id_part) throws OnnojiError {
        Sqlite.Statement stmt;
        const string sql = """
SELECT SONG_ID, TITLE, ARTIST_ID, GENRE_ID, ALBUM_ID, DISC_NUMBER, TRACK_NUMBER, PUB_DATE,
COPYRIGHT, COMMENT, TIME_LENGTH, MIME_TYPE, FILE_PATH, ARTWORK_FILE_PATH, CREATION_DATETIME 
FROM Songs WHERE song_id LIKE $SONG_ID || '%';
""";

        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        assert(param_position > 0);
        stmt.bind_text(param_position, song_id_part);
        print("  execute sql: %s\n", stmt.expanded_sql());

        SongData data = new SongData();
        if (stmt.step() == Sqlite.ROW) {
            transfer_data(stmt, data);
        }
        return data;
    }

    public SongData? find_by_artwork_id_lazy(string artwork_id) throws OnnojiError {
        Sqlite.Statement stmt;
        const string sql = """
SELECT SONG_ID, TITLE, ARTIST_ID, GENRE_ID, ALBUM_ID, DISC_NUMBER, TRACK_NUMBER, PUB_DATE,
COPYRIGHT, COMMENT, TIME_LENGTH, MIME_TYPE, FILE_PATH, ARTWORK_FILE_PATH, CREATION_DATETIME 
FROM SONGS WHERE ARTWORK_FILE_PATH LIKE '/srv/music/data/artworks/' || $ARTWORK_ID || '%';
""";

        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        
        int param_position = stmt.bind_parameter_index("$ARTWORK_ID");
        assert(param_position > 0);
        stmt.bind_text(param_position, artwork_id);
        print("  execute sql: %s\n", stmt.expanded_sql());

        SongData data = new SongData();
        if (stmt.step() == Sqlite.ROW) {
            transfer_data(stmt, data);
        }
        return data;
    }

    public Gee.List<Gee.Map<string, string>>? map_find_all(string? album_id, int artist_id) throws OnnojiError {
        string sql = """
SELECT
    S.SONG_ID, S.TITLE, S.ARTIST_ID, A.ARTIST_NAME, S.GENRE_ID, G.GENRE_NAME, S.ALBUM_ID, AL.ALBUM_NAME,
    S.DISC_NUMBER, S.TRACK_NUMBER, S.PUB_DATE, S.COPYRIGHT, S.COMMENT, S.TIME_LENGTH, S.MIME_TYPE, 
    S.FILE_PATH, S.ARTWORK_FILE_PATH, S.CREATION_DATETIME 
FROM
    SONGS S
INNER JOIN
    GENRES G ON G.GENRE_ID = S.GENRE_ID
LEFT OUTER JOIN
    ARTISTS A ON A.ARTIST_ID = S.ARTIST_ID
LEFT OUTER JOIN
    ALBUMS AL ON AL.ALBUM_ID = S.ALBUM_ID 
""";
        string[] where_clause = new string[0];
        if (album_id != null) {
            where_clause += "S.ALBUM_ID LIKE $ALBUM_ID || '%'";
        }
        if (artist_id > 0) {
            where_clause += "S.ARTIST_ID = $ARTIST_ID";
        }
        if (where_clause.length > 0) {
            sql += "WHERE " + string.joinv(" AND ", where_clause);
        }
        sql += " ORDER BY AL.ALBUM_NAME, S.DISC_NUMBER, S.TRACK_NUMBER, S.TITLE;";
        
        Sqlite.Statement stmt;
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Album.find_album_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$ALBUM_ID");
        if (param_position > 0) {
            stmt.bind_text(param_position, album_id);
        }
        param_position = stmt.bind_parameter_index("$ARTIST_ID");
        if (param_position > 0) {
            stmt.bind_int(param_position, artist_id);
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        Gee.List<Gee.Map<string, string>> list = new Gee.ArrayList<Gee.Map<string, string>>();
        int cols = stmt.column_count();
        while (stmt.step() == Sqlite.ROW) {
            Gee.Map<string, string> map = new Gee.HashMap<string, string>();
            print("  row of songs\n");
            for (int i = 0; i < cols; i++) {
                string col_name = stmt.column_name(i) ?? "<none>";
                int type_id = stmt.column_type(i);
                switch (type_id) {
                  case Sqlite.INTEGER:
                    map[col_name] = stmt.column_int(i).to_string();
                    print("    col_name = %s, col_value = %s\n", col_name, map[col_name]);
                    break;
                  case Sqlite.TEXT:
                    map[col_name] = stmt.column_text(i);
                    print("    col_name = %s, col_value = %s\n", col_name, map[col_name]);
                    break;
                  default:
                    // null.
                    print("    col_name = %s, col_value = null\n", col_name);
                    break;
                }
            }
            list.add(map);
        }
        print(@"  rows = $(list.size.to_string())\n");
        return list;
    }
    
    private void transfer_data(Sqlite.Statement stmt, SongData data) {
        data.song_id = stmt.column_text(0);
        data.title = stmt.column_text(1);
        data.artist_id = stmt.column_int(2);
        data.genre_id = stmt.column_int(3);
        data.album_id = stmt.column_text(4);
        data.disc_number = stmt.column_int(5);
        data.track_number = stmt.column_int(6);
        data.pub_date = stmt.column_int(7);
        data.copyright = stmt.column_text(8);
        data.comment = stmt.column_text(9);
        string time_length = stmt.column_text(10);
        data.time_length = new Moegi.SmallTime.from_string(time_length);
        data.mime_type = stmt.column_text(11);
        data.file_path = stmt.column_text(12);
        data.artwork_file_path = stmt.column_text(13);
        string? creation_datetime = stmt.column_text(14);
        if (creation_datetime != null) {
            data.creation_datetime = SqliteUtils.from_sqldate(creation_datetime);
        }
    }
}
