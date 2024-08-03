import React, { useState, useEffect, useContext } from 'react';
import './Genres.css';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

export default function Genres() {
  const [genres, setGenres] = useState([]);
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const displayValue = appState?.visible.genres ? 'block' : 'none';

  useEffect(() => {
    if (appConfig == null) {
      return;
    }

    const fetchData = async () => {
      const response = await fetch(`http://${appConfig?.apiHost}:${appConfig?.apiPort}/api/v2/genres`);
      if (response.ok) {
        const json = await response.json();
        setGenres(json.genres);
      } else {
        console.log(await response.text());
      }
    };
    
    fetchData();
    
  }, [appConfig?.apiHost, appConfig?.apiPort]);

  console.log("Displays Genres");
  
  if (appConfig == null) {
    return <div></div>;
  }
  
  return (
    <div style={{display: displayValue}}>
      <h2>ジャンルを選びます</h2>
      <ul className="genre-list">
        {genres.map((genre) => (
          <li key={"genre" + genre.genreId} className="genre-list-item text-center">
            <img className="genre-icon rounded-circle" src={`http://${appConfig.apiHost}:${appConfig.apiPort}${genre.icon}`} width="160px" height="160px" alt="genre icon"/>
            <h3>{genre.genreName}</h3>
            <LinkButton onClick={() => viewSwitcher.showAlbums({genre})}>
              アルバム一覧を見る
            </LinkButton>
            <LinkButton onClick={() => viewSwitcher.showArtists({genre})}>
              アーティスト一覧を見る
            </LinkButton>
          </li>
        ))}
      </ul>
    </div>
  );
}
