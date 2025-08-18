# 音之時 =Onnoji=

楽曲サーバとクライアント。

## API
### GET /api/v2/song/[song_id]/stream : 楽曲再生ストリームの取得 : BIN
### GET /api/v2/song/[song_id]/metadata : 楽曲メタデータ取得 : JSON
### GET /api/v2/song/[song_id]/artwork : 楽曲アートワーク(画像)取得 : BIN
### GET /api/v2/song/[song_id]/genres : 楽曲のジャンル取得 : JSON
### GET /api/v2/song/[song_id]/artists : 楽曲のアーティスト取得 : JSON
### GET /api/v2/song/[song_id]/albums : 楽曲のアルバムを取得 : JSON
### GET /api/v2/song/[song_id]/playlists : 楽曲のプレイリスト一覧を取得 : JSON
### GET /api/v2/artwork/[artwork_id] : アートワークを取得 : BIN
### GET /api/v2/playlists : プレイリスト一覧を取得 : JSON
### POST /api/v2/playlist : プレイリストを登録 : JSON
### GET /api/v2/albums : アルバム一覧を取得 : JSON
### POST /api/v2/album : アルバムを登録 : JSON
### GET /api/v2/playlist/[playlist_id] : プレイリストを取得 : JSON
### GET /api/v2/album/[album_id] : アルバムを取得 : JSON
### GET /api/v2/playlist/[playlist_id]/songs : プレイリストの楽曲一覧を取得 : JSON
### GET /api/v2/album/[album_id]/songs : アルバムの楽曲一覧を取得 : JSON
### GET /api/v2/playlist/[playlist_id]/genres : プレイリストのジャンル一覧を取得 : JSON
### GET /api/v2/album/[album_id]/genres : アルバムのジャンル一覧を取得 : JSON
### GET /api/v2/playlist/[playlist_id]/artists : プレイリストのアーティスト一覧を取得 : JSON
### GET /api/v2/album/[album_id]/artists : アルバムのアーティスト一覧を取得 : JSON
### GET /api/v2/playlist/[playlist_id]/artworks : プレイリストのアートワークを取得 : JSON
### GET /api/v2/album/[album_id]/artworks : アルバムのアートワークを取得 : JSON
### GET /api/v2/playlist/[playlist_id]/artwork : プレイリストのアートワークを取得 : BIN
### GET /api/v2/album/[album_id]/artwork : アルバムのアートワークを取得 : BIN
### GET /api/v2/artist/[artist_id] : アーティストを取得 : JSON
### GET /api/v2/artist/[artist_id]/albums : アーティストのアルバムを取得 : JSON
### GET /api/v2/artist/[artist_id]/playlists : アーティストのプレイリストを取得 : JSON
### GET /api/v2/artist/[artist_id]/genres : アーティストのジャンルを取得 : JSON
### GET /api/v2/artist/[artist_id]/songs : アーティストの楽曲を取得 : JSON
### GET /api/v2/genres : ジャンル一覧を取得 : JSON
+ Array
  + Object
    + String "genreId"
    + String "genreName"
    + String(url) "icon"
    + String(url) "albums"
    + String(url) "playlists"
    + String(url) "artists"
### GET /api/v2/genre/[genre_id]/icon : ジャンルのアイコンを取得 : JSON
### POST /api/v2/genre/[genre_id]/icon : ジャンルのアイコンを登録 : JSON
### GET /api/v2/genre/[genre_id]/playlists : ジャンルのプレイリスト一覧を取得 : JSON
### GET /api/v2/genre/[genre_id]/albums : ジャンルのアルバム一覧を取得 : JSON
### GET /api/v2/genre/[genre_id]/artists : ジャンルのアーティスト一覧を取得 : JSON
### POST /api/v2/history/[song_id] : 楽曲再生履歴を登録 : JSON
### GET /api/v2/recently-requested/[min-max]/songs : 最近再生した楽曲を取得 : JSON
### GET /api/v2/recently-requested/[min-max]/playlists : 最近再生したプレイリストを取得 : JSON
### GET /api/v2/recently-requested/[min-max]/albums : 最近再生したアルバムを取得 : JSON
### GET /api/v2/recently-registered/[min-max]/songs : 最近登録した楽曲を取得 : JSON
### GET /api/v2/recently-registered/[min-max]/playlists : 最近登録したプレイリストを取得 : JSON
### GET /api/v2/recently-registered/[min-max]/albums : 最近登録したアルバムを取得 : JSON
