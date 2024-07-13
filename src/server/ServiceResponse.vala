public class ServiceResponse : Object {
    public string? mime_type { get; set; }
    public uint8[]? data { get; set; }
    public uint length { get; set; }

    public ServiceResponse(uint8[]? data, string? mime_type) {
        this.data = data;
        this.mime_type = mime_type;
        this.length = data.length;
    }
    
    public ServiceResponse.for_json(Json.Node json) {
        this.data = Json.to_string(json, false).data;
        this.mime_type = "application_json";
        this.length = this.data.length;
    }
}
