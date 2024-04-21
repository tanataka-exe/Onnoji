import React, { useState, useEffect } from 'react';
import AlbumData from './AlbumData.js';
import AllSongs from './AllSongs.js';
import './Albums.css';
import conf from './conf.json';

export default function ArtistAlbums({ appState }) {
    const [albums, setAlbums] = useState([]);
    const [artist, setArtist] = useState({artist_id: 0, artist_name: ''});

    useEffect(() => {
        async function fetchData() {
            const response = await fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/albums?artist=${appState.artistId}&lazy=true`)
            if (response.ok) {
                const json = await response.json();
                setAlbums(json.albums);
                setArtist({ artist_id: json.artist_id, artist_name: json.artist_name });
            } else {
                console.log(response.text);
            }
        }
        fetchData();
    }, [appState.artistId]);
    
    return (
        <div className="albums text-center">
            <h2>{artist.artist_name}のアルバムを選びます</h2>
            <div className="album-list">
                <AllSongs artistId={artist.artist_id}/>
                { albums.map((albumData) =>
                    <AlbumData key={albumData.album_id} albumData={albumData} artist={appState.artistId} linkArtist="false"/>
                )}
            </div>
        </div>
    );
}
