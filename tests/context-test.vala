int main() {
    set_print_handler(text => stdout.puts(text));
    var context = TestApplicationContext.get_instance();
    try {
        //return test_select_artist(context);
        return test_delete_artist(context);
        //return test_update_artist(context);
        //return test_insert_artist(context);
    } finally {
        context.close();
    }
}

/*
int test_select_song(TestApplicationContext context) {
    try {
        var repo = context.get_song_repository();
        for (int i = 1; i <= 100; i++) {
            try {
                var artist = repo.find_one(null);
                print("%d: %s\n", artist.artist_id, artist.artist_name);
            } catch (Error e) {
                printerr("%d: %s\n", e.code, e.message);
            }
        }
        return 0;
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return -1;
    }
}
*/

int test_select_artist(TestApplicationContext context) {
    try {
        var repo = context.get_artist_repository();
        for (int i = 1; i <= 100; i++) {
            try {
                var artist = repo.find_one(i);
                print("%d: %s\n", artist.artist_id, artist.artist_name);
            } catch (Error e) {
                printerr("%d: %s\n", e.code, e.message);
            }
        }
        return 0;
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return -1;
    }
}

int test_insert_artist(TestApplicationContext context) {
    try {
        var repo = context.get_artist_repository();
        var artist = new Artist() {
            artist_id = 500,
            artist_name = "名無しの権兵衛"
        };
        bool response = repo.insert_one(artist);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return 1;
    }
}

int test_delete_artist(TestApplicationContext context) {
    try {
        var repo = context.get_artist_repository();
        bool response = repo.delete_one(500);
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return 1;
    }
}

int test_update_artist(TestApplicationContext context) {
    try {
        var repo = context.get_artist_repository();
        bool response = repo.update_one(500, "川野流");
        print("insert status: %s\n", response ? "Success" : "Failure");
        return 0;
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return 1;
    }
}
