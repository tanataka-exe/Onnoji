import { useContext, useState, useEffect } from 'react';
import emptyImage from './images/empty-image200.png';
import './Albums.css';
import './AlbumData.css';
import ViewContext from './ViewContext.js';
import Button from 'react-bootstrap/Button';

function ArtistLink({ artist }) {
  const { viewSwitcher } = useContext(ViewContext);
  const params = {
    requestType: 'artist-albums',
    artist: artist,
  };
  return (
    <Button variant="link" onClick={() => viewSwitcher.showAlbums(params)}>
      <span className="artist-name">{artist.artistName}</span>
    </Button>
  );
};

function ArtistList({ album, linkArtist, artists, genre }) {
  if (!linkArtist) {
    return <span></span>;
  }
  if (artists === null || JSON.stringify(artists) === "") {
    return <span></span>;
  }
  console.log(JSON.stringify(artists));

  return (
    <div>
      {artists.slice(0, 3).map((artist, index) => (
        <div key={album.albumId + ':' + artist.artistId}>
          <ArtistLink artist={artist}/>
          <span>
            {index < (artists.length - 1) ? ', ' : ''}
          </span>
        </div>
      ))}{artists.length > 3 ? ' etc.' : ''}
    </div>
  );
};

function AlbumTitle ({children}) {
  const title = children;
  
  if (title.length >= 50) {
    return (
      <div className="mytooltip">
        <h4>{title.substring(0, 50) + '...'}</h4>
        <span className="mytooltiptext">{title}</span>
      </div>
    );
  } else {
    return (
      <h4>{title}</h4>
    );
  }
};

export default function AlbumData({ album, linkArtist }) {
  const { appState, appConfig, viewSwitcher } = useContext(ViewContext);
  const [ artists, setArtists ] = useState([]);
  const [ genres, setGenres ] = useState([]);
  const [ artwork, setArtwork ] = useState();
  const [ songsParam, setSongsParam ] = useState({
    album: album,
    genre: appState.genre,
    artist: appState.artist
  });

  useEffect(() => {
    console.log("get albumData " + JSON.stringify(appState));
    const fetchData = async () => {
      const artistsResponse = await fetch(
        `http://${appConfig?.apiHost}:${appConfig?.apiPort}/api/v2/playlist/${album.albumId}/artists`
      );
      const artistsJson = await artistsResponse.json();
      setArtists(artistsJson.artists);

      const genresResponse = await fetch(
        `http://${appConfig?.apiHost}:${appConfig?.apiPort}/api/v2/playlist/${album.albumId}/genres`
      );
      const genresJson = await genresResponse.json();
      setGenres(genresJson.genres);

      setArtwork(`http://${appConfig?.apiHost}:${appConfig?.apiPort}${album.artwork}`);

      const values = {
        album: album,
        genre: genresJson.genres.length > 0 ? genresJson.genres[0] : null,
        artist: artistsJson.artists.length > 0 ? artistsJson.artists[0] : null
      };
      console.log('setSongsParam: ' + JSON.stringify(values));
      setSongsParam(values);
    };
    fetchData();
  }, [album, appConfig, appState]);

  return (
    <div className="album-list-item">
      <div>
        <Button variant="link" onClick={() => viewSwitcher.showSongs(songsParam)}>
          <img className="img-thumbnail" src={artwork ?? emptyImage} alt="album icon"/>
        </Button>
      </div>
      <div>
        <Button variant="link" onClick={() => viewSwitcher.showSongs(songsParam)}>
          <AlbumTitle>{album.albumName}</AlbumTitle>
        </Button>
        {linkArtist && artists != null ?
         <ArtistList album={album} artists={artists} genre={genres} linkArtist={linkArtist}/>
         : null}
      </div>
    </div>
  );
}
