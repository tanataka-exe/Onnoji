namespace OnnojiUtils {
    public string make_song_url(Soup.URI req_uri, string song_id) {
        string scheme = req_uri.get_scheme();
        string host = req_uri.get_host();
        uint port = req_uri.get_port();
        string id = song_id.substring(0, ID_LENGTH);
        return @"$(scheme)://$(host):$(port)/music/v1/song?id=$(id)";
    }
    
    public string make_artwork_url(Soup.URI req_uri, string artwork_file_path) {
        string scheme = req_uri.get_scheme();
        string host = req_uri.get_host();
        uint port = req_uri.get_port();
        File artwork_file = File.new_for_path(artwork_file_path);
        string id = artwork_file.get_basename().substring(0, ID_LENGTH);
        return @"$(scheme)://$(host):$(port)/music/v1/artwork?id=$(id)";
    }
    
    public string make_genre_icon_url(Soup.URI req_uri, int genre_id) {
        string scheme = req_uri.get_scheme();
        string host = req_uri.get_host();
        uint port = req_uri.get_port();
        return @"$(scheme)://$(host):$(port)/music/v1/icon?genre=$(genre_id)";
    }
}
