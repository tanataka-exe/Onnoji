import React, { useState, useEffect } from 'react';
import './Albums.css';
import AlbumData from './AlbumData.js';
import conf from './conf.json';
import RoundButton from './RoundButton.js';

function compareStrings(s1, s2) {
    if (s1 === s2) {
        return 0;
    } else if (s1 < s2) {
        return -1;
    } else {
        return 1;
    }
};

export default function RecentlyCreatedAlbums({ appState }) {
    const [albums, setAlbums] = useState([]);
    const [recentCount, setRecentCount] = useState(20);
    const displayValue = appState.visible.albums ? 'block' : 'none';
    const genreId = null;
    
    useEffect(() => {
        fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/albums?recent_creation=${recentCount}`)
            .then((res) => res.json())
            .then(
                (json) => {
                    setAlbums(json.albums);
                    //setGenre({id: json.genre_id, name: json.genre_name});
                },
                (error) => {
                    console.log(error);
                }
            );
    }, [recentCount]);

    return (
        <div className="albums text-center" style={{display: displayValue}}>
            <h2>最近追加されたアルバムです</h2>
            <div className="album-list">
                {albums.sort((a, b) => compareStrings(b.creation_datetime, a.creation_datetime)).map((albumData) => (
                    <AlbumData albumData={albumData} genre={genreId} linkArtist="true" key={albumData.album_id}/>
                ))}
            </div>
	    <div>
		<RoundButton onClick={() => setRecentCount(recentCount + 20)}>もっと見る</RoundButton>
	    </div>
        </div>
    );
}
