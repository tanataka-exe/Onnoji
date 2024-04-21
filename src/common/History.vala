public class History : Object {
    private unowned Sqlite.Database db;

    public History(Sqlite.Database db) {
        this.db = db;
    }
    
    public void register(HistoryData data) throws OnnojiError {
        string sql = "INSERT INTO HISTORY (SONG_ID, REQUEST_DATETIME) VALUES ($SONG_ID, $REQUEST_DATETIME);";
        Sqlite.Statement stmt;
        int ec = db.prepare_v2(sql, sql.length, out stmt);
        int param_position = stmt.bind_parameter_index("$SONG_ID");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("History.register param position is invalid");
        }
        stmt.bind_text(param_position, data.song_id);
        param_position = stmt.bind_parameter_index("$REQUEST_DATETIME");
        if (param_position <= 0) {
            throw new OnnojiError.SQL_ERROR("History.register param position is invalid");
        }
        stmt.bind_text(param_position, SqliteUtils.to_sqldate(data.request_datetime));
        string expanded_sql = stmt.expanded_sql();
        string? errmsg;
        ec = db.exec(expanded_sql, null, out errmsg);
        if (ec != Sqlite.OK) {
            throw new OnnojiError.SQL_ERROR(@"SqlError: $(errmsg)");
        }
    }
}

