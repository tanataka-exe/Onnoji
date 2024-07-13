using Moegi;

class BatchTask : Object {
    private Sqlite.Database db;
    public string database_path { get; construct set; }
    public string song_dir_path { get; construct set; }
    public string artwork_dir_path { get; construct set; }
    public bool is_copy_song_files { get; construct set; }
    public bool is_copy_artwork_files { get; construct set; }
    public bool is_recursive { get; set; default = false; }
    public Gee.List<string>? registered_album_ids;
    public Gda.Connection conn { get; set; }
    public SongRepository songs_repository { get; set; }
    public Playlist playlist_repo { get; set; }
    public GenreRepository genre_repo;
    public Artist artist_repo;
    public HistoryRepository history_repo;
    public RelationRepository relation_repo;
    public ArtworkRepository artwork_repo;

    public BatchTack(SongRepository song_repo, PlaylistRepository playlist_repo, ArtistRepository artist_repo,
            GenreRepository genre_repo) {
        this.song_repo = song_repo;
        this.playlist_repo = playlist_repo;
        this.artist_repo = artist_repo;
        this.genre_repo = genre_repo;
    }
    
    private void init_registered_album_ids() {
        registered_album_ids = new Gee.ArrayList<string>();
    }
    
    private void add_album_id(string album_id) {
        if (registered_album_ids == null) {
            init_registered_album_ids();
        }
        registered_album_ids.add(album_id);
    }
    
    private bool is_registered_at_same_time(string album_id) {
        if (registered_album_ids == null) {
            init_registered_album_ids();
        }
        return album_id in registered_album_ids;
    }
    
    public int execute(Gee.List<string> file_paths) throws OnnojiError {
        foreach (string file_path in file_paths) {
            File file = File.new_for_path(file_path);
            if (!file.query_exists()) {
                return 2;
            }
            if (FileUtils.test(file_path, IS_REGULAR)) {
                return execute_file(file);
            } else if (FileUtils.test(file_path, IS_DIR) && is_recursive) {
                return execute_directory(file);
            }
        }
        return 0;
    }
    
    private int execute_file(File file) throws OnnojiError {
        Moegi.FileInfo? music_info = read_music_info(file);
        int playlist_id;
        do {
            playlist_id = playlist_repo.get_next_id();
            if (!is_registered_at_same_time(playlist_id) && playlist_repo.playlist_exists(playlist_id)) {
                print(@"The playlist named \"$(music_info.dir)\" exists. Do you rename it?[y/n]: ");
                string? answer = stdin.read_line();
                if (answer != null && answer == "y") {
                    print("Enter the new playlist_name: ");
                    playlist_id_name = stdin.read_line();
                } else {
                    print("This registration was cancelled\n");
                    return 1;
                }
            } else {
                break;
            }
        } while (true);
        music_info.dir = playlist_id_name;
        add_playlist_id(playlist_id);
        if (music_info != null && music_info.type == Moegi.FileType.MUSIC) {
            print("execute file \"%s\"\n", file.get_path());
            string md5sum = calc_md5sum(file);
            print("  md5sum: %s\n", md5sum);
            print("  music info: %s\n", music_info.to_string());
            Songs songs = new Songs(db);
            bool is_found = song_repo.song_exists(md5sum);
            if (!is_found) {
                print("  Register mode\n");
                File? artwork_file = null;
                if (music_info.artwork != null) {
                    artwork_file = save_artwork_file(md5sum, music_info.artwork);
                }
                if (is_copy_artwork_files && artwork_file != null) {
                    print("  Artwork was saved\n");
                }
                File song_file = save_song_file(md5sum, music_info.path);
                if (is_copy_song_files) {
                    print("  Song file was saved\n");
                }
                try {
                    register_song(md5sum, music_info, song_file.get_path(),
                            artwork_file != null ? artwork_file.get_path() : null);
                    print("  Song data was registered\n");
                    return 0;
                } catch (OnnojiError e) {
                    string? errmsg = "";
                    try {
                        artwork_file.delete();
                        stderr.puts("  Artwork was deleted\n");
                    } catch (GLib.Error e) {
                        errmsg += e.message;
                    }
                    
                    try {
                        song_file.delete();
                        stderr.puts("  Song file was deleted\n");
                    } catch (GLib.Error e) {
                        errmsg += e.message;
                    }
                    
                    if (errmsg.length > 0) {
                        throw new OnnojiError.FILE_ERROR(e.message + "\n" + errmsg);
                    }

                    throw e;
                }
            } else {
                stderr.puts("Song does already exist (%s)\n");
                return 6;
            }
        } else {
            stderr.puts("The file is not a music file (%s)\n");
            return 4;
        }
    }
    
    private int execute_directory(File file) throws OnnojiError {
        try {
            Dir dir = Dir.open(file.get_path());
            string? name;
            while ((name = dir.read_name()) != null) {
                if (name[0] == '.') {
                    continue;
                }
                string child_path = Path.build_path(Path.DIR_SEPARATOR_S, file.get_path(), name);
                File child = File.new_for_path(child_path);
                if (FileUtils.test(child_path, FileTest.IS_REGULAR)) {
                    try {
                        int status = execute_file(child);
                    } catch (OnnojiError e) {
                        stderr.puts(e.message);
                    }
                } else if (FileUtils.test(child_path, FileTest.IS_DIR)) {
                    int status = execute_directory(child);
                    if (status != 0) {
                        return status;
                    }
                }
            }
            return 0;
        } catch (FileError e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        }
    }
    
    private Moegi.FileInfo? read_music_info(File file) throws OnnojiError {
        try {
            GLib.FileInfo fi = file.query_info("standard::*", 0);
            string mime_type = fi.get_content_type();
            FileInfoAdapter freader = new FileInfoAdapter();
            if (mime_type.has_prefix("audio/")) {
                Moegi.FileInfo? file_info = freader.read_metadata_from_path(file.get_path());
                if (file_info == null) {
                    return null;
                } else if (file_info.type == Moegi.FileType.MUSIC) {
                    file_info.mime_type = mime_type;
                    return file_info;
                }
            }
            return null;
        } catch (GLib.Error e) {
            throw new OnnojiError.OTHER_ERROR(@"Error: $(e.message)");
        }
    }

    private string calc_md5sum(File file) {
        Checksum checksum = new Checksum(ChecksumType.MD5);
        FileStream stream = FileStream.open(file.get_path(), "rb");
        uint8 fbuf[100];
        size_t size;

        while((size = stream.read(fbuf)) > 0) {
            checksum.update(fbuf, size);
        }

        return checksum.get_string();
    }

    public void register_song(string md5sum, Moegi.FileInfo music_info, string song_file_path,
            string? artwork_file_path) throws OnnojiError {
        Song data = new Song();
        data.song_id = md5sum;
        data.title = music_info.title == null || music_info.title == "" ? music_info.name : music_info.title;
        
        if (music_info.artist != null) {
            Artists artists = new Artists(db);
            
            int artist_id = artists.find_artist_id(music_info.artist);
            if (artist_id <= 0) {
                Artist artist = new Artist();
                artist.artist_id = artists.find_max_artist_id() + 1;
                artist.artist_name = music_info.artist;
                artist_repo.insert(artist);
                artist_id = artist.artist_id;
            }
            data.artist_id = artist_id;
        }
        
        if (music_info.genre != null) {
            Genres genres = new Genres(db);

            int genre_id = genres.find_genre_id(music_info.genre);
            if (genre_id <= 0) {
                Genre genre = new Genre();
                genre.genre_id = genres.find_max_genre_id() + 1;
                genre.genre_name = music_info.genre;
                genre_repo.insert(genre);
                genre_id = genre.genre_id;
            }
            data.genre_id = genre_id;
        }
        
        string playlist_id = calc_playlist_id(music_info.dir);
        if (!playlist_repo.playlist_exists(playlist_id)) {
            Playlist playlist = new Playlist();
            playlist.id = playlist_id;
            if (music_info.playlist != null) {
                playlist.name = music_info.playlist;
            } else {
                File dir_file = File.new_for_path(music_info.dir);
                playlist.name = dir_file.get_basename();
            }
            playlist.id_name = music_info.dir;
            playlist_repo.insert(playlist);
        }
        data.playlist_id = playlist_id;
        
        data.disc_number = (int) music_info.disc_number;
        data.track_number = (int) music_info.track;
        data.pub_date = (int) music_info.date;
        data.copyright = music_info.copyright;
        data.comment = music_info.comment;
        data.time_length = music_info.time_length;
        data.mime_type = music_info.mime_type;
        data.file_path = song_file_path;
        data.artwork_file_path = artwork_file_path;
        data.creation_datetime = new DateTime.now_local();
        
        song_repo.insert(data);
    }
    
    private string calc_playlist_id(string playlist_dir) {
        return Checksum.compute_for_string(ChecksumType.MD5, playlist_dir, playlist_dir.length);
    }
    
    private File? save_artwork_file(string song_id, Gdk.Pixbuf artwork) throws OnnojiError {
        try {
            string artwork_checksum = Checksum.compute_for_data(MD5, artwork.pixel_bytes.get_data());
            string artwork_file_path = Path.build_path(Path.DIR_SEPARATOR_S, artwork_dir_path, artwork_checksum);
            File artwork_file = File.new_for_path(artwork_file_path);
            if (artwork_file.query_exists()) {
                return artwork_file;
            }
            if (is_copy_artwork_files) {
                File artwork_dir = artwork_file.get_parent();
                if (!artwork_dir.query_exists()) {
                    DirUtils.create_with_parents(artwork_dir.get_path(), 0755);
                }
                artwork.save(artwork_file_path, "jpeg");
            }
            return artwork_file;
        } catch (IOError e) {
            throw new OnnojiError.IO_ERROR(@"IOError: $(e.message)");
        } catch (GLib.Error e) {
            throw new OnnojiError.OTHER_ERROR(@"Error: $(e.message)");
        }
    }
    
    private File save_song_file(string song_id, string src_file_path) throws OnnojiError {
        try {
            File src_file = File.new_for_path(src_file_path);
            string song_file_path = Path.build_path(Path.DIR_SEPARATOR_S, song_dir_path, song_id);
            File dest_file = File.new_for_path(song_file_path);
            if (is_copy_song_files) {
                File dest_dir = dest_file.get_parent();
                if (!dest_dir.query_exists()) {
                    DirUtils.create_with_parents(dest_dir.get_path(), 0755);
                }
                bool result = src_file.copy(dest_file, NONE, null, null);
                if (!result) {
                    throw new OnnojiError.FILE_ERROR(@"FileError: copy failed ($(src_file.get_path()) -> $(dest_file.get_path()))");
                }
            }
            return dest_file;
        } catch (GLib.Error e) {
            throw new OnnojiError.FILE_ERROR(@"Error (copy): $(e.message)");
        }
    }
}
