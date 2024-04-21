import React, { useState, useEffect } from 'react';
import './Albums.css';
import AlbumData from './AlbumData.js';
import conf from './conf.json';

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
        const s1 = album1.artists.sort((a, b) => compareString(a.artist_name, b.artist_name))[0].artist_name;
        const s2 = album2.artists.sort((a, b) => compareString(a.artist_name, b.artist_name))[0].artist_name;
        return compareString(s1, s2);
    } else if (album1.artists === null || album2.artists.length === 0) {
        return 1;
    } else {
        return 0;
    }
};

export default function GenreAlbums({ appState }) {
    const [albums, setAlbums] = useState([]);
    const [genre, setGenre ] = useState({genre_id: 0, genre_name: ''});
    const displayValue = appState.visible.albums ? 'block' : 'none';
    
    useEffect(() => {
        const fetchData = async () => {
            if (appState.genreId != null) {
                console.log('Albums.fetchData(genreId = ' + appState.genreId + ')');
                const response = await fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/albums?genre=${appState.genreId}`)
                if (response.ok) {
                    const json = await response.json();
                    setAlbums(json.albums);
                    setGenre({id: json.genre_id, name: json.genre_name});
                } else {
                    console.log(response.text);
                }
            }
        }
        fetchData();
    }, [appState]);

    return (
        <div className="albums text-center" style={{display: displayValue}}>
            <h2>ジャンル “{genre.name}” のアルバムを選びます</h2>
            <div className="album-list">
                {albums.sort(compareAlbumByArtistName).map((albumData) => (
                    <AlbumData albumData={albumData} genre={appState.genreId} linkArtist="true" key={albumData.album_id}/>
                ))}
            </div>
        </div>
    );
}
