public class Genres : Object {
    private unowned Sqlite.Database db;

    public Genres(Sqlite.Database db) {
        this.db = db;
    }

    public void register(GenreData data) throws OnnojiError {
        string sql = "INSERT INTO GENRES (GENRE_ID, GENRE_NAME) VALUES ($GENRE_ID, $GENRE_NAME);";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing insert genre has failed");
        }
        
        int param_position = stmt.bind_parameter_index("$GENRE_ID");
        stmt.bind_int(param_position, data.id);
        
        param_position = stmt.bind_parameter_index("$GENRE_NAME");
        stmt.bind_text(param_position, data.name);
        
        string expanded_sql = stmt.expanded_sql();
        print("  execute sql: %s\n", expanded_sql);
        string errmsg;
        ec = db.exec(expanded_sql, null, out errmsg);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(errmsg);
        }
    }
    
    public int find_max_genre_id() throws OnnojiError {
        string sql = "SELECT MAX(GENRE_ID) AS MAX_GENRE_ID FROM GENRES;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Genre.find_max_id has failed ($(sql))");
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        int max_genre_id = 0;
        while (stmt.step() == Sqlite.ROW) {
            max_genre_id = stmt.column_int(0);
        }
        return max_genre_id;
    }
    
    public GenreData? find_genre_by_id(int genre_id) throws OnnojiError {
        string sql = "SELECT GENRE_NAME FROM GENRES WHERE GENRE_ID = $GENRE_ID;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Genre.find_genre_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$GENRE_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Genre.find_genre_id param_position is less than 1");
        }
        stmt.bind_int(param_position, genre_id);
        print("  execute sql: %s\n", stmt.expanded_sql());
        if (stmt.step() == Sqlite.ROW) {
            GenreData data = new GenreData();
            data.id = genre_id;
            data.name = stmt.column_text(0);
            return data;
        } else {
            return null;
        }
    }
    
    public int find_genre_id(string genre_name) throws OnnojiError {
        string sql = "SELECT GENRE_ID FROM GENRES WHERE GENRE_NAME = $GENRE_NAME;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Genre.find_genre_id has failed ($(sql))");
        }
        int param_position = stmt.bind_parameter_index("$GENRE_NAME");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("Genre.find_genre_id param_position is less than 1");
        }
        stmt.bind_text(param_position, genre_name);
        print("  execute sql: %s\n", stmt.expanded_sql());
        int max_genre_id = 0;
        while (stmt.step() == Sqlite.ROW) {
            max_genre_id = stmt.column_int(0);
        }
        return max_genre_id;
    }
    
    public Gee.List<GenreData> find_all() throws OnnojiError {
        string sql = "SELECT GENRE_ID, GENRE_NAME FROM GENRES ORDER BY GENRE_NAME;";
        Sqlite.Statement stmt;
        int ec = db.prepare(sql, sql.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"Preparing Genre.find_all has failed ($(sql))");
        }
        print("  execute sql: %s\n", stmt.expanded_sql());
        Gee.List<GenreData> result_list = new Gee.ArrayList<GenreData>();
        while (stmt.step() == Sqlite.ROW) {
            GenreData data = new GenreData();
            data.id = stmt.column_int(0);
            data.name = stmt.column_text(1);
            result_list.add(data);
        }
        return result_list;
    }
}
