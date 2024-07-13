namespace HistoryTest {
    const int HISTORY_ID_0 = 600000;
    const int SONG_ID_0 = 100000;
    
    int test_select(RepositoryTestContext context) throws Error {
        var repo = context.get_history_repository();
        for (int i = 1; i <= 50; i++) {
            try {
                var history = repo.select_by_id(i);
                if (history.size == 1) {
                    print("%d: %d, %s\n",
                        history[0].history_id, history[0].song_id,
                        format_gda_timestamp(history[0].request_datetime, "%Y-%m-%d %H:%M:%S")
                    );
                } else {
                    print("The history of id %d is not found\n", i);
                }
            } catch (Error e) {
                printerr("ERROR (%d): %s\n", e.code, e.message);
            }
        }
        return 0;
    }

    int test_select_2(RepositoryTestContext context) throws Error {
        var repo = context.get_history_repository();
        var repo2 = context.get_song_repository();
        for (int i = 1; i <= 50; i++) {
            try {
                var history = repo.select_by_id(i);
                if (history.size == 1) {
                    var song = repo2.select_by_id(history[0].song_id);
                    print("%d: %s (%d), %s\n",
                        history[0].history_id, song[0].title, history[0].song_id,
                        format_gda_timestamp(history[0].request_datetime, "%Y-%m-%d %H:%M:%S")
                    );
                } else {
                    print("The history of id %d is not found\n", i);
                }
            } catch (Error e) {
                printerr("ERROR (%d): %s\n", e.code, e.message);
            }
        }
        return 0;
    }

    int test_insert(RepositoryTestContext context) throws Error {
        var repo = context.get_history_repository();
        var history = new History() {
            history_id = HISTORY_ID_0,
            song_id = SONG_ID_0,
            request_datetime = create_gda_timestamp_now_local()
        };
        bool response = repo.insert(history);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_delete(RepositoryTestContext context) throws Error {
        var repo = context.get_history_repository();
        bool response = repo.delete_by_id(HISTORY_ID_0);
        print("delete status: %s\n", response ? "Success" : "Failure");
        return 0;
    }

    int test_update(RepositoryTestContext context) throws Error {
        var repo = context.get_history_repository();
        var ts = create_gda_timestamp_now_local();
        print("timezone: %ld\n", ts.timezone);
        var params = create_map("request_datetime", Values.of_gda_timestamp(ts));
        bool response = repo.update_by_id(HISTORY_ID_0, params);
        print("update status: %s\n", response ? "Success" : "Failure");
        return 0;
    }
}
