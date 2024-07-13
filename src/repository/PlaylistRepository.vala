public interface PlaylistRepository : Object {
    public abstract int get_next_playlist_id() throws Error;
    public abstract Gee.List<Playlist> select_by_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Playlist> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Playlist> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Playlist> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Playlist> select_recently_requested(int min, int max, bool is_album) throws Error;
    public abstract Gee.List<Playlist> select_recently_registered(int min, int max, bool is_album) throws Error;
    public abstract bool delete_by_id(int playlist_id) throws Error;
    public abstract bool update_by_id(int playlist_id, SList<string> col_names, SList<Value?> col_values) throws Error;
    public abstract bool insert(Playlist playlist, SqlInsertFlags flags = 0) throws Error;
    public abstract bool insert_link_to_song(Playlist playlist, Song song, int disc_number, int track_number) throws Error;
    public abstract bool delete_link_to_song(Playlist playlist, Song song) throws Error;
    public abstract bool update_link_to_song(Playlist playlist, Song song, int disc_number, int track_number) throws Error;
}
