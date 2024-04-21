import React, { useState, useEffect, useContext } from 'react';
import conf from './conf.json';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

export default function Artists({ appState }) {
    const viewSwitcher = useContext(ViewContext);
    const displayValue = appState.visible.artists ? 'block' : 'none';
    const [ artists, setArtists ] = useState([]);
    
    useEffect(() => {
        async function fetchData() {
            if (appState.genreId != null) {
                const response = await fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/artists?genre=${appState.genreId}`)
                if (response.ok) {
                    const json = await response.json();
                    setArtists(json.artists);
                } else {
                    console.log(response.text);
                }
            }
        }
        fetchData();
    }, [appState.genreId]);

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
                        <tr key={artist.artist_id} className="artist-list">
                            <td className="text-body text-start">{artist.artist_name}</td>
                            <td className="text-body text-end">
                                <LinkButton key={artist.artist_id} onClick={() => viewSwitcher.showAlbums({requestType: 'artist-albums', artistId: artist.artist_id, genreId: appState.genreId})}>アルバムを見る</LinkButton>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
