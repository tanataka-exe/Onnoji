import React, { useState, useEffect, useContext } from 'react';
import './Albums.css';
import AlbumData from './AlbumData.js';
import ViewContext from './ViewContext.js';

function compareStrings(s1, s2) {
  if (s1 === s2) {
    return 0;
  } else if (s1 < s2) {
    return -1;
  } else {
    return 1;
  }
};

export default function RecentlyRequestedAlbums() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const [albums, setAlbums] = useState([]);
  const displayValue = appState.visible.albums ? 'block' : 'none';

  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const albumResponse = await fetch(
          `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/recently-requested/1-${appConfig.recentCount}/albums`
        );
        const albumJson = await albumResponse.json();
        setAlbums(albumJson.albums);
      } catch (err) {
        console.log(err);
      }
    };
    fetchData();
  }, [appConfig.apiHost, appConfig.apiPort, appConfig.recentCount]);

  return (
    <div className="albums text-center" style={{display: displayValue}}>
      <h2>最近聴いたアルバムです</h2>
      <div className="album-list">
        {albums.sort((a, b) => compareStrings(b.last_request_datetime, a.last_request_datetime)).map((album) => (
          <AlbumData album={album} linkArtist="true" key={album.albumId}/>
        ))}
      </div>
    </div>
  );
}
