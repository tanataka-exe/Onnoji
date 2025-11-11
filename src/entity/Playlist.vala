public class Playlist : Object {
    public int playlist_id { get; set; }
    public string playlist_name { get; set; }
    public bool is_album { get; set; }
    public DateTime creation_datetime { get; set; }
    public DateTime? update_datetime { get; set; }
}
