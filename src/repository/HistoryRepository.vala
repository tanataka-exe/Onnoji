public interface HistoryRepository : Object {
    public abstract int get_next_history_id() throws Error;
    public abstract Gee.List<History> select_by_id(int history_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<History> select_by_song_id(int song_id) throws Error;
    public abstract Gee.List<History> select_by_request_datetime(Gda.Timestamp request_datetime, SqlConditionType condition_type) throws Error;
    public abstract bool delete_by_id(int history_id) throws Error;
    public abstract bool update_by_id(int history_id, Gee.Map<string, Value?> updata) throws Error;
    public abstract bool insert(History history, SqlInsertFlags flags = 0) throws Error;
}
