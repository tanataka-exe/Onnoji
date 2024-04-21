import { useContext } from 'react';
import allSongsPng from './images/all-songs.png';
import './Albums.css';
import LinkButton from './LinkButton.js';
import ViewContext from './ViewContext.js';

export default function AllSongs(props) {
    const viewSwitcher = useContext(ViewContext);
    return (
        <div key={0} className="album-list-item">
            <div>
                <LinkButton onClick={() => viewSwitcher.showSongs({artistId: props.artistId})}>
                    <img className="rounded" src={allSongsPng} alt="Listen All Songs"/>
                </LinkButton>
            </div>
            <div>
                <LinkButton onClick={() => viewSwitcher.showSongs({artistId: props.artistId})}>
                    <h4>全ての曲</h4>
                </LinkButton>
            </div>
        </div>
    );
}
