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
    public class FileInfoAdapter : Object {
        public Moegi.MetadataReader meta_reader { get; construct set; }
        private Moegi.FileInfo file_info;
        
        public FileInfoAdapter(Moegi.MetadataReader meta_reader) {
            this.meta_reader = meta_reader;
            this.meta_reader.tag_found.connect((tag, value) => {
                file_info_set_value(ref file_info, tag, value);
                return true;
            });
        }
        
        public Moegi.FileInfo? read_metadata_from_path(string file_path) {
            GLib.File file = GLib.File.new_for_path(file_path);
            this.file_info = new Moegi.FileInfo();
            file_info.dir = file.get_parent().get_path();
            file_info.path = file.get_path();
            file_info.name = file.get_basename();
            file_info.type = Moegi.FileType.MUSIC;
            try {
                meta_reader.get_metadata(file.get_path());
                return file_info;
            } catch (Moegi.Error e) {
                stderr.printf(@"Moegi.Error: $(e.message)\n");
                return null;
            } catch (GLib.Error e) {
                stderr.printf(@"GLib.Error: $(e.message)\n");
                return null;
            }
        }

        private void file_info_set_value(ref Moegi.FileInfo file_info, string tag, Value? value) {
            string tag_lower = tag.down();
            debug(@"Tag: $(tag)");
            switch (tag_lower) {

              case "title":
                file_info.title = value.get_string();
                break;

              case "artist":
              case "album-artist":
              case "composer":
                if (file_info.artist == null) {
                    file_info.artist = value.get_string();
                } else {
                    file_info.artist += ", " + value.get_string();
                }
                break;

              case "album":
                file_info.album = value.get_string();
                break;

              case "datetime":
                Gst.DateTime datetime = (Gst.DateTime)value.get_boxed();
                file_info.date = datetime.get_year();
                break;

              case "comment":
                file_info.comment = value.get_string();
                break;

              case "track":
              case "track-number":
                file_info.track = value.get_uint();
                break;

              case "genre":
                file_info.genre = value.get_string();
                break;

              case "track-count":
                file_info.track_count = value.get_uint();
                break;

              case "disc-count":
              case "album-disc-count":
                file_info.disc_count = value.get_uint();
                break;

              case "disc":
              case "disc-number":
              case "album-disc-number":
                file_info.disc_number = value.get_uint();
                break;

              case "duration":
                file_info.time_length_milliseconds = value.get_uint();
                break;

              case "image":
                GstSampleAdapter preader = new GstSampleAdapter();
                Gdk.Pixbuf? pixbuf = null;
                pixbuf = preader.extract_pixbuf_from_gst_sample((Gst.Sample)value.get_boxed(), file_info.path);
                file_info.artwork = pixbuf;
                break;
            }
        }
    }
}
