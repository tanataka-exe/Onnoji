namespace Mocks {
    Song create_song_mock(int song_id) {
        return new Song() {
            song_id = song_id,
            title = "Hoge Song",
            pub_date = 2024,
            copyright = "Test inc.",
            comment = "This is test mock",
            time_length_milliseconds = 1 * 60 * 60 * 1000, // 1 hour
            mime_type = "text/plain",
            file_path = "/path/to/the/file",
            artwork_id = 10000,
            creation_datetime = new DateTime.now_local()
        };
    }
    
    Genre create_genre_mock(int genre_id) {
        return new Genre() {
            genre_id = genre_id,
            genre_name = "Test Genre"
        };
    }
    
    Artist create_artist_mock(int artist_id) {
        return new Artist() {
            artist_id = artist_id,
            artist_name = "Test Artist",
        };
    }
    
    Playlist create_playlist_mock(int playlist_id) {
        return new Playlist() {
            playlist_id = playlist_id,
            playlist_name = "Test Playlist",
            is_album = true,
            creation_datetime = new DateTime.now_local(),
        };
    }
}

