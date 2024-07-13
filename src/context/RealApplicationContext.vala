public class RealApplicationContext : ApplicationContext, Object {

    private static RealApplicationContext? instance;
    
    private Gda.Connection? conn;
    private SongRepository song_repo;
    private GenreRepository genre_repo;
    private PlaylistRepository playlist_repo;
    private ArtistRepository artist_repo;
    private ArtworkRepository artwork_repo;
    private HistoryRepository history_repo;
    private ResourceManager? resource;
    private XmlResourceManager? xml_resource;

    private RealApplicationContext() {}
    
    public static RealApplicationContext get_instance() {
        if (instance == null) {
            instance = new RealApplicationContext();
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
                get_resource_manager().get_string("db.provider"),
                get_resource_manager().get_string("db.cns"),
                get_resource_manager().get_string("db.auth"), 0
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
    
    public Soup.Server get_server() throws Error {
        int port = 8765;
        Soup.Server server = new Soup.Server("server-header", null);
        server.listen_local(port, 0);
        return server;
    }
    
    public OnnojiThreadData get_onnoji_thread_data() throws Error {
        return new OnnojiThreadData() {
            producer = get_music_data_producer()
        };
    }

    public Moegi.MetadataReader get_moegi_metadata_reader() {
        return new Moegi.MetadataReader();
    }
    
    public Moegi.FileInfoAdapter get_moegi_file_info_adapter() {
        return new Moegi.FileInfoAdapter(get_moegi_metadata_reader());
    }
    
    public MusicDataProducer get_music_data_producer() throws Error {
        return new MusicDataProducerImpl1() {
            song_repo = get_song_repository(),
            genre_repo = get_genre_repository(),
            artist_repo = get_artist_repository(),
            playlist_repo = get_playlist_repository(),
            history_repo = get_history_repository(),
            artwork_repo = get_artwork_repository(),
            json_maker = get_response_json_maker(),
            file_adapter = get_moegi_file_info_adapter(),
            artwork_base_path = get_resource_manager().get_string("test.server.path.artwork"),
            song_base_path = get_resource_manager().get_string("test.server.path.song"),
            genre_default_icon_path = get_resource_manager().get_string("test.server.path.genre-default-icon"),
            artwork_default_resource_uri = "/local/asusturn/onnoji/images/empty-image200.png"
        };
    }
    
    /*
    public OnnojiBatch get_onnoji_batch() {
        return new OnnojiBatch();
    }
    
    public BatchTask get_batch_task() {
        return new BatchTask() {
            song_dir_path = get_resource_manager().get_string("server.path.song"),
            artwork_dir_path = get_resource_manager().get_string("server.path.artworks"),
            database_path = get_resource_manager().get_string("server.path.database"),
            conn = get_gda_connection(),
            song_repo = get_song_repository(),
            genre_repo = get_genre_repository(),
            artist_repo = get_artist_repository(),
            playlist_repo = get_playlist_repository(),
            history_repo = get_history_repository(),
            relation_repo = get_relation_repository()
        };
    }
    */
    
    public ResponseJsonMaker get_response_json_maker() throws Error {
        return new ResponseJsonMaker();
    }
    
    public void finalize() throws Error {
        conn.close();
        debug("connection was closed");
    }

}
