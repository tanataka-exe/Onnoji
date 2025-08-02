int main(string[] args) {
    set_print_handler(text => stdout.puts(text));
    set_printerr_handler(text => stderr.puts(text));
    Gst.init(ref args);
    ReorgContext ctx = ReorgContext.get_instance();
    try {
        PlaylistRepository playlist_repo = ctx.get_playlist_repository();
        print("-- playlist_repo is initialized\n");
        SongRepository song_repo = ctx.get_song_repository();
        print("-- song_repo is initialized\n");
        ArtistRepository artist_repo = ctx.get_artist_repository();
        print("-- artist_repo is initialized\n");
        GenreRepository genre_repo = ctx.get_genre_repository();
        print("-- genre_repo is initialized\n");
        Moegi.FileInfoAdapter file_info_adapter = ctx.get_moegi_file_info_adapter();
        print("-- file_info_adapter is initialized.\n");
        Gee.List<Playlist> playlists = playlist_repo.select_by_id(0, GREATER_THAN | EQUALS);
        print("-- %d playlists exists\n", playlists.size);
        Gee.List<string> genre_names = new Gee.ArrayList<string>();
        Gee.List<string> artist_names = new Gee.ArrayList<string>();
        Gee.List<string> sql_list = new Gee.ArrayList<string>();
        foreach (Playlist playlist in playlists) {
            if (!playlist.is_album) {
                continue;
            }
            Gee.List<Song> songs = song_repo.select_by_playlist_id(playlist.playlist_id);
            foreach (Song song in songs) {
                if (!FileUtils.test(song.file_path, FileTest.EXISTS)) {
                    printerr("-- file doesn't exist\n");
                    continue;
                }
                Moegi.FileInfo info = file_info_adapter.read_metadata_from_path(song.file_path);
                string sql = "update song set\n";
                bool comma_needed = false;
                if (song.title.collate(info.title) != 0) {
                    sql += "  title = '%s'\n".printf(info.title);
                    comma_needed = true;
                }
                if (info.comment != null) {
                    sql += "  %s comment = '%s'\n".printf(comma_needed ? "," : "", info.comment);
                    comma_needed = true;
                }
                if (info.copyright != null) {
                    sql += "  %s copyright = '%s'\n".printf(comma_needed ? "," : "", info.copyright);
                    comma_needed = true;
                }
                if (info.time_length_milliseconds > 0) {
                    sql += "  %s time_length_milliseconds = %u\n".printf(comma_needed ? "," : "", info.time_length_milliseconds);
                }
                sql += "where\n";
                sql += "  song_id = %d;\n".printf(song.song_id);
                if (info.title.collate(song.title) != 0 || info.comment != null || info.copyright != null) {
                    sql_list.add(sql);
                }
                Gee.List<Genre> old_genres = genre_repo.select_by_song_id(song.song_id);
                if (info.genre != null) {
                    string[] genre_parted = info.genre.split(",");
                    sql_list.add("delete from song_genre where song_id = %d;\n".printf(song.song_id));
                    foreach (string genre_name in genre_parted) {
                        genre_name = genre_name.strip();
                        int genre_id = genre_names.index_of(genre_name) + 1;
                        if (genre_id <= 0) {
                            genre_names.add(genre_name);
                            genre_id = genre_names.size;
                            sql_list.add("insert into genre values (%d, '%s');\n".printf(genre_id, genre_name));
                        }
                        string link_sql = "insert into song_genre values (%d, %d);\n".printf(song.song_id, genre_id);
                        if (sql_list.index_of(link_sql) < 0) {
                            sql_list.add(link_sql);
                        }
                    }
                }
                Gee.List<Artist> old_artists = artist_repo.select_by_song_id(song.song_id);
                if (info.artist != null) {
                    string[] artist_parted = info.artist.split(",");
                    sql_list.add("delete from song_artist where song_id = %d;\n".printf(song.song_id));
                    foreach (string artist_name in artist_parted) {
                        artist_name = artist_name.strip();
                        int artist_id = artist_names.index_of(artist_name) + 1;
                        if (artist_id <= 0) {
                            artist_names.add(artist_name);
                            artist_id = artist_names.size;
                            sql_list.add("insert into artist values (%d, '%s');\n".printf(artist_id, artist_name));
                        }
                        string link_sql = "insert into song_artist values (%d, %d);\n".printf(song.song_id, artist_id);
                        if (sql_list.index_of(link_sql) < 0) {
                            sql_list.add(link_sql);
                        }
                    }
                }
                sql_list.add("\n");
            }
        }
        foreach (string sql in sql_list) {
            print(sql);
        }
        ctx.finalization();
        print("-- complete!\n");
        return 0;
    } catch (Error e) {
        ctx.finalization();
        printerr("ERROR (%d): %s\n", e.code, e.message);
        return 127;
    }
}
