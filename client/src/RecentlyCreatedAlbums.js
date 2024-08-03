import React, { useState, useEffect, useContext } from 'react';
import './Albums.css';
import AlbumData from './AlbumData.js';
import RoundButton from './RoundButton.js';
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

export default function RecentlyCreatedAlbums() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const [albums, setAlbums] = useState([]);
  const [recentCount, setRecentCount] = useState(20);
  const displayValue = appState.visible.albums ? 'block' : 'none';

  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(
          `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/recently-registered/1-${recentCount}/albums`
        );
        if (response.ok) {
          const json = await response.json();
          setAlbums(json.albums);
        } else {
          console.log(await response.text());
        }
      } catch (err) {
        console.log(err);
      }
    };

    fetchData();
  }, [appConfig.apiHost, appConfig.apiPort, recentCount]);

  return (
    <div className="albums text-center" style={{display: displayValue}}>
      <h2>最近追加されたアルバムです</h2>
      <div className="album-list">
        {albums.sort((a, b) => compareStrings(b.creation_datetime, a.creation_datetime)).map((album) => (
          <AlbumData album={album} linkArtist="true" key={album.albumId}/>
        ))}
      </div>
      <div>
	<RoundButton onClick={() => setRecentCount(recentCount + 20)}>もっと見る</RoundButton>
      </div>
    </div>
  );
}
