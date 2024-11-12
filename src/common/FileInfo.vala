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
 * Copyright 2018 Takayuki Tanaka
 */

namespace Moegi {
    public class FileInfo : Object {
        public string dir;
        public string name;
        public string path;
        public string title;
        public string? artist;
        public string? album;
        public string? genre;
        public string? comment;
        public string? copyright;
        public uint disc_number;
        public uint disc_count;
        public uint track;
        public uint track_count;
        public uint date;
        public SmallTime time_length;
        public Moegi.FileType type;
        public Gdk.Pixbuf? artwork;
        public string mime_type;

        public FileInfo copy() {
            Moegi.FileInfo cp = new Moegi.FileInfo();
            cp.dir = this.dir;
            cp.name = this.name;
            cp.path = this.path;
            cp.title = this.title;
            cp.artist = this.artist;
            cp.album = this.album;
            cp.genre = this.genre;
            cp.comment = this.comment;
            cp.copyright = this.copyright;
            cp.disc_number = this.disc_number;
            cp.disc_count = this.disc_count;
            cp.track = this.track;
            cp.track_count = this.track_count;
            cp.date = this.date;
            cp.time_length = this.time_length;
            cp.type = this.type;
            cp.artwork = this.artwork;
            cp.mime_type = this.mime_type;
            return cp;
        }

        public string to_string() {
            StringBuilder sb = new StringBuilder("{");
            string empty = "null";
            sb.append("\"dir\" : ");
            if (dir != null) {
                sb.append("\"").append(dir).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"name\" : ");
            if (name != null) {
                sb.append("\"").append(name).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"path\" : ");
            if (path != null) {
                sb.append("\"").append(path).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"title\" : ");
            if (title != null) {
                sb.append("\"").append(title).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"artist\" : ");
            if (artist != null) {
                sb.append("\"").append(artist).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"album\" : ");
            if (album != null) {
                sb.append("\"").append(album).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"genre\" : ");
            if (genre != null) {
                sb.append("\"").append(genre).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"comment\" : ");
            if (comment != null) {
                sb.append("\"").append(comment).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"copyright\" : ");
            if (copyright != null) {
                sb.append("\"").append(copyright).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"disc_number\" : ").append(disc_number.to_string());
            sb.append(", \"disc_count\" : ").append(disc_count.to_string());
            sb.append(", \"track\" : ").append(track.to_string());
            sb.append(", \"track_count\" : ").append(track.to_string());
            sb.append(", \"date\" : ").append(date.to_string());
            sb.append(", \"time_length\" : ");
            if (time_length != null) {
                sb.append("\"").append(time_length.to_string()).append("\"");
            } else {
                sb.append(empty);
            }
            sb.append(", \"mime_type\" : \"").append(mime_type).append("\"");
            sb.append(", \"type\" : \"").append(type.get_name()).append("\" }");
            return sb.str;
        }
    }
}
