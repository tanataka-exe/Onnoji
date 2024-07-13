[Flags]
public enum RequiredRelation {
    SONG, ARTIST, PLAYLIST_ALBUM, PLAYLIST, GENRE, HISTORY, ARTWORK;
    
    public string? get_name() {
        switch (this) {
          case SONG:
            return "song";
          case ARTIST:
            return "artist";
          case PLAYLIST:
          case PLAYLIST_ALBUM:
            return "playlist";
          case GENRE:
            return "genre";
          case HISTORY:
            return "history";
          case ARTWORK:
            return "artwork";
          default:
            return null;
        }
    }
}

