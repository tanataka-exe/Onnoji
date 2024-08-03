import React, { useContext, useState, useEffect } from 'react';
import ViewContext from './ViewContext.js';
import './Albums.css';
import AlbumData from './AlbumData.js';

function compareString(s1, s2) {
  if (s1 === s2) {
    return 0;
  } else if (s1 < s2) {
    return -1;
  } else {
    return 1;
  }
};

function compareAlbumByArtistName(album1, album2) {
  if (album1.artists.length > 0 && album2.artists.length > 0) {
    const s1 = album1.artists.sort((a, b) => compareString(a.artistName, b.artistName))[0].artistName;
    const s2 = album2.artists.sort((a, b) => compareString(a.artistName, b.artistName))[0].artistName;
    return compareString(s1, s2);
  } else if (album1.artists === null || album2.artists.length === 0) {
    return 1;
  } else {
    return 0;
  }
};

export default function GenreAlbums() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const [albums, setAlbums] = useState([]);
  const displayValue = appState.visible.albums ? 'block' : 'none';
  
  useEffect(() => {
    const fetchData = async () => {
      console.log("Get genre albums " + JSON.stringify(appState));
      if (appState.genre != null) {
        console.log('Albums.fetchData(genreId = ' + appState.genre.genreId + ')');
        const response = await fetch(
          `http://${appConfig?.apiHost}:${appConfig?.apiPort}${appState?.genre.albums}`
        );
        if (response.ok) {
          const json = await response.json();
          for (let album of json.albums) {
            const artistRes = await fetch(
              `http://${appConfig.apiHost}:${appConfig.apiPort}${album.artists}`
            );
            if (artistRes.ok) {
              const artistJson = await artistRes.json();
              album.artists = artistJson.artists;
            } else {
              console.log(await artistRes.text());
            }
          }
          setAlbums(json.albums);
        } else {
          console.log(await response.text());
        }
            }
          }
          setAlbums(json.albums);
        } else {
          console.log(await response.text());
        }
      }
    };
    fetchData();
  }, [appConfig, appState]);

  return (
    <div className="albums text-center" style={{display: displayValue}}>
      <h2>ジャンル “{appState.genre.genreName}” のアルバムを選びます</h2>
      <div className="album-list">
        {albums.sort(compareAlbumByArtistName).map((album) => (
          <AlbumData album={album} linkArtist="true" key={album.albumId}/>
        ))}
      </div>
    </div>
  );
}
