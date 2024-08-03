import { useContext } from 'react';
import allSongsPng from './images/all-songs.png';
import './Albums.css';
import Button from 'react-bootstrap/Button';
import ViewContext from './ViewContext.js';

export default function AllSongs({ artist }) {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  return (
    <div key={0} className="album-list-item">
      <div>
        <Button variant="link" onClick={() => viewSwitcher.showSongs({artist: appState.artist})}>
          <img className="rounded" src={allSongsPng} alt="Listen All Songs"/>
        </Button>
      </div>
      <div>
        <Button variant="link" onClick={() => viewSwitcher.showSongs({artist: appState.artist})}>
          <h4>全ての曲</h4>
        </Button>
      </div>
    </div>
  );
}
