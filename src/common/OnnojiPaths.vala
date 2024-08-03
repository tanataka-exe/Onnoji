namespace OnnojiPaths {
    const string api_path = "/api/v2";
    const string server_data_path = "/srv/music/data";
    
    public string song_stream_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/stream";
    }
    
    public string song_artwork_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/artwork";
    }

    public string song_genres_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/genres";
    }
    
    public string song_artists_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/artists";
    }
    
    public string song_albums_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/albums";
    }
    
    public string song_playlists_url(int song_id) {
        return @"$(api_path)/song/$(song_id)/playlists";
    }

    public string artwork_url(int artwork_id) {
        return @"$(api_path)/artwork/$(artwork_id)";
    }
    
    public string genre_albums_url(int genre_id) {
        return @"$(api_path)/genre/$(genre_id)/albums";
    }
    
    public string genre_playlists_url(int genre_id) {
        return @"$(api_path)/genre/$(genre_id)/playlist";
    }

    public string genre_artists_url(int genre_id) {
        return @"$(api_path)/genre/$(genre_id)/artists";
    }
        
    public string genre_icon_url(int genre_id) {
        return @"$(api_path)/genre/$(genre_id)/icon";
    }
    
    public string artist_songs_url(int artist_id) {
        return @"$(api_path)/artist/$(artist_id)/songs";
    }
    
    public string artist_albums_url(int artist_id) {
        return @"$(api_path)/artist/$(artist_id)/albums";
    }

    public string artist_genres_url(int artist_id) {
        return @"$(api_path)/artist/$(artist_id)/genres";
    }
    
    public string playlist_songs_url(int playlist_id) {
        return @"$(api_path)/playlist/$(playlist_id)/songs";
    }

    public string playlist_artists_url(int playlist_id) {
        return @"$(api_path)/playlist/$(playlist_id)/artists";
    }

    public string playlist_genres_url(int playlist_id) {
        return @"$(api_path)/playlist/$(playlist_id)/genres";
    }

    public string playlist_artworks_url(int playlist_id) {
        return @"$(api_path)/playlist/$(playlist_id)/artworks";
    }

    public string playlist_artwork_url(int playlist_id) {
        return @"$(api_path)/playlist/$(playlist_id)/artwork";
    }

    public string genre_icon_file_path(int genre_id) {
        return @"$(server_data_path)/icons/genre/$(genre_id).jpg";
    }
    
    /**
     * match 2 paths and return true if two are same, else false.
     * when path pattern has square bracketed parts (like "/[ABC]/") it pass through.
     */
    private bool match_path(string path, string pattern) {
        int i = 0;
        int j = 0;
        while (true) {
            if (i == path.length && j == pattern.length) {
                return true;
            } else if (i == path.length || j == pattern.length) {
                return false;
            } else if (pattern[j] == '[') {
                while (j < pattern.length) {
                    if (pattern[j] == ']') {
                        j++;
                        break;
                    }
                    j++;
                }
                while (i < path.length) {
                    if (path[i] == '/') {
                        break;
                    }
                    i++;
                }
            } else if (pattern[j] != path[i]) {
                return false;
            } else {
                i++;
                j++;
            }
        }
    }
}
