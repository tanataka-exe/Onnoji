public class ReorgContext : Object {

    private static ReorgContext? instance;
    
    private Gda.Connection? conn;
    private SongRepository song_repo;
    private GenreRepository genre_repo;
    private PlaylistRepository playlist_repo;
    private ArtistRepository artist_repo;
    private ArtworkRepository artwork_repo;
    private HistoryRepository history_repo;
    private ResourceManager? resource;
    private XmlResourceManager? xml_resource;

    private ReorgContext() {}
    
    public static ReorgContext get_instance() {
        if (instance == null) {
            instance = new ReorgContext();
        }
        return instance;
    }
    
    public ResourceManager get_resource_manager() throws Error {
        if (resource == null) {
            resource = new ResourceManager.for_uri("resource:///local/asusturn/onnoji/main/application.properties");
        }
        return resource;
    }
    
    public XmlResourceManager get_xml_resource_manager() throws Error {
        if (xml_resource == null) {
            xml_resource = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
        }
        return xml_resource;
    }

    public Gda.Connection get_gda_connection() throws Error {
        if (this.conn == null) {
            this.conn = Gda.Connection.open_from_string(
                get_resource_manager().get_string("reorg.db.provider"),
                get_resource_manager().get_string("reorg.db.cns"),
                get_resource_manager().get_string("reorg.db.auth"), 0
            );
        } else if (!this.conn.is_opened()) {
            this.conn.open();
        }
        return this.conn;
    }

    public ArtistRepository get_artist_repository() throws Error {
        if (artist_repo == null) {
            artist_repo = new ArtistRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return artist_repo;
    }
    
    public ArtworkRepository get_artwork_repository() throws Error {
        if (artwork_repo == null) {
            artwork_repo =  new ArtworkRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return artwork_repo;
    }
    
    public GenreRepository get_genre_repository() throws Error {
        if (genre_repo == null) {
            genre_repo = new GenreRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return genre_repo;
    }
    
    public SongRepository get_song_repository() throws Error {
        if (song_repo == null) {
        song_repo = new SongRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return song_repo;
    }
    
    public PlaylistRepository get_playlist_repository() throws Error {
        if (playlist_repo == null) {
            playlist_repo = new PlaylistRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return playlist_repo;
    }
    
    public HistoryRepository get_history_repository() throws Error {
        if (history_repo == null) {
            history_repo = new HistoryRepositoryImpl(
                get_xml_resource_manager(),
                get_gda_connection()
            );
        }
        return history_repo;
    }
    
    public Moegi.MetadataReader get_moegi_metadata_reader() {
        return new Moegi.MetadataReader();
    }
    
    public Moegi.FileInfoAdapter get_moegi_file_info_adapter() {
        return new Moegi.FileInfoAdapter(get_moegi_metadata_reader());
    }
    
    public void finalization() throws Error {
        conn.close();
        debug("connection was closed");
    }

}
