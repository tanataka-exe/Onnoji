public class MusicDataProducerImpl1 : MusicDataProducer, Object {
    public SongRepository song_repo { get; construct set; }
    public PlaylistRepository playlist_repo { get; construct set; }
    public GenreRepository genre_repo { get; construct set; }
    public ArtistRepository artist_repo { get; construct set; }
    public HistoryRepository history_repo { get; construct set; }
    public ArtworkRepository artwork_repo { get; construct set; }
    public ResponseJsonMaker json_maker { get; construct set; }
    public Moegi.FileInfoAdapter file_adapter { get; construct set; }
    public string artwork_base_path { get; construct set; }
    public string song_base_path { get; construct set; }
    public string genre_icon_base_path { get; construct set; }
    public string genre_default_icon_path { get; construct set; }
    public string artwork_default_resource_uri { get; construct set; }
    
    construct {}
    
    public ServiceResponse? register_song_history(int song_id) throws OnnojiError {
        try {
            int history_id = history_repo.get_next_history_id();
            history_repo.insert(new History() {
                history_id = history_id,
                song_id = song_id,
                request_datetime = create_gda_timestamp_now_local()
            });
            return new ServiceResponse.for_json(
                json_maker.object_node(json_maker.success_object())
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at register song history");
        }
    }
    
    public ServiceResponse? query_song_stream(int song_id) throws OnnojiError {
        try {
            Gee.List<Song> songs = this.song_repo.select_by_id(song_id);
            if (songs.size == 1) {
                Song? song = songs[0];
                uint8[] bytestream;
                FileUtils.get_data(song.file_path, out bytestream);
                return new ServiceResponse(bytestream, song.mime_type);
            } else {
                return null;
            }
        } catch (FileError e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        } catch (GLib.Error e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        }
    }

    public ServiceResponse? query_artwork_default() throws OnnojiError {
        try {
            Gdk.Pixbuf? icon_data = new Gdk.Pixbuf.from_resource(artwork_default_resource_uri);
            if (icon_data == null) {
                throw new OnnojiError.RESOURCE_ERROR("default artwork not found");
            }
            uint8[] buffer;
            icon_data.save_to_buffer(out buffer, "png");
            return new ServiceResponse(buffer, "image/png");
        } catch (Error e) {
            throw new OnnojiError.RESOURCE_ERROR("default artwork not found. " + e.message);
        }
    }
    
    public ServiceResponse? query_artwork(int artwork_id) throws OnnojiError {
        try {
            Gee.List<Artwork>? artworks = artwork_repo.select_by_id(artwork_id);
            if (artworks.size != 0) {
                uint8[] data;
                Artwork artwork = artworks[0];
                FileUtils.get_data(artwork.artwork_file_path, out data);
                if (artwork.mime_type == null) {
                    File artwork_file = File.new_for_path(artwork.artwork_file_path);
                    GLib.FileInfo? artwork_file_info = artwork_file.query_info("standard::*", 0);
                    string mime_type = artwork_file_info.get_content_type();
                    return new ServiceResponse(data, mime_type);
                } else {
                    return new ServiceResponse(data, artwork.mime_type);
                }
            } else {
                return null;
            }
        } catch (FileError e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        } catch (GLib.Error e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        }
    }

    public ServiceResponse? query_song_artwork(int song_id) throws OnnojiError {
        try {
            Gee.List<Artwork>? artworks = artwork_repo.select_by_song_id(song_id);
            if (artworks.size > 0) {
                uint8[] data;
                Artwork artwork = artworks[0];
                return query_artwork(artwork.artwork_id);
            } else {
                return null;
            }
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }
    
    public ServiceResponse? query_song_metadata(int song_id) throws OnnojiError {
        try {
            Gee.List<Song>? songs = song_repo.select_by_id(song_id);
            if (songs.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_object_node("metadata", json_maker.song_metadata_object(songs[0]))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_song_artists(int song_id) throws OnnojiError {
        try {
            Gee.List<Artist>? artists = artist_repo.select_by_song_id(song_id);
            if (artists.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("artists", json_maker.artist_array(artists))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_song_genres(int song_id) throws OnnojiError {
        try {
            Gee.List<Genre>? genres = genre_repo.select_by_song_id(song_id);
            if (genres.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("genres", json_maker.genre_array(genres))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_song_albums(int song_id) throws OnnojiError {
        try {
            Gee.List<Playlist>? playlists = playlist_repo.select_by_song_id(song_id);
            Gee.List<Playlist> albums = new Gee.ArrayList<Playlist>();
            albums.add_all_iterator(playlists.filter((item) => item.is_album));
            if (albums.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("albums", json_maker.playlist_array(albums))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_song_playlists(int song_id) throws OnnojiError {
        try {
            Gee.List<Playlist>? playlists = playlist_repo.select_by_song_id(song_id);
            Gee.List<Playlist> playlists2 = new Gee.ArrayList<Playlist>();
            playlists2.add_all_iterator(playlists.filter((item) => !item.is_album));
            if (playlists2.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("playlists", json_maker.playlist_array(playlists2))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_by_id(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Playlist> playlists = playlist_repo.select_by_id(playlist_id);
            if (playlists.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("playlist", json_maker.playlist_array(playlists))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_songs(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Song> songs = song_repo.select_by_playlist_id(playlist_id);
            if (songs.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("songs", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("songs", json_maker.song_array(songs))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_genres(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Genre> genres = genre_repo.select_by_playlist_id(playlist_id);
            if (genres.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("genres", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("genres", json_maker.genre_array(genres))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_artists(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Artist> artists = artist_repo.select_by_playlist_id(playlist_id);
            if (artists.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("artists", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("artists", json_maker.artist_array(artists))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_artworks(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Artwork> artworks = artwork_repo.select_by_playlist_id(playlist_id);
            if (artworks.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("artworks", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("artworks", json_maker.artwork_array(artworks))
            );
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_playlist_artwork(int playlist_id) throws OnnojiError {
        try {
            Gee.List<Artwork> artworks = artwork_repo.select_by_playlist_id(playlist_id);
            if (artworks.size == 0) {
                return query_artwork(0);
            }
            return query_artwork(artworks[0].artwork_id);
        } catch (Error e) {
            throw new OnnojiError.SQL_ERROR(e.message);
        }
    }

    public ServiceResponse? query_artists() throws OnnojiError {
        try {
            Gee.List<Artist> artists = artist_repo.select_all();
            if (artists.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("artists", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("artists", json_maker.artist_array(artists))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artists (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_artist(int artist_id) throws OnnojiError {
        try {
            Gee.List<Artist> artists = artist_repo.select_by_id(artist_id);
            if (artists.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_object_node("artist", json_maker.artist_object(artists[0]))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artists (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_artist_songs(int artist_id) throws OnnojiError {
        try {
            Gee.List<Song> songs = song_repo.select_by_artist_id(artist_id);
            if (songs.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("songs", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("songs", json_maker.song_array(songs))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artist songs (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_artist_genres(int artist_id) throws OnnojiError {
        try {
            Gee.List<Genre> genres = genre_repo.select_by_artist_id(artist_id);
            if (genres.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("genres", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("genres", json_maker.genre_array(genres))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artist genres (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_genre_icon(int genre_id) throws OnnojiError {
        try {
            Gee.List<Genre>? genres = genre_repo.select_by_id(genre_id);
            if (genres.size == 0) {
                return null;
            }
            uint8[] data;
            Genre genre = genres[0];
            debug("genre id = %d, name = %s, file path = %s", genre.genre_id, genre.genre_name, genre.genre_file_path);
            string file_path;
            if (genre.genre_file_path == null) {
                file_path = genre_default_icon_path;
            } else {
                file_path = genre.genre_file_path;
            }
            FileUtils.get_data(file_path, out data);
            File genre_file = File.new_for_path(file_path);
            GLib.FileInfo? genre_file_info = genre_file.query_info("standard::*", 0);
            string mime_type = genre_file_info.get_content_type();
            return new ServiceResponse(data, mime_type);
        } catch (FileError e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        } catch (GLib.Error e) {
            throw new OnnojiError.FILE_ERROR(e.message);
        }
    }
    
    public ServiceResponse? query_genre_songs(int genre_id) throws OnnojiError {
        try {
            Gee.List<Song> songs = song_repo.select_by_genre_id(genre_id);
            if (songs.size == 0) {
                return null;
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("songs", json_maker.song_array(songs))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query genre songs (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_genre_playlists(int genre_id) throws OnnojiError {
        try {
            Gee.List<Playlist> playlist_list = new Gee.ArrayList<Playlist>();
            playlist_list.add_all_iterator(playlist_repo.select_by_genre_id(genre_id)
                    .list_iterator().filter(playlist => !playlist.is_album));

            if (playlist_list.size == 0) {
                return null;
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("playlists", json_maker.playlist_array(playlist_list))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query genre playlists (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? query_genre_albums(int genre_id) throws OnnojiError {

        try {
            Gee.List<Playlist> playlist_list = new Gee.ArrayList<Playlist>();
            playlist_list.add_all_iterator(
                    playlist_repo.select_by_genre_id(genre_id).list_iterator()
                            .filter(playlist => playlist.is_album));

            if (playlist_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("albums", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("albums", json_maker.playlist_array(playlist_list))
            );

        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query genre albums (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? query_genre_artists(int genre_id) throws OnnojiError {
        try {
            Gee.List<Artist> artists = artist_repo.select_by_genre_id(genre_id);
            if (artists.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("artists", json_maker.empty_array())
                );
            }
            return new ServiceResponse.for_json(
                json_maker.named_array_node("artists", json_maker.artist_array(artists))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query genre artists (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_artist_playlists(int artist_id) throws OnnojiError {

        try {
            Gee.List<Playlist> playlist_list = new Gee.ArrayList<Playlist>();
            playlist_list.add_all_iterator(
                    playlist_repo.select_by_artist_id(artist_id).list_iterator()
                            .filter(playlist => !playlist.is_album));

            if (playlist_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("playlists", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("playlists", json_maker.playlist_array(playlist_list))
            );

        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artist playlists (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? query_artist_albums(int artist_id) throws OnnojiError {
        try {

            Gee.List<Playlist> playlist_list = new Gee.ArrayList<Playlist>();
            playlist_list.add_all_iterator(
                    playlist_repo.select_by_artist_id(artist_id).list_iterator()
                            .filter(playlist => playlist.is_album));

            if (playlist_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("albums", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("albums", json_maker.playlist_array(playlist_list))
            );

        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query artist albums (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? query_recently_requested_playlists(int min, int max, bool is_album) throws OnnojiError {
        try {
            Gee.List<Playlist> playlist_list = playlist_repo.select_recently_requested(min, max, is_album);
            if (playlist_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node(is_album ? "albums" : "playlists", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node(
                    is_album ? "albums" : "playlists",
                    json_maker.playlist_array(playlist_list)
                )
            );

        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query recently requested playlists (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_recently_requested_songs(int min, int max) throws OnnojiError {
        try {
            Gee.List<Song> song_list = song_repo.select_recently_requested(min, max);
            debug("retrive song_list OK");
            if (song_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("songs", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("songs", json_maker.song_array(song_list))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query recently requested songs (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? query_recently_registered_playlists(int min, int max, bool is_album) throws OnnojiError {
        try {
            Gee.List<Playlist> playlist_list = playlist_repo.select_recently_registered(min, max, is_album);
            if (playlist_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node(is_album ? "albums" : "playlists", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node(
                    is_album ? "albums" : "playlists",
                    json_maker.playlist_array(playlist_list)
                )
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query recently registered playlists (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_recently_registered_songs(int min, int max) throws OnnojiError {
        try {
            Gee.List<Song> song_list = song_repo.select_recently_registered(min, max);
            if (song_list.size == 0) {
                return new ServiceResponse.for_json(
                    json_maker.named_array_node("songs", json_maker.empty_array())
                );
            }

            return new ServiceResponse.for_json(
                json_maker.named_array_node("songs", json_maker.song_array(song_list))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query recently registered songs (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? query_genres() throws OnnojiError {
        try {
            Gee.List<Genre> genre_list = genre_repo.select_all();
            return new ServiceResponse.for_json(
                json_maker.named_array_node("genres", json_maker.genre_array(genre_list))
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at query genres (details = %s)".printf(e.message));
        }
    }

    public ServiceResponse? register_playlist_with_songs(
            string playlist_name, Gee.List<PostFileData> file_list) throws OnnojiError {
        try {

            // 新しいアルバムを作成する

            int playlist_id = playlist_repo.get_next_playlist_id();
            
            debug("new playlist id = %d", playlist_id);
            
            Playlist new_album = new Playlist() {
                playlist_id = playlist_id,
                playlist_name = playlist_name,
                is_album = true,
                creation_datetime = create_gda_timestamp_now_local(),
                update_datetime = create_gda_timestamp_now_local()
            };
            playlist_repo.insert(new_album);

            debug("playlist (id = %d) was registered", playlist_id);
            
            // 楽曲データを1個ずつ処理する

            foreach (PostFileData file_data in file_list) {

                // 一時ファイルから楽曲のメタデータを読み込む

                Moegi.FileInfo? file_info = file_adapter.read_metadata_from_path(file_data.file_path);

                debug("get file meta data");
                
                // 一時ファイルのMIME-TYPEを取得する

                file_info.mime_type = file_data.mime_type;

                // 新しいアートワークのMD5チェックサムを計算する

                Artwork? artwork = null;

                if (file_info.artwork != null) {
                    uint8[] pixbuf_data = file_info.artwork.get_pixels();
                    if ((int) file_info.artwork.get_byte_length() > 0) {
                        string md5sum = Checksum.compute_for_data(MD5, file_info.artwork.pixel_bytes.get_data());

                        // アートワークの存在確認する

                        Gee.List<Artwork> artwork_list = artwork_repo.select_by_digest(md5sum);

                        // 存在しない場合、新しいアートワークを登録し、ファイルを保存する

                        if (artwork_list.size == 0) {
                            debug("not found artwork select by digest");

                            int artwork_id = artwork_repo.get_next_artwork_id();

                            debug("new artwork id = %d", artwork_id);

                            string new_artwork_file_path = "%s/art%012d".printf(artwork_base_path, artwork_id);
                            artwork = new Artwork() {
                                artwork_id = artwork_id,
                                artwork_file_path = new_artwork_file_path,
                                digest = md5sum
                            };
                            artwork_repo.insert(artwork);

                            debug("new artwork (id = %d) was registered", artwork_id);

                            // アートワークファイルをファイルシステムに保存する

                            file_info.artwork.save(new_artwork_file_path, "jpeg");

                            debug("new artwork file was saved at %s", new_artwork_file_path);

                        // 存在する場合、既存のアートワークのIDを取っておく。

                        } else {
                            debug("found artwork select by digest");

                            artwork = artwork_list[0];
                        }
                    }
                }

                // アーティストが存在するかどうか探す

                Gee.List<Artist>? artists = new Gee.ArrayList<Artist>();

                if (file_info.artist != null) {
                    string[] artist_names = file_info.artist.split(",");
                    foreach (string  artist_name in artist_names) {
                        artist_name = artist_name.strip();
                        Gee.List<Artist> artist_list = artist_repo.select_by_name(artist_name);

                        // 存在しない場合、新しいアーティストを登録する。

                        if (artist_list.size == 0) {
                            debug("not found artist");

                            int artist_id = artist_repo.get_next_artist_id();
                            Artist artist = new Artist() {
                                artist_id = artist_id,
                                artist_name = artist_name
                            };
                            artist_repo.insert(artist);

                            debug("new artist (id = %d) was registered", artist_id);

                            artists.add(artist);

                        // 存在する場合、既存のアーティストのIDを取得する。

                        } else {
                            debug("found artist");

                            artists.add(artist_list[0]);
                        }
                    }
                }

                // ジャンルが存在するかどうか探す

                Gee.List<Genre>? genres = new Gee.ArrayList<Genre>();

                if (file_info.genre != null) {
                    string[] genre_names = file_info.genre.split(",");
                    foreach (string genre_name in genre_names) {
                        genre_name = genre_name.strip();
                        debug("genre is %s", genre_name);

                        Gee.List<Genre> genre_list = genre_repo.select_by_name(genre_name);

                        // 存在しない場合、新しいジャンルを登録する。

                        if (genre_list.size == 0) {
                            debug("not found genre");

                            int genre_id = genre_repo.get_next_genre_id();

                            debug("next genre id = %d", genre_id);

                            Genre genre = new Genre() {
                                genre_id = genre_id,
                                genre_name = genre_name
                            };
                            genre_repo.insert(genre);

                            debug("new genre was registered");

                            genres.add(genre);
                            
                        // 存在する場合、既存のジャンルのIDを取得する。

                        } else {
                            debug("found genre");

                            genres.add(genre_list[0]);
                        }
                    }
                }

                // 楽曲のIDを取得する

                int song_id = song_repo.get_next_song_id();

                // 楽曲のチェックサムを計算する

                string song_md5sum = calc_md5sum(File.new_for_path(file_data.file_path));

                Song? song = new Song() {
                    song_id = song_id,
                    title = file_info.title,
                    pub_date = (int) file_info.date,
                    copyright = file_info.copyright,
                    comment = file_info.comment,
                    time_length_milliseconds = file_info.time_length_milliseconds,
                    mime_type = file_data.mime_type,
                    file_path = "%s/sng%012d".printf(song_base_path, song_id),
                    digest = song_md5sum,
                    artwork_id = (artwork == null ? 0 : artwork.artwork_id),
                    creation_datetime = create_gda_timestamp_now_local()
                };

                song_repo.insert(song);

                debug("The song (id = %d) was registered!", song_id);
                
                string song_file_path = "%s/sng%012d".printf(song_base_path, song_id);
                
                File src_file = File.new_for_path(file_data.file_path);
                File dest_file = File.new_for_path(song_file_path);
                src_file.move(dest_file, FileCopyFlags.NONE);

                debug("The file was moved! path: %s", song_file_path);
                
                if (new_album != null) {
                    song_repo.insert_link_to_playlist(song, new_album, (int) file_info.disc_number, (int) file_info.track);
                    
                    debug("The song (id = %d) was added to album (id = %d)", song_id, playlist_id);
                }
                
                if (artists.size > 0) {
                    foreach (Artist artist in artists) {
                        if (!song_repo.exists_link_to_artist(song, artist)) {
                            song_repo.insert_link_to_artist(song, artist);

                            debug("The artist (id = %d) was added to song (id = %d)", artist.artist_id, song.song_id);
                        }
                    }
                }
                
                if (genres.size > 0) {
                    foreach (Genre genre in genres) {
                        if (!song_repo.exists_link_to_genre(song, genre)) {
                            song_repo.insert_link_to_genre(song, genre);

                            debug("The song (id = %d) was added to genre (id = %d)", song.song_id, genre.genre_id);
                        }
                    }
                }
            }
            
            return new ServiceResponse.for_json(
                json_maker.object_node(json_maker.success_object())
            );
        } catch (GLib.Error e) {
            throw new OnnojiError.SQL_ERROR("Error at register song (details = %s)".printf(e.message));
        }
    }
    
    public ServiceResponse? register_genre_icon(int genre_id, string genre_icon_file_path) throws OnnojiError {
        string dest_genre_icon_file_path = "%s/gnr%012d".printf(genre_icon_base_path, genre_id);
        debug("src_genre_icon_file_path = %s\n", genre_icon_file_path);
        debug("dest_genre_icon_file_path = %s\n", dest_genre_icon_file_path);
        File src_file = File.new_for_path(genre_icon_file_path);
        File dest_file = File.new_for_path(dest_genre_icon_file_path);
        src_file.move(dest_file, FileCopyFlags.OVERWRITE);
        genre_repo.update_by_id(genre_id,
            slist<string>("genre_file_path"),
            slist<Value?>(Values.of_string(dest_genre_icon_file_path))
        );
        return new ServiceResponse.for_json(
            json_maker.object_node(json_maker.success_object())
        );
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
}
