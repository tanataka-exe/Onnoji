public interface ArtistRepository : Object {
    public abstract int get_next_artist_id() throws Error;
    public abstract Gee.List<Artist> select_all() throws Error;
    public abstract Gee.List<Artist> select_by_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artist> select_by_name(string artist_name, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artist> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artist> select_by_genre_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artist> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool delete_by_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool update_by_id(int artist_id, string new_artist_name) throws Error;
    public abstract bool insert(Artist artist, SqlInsertFlags flags = 0) throws Error;
    public abstract bool insert_link_to_song(Artist artist, Song song) throws Error;
    public abstract bool delete_link_to_song(Artist artist, Song song) throws Error;
}
