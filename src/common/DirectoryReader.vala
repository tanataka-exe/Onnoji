/*
 * This file is part of moegi-player.
 *
 *     moegi-player is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     moegi-player is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with moegi-player.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2020 Takayuki Tanaka
 */

namespace Moegi {
    public delegate bool DirectoryFoundFunc(GLib.File directory);
    public delegate bool FileFoundFunc(GLib.File file);

    public class DirectoryReader : Object {
        private string path;
        public signal bool directory_found(GLib.File directory);
        public signal bool file_found(GLib.File file);

        public DirectoryReader(string path) throws Moegi.Error {
            GLib.File file = GLib.File.new_for_path(path);
            if (!file.query_exists()) {
                throw new Moegi.Error.FILE_DOES_NOT_EXISTS("File does not exists (%s)\n".printf(path));
            }
            GLib.FileType file_type = file.query_file_type(0);
            if (file_type != GLib.FileType.DIRECTORY) {
                throw new Moegi.Error.FILE_IS_NOT_A_DIRECTORY("File is not a directory (%s)\n".printf(path));
            }
            this.path = path;
        }

        public void run() throws GLib.FileError {
            string? name;
            GLib.Dir dir = Dir.open(this.path);
            while ((name = dir.read_name()) != null) {
                if (name == "." || name == "..") {
                    continue;
                }
                string child_path = Path.build_path(Path.DIR_SEPARATOR_S, this.path, name);
                GLib.File child_file = GLib.File.new_for_path(child_path);
                GLib.FileType child_file_type = child_file.query_file_type(0);
                bool response = true;
                if (child_file_type == GLib.FileType.DIRECTORY) {
                    response = directory_found(child_file);
                } else if (child_file_type == GLib.FileType.REGULAR) {
                    response = file_found(child_file);
                }
                if (response == false) {
                    break;
                }
            }
        }
    }
}
