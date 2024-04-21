namespace SqliteUtils {
    public string to_sqldate(DateTime dt) {
        return dt.format("%Y-%m-%d %H:%M:%S");
    }
    
    public DateTime from_sqldate(string sqldate) {
        int year = 2000, month = 1, day_of_month = 1, hour = 0, minut = 0, second = 0;
        sqldate.scanf("%04d-%02d-%02d %02d:%02d:%02d", &year, &month, &day_of_month, &hour, &minut, &second);
        DateTime dt = new DateTime(new TimeZone.local(), year, month, day_of_month, hour, minut, second);
        return dt;
    }
    
    public string sqldate_to_jsondate(string sqldate) {
        DateTime dt = from_sqldate(sqldate);
        return dt.format_iso8601();
    }
}
