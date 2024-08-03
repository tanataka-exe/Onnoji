import React, { useState, useEffect, useContext } from 'react';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

export default function Artists() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const displayValue = appState.visible.artists ? 'block' : 'none';
  const [ artists, setArtists ] = useState([]);
  
  useEffect(() => {
    const fetchData = async () => {
      if (appState.genre != null) {
        const response = await fetch(
          `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/genre/${appState.genre.genreId}/artists`
        );
        if (response.ok) {
          const json = await response.json();
          setArtists(json.artists);
        } else {
          console.log(await response.text());
        }
      }
    };
    fetchData();
  }, [appConfig.apiHost, appConfig.apiPort, appState.genre]);

  return (
    <div style={{display: displayValue}}>
      <h2>アーティストを選びます</h2>
      <table className="table text-white">
        <thead>
          <tr>
            <th className="text-left">アーティスト名</th>
            <th className="text-left"></th>
          </tr>
        </thead>
        <tbody>
          {artists.map((artist, index) => (
            <tr key={artist.artistId} className="artist-list">
              <td className="text-body text-start">{artist.artistName}</td>
              <td className="text-body text-end">
                <LinkButton key={artist.artistId} onClick={() => viewSwitcher.showAlbums({requestType: 'artist-albums', artist: artist, genre: appState.genre})}>アルバムを見る</LinkButton>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
