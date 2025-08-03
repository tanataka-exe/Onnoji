public interface ApplicationContext : Object {
    public abstract string get_config_file_path() throws Error;
    public abstract KeyFile get_config() throws Error;
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
    public abstract OnnojiActionHandler get_onnoji_action_handler() throws Error;
    public abstract MusicDataProducer get_music_data_producer() throws Error;
    public abstract ResponseJsonMaker get_response_json_maker() throws Error;
    public abstract void finalize() throws Error;
}
