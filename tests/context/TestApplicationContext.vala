public class TestApplicationContext : ApplicationContext, Object {

    private static TestApplicationContext? instance;
    
    private Gda.Connection? conn;
    private ResourceManager? resource;
    private XmlResourceManager? xml_resource;
    private SongRepository? song_repo;
    private GenreRepository? genre_repo;
    private ArtistRepository? artist_repo;
    private PlaylistRepository? playlist_repo;
    private HistoryRepository? history_repo;
    private ArtworkRepository? artwork_repo;
    private MusicDataProducer? producer;
    private ResponseJsonMaker? json_maker;

    private TestApplicationContext() {}
    
    public static TestApplicationContext get_instance() {
        if (instance == null) {
            instance = new TestApplicationContext();
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
                get_resource_manager().get_string("test.db.provider"),
                get_resource_manager().get_string("test.db.cns"),
                get_resource_manager().get_string("test.db.auth"), 0
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
            artwork_repo = new ArtworkRepositoryImpl(
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
        return new Soup.Server("port", 8765);
    }
    
    public OnnojiThreadData get_onnoji_thread_data() throws Error {
        return new OnnojiThreadData() {
            producer = get_producer()
        };
    }

    public MusicDataProducer get_producer() {
        if (producer == null) {
            producer = new MusicDataProducerImpl1() {
                conn = get_gda_connection(),
                song_repo = get_song_repository(),
                genre_repo = get_genre_repository(),
                artist_repo = get_artist_repository(),
                playlist_repo = get_playlist_repository(),
                history_repo = get_history_repository(),
                relation_repo = get_relation_repository(),
                json_maker = get_response_json_maker()
            };
        }
        return producer;
    }
    
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
    
    public ResponseJsonMaker get_response_json_maker() throws Error {
        if (response_json_maker == null) {
            response_json_maker = new ResponseJsonMaker();
        }
        return response_json_maker;
    }
    
    public void close() {
        conn.close();
        debug("connection was closed");
    }

}
