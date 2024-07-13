public interface ArtworkRepository : Object {
    public abstract int get_next_artwork_id() throws Error;
    public abstract Gee.List<Artwork> select_by_id(int artwork_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artwork> select_by_digest(string digest, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artwork> select_by_artist_id(int artist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artwork> select_by_song_id(int song_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract Gee.List<Artwork> select_by_playlist_id(int playlist_id, SqlConditionType cond_type = EQUALS) throws Error;
    public abstract bool delete_by_id(int artwork_id) throws Error;
    public abstract bool update_by_id(int artwork_id, string new_path, string new_mime_type, string new_digest) throws Error;
    public abstract bool insert(Artwork artwork, SqlInsertFlags flags = 0) throws Error;
}
