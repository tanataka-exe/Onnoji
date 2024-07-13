#include <glib.h>
#include <libgda.h>

extern long timezone;


GdaTimestamp *create_gda_timestamp() {
    GdaTimestamp *instance = g_malloc(sizeof(GdaTimestamp));
    tzset();
    return instance;
}

GdaTimestamp *create_gda_timestamp_now_local() {
    GdaTimestamp *instance = create_gda_timestamp();
    GDateTime *dt = g_date_time_new_now_local();
    instance->year = g_date_time_get_year(dt);
    instance->month = g_date_time_get_month(dt);
    instance->day = g_date_time_get_day_of_month(dt);
    instance->hour = g_date_time_get_hour(dt);
    instance->minute = g_date_time_get_minute(dt);
    instance->second = g_date_time_get_second(dt);
    instance->fraction = 0;
    instance->timezone = timezone;
    g_date_time_unref(dt);
    return instance;
}

GdaTimestamp *create_gda_timestamp_with_date(int year, int month, int day) {
    GdaTimestamp *instance = create_gda_timestamp();
    instance->year = year;
    instance->month = month;
    instance->day = day;
    instance->hour = 0;
    instance->minute = 0;
    instance->second = 0;
    instance->fraction = 0;
    instance->timezone = timezone;
    return instance;
}

GdaTimestamp *create_gda_timestamp_with_datetime(int year, int month, int day,
        int hour, int minute, int second) {
    GdaTimestamp *instance = create_gda_timestamp();
    instance->year = year;
    instance->month = month;
    instance->day = day;
    instance->hour = hour;
    instance->minute = minute;
    instance->second = second;
    instance->fraction = 0;
    instance->timezone = timezone;
    return instance;
}

