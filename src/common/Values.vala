namespace Values {
    public Value of_int(int int_param) {
        Value result = Value(typeof(int));
        result.set_int(int_param);
        return result;
    }

    public Value of_uint(uint int_param) {
        Value result = Value(typeof(uint));
        result.set_uint(int_param);
        return result;
    }

    public Value of_string(string? string_param) {
        Value result = Value(typeof(string));
        result.set_string(string_param);
        return result;
    }
    
    public Value of_gda_timestamp(Gda.Timestamp? timestamp_param) {
        if (timestamp_param != null) {
            Value result = Value(typeof(Gda.Timestamp));
            result.set_boxed(timestamp_param);
            return result;
        } else {
            return Value(Type.NONE);
        }
    }
    
    public string? extract_string_or_null(Value val) {
        if (val.holds(typeof(string))) {
            return val.get_string();
        } else {
            return null;
        }
    }
}
