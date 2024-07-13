namespace ArtistTest {
    const int ARTIST_ID_0 = 400;
    const int ARTIST_ID_1 = 10;
    const int ARTIST_ID_2 = 500;
    
    int test_select(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        for (int i = 1; i <= 100; i++) {
            try {
                var artist = repo.select_by_id(i);
                if (artist.size == 1) {
                    print("%d: %s\n", artist[0].artist_id, artist[0].artist_name);
                }
            } catch (Error e) {
                printerr("%d: %s\n", e.code, e.message);
            }
        }
        return 0;
    }

    int test_select_gt(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        var artists = repo.select_by_id(ARTIST_ID_0, GREATER_THAN);
        foreach (Artist artist in artists) {
            print("%d: %s\n", artist.artist_id, artist.artist_name);
        }
        return 0;
    }

    int test_select_lt(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        var artists = repo.select_by_id(ARTIST_ID_1, LESS_THAN);
        foreach (Artist artist in artists) {
            print("%d: %s\n", artist.artist_id, artist.artist_name);
        }
        return 0;
    }

    int test_select_ge(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        var artists = repo.select_by_id(ARTIST_ID_0, GREATER_THAN | EQUALS);
        foreach (Artist artist in artists) {
            print("%d: %s\n", artist.artist_id, artist.artist_name);
        }
        return 0;
    }

    int test_select_le(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        var artists = repo.select_by_id(ARTIST_ID_1, LESS_THAN | EQUALS);
        foreach (Artist artist in artists) {
            print("%d: %s\n", artist.artist_id, artist.artist_name);
        }
        return 0;
    }

    int test_insert(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        var artist = new Artist() {
            artist_id = ARTIST_ID_2,
            artist_name = "名無しの権兵衛"
        };
        bool response = repo.insert(artist);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_delete(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        bool response = repo.delete_by_id(ARTIST_ID_2);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_update(RepositoryTestContext context) throws Error {
        var repo = context.get_artist_repository();
        bool response = repo.update_by_id(ARTIST_ID_2, "川野流");
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }
}
