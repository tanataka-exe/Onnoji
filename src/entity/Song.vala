public class Song : Object {
    public int song_id { get; set; }
    public string title { get; set; }
    public int pub_date { get; set; }
    public string copyright { get; set; }
    public string comment { get; set; }
    public uint time_length_milliseconds { get; set; }
    public string mime_type { get; set; }
    public string file_path { get; set; }
    public string digest { get; set; }
    public int artwork_id { get; set; }
    public Gda.Timestamp creation_datetime { get; set; }
}
