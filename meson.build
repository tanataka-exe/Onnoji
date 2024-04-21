project(
  'com.github.aharotias2.onnoji',
  'vala', 'c',
  version: '1.0.0'
)

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gstreamer-1.0'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('sqlite3'),
  dependency('libsoup-2.4'),
  dependency('gdk-3.0')
]

common_sources = files([
  'src/common/OnnojiConstants.vala',
  'src/common/ProgramName.vala',
  'src/common/MetadataReader.vala',
  'src/common/HistoryData.vala',
  'src/common/FileInfo.vala',
  'src/common/Songs.vala',
  'src/common/FileInfoAdapter.vala',
  'src/common/OnnojiError.vala',
  'src/common/DirectoryReader.vala',
  'src/common/SongData.vala',
  'src/common/Artists.vala',
  'src/common/SqliteUtils.vala',
  'src/common/SmallTime.vala',
  'src/common/AlbumDataEx.vala',
  'src/common/AlbumData.vala',
  'src/common/FileType.vala',
  'src/common/GstSampleAdapter.vala',
  'src/common/GenreData.vala',
  'src/common/FilePathUtils.vala',
  'src/common/Albums.vala',
  'src/common/Error.vala',
  'src/common/ArtistData.vala',
  'src/common/Genres.vala',
  'src/common/History.vala'
])

batch_sources = files([
  'src/batch/OnnojiBatch.vala',
  'src/batch/BatchTask.vala'
]) + common_sources

server_sources = files([
  'src/server/OnnojiThreadData.vala',
  'src/server/Onnoji.vala',
  'src/server/OnnojiUtils.vala',
  'src/server/ResponseJsonMaker.vala',
  'src/server/MusicDataProducer.vala',
]) + common_sources

# ブラウザアプリは作るかもしれないけど、作らないかもしれない。
#browser_sources = files([
#  'src/browser/OnnojiBrowser.vala'
#])

executable('onnoji', server_sources, dependencies: dependencies)
executable('onnoji-batch', batch_sources, dependencies: dependencies)
