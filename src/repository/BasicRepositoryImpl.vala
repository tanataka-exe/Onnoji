public class BasicRepositoryImpl : Object {
    
    protected Gda.Connection conn;
    protected XmlResourceManager res;
    
    protected int execute_non_select_with_params(Gda.Statement stmt, ...) throws Error {
        var l = va_list();
        Gda.Set params;
        stmt.get_parameters(out params);
        do {
            string? param_name = l.arg();
            if (param_name == null) {
                break;
            }
            Value? param_value = l.arg();
            if (param_value == null) {
                throw new OnnojiError.LOGICAL_ERROR("param value is required in BasicRepositoryImpl.execute_non_select_with_params");
            }
            params.get_holder(param_name).set_value(param_value);
        } while (true);
        return conn.statement_execute_non_select(stmt, params, null);
    }

    protected Gda.DataModel execute_select_with_params(Gda.Statement stmt, ...) throws Error {
        var l = va_list();
        Gda.Set params;
        stmt.get_parameters(out params);
        do {
            string? param_name = l.arg();
            if (param_name == null) {
                break;
            }
            Value? param_value = l.arg();
            if (param_value == null) {
                throw new OnnojiError.LOGICAL_ERROR("param value is required in BasicRepositoryImpl.execute_non_select_with_params");
            }
            params.get_holder(param_name).set_value(param_value);
        } while (true);
        return conn.statement_execute_select(stmt, params);
    }
}