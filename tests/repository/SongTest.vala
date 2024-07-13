namespace SongTest {
    const int SONG_ID_0 = 100000;
    const int SONG_ID_1 = 100001;
    const int SONG_ID_2 = 100002;
    const int SONG_ID_3 = 100003;
    const int PLAYLIST_ID_0 = 200000;
    const int PLAYLIST_ID_1 = 200001;
    const int ARTIST_ID_1 = 400000;
    const int GENRE_ID_1 = 400001;

    int test_select(RepositoryTestContext context) throws Error {
        var conn = context.get_gda_connection();
        var repo = context.get_song_repository();
        try {
            var songs = repo.select_by_id(SONG_ID_1, SqlConditionType.STARTS_WITH);
            foreach (var song in songs) {
                print("%d: %s\n", song.song_id, song.title);
            }
        } catch (Error e) {
            printerr("%d: %s\n", e.code, e.message);
        }
        return 0;
    }

    int test_select_by_playlist_id(RepositoryTestContext context) throws Error {
        var conn = context.get_gda_connection();
        var song_repo = context.get_song_repository();
        var playlist_repo = context.get_playlist_repository();
        
        Song song_mock = Mocks.create_song_mock(SONG_ID_2);
        song_repo.insert(song_mock);
        debug("insert song");

        Playlist playlist_mock = Mocks.create_playlist_mock(PLAYLIST_ID_1);
        playlist_repo.insert(playlist_mock);
        debug("insert playlist");

        song_repo.insert_link_to_playlist(song_mock, playlist_mock, 1, 1);
        debug("insert link song and playlist");

        var songs = song_repo.select_by_playlist_id(PLAYLIST_ID_1);
        debug("select song by playlist");

        foreach (var song in songs) {
            print("%d: %s\n", song.song_id, song.title);
        }
        return 0;
    }

    int test_select_by_artist_id(RepositoryTestContext context) throws Error {
        var conn = context.get_gda_connection();
        var song_repo = context.get_song_repository();
        var artist_repo = context.get_artist_repository();
        Song song_mock = Mocks.create_song_mock(SONG_ID_3);
        song_repo.insert(song_mock);
        debug("insert song");
        Artist artist_mock = Mocks.create_artist_mock(ARTIST_ID_1);
        artist_repo.insert(artist_mock);
        debug("insert artist");
        song_repo.insert_link_to_artist(song_mock, artist_mock);
        debug("insert link song and artist");
        var songs = song_repo.select_by_artist_id(ARTIST_ID_1);
        debug("select song by artist");
        foreach (var song in songs) {
            print("%d: %s\n", song.song_id, song.title);
        }
        return 0;
    }

    int test_select_by_genre_id(RepositoryTestContext context) throws Error {
        var conn = context.get_gda_connection();
        var song_repo = context.get_song_repository();
        var genre_repo = context.get_genre_repository();
        Song song_mock = Mocks.create_song_mock(SONG_ID_1);
        song_repo.insert(song_mock);
        debug("insert song");
        Genre genre_mock = Mocks.create_genre_mock(GENRE_ID_1);
        genre_repo.insert(genre_mock);
        debug("insert genre");
        song_repo.insert_link_to_genre(song_mock, genre_mock);
        debug("insert link song and genre");
        var songs = song_repo.select_by_genre_id(GENRE_ID_1);
        debug("select song by genre");
        foreach (var song in songs) {
            print("%d: %s\n", song.song_id, song.title);
        }
        return 0;
    }

    int test_insert(RepositoryTestContext context) throws Error {
        var repo = context.get_song_repository();
        var song = Mocks.create_song_mock(SONG_ID_0);
        bool response = repo.insert(song);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_delete(RepositoryTestContext context) throws Error {
        var repo = context.get_song_repository();
        bool response = repo.delete_by_id(SONG_ID_0);
        print("delete status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_update(RepositoryTestContext context) throws Error {
        var repo = context.get_song_repository();
        bool response = repo.update_by_id(SONG_ID_0,
            create_map(
                "title", Values.of_string("Changed title of it"),
                "time_length_milliseconds", Values.of_int(100000000)
            )
        );
        print("update status: %s\n", response ? "Success" : "Failure");
        return 0;
    }
}

