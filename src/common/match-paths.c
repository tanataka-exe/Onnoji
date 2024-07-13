#include <glib.h>

gboolean onnoji_paths_match_path(const gchar* path, const gchar* pattern) {
    gint i = 0;
    gint j = 0;
    gboolean result;
	g_return_val_if_fail (path != NULL, FALSE);
	g_return_val_if_fail (pattern != NULL, FALSE);
    gint path_length = strlen(path);
    gint pattern_length = strlen(pattern);
    while (TRUE) {
        if (i == path_length && j == pattern_length) {
            return TRUE;
        } else if (i == path_length || j == pattern_length) {
            return FALSE;
        } else if (pattern[j] == '[') {
            while (j < pattern_length) {
                if (pattern[j] == ']') {
                    j++;
                    break;
                }
            }
            while (i < path_length) {
                if (path[i] == '/') {
                    break;
                }
                i++;
            }
        } else if (pattern[j] != path[i]) {
            return FALSE;
        } else {
            i++;
            j++;
        }
    }
}
    
