project(
  'com.github.aharotias2.onnoji',
  'vala', 'c',
  version: '1.0.0'
)

add_global_arguments('-O2', language: 'c')

subproject('gxml').get_variable('libgxml_build_dir')

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gstreamer-1.0'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libgda-5.0'),
  dependency('libsoup-2.4'),
  dependency('gdk-3.0'),
  dependency('libxml-2.0'),
  dependency(
    'gxml-0.20',
    fallback : [
      'gxml',
      'libgxml_dep'
    ]
  )
]

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources',
    join_paths('resources', 'onnoji-resources.xml'),
    source_dir: 'resources',
    c_name: 'as'
)

common_sources = files([
  'src/common/Error.vala',
  'src/common/FilePathUtils.vala',
  'src/common/FileType.vala',
  'src/common/DirectoryReader.vala',
  'src/common/ProgramName.vala',
  'src/common/Values.vala',
  'src/common/OnnojiError.vala',
  'src/common/OnnojiPaths.vala',
  'src/common/functions.vala',
  'src/common/timestamp.c'
])

resource_sources = files([
  'src/common/ResourceManager.vala',
  'src/common/XmlResourceManager.vala'
])

repository_sources = files([
  'src/entity/Artist.vala',
  'src/entity/Artwork.vala',
  'src/entity/Genre.vala',
  'src/entity/History.vala',
  'src/entity/Playlist.vala',
  'src/entity/Song.vala',
  'src/repository/ArtistRepository.vala',
  'src/repository/ArtistRepositoryImpl.vala',
  'src/repository/ArtworkRepository.vala',
  'src/repository/ArtworkRepositoryImpl.vala',
  'src/repository/BasicRepositoryImpl.vala',
  'src/repository/GenreRepository.vala',
  'src/repository/GenreRepositoryImpl.vala',
  'src/repository/HistoryRepository.vala',
  'src/repository/HistoryRepositoryImpl.vala',
  'src/repository/PlaylistRepository.vala',
  'src/repository/PlaylistRepositoryImpl.vala',
  'src/repository/RequiredRelation.vala',
  'src/repository/SongRepository.vala',
  'src/repository/SongRepositoryImpl.vala',
  'src/repository/SqlConditionType.vala',
  'src/repository/SqlInsertFlags.vala'
])

gst_utils_sources = files([
  'src/common/FileInfo.vala',
  'src/common/FileInfoAdapter.vala',
  'src/common/MetadataReader.vala',
  'src/common/GstSampleAdapter.vala'
])

server_service_sources = files([
  'src/server/PostFileData.vala',
  'src/server/ServiceResponse.vala',
  'src/server/ResponseJsonMaker.vala',
  'src/server/MusicDataProducer.vala',
  'src/server/MusicDataProducerImpl1.vala'
])

context_sources = files([
  'src/context/ApplicationContext.vala',
  'src/context/RealApplicationContext.vala'
])

batch_sources = files([
  'src/batch/OnnojiBatch.vala',
  'src/batch/BatchTask.vala'
])

server_sources = files([
  'src/server/Onnoji.vala',
  'src/server/OnnojiThreadData.vala'
])

test_sources = files([
  'tests/context/TestApplicationContext.vala',
])

gstreamer_test_sources = files([
  'tests/gstreamer-test.vala',
])

repository_test_sources = files([
  'tests/repository-test.vala',
  'tests/context/RepositoryTestContext.vala',
  'tests/repository/Mocks.vala',
  'tests/repository/SongTest.vala',
  'tests/repository/ArtistTest.vala',
  'tests/repository/PlaylistTest.vala',
  'tests/repository/GenreTest.vala',
  'tests/repository/HistoryTest.vala'
])

producer_test_sources = files([
  'tests/producer-test.vala',
  'tests/context/ProducerTestContext.vala'
])

common_test_sources = files([
  'tests/common-tests.vala'
])

#executable('onnoji', server_sources, dependencies: dependencies)
#executable('onnoji-batch', batch_sources, dependencies: dependencies)

#executable(
#  'onnoji-test',
#  ['tests/test1.vala'] + asresources + repository_sources + test_sources + common_sources + service_sources,
#  dependencies: dependencies
#)

gstreamer_test = executable(
  'onnoji-gstreamer-test',
  gstreamer_test_sources
  + common_sources
  + gst_utils_sources,
  dependencies: dependencies
)

resource_test = executable(
  'onnoji-resource-test',
  ['tests/resource-test.vala', 'tests/context/ResourceTestContext.vala']
  + asresources
  + common_sources
  + resource_sources,
  dependencies: dependencies
)

repository_test = executable(
  'onnoji-repository-test',
  repository_test_sources
  + repository_sources
  + common_sources
  + resource_sources
  + asresources,
  dependencies: dependencies
)

producer_test = executable(
  'onnoji-producer-test',
  producer_test_sources
  + repository_sources
  + common_sources
  + resource_sources
  + server_service_sources
  + gst_utils_sources
  + asresources,
  dependencies: dependencies
)

common_test = executable(
  'onnoji-common-test',
  common_test_sources
  + common_sources,
  dependencies: dependencies
)

onnoji = executable(
  'onnoji',
  server_sources
  + context_sources
  + server_service_sources
  + repository_sources
  + common_sources
  + resource_sources
  + gst_utils_sources
  + asresources,
  dependencies: dependencies
)
  
test('insert artist', repository_test, args: ['artist', 'insert'])
test('select artist', repository_test, args: ['artist', 'select-equals'])
test('update artist', repository_test, args: ['artist', 'update'])
test('delete artist', repository_test, args: ['artist', 'delete'])
test('insert genre', repository_test, args: ['genre', 'insert'])
test('select genre', repository_test, args: ['genre', 'select-equals'])
test('update genre', repository_test, args: ['genre', 'update'])
test('delete genre', repository_test, args: ['genre', 'delete'])
test('insert history', repository_test, args: ['history', 'insert'])
test('select history', repository_test, args: ['history', 'select-equals'])
test('update history', repository_test, args: ['history', 'update'])
test('delete history', repository_test, args: ['history', 'delete'])
test('insert song', repository_test, args: ['song', 'insert'])
test('select song', repository_test, args: ['song', 'select-equals'])
test('update song', repository_test, args: ['song', 'update'])
test('delete song', repository_test, args: ['song', 'delete'])
test('select song by playlist', repository_test, args: ['song', 'select-equals-playlist', 'transactional'])
test('select song by genre', repository_test, args: ['song', 'select-equals-genre', 'transactional'])
test('select song by artist', repository_test, args: ['song', 'select-equals-artist', 'transactional'])
test('select genre by song', repository_test, args: ['genre', 'select-by-song-id', 'transactional'])
test('produce song metadata', producer_test, args: ['test-query-song-metadata', '1'])
test('file info adapter test', gstreamer_test, args: ['file_info', '../tests/data/lightweight/sng000000000147'])
test('metadata reader test', gstreamer_test, args: ['metadata', '../tests/data/lightweight/sng000000000147'])
