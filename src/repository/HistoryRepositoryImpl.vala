public class HistoryRepositoryImpl : HistoryRepository, BasicRepositoryImpl {

    public HistoryRepositoryImpl(ResourceManager res, Gda.Connection conn) {
        this.conn = conn;
        this.res = res as XmlResourceManager;
    }
    
    public int get_next_history_id() throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("history-next-id"), null);
        Gda.DataModel model = this.conn.statement_execute_select(stmt, null);

        if (model.get_n_columns() == 1 && model.get_n_rows() == 1) {
            return (int) model.get_value_at(0, 0).get_int64();
        } else {
            throw new OnnojiError.SQL_ERROR("failed to generate the next artwork id!");
        }
    }

    public Gee.List<History> select_by_id(int history_id, SqlConditionType condition_type = EQUALS) throws Error {
        string sql;
        string param_name;
        if (GREATER_THAN in condition_type && LESS_THAN in condition_type) {
            throw new OnnojiError.SQL_ERROR("This is condition is not met");
        } else if (EQUALS in condition_type) {
            if (GREATER_THAN in condition_type) {
                sql = res.get_string_with_params("history-select-by-id", "history-id-ge");
                param_name = "ge_history_id";
            } else if (LESS_THAN in condition_type) {
                sql = res.get_string_with_params("history-select-by-id", "history-id-le");
                param_name = "le_history_id";
            } else {
                sql = res.get_string_with_params("history-select-by-id", "history-id-equals");
                param_name = "equals_history_id";
            }
        } else if (GREATER_THAN in condition_type) {
            sql = res.get_string_with_params("history-select-by-id", "history-id-gt");
            param_name = "gt_history_id";
        } else if (LESS_THAN in condition_type) {
            sql = res.get_string_with_params("history-select-by-id", "history-id-lt");
            param_name = "lt_history_id";
        } else {
            throw new OnnojiError.SQL_ERROR("At least 1 condition type must be specified");
        }
        
        return fetch_history(sql, param_name, Values.of_int(history_id));
    }
    
    public Gee.List<History> select_by_song_id(int song_id) throws Error {
        Gda.SqlParser parser = conn.create_parser();
        Gda.Statement stmt = parser.parse_string(res.get_string("history-select-by-song-id"), null);
        Gda.Set params;
        stmt.get_parameters(out params);
        params.get_holder("song_id").set_value(Values.of_int(song_id));
        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        Gee.List<History> list = new Gee.ArrayList<History>();
        if (model.get_n_rows() == 0) {
            return list;
        }
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new History() {
                history_id = iter.get_value_at(0).get_int(),
                song_id = iter.get_value_at(1).get_int(),
                request_datetime = (Gda.Timestamp) iter.get_value_at(2).get_boxed()
            });
        }
        return list;
    }

    public Gee.List<History> select_by_request_datetime(Gda.Timestamp request_datetime, SqlConditionType condition_type) throws Error {
        string sql;
        string param_name;
        if (GREATER_THAN in condition_type && LESS_THAN in condition_type) {
            throw new OnnojiError.SQL_ERROR("This is condition is not met");
        } else if (EQUALS in condition_type) {
            if (GREATER_THAN in condition_type) {
                sql = res.get_string_with_params("history-select-by-request-datetime", "request-datetime-ge");
                param_name = "ge_request_datetime";
            } else if (LESS_THAN in condition_type) {
                sql = res.get_string_with_params("history-select-by-request-datetime", "request-datetime-le");
                param_name = "le_request_datetime";
            } else {
                sql = res.get_string_with_params("history-select-by-request-datetime", "request-datetime-equals");
                param_name = "equals_request_datetime";
            }
        } else if (GREATER_THAN in condition_type) {
            sql = res.get_string_with_params("history-select-by-request-datetime", "request-datetime-gt");
            param_name = "gt_request_datetime";
        } else if (LESS_THAN in condition_type) {
            sql = res.get_string_with_params("history-select-by-request-datetime", "request-datetime-lt");
            param_name = "lt_request_datetime";
        } else {
            throw new OnnojiError.SQL_ERROR("At least 1 condition type must be specified");
        }
        
        return fetch_history(sql, param_name, Values.of_gda_timestamp(request_datetime));
    }

    private Gee.List<History> fetch_history(string sql, ...) throws Error {
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
        debug(sql);

        Gda.DataModel model = this.conn.statement_execute_select(stmt, params);
        
        Gee.List<History> list = new Gee.ArrayList<History>();
        
        for (Gda.DataModelIter iter = model.create_iter(); iter.move_next();) {
            list.add(new History() {
                history_id = iter.get_value_at(0).get_int(),
                song_id = iter.get_value_at(1).get_int(),
                request_datetime = (Gda.Timestamp) iter.get_value_at(2).get_boxed()
            });
        }
        
        return list;
    }
    
    public bool delete_by_id(int history_id) throws Error {
        int num_affected = execute_non_select_with_params(
            conn.create_parser().parse_string(res.get_string("history-delete-by-id"), null),
            "history_id", Values.of_int(history_id)
        );
        if (num_affected != 1) {
            throw new OnnojiError.SQL_ERROR("More than 1 rows are affected when applying delete statement to history");
        }
        return true;;
    }
    
    public bool update_by_id(int history_id, Gee.Map<string, Value?> updata) throws Error {
        SList<string> col_names = new SList<string>();
        SList<Value?> values = new SList<Value?>();
        foreach (string key in updata.keys) {
            col_names.append(key);
            values.append(updata[key]);
        }
        return conn.update_row_in_table_v("history", "history_id", Values.of_int(history_id), col_names, values);
    }
    
    public bool insert(History history, SqlInsertFlags flags = 0) throws Error {
        return conn.insert_row_into_table_v(
            "history",
            slist<string>("history_id", "song_id", "request_datetime"),
            slist<Value?>(
                Values.of_int(
                    GENERATE_NEXT_ID in flags ? get_next_history_id() : history.history_id
                ),
                Values.of_int(history.song_id),
                Values.of_gda_timestamp(history.request_datetime)
            )
        );
    }
}
