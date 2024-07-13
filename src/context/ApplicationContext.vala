public interface ApplicationContext : Object {
    public abstract ResourceManager get_resource_manager() throws Error;
    public abstract XmlResourceManager get_xml_resource_manager() throws Error;
    public abstract Gda.Connection get_gda_connection() throws Error;
    public abstract ArtistRepository get_artist_repository() throws Error;
    public abstract ArtworkRepository get_artwork_repository() throws Error;
    public abstract GenreRepository get_genre_repository() throws Error;
    public abstract SongRepository get_song_repository() throws Error;
    public abstract PlaylistRepository get_playlist_repository() throws Error;
    public abstract HistoryRepository get_history_repository() throws Error;
    public abstract Soup.Server get_server() throws Error;
    public abstract OnnojiThreadData get_onnoji_thread_data() throws Error;
    public abstract MusicDataProducer get_music_data_producer() throws Error;
    public abstract ResponseJsonMaker get_response_json_maker() throws Error;
    //public abstract OnnojiBatch get_onnoji_batch() throws Error;
    //public abstract BatchTask get_batch_task() throws Error;
    public abstract void finalize() throws Error;
}
