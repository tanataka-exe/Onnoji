public class Playlist : Object {
    public int playlist_id { get; set; }
    public string playlist_name { get; set; }
    public bool is_album { get; set; }
    public Gda.Timestamp creation_datetime { get; set; }
    public Gda.Timestamp? update_datetime { get; set; }
}
