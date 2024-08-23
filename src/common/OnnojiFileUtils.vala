namespace OnnojiFileUtils {
    public async void get_data_async(string file_path, out uint8[] data) throws Error {
        File file = File.new_for_path(file_path);
        FileInfo info = file.query_info("standard::size", 0);
        uint64 size = info.get_attribute_uint64("standard::size");
        data = new uint8[size];
        string etag;
        yield file.load_contents_async(null, out data, out etag);
    }
    
    public async void set_data_async(string file_path, uint8[] data) throws Error {
        File file = File.new_for_path(file_path);
        string new_etag;
        yield file.replace_contents_async(data, null, false, FileCreateFlags.NONE, null, out new_etag);
    }
}
