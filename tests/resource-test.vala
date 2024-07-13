int main() {
    try {
        return test7();
    } catch (Error e) {
        printerr("%d: %s\n", e.code, e.message);
        return -127;
    }
}

int test3() throws Error {
    var context = ResourceTestContext.get_instance();
    ResourceManager res = context.get_xml_resource_manager();
    print("delete: %s\n", res.get_string("artist-delete-row"));
    return 0;
}

int test2() throws Error {
    ResourceManager res = new ResourceManager.for_uri("resource:///local/asusturn/onnoji/main/application.properties");
    print("%s\n", res.get_string("db.provider"));
    print("%s\n", res.get_string("db.cns"));
    print("%s\n", res.get_string("db.auth"));
    return 0;
}

int test1() throws Error {
    ResourceManager res = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
    string sql = res.get_string("artist-delete-sql");
    print("%s\n", sql);
    return 0;
}

int test4() throws Error {
    XmlResourceManager res = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
    string sql = res.get_string_with_params("song-select-by-id", "song-id-equals", "song-id-starts-with");
    print("%s\n", sql);
    return 0;
}

int test5() throws Error {
    XmlResourceManager res = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
    string sql = res.get_string_with_params("song-select-by-id");
    print("%s\n", sql);
    return 0;
}

int test6() throws Error {
    XmlResourceManager res = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
    string sql = res.get_string("genre-delete-by-id");
    print("%s\n", sql);
    return 0;
}

int test7() throws Error {
    XmlResourceManager res = new XmlResourceManager.for_uri("resource:///local/asusturn/onnoji/sql/repository.xml");
    string sql = res.get_string_with_params("genre-select-by-id", "genre-id-equals");
    print("%s\n", sql);
    return 0;
}
