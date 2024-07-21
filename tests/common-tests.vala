int main(string[] args) {
    if (args.length < 2) {
        printerr("requires at least one argument\n");
        return -1;
    }
    switch (args[1]) {
      case "onnoji-paths-match-path-1":
        if (OnnojiPaths.match_path("/api/v2/song/1/artists", "/api/v2/song/[song_id]/artists")) {
            return 0;
        } else {
            return 1;
        }
      case "onnoji-paths-match-path-2":
        if (OnnojiPaths.match_path("/api/v2/history/1", "/api/v2/history/[song_id]")) {
            return 0;
        } else {
            return 1;
        }
      case "onnoji-paths-match-path-3":
        if (!OnnojiPaths.match_path("/api/v2/song/1/genres", "/api/v2/song/[song_id]/artists")) {
            return 0;
        } else {
            return 1;
        }
      case "onnoji-paths-match-path-4":
        if (!OnnojiPaths.match_path("/api/v2/song/1", "/api/v2/song/[song_id]/albums")) {
            return 0;
        } else {
            return 1;
        }
      case "onnoji-paths-match-path-5":
        if (!OnnojiPaths.match_path("/api/v2/recently-registered/1-20/songs", "/api/v2/recently-registered/[min-max]/songs")) {
            return 1;
        } else {
            return 0;
        }
      case "onnoji-paths-match-path-6":
        if (!OnnojiPaths.match_path("/api/v2/playlist/1/artworks", "/api/v2/playlist/[playlist_id]/artwork")) {
            return 0;
        } else {
            return 1;
        }
      case "onnoji-paths-match-path-7":
        if (OnnojiPaths.match_path("/api/v2/playlist/1/artworks", "/api/v2/playlist/[playlist_id]/artworks")) {
            return 0;
        } else {
            return 1;
        }
      default:
        printerr("%s is not implemented test\n", args[1]);
        return 1;
    }
}
