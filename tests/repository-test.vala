int main(string[] args) {
    set_print_handler(text => stdout.puts(text));
    if (args.length != 3 && args.length != 4) {
        printerr("arguments must have 3 or 4 (actually has %d)\n", args.length);
        return -1;
    }
    string target = args[1];
    string command = args[2];
    bool is_transactional = args.length == 4 && args[3] == "transactional";
    
    Gda.Connection? conn = null;
    
    try {
        var context = RepositoryTestContext.get_instance();
        
        conn = context.get_gda_connection();

        if (is_transactional) {
            return test_transactional(context, target, command);
        } else {
            return test(context, target, command);
        }
    } catch (Error e) {
        printerr("ERROR %d: %s\n", e.code, e.message);
        return -1;
        
    } finally {
        if (conn != null) {
            conn.close();
        }
    }
}

int test_transactional(RepositoryTestContext context, string target, string command) throws Error {
    Gda.Connection conn = context.get_gda_connection();
    try {

        conn.begin_transaction(null, 0);
        debug("begin transaction");

        int res = test(context, target, command);

        conn.rollback_transaction(null);
        debug("rollback transaction");

        return res;

    } catch (Error e) {

        conn.rollback_transaction(null);
        debug("rollback transaction");

        throw e;
    }
}

int test(RepositoryTestContext context, string target, string command) throws Error {
    switch (target) {
      case "song":
        switch (command) {
          case "select-equals":
            return SongTest.test_select(context);
          case "select-equals-playlist":
            return SongTest.test_select_by_playlist_id(context);
          case "select-equals-artist":
            return SongTest.test_select_by_artist_id(context);
          case "select-equals-genre":
            return SongTest.test_select_by_genre_id(context);
          case "insert":
            return SongTest.test_insert(context);
          case "update":
            return SongTest.test_update(context);
          case "delete":
            return SongTest.test_delete(context);
          default:
            printerr("this test name are not implemented\n");
            return -127;
        }
      case "playlist":
        switch (command) {
          case "next-id":
            return PlaylistTest.test_next_id(context);
          case "select-equals":
            return PlaylistTest.test_select(context);
          case "insert":
            return PlaylistTest.test_insert(context);
          case "update":
            return PlaylistTest.test_update(context);
          case "delete":
            return PlaylistTest.test_delete(context);
          default:
            printerr("this test name are not implemented\n");
            return -127;
        }
      case "artist":
        switch (command) {
          case "select-equals":
            return ArtistTest.test_select(context);
          case "select-gt":
            return ArtistTest.test_select_gt(context);
          case "select-lt":
            return ArtistTest.test_select_lt(context);
          case "select-ge":
            return ArtistTest.test_select_ge(context);
          case "select-le":
            return ArtistTest.test_select_le(context);
          case "delete":
            return ArtistTest.test_delete(context);
          case "update":
            return ArtistTest.test_update(context);
          case "insert":
            return ArtistTest.test_insert(context);
          default:
            printerr("this test name are not implemented\n");
            return -127;
        }
      case "genre":
        switch (command) {
          case "select-equals":
            return GenreTest.test_select(context);
          case "delete":
            return GenreTest.test_delete(context);
          case "update":
            return GenreTest.test_update(context);
          case "insert":
            return GenreTest.test_insert(context);
          case "select-by-song-id":
            return GenreTest.test_select_by_song_id(context);
          default:
            printerr("this test name are not implemented\n");
            return -127;
        }
      case "history":
        switch (command) {
          case "select-equals":
            return HistoryTest.test_select_2(context);
          case "delete":
            return HistoryTest.test_delete(context);
          case "update":
            return HistoryTest.test_update(context);
          case "insert":
            return HistoryTest.test_insert(context);
          default:
            printerr("this test name are not implemented\n");
            return -127;
        }
      default:
        printerr("this test name are not implemented\n");
        return -127;
    }
}
