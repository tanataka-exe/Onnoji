namespace GenreTest {
    const int SONG_ID_0 = 100000;
    const int PLAYLIST_ID_0 = 200000;
    const int GENRE_ID_0 = 300000;
    
    int test_select(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        for (int i = 1; i <= 50; i++) {
            try {
                var genre = repo.select_by_id(i);
                if (genre.size == 1) {
                    print("%d: %s\n", genre[0].genre_id, genre[0].genre_name);
                } else {
                    print("The genre of id %d is not found\n", i);
                }
            } catch (Error e) {
                printerr("ERROR (%d): %s\n", e.code, e.message);
            }
        }
        return 0;
    }

    int test_select_by_song_id(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        var genres = repo.select_by_song_id(SONG_ID_0);
        foreach (var genre in genres) {
            print("%d: %s\n", genre.genre_id, genre.genre_name);
        }
        return 0;
    }

    int test_select_by_playlist_id(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        var genres = repo.select_by_playlist_id(PLAYLIST_ID_0);
        foreach (var genre in genres) {
            print("%d: %s\n", genre.genre_id, genre.genre_name);
        }
        return 0;
    }

    int test_insert(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        var genre = new Genre() {
            genre_id = GENRE_ID_0,
            genre_name = "テストジャンル"
        };
        bool response = repo.insert(genre);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_delete(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        bool response = repo.delete_by_id(GENRE_ID_0);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_update(RepositoryTestContext context) throws Error {
        var repo = context.get_genre_repository();
        bool response = repo.update_by_id(GENRE_ID_0,
            slist<string>("改変ジャンル"),
            slist<Value?>(Values.of_string("/new/path/to/genre/icon"))
        );
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }
}
