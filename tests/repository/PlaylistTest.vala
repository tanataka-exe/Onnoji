namespace PlaylistTest {
    const int PLAYLIST_ID_0 = 100000;
    const int PLAYLIST_ID_1 = 100001;

    int test_next_id(RepositoryTestContext context) throws Error {
        var repo = context.get_playlist_repository();
        int id = repo.get_next_playlist_id();
        print("next id is %d\n", id);
        return 0;
    }
    
    int test_select(RepositoryTestContext context) throws Error {
        var repo = context.get_playlist_repository();
        var playlist = repo.select_by_id(PLAYLIST_ID_0);
        print("%d: %s%s, %s\n",
            playlist[0].playlist_id,
            playlist[0].playlist_name,
            playlist[0].is_album ? " (album)" : "",
            playlist[0].creation_datetime.format("%Y-%m-%d %H:%M:%S")
        );
        return 0;
    }

    int test_insert(RepositoryTestContext context) throws Error {
        var repo = context.get_playlist_repository();
        var playlist = Mocks.create_playlist_mock(PLAYLIST_ID_0);
        bool response = repo.insert(playlist);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_delete(RepositoryTestContext context) throws Error {
        var repo = context.get_playlist_repository();
        bool response = repo.delete_by_id(PLAYLIST_ID_0);
        print("delete status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_update(RepositoryTestContext context) throws Error {
        var repo = context.get_playlist_repository();
        bool response = repo.update_by_id(
            PLAYLIST_ID_0,
            slist<string>("playlist_name"),
            slist<Value?>("Playlist New Name")
        );
        print("update status: %s\n", response ? "Success" : "Failure");
        return 0;
    }
}
