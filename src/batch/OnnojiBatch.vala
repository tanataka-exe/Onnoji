using Moegi;

class OnnojiBatch : Application {
    private string database_path;
    private Sqlite.Database db;

    private bool is_copy_song_files;
    private bool is_copy_artwork_files;
    private Gee.List<string> file_paths;
    
    public OnnojiBatch() {
        Object(
            application_id: "com.github.aharotias.music-server-batch",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
        );
    }
    
    public override void activate() {
        hold();
        release();
    }
    
    private void read_options(string[] args) {
        is_copy_song_files = true;
        is_copy_artwork_files = true;
        file_paths = new Gee.ArrayList<string>();
        for (int i = 1; i < args.length; i++) {
            if (args[i] == "-F") {
                is_copy_song_files = false;
            } else if (args[i] == "-A") {
                is_copy_artwork_files = false;
            } else {
                file_paths.add(args[i]);
            }
        }
    }
    
    public override int command_line(ApplicationCommandLine command_line) {
        hold();
        string[] args = command_line.get_arguments();
        if (args.length < 2) {
            return 1;
        }
        read_options(args);
        BatchTask task = new BatchTask() {
            song_dir_path = "/srv/music/data/songs",
            artwork_dir_path = "/srv/music/data/artworks",
            database_path = "/srv/music/data/music.db",
            is_copy_song_files = is_copy_song_files,
            is_copy_artwork_files = is_copy_artwork_files,
            is_recursive = true
        };
        int result = 0;
        try {
            result = task.execute(file_paths);
        } catch (OnnojiError e) {
            stderr.printf("%s\n", e.message);
            result = 127;
        }
        release();
        return result;
    }

    public static int main(string[] args) {
        set_print_handler((text) => stdout.puts(text));
        Gst.init(ref args);
        OnnojiBatch batch_app = new OnnojiBatch();
        int status = batch_app.run(args);
        return status;
    }
}
