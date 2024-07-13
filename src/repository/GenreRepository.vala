public interface GenreRepository : Object {
    public abstract int get_next_genre_id() throws Error;
    public abstract Gee.List<Genre> select_by_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Genre> select_by_name(string genre_name, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Genre> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Genre> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Genre> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Genre> select_all() throws Error;
    public abstract bool delete_by_id(int genre_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool update_by_id(int genre_id, string new_genre_name, string new_file_path, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool insert(Genre genre, SqlInsertFlags flags = 0) throws Error;
    public abstract bool insert_link_to_song(Genre genre, Song song) throws Error;
    public abstract bool delete_link_to_song(Genre genre, Song song) throws Error;
}
