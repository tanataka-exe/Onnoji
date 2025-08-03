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
    private KeyFile? config;

    private RealApplicationContext() {}
    
    public static RealApplicationContext get_instance() {
        if (instance == null) {
            instance = new RealApplicationContext();
        }
        return instance;
    }

    public string get_config_file_path() throws Error {
        return Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_home_dir(), ".onnoji");
    }
    
    public KeyFile get_config() throws Error {
        debug("get_config");
        if (config == null) {
            debug("config is not initialized");
            string config_file_path = get_config_file_path();
            if (!FileUtils.test(config_file_path, FileTest.EXISTS)) {
                debug("config file does not exist");
                throw new OnnojiError.CONFIG_NOT_EXIST("config file does not exists.");
            }
            debug("config file exists");
            config = new KeyFile();
            config.load_from_file(config_file_path, KeyFileFlags.NONE);
        }
        return config;
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
        string? config_db_provider = null;
        string? config_db_cns = null;
        string? config_db_auth = null;

        config_db_provider = Environment.get_variable("ONNOJI_CONFIG_DB_PROVIDER");
        if (config_db_provider == null) {
            config_db_provider = get_config().get_string("BasicSettings", "db.provider");
        }

        config_db_cns = Environment.get_variable("ONNOJI_CONFIG_DB_CNS");
        if (config_db_cns == null) {
            config_db_cns = get_config().get_string("BasicSettings", "db.cns");
        }
        
        config_db_auth = Environment.get_variable("ONNOJI_CONFIG_DB_AUTH");
        if (config_db_auth == null) {
            config_db_auth = get_config().get_string("BasicSettings", "db.auth");
        }
        
        if (this.conn == null) {
            this.conn = Gda.Connection.open_from_string(
                config_db_provider,
                config_db_cns,
                config_db_auth, 0
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
        int port = get_config().get_integer("BasicSettings", "server.port");
        Soup.Server server = new Soup.Server("server-header", null);
        server.listen_all(port, 0);
        return server;
    }

    public OnnojiActionHandler get_onnoji_action_handler() throws Error {
        string? onnoji_config_access_control_allow_origin = null;

        onnoji_config_access_control_allow_origin =
                Environment.get_variable("ONNOJI_CONFIG_ACCESS_CONTROL_ALLOW_ORIGIN");
        if (onnoji_config_access_control_allow_origin == null) {
            onnoji_config_access_control_allow_origin =
                    get_config().get_string("BasicSettings", "server.access-control-allow-origin");
        }
        
        return new OnnojiActionHandler() {
            producer = get_music_data_producer(),
            access_control_allow_origin = onnoji_config_access_control_allow_origin
        };
    }

    public Moegi.MetadataReader get_moegi_metadata_reader() {
        return new Moegi.MetadataReader();
    }
    
    public Moegi.FileInfoAdapter get_moegi_file_info_adapter() {
        return new Moegi.FileInfoAdapter(get_moegi_metadata_reader());
    }
    
    public MusicDataProducer get_music_data_producer() throws Error {
        string? config_artwork_path = Environment.get_variable("ONNOJI_CONFIG_ARTWORK_PATH");
        string? config_song_path = Environment.get_variable("ONNOJI_CONFIG_SONG_PATH");
        string? config_genre_path = Environment.get_variable("ONNOJI_CONFIG_GENRE_PATH");
        string? config_genre_default_icon_path = Environment.get_variable("ONNOJI_CONFIG_GENRE_DEFAULT_ICON_PATH");
        if (config_artwork_path == null) {
            config_artwork_path = get_config().get_string("BasicSettings", "server.path.artwork");
        }
        if (config_song_path == null) {
            config_song_path = get_config().get_string("BasicSettings", "server.path.song");
        }
        if (config_genre_path == null) {
            config_genre_path = get_config().get_string("BasicSettings", "server.path.genre");
        }
        if (config_genre_default_icon_path == null) {
            config_genre_default_icon_path = get_config().get_string("BasicSettings", "server.path.genre-default-icon");
        }
        return new MusicDataProducerImpl1() {
            song_repo = get_song_repository(),
            genre_repo = get_genre_repository(),
            artist_repo = get_artist_repository(),
            playlist_repo = get_playlist_repository(),
            history_repo = get_history_repository(),
            artwork_repo = get_artwork_repository(),
            json_maker = get_response_json_maker(),
            file_adapter = get_moegi_file_info_adapter(),
            artwork_base_path = config_artwork_path,
            song_base_path = config_song_path,
            genre_icon_base_path = config_genre_path,
            genre_default_icon_path = config_genre_default_icon_path,
            artwork_default_resource_uri = "/local/asusturn/onnoji/images/empty-image200.png"
        };
    }

    public ResponseJsonMaker get_response_json_maker() throws Error {
        return new ResponseJsonMaker();
    }
    
    public void finalize() throws Error {
        conn.close();
        debug("connection was closed");
    }

}
