extern Gda.Timestamp create_gda_timestamp();
extern Gda.Timestamp create_gda_timestamp_with_datetime(int year, int month, int day,
        int hour, int minute, int second);
extern Gda.Timestamp create_gda_timestamp_with_date(int year, int month, int day);
extern Gda.Timestamp create_gda_timestamp_now_local();

string get_lan_ip() throws SpawnError {
    string output;
    Process.spawn_command_line_sync("lan-ip", out output);
    return output.strip();
}

string format_gda_timestamp(Gda.Timestamp ts, string format) {
    DateTime dt = new DateTime.local(ts.year, ts.month, ts.day, ts.hour, ts.minute, (double) ts.second);
    return dt.format(format);
}

Gee.Map create_map(string first_key, ...) {
    var l = va_list();
    if (first_key == null) {
        return new Gee.HashMap<string, Value?>();
    }
    string key = first_key;
    Gee.Map<string, Value?> map = new Gee.HashMap<string, Value?>();
    do {
        Value val = l.arg();
        map[key] = val;
        string next_key = l.arg();
        if (next_key == null) {
            break;
        }
        key = next_key;
    } while (true);
    return map;
}

SList<T> slist<T>(T first_value, ...) {
    var l = va_list();
    SList<T> list = new SList<T>();
    if (first_value == null) {
        return list;
    } else {
        list.append(first_value);
    }
    T next_value = null;
    while ((next_value = l.arg()) != null) {
        list.append(next_value);
    }
    return list;
}
