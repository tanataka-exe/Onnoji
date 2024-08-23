int main(string[] args) {
    MainLoop loop = new MainLoop();
    main_async.begin(args, (x, y) => {
        loop.quit();
    });
    loop.run();
    return 0;
}

async int main_async(string[] args) {
    try {
        Gst.init(ref args);
        set_print_handler(text => stdout.puts(text));
        var context = ProducerTestContext.get_instance();
        MusicDataProducer producer = context.get_music_data_producer();
        ServiceResponse? response = null;
        switch (args[1]) {
          case "test-query-genres":
            response = producer.query_genres();
            break;
          case "test-query-song-metadata":
            if (args.length >= 3) {
                response = producer.query_song_metadata(int.parse(args[2]));
            }
            break;
          case "test-query-playlist-songs":
            if (args.length >= 3) {
                response = producer.query_playlist_songs(int.parse(args[2]));
            }
            break;
          case "test-query-genre-albums":
            if (args.length >= 3) {
                response = producer.query_genre_albums(int.parse(args[2]));
            }
            break;
          case "test-query-genre-artists":
            if (args.length >= 3) {
                response = producer.query_genre_artists(int.parse(args[2]));
            }
            break;
          case "test-query-artist-albums":
            if (args.length >= 3) {
                response = producer.query_artist_albums(int.parse(args[2]));
            }
            break;
          case "test-query-recently-requested-songs":
            if (args.length >= 4) {
                response = producer.query_recently_requested_songs(int.parse(args[2]), int.parse(args[3]));
            }
            break;
          case "test-query-recently-registered-songs":
            if (args.length >= 4) {
                response = producer.query_recently_registered_songs(int.parse(args[2]), int.parse(args[3]));
            }
            break;
          case "test-query-recently-registered-albums":
            if (args.length >= 4) {
                response = producer.query_recently_registered_playlists(int.parse(args[2]), int.parse(args[3]), true);
            }
            break;
          case "test-upload-files":
            response = yield test_upload_files(producer);
            break;
        }
        if (response != null) {
            print("%s\0", data_array_to_string(response.data));
        } else {
            print("response is null\n");
        }
        return 0;
    } catch (OnnojiError e) {
        print("ERROR: %s\n", e.message);
        return -1;
    }
}

string data_array_to_string(uint8[] data) {
    uint8[] str = new uint8[data.length + 1];
    for (int i = 0; i < str.length; i++) {
        str[i] = data[i];
    }
    str[str.length - 1] = '\0';
    return (string) str;
}

async ServiceResponse test_upload_files(MusicDataProducer producer) {
    Gee.List<PostFileData> file_list = new Gee.ArrayList<PostFileData>();
    string[] file_names = {
        "sng000000001865",
        "sng000000004435",
        "sng000000003086",
        "sng000000001855",
        "sng000000000153",
        "sng000000005204",
        "sng000000000923",
        "sng000000002926",
        "sng000000000147",
        "sng000000001188",
        "sng000000001165",
        "sng000000005109",
        "sng000000000113",
        "sng000000000162",
        "sng000000001203"
    };
    foreach (string file_name in file_names) {
        string file_path = "/home/ta/repo/asusturn/onnoji/tests/data/lightweight/" + file_name;
        File f = File.new_for_path(file_path);
        GLib.FileInfo fi = f.query_info("standard::content-type", 0);
        string mime_type = fi.get_content_type();
        PostFileData data = new PostFileData() {
            file_name = file_name,
            file_path = file_path,
            mime_type = mime_type
        };
        file_list.add(data);
    }
    string album_title = "Test Album";
    return producer.register_playlist_with_songs(album_title, file_list);
}
