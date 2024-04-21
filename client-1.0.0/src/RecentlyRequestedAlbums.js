import React, { useState, useEffect } from 'react';
import './Albums.css';
import AlbumData from './AlbumData.js';
import conf from './conf.json';

function compareStrings(s1, s2) {
    if (s1 === s2) {
        return 0;
    } else if (s1 < s2) {
        return -1;
    } else {
        return 1;
    }
};

export default function RecentlyRequestedAlbums({ appState }) {
    const [albums, setAlbums] = useState([]);
    const displayValue = appState.visible.albums ? 'block' : 'none';
    const genreId = appState.genreId;
    
    useEffect(() => {
        fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/albums?recent_request=${conf.recentCount}`)
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
    }, []);

    return (
        <div className="albums text-center" style={{display: displayValue}}>
            <h2>最近聴いたアルバムです</h2>
            <div className="album-list">
                {albums.sort((a, b) => compareStrings(b.last_request_datetime, a.last_request_datetime)).map((albumData) => (
                    <AlbumData albumData={albumData} genre={genreId} linkArtist="true" key={albumData.album_id}/>
                ))}
            </div>
        </div>
    );
}
