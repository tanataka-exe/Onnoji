public class Artists : Object {
    private unowned Sqlite.Database db;

    public Artists(Sqlite.Database db) {
        this.db = db;
    }

    public void register(ArtistData data) throws OnnojiError {
        string sql = "INSERT INTO ARTISTS (ARTIST_ID, ARTIST_NAME) VALUES ($ARTIST_ID, $ARTIST_NAME);";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing insert artist has failed");
        }
        
        int param_position = stmt.bind_parameter_index("$ARTIST_ID");
        stmt.bind_int(param_position, data.id);
        
        param_position = stmt.bind_parameter_index("$ARTIST_NAME");
        stmt.bind_text(param_position, data.name);
        
        string expanded_sql = stmt.expanded_sql();
        print("  execute sql: %s\n", expanded_sql);
        string errmsg;
        ec = db.exec(expanded_sql, null, out errmsg);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(errmsg);
        }
    }
    
    public int find_max_artist_id() throws OnnojiError {
        string sql = "SELECT MAX(ARTIST_ID) AS MAX_ARTIST_ID FROM ARTISTS;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Artist.find_max_id has failed ($(sql))");
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        int max_artist_id = 0;
        while (stmt.step() == Sqlite.ROW) {
            max_artist_id = stmt.column_int(0);
        }
        return max_artist_id;
    }

    public ArtistData? find_artist_by_id(int artist_id) throws OnnojiError {
        string sql = "SELECT ARTIST_NAME FROM ARTISTS WHERE ARTIST_ID = $ARTIST_ID;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Artist.find_artist_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$ARTIST_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Artist.find_artist_id param_position is less than 1");
        }
        stmt.bind_int(param_position, artist_id);
        print("  execute sql: %s\n", stmt.expanded_sql());
        if (stmt.step() == Sqlite.ROW) {
            string artist_name = stmt.column_text(0);
            ArtistData data = new ArtistData();
            data.id = artist_id;
            data.name = artist_name;
            return data;
        } else {
            return null;
        }
    }
    
    public int find_artist_id(string artist_name) throws OnnojiError {
        string sql = "SELECT ARTIST_ID FROM ARTISTS WHERE ARTIST_NAME = $ARTIST_NAME;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Artist.find_artist_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$ARTIST_NAME");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Artist.find_artist_id param_position is less than 1");
        }
        stmt.bind_text(param_position, artist_name);
        print("  execute sql: %s\n", stmt.expanded_sql());
        int max_artist_id = 0;
        while (stmt.step() == Sqlite.ROW) {
            max_artist_id = stmt.column_int(0);
        }
        return max_artist_id;
    }

    public Gee.List<ArtistData> find_all(int genre_id, string? album_id) throws OnnojiError {
        string sql = "SELECT TMP.ARTIST_ID, ARTISTS.ARTIST_NAME FROM (SELECT ARTIST_ID FROM SONGS ";
        string[] where_clause = new string[0];
        if (genre_id > 0) {
            where_clause += "GENRE_ID = $GENRE_ID";
        }
        if (album_id != null) {
            where_clause += "ALBUM_ID LIKE $ALBUM_ID || '%'";
        }
        if (where_clause.length > 0) {
            sql += "WHERE " + string.joinv(" AND ", where_clause);
        }
        sql += " GROUP BY ARTIST_ID) TMP INNER JOIN ARTISTS ON TMP.ARTIST_ID = ARTISTS.ARTIST_ID "
                + "ORDER BY ARTISTS.ARTIST_NAME;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Artist.find_all has failed ($(sql))");
        }
        if (genre_id > 0) {
            int param_position = stmt.bind_parameter_index("$GENRE_ID");
            if (param_position <= 0) {
                throw new OnnojiError.SQL_ERROR("Artist.find_all param_position is less than 1");
            }
            stmt.bind_int(param_position, genre_id);
        }
        if (album_id != null) {
            int param_position = stmt.bind_parameter_index("$ALBUM_ID");
            if (param_position <= 0) {
                throw new OnnojiError.SQL_ERROR("Artist.find_all param_position is less than 1");
            }
            stmt.bind_text(param_position, album_id);
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        Gee.List<ArtistData> result_list = new Gee.ArrayList<ArtistData>();
        while (stmt.step() == Sqlite.ROW) {
            ArtistData data = new ArtistData();
            data.id = stmt.column_int(0);
            data.name = stmt.column_text(1);
            result_list.add(data);
        }
        return result_list;
    }
}
