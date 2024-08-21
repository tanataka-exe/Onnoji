public interface SongRepository : Object {
    public abstract int get_next_song_id() throws Error;
    public abstract Gee.List<Song> select_all() throws Error;
    public abstract Gee.List<Song> select_by_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Song> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Song> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Song> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool delete_by_id(int song_id) throws Error;
    public abstract bool update_by_id(int song_id, Gee.Map<string, Value?> params) throws Error;
    public abstract bool update_by_id_v(int song_id, SList<string> param_names, SList<Value?> param_values) throws Error;
    public abstract Gee.List<Song> select_recently_requested(int min, int max) throws Error;
    public abstract Gee.List<Song> select_recently_registered(int min, int max) throws Error;
    public abstract bool insert(Song song, SqlInsertFlags flags = 0) throws Error;
    public abstract bool exists_link_to_playlist(Song song, Playlist playlist) throws Error;
    public abstract bool insert_link_to_playlist(Song song, Playlist playlist, int disc_number, int track_number) throws Error;
    public abstract bool update_link_to_playlist(Song song, Playlist playlist, int disc_number, int track_number) throws Error;
    public abstract bool delete_link_to_playlist(Song song, Playlist playlist) throws Error;
    public abstract bool exists_link_to_artist(Song song, Artist artist) throws Error;
    public abstract bool insert_link_to_artist(Song song, Artist artist) throws Error;
    public abstract bool delete_link_to_artist(Song song, Artist artist) throws Error;
    public abstract bool exists_link_to_genre(Song song, Genre genre) throws Error;
    public abstract bool insert_link_to_genre(Song song, Genre genre) throws Error;
    public abstract bool delete_link_to_genre(Song song, Genre genre) throws Error;
}
