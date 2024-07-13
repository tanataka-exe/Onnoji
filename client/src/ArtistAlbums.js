import React, { useContext, useState, useEffect } from 'react';
import ViewContext from './ViewContext.js';
import AlbumData from './AlbumData.js';
import AllSongs from './AllSongs.js';
import './Albums.css';

export default function ArtistAlbums() {
    const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
    const [albums, setAlbums] = useState([]);
    const artist = appState.artist;

    useEffect(() => {
        const fetchData = async () => {
            const response = await fetch(
                `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/artist/${artist.artistId}/albums`
            );
            if (response.ok) {
                const json = await response.json();
                setAlbums(json.albums);
            } else {
                console.log(response.text);
            }
        };
        fetchData();
    }, [appConfig.apiHost, appConfig.apiPort, appState.artist.artistId]);
    
    return (
        <div className="albums text-center">
            <h2>{artist.artistName}のアルバムを選びます</h2>
            <div className="album-list">
                <AllSongs/>
                { albums.map((album) =>
                    <AlbumData key={album.albumId} album={album} linkArtist="false"/>
                )}
            </div>
        </div>
    );
}
