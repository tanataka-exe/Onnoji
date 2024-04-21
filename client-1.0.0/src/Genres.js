import React, { useState, useEffect, useContext } from 'react';
import './Genres.css';
import conf from './conf.json';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

export default function Genres({ appState }) {
    const [genres, setGenres] = useState([]);
    const viewSwitcher = useContext(ViewContext);
    const displayValue = appState.visible.genres ? 'block' : 'none';
    
    useEffect(() => {
        async function fetchData() {
            const response = await fetch(`http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/genres`);
            if (response.ok) {
                const json = await response.json();
                setGenres(json.genres);
            } else {
                console.log(response.text);
            }
        }
        fetchData();
    }, []);

    const callShowAlbums = (genreId) => {
        console.log('genreData.genre_id: ' + genreId);
        viewSwitcher.showAlbums({genreId});
    };

    const callShowArtists = (genreId) => {
        console.log('genreData.genre_id: ' + genreId);
        viewSwitcher.showArtists({genreId});
    };
    
    return (
        <div style={{display: displayValue}}>
            <h2>ジャンルを選びます</h2>
            <ul className="genre-list">
                {genres.map((genreData) => (
                    <li key={"genre" + genreData.genre_id} className="genre-list-item text-center">
                        <img className="genre-icon rounded-circle" src={genreData.icon} width="160px" height="160px" alt="genre icon"/>
                        <h3>{genreData.genre_name}</h3>
                        <LinkButton onClick={() => callShowAlbums(genreData.genre_id)}>アルバム一覧を見る</LinkButton>
                        <LinkButton onClick={() => callShowArtists(genreData.genre_id)}>アーティスト一覧を見る</LinkButton>
                    </li>
                ))}
            </ul>
        </div>
    );
}
