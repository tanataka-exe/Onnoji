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

    public Value of_datetime(DateTime? datetime_param) {
        if (datetime_param != null) {
            Value result = Value(typeof(DateTime));
            result.set_boxed(datetime_param);
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
