import React, { useState, useEffect } from 'react';
import './App.css';
import Genres from './Genres.js';
import Albums from './Albums.js';
import Songs from './Songs.js';
import Artists from './Artists.js';
import UploadPage from './UploadPage.js';
import Navi from './Navi.js';
import ViewContext from "./ViewContext.js";
import logo from './images/onnoji-logo.png';
import Optional from './Optional.js';

export default function App() {
    const [ appState, setAppState ] = useState({
        visible: {genres: true, albums: false, songs: false, artists: false, uploadPage: false},
        genre: null, album: null, artist: null,
        naviSymbols: [
            { to: "recently-created-albums" },
            { to: "recently-requested-albums" },
            { to: "upload-album" }
        ]
    });
    const [ appConfig, setAppConfig ] = useState();

    useEffect(() => {
        window.scrollTo(0, 0);
        const loadAppConfig = async () => {
            const response = await fetch('/config.json');
            if (response.ok) {
                const json = await response.json();
                setAppConfig(json);
            } else {
                console.log("config is not found!");
            }
        };
        loadAppConfig();
    }, []);
    
    const viewSwitcher = {
        showGenres: () => {
            setAppState({
                visible: {genres: true, albums: false, songs: false, artists: false, uploadPage: false},
                genre: null, album: null, artist: null,
                naviSymbols: [{to: "recently-created-albums"}, {to: "recently-requested-albums"}, {to: "upload-album"}]
            });
        },
        showAlbums: (params) => {
            setAppState({
                requestType: params.requestType,
                visible: {genres: false, albums: true, songs: false, artists: false, uploadPage: false},
                genre: params.genre, album: params.album, artist: params.artist,
                naviSymbols: [
                    {to: "genres"},
                    {to: "artists", params: {genre: params.genre}},
                    {to: "upload-album"}
                ]
            });
        },
        showArtists: (params) => {
            setAppState({
                visible: {genres: false, albums: false, songs: false, artists: true, uploadPage: false},
                genre: params.genre, album: params.album, artist: params.artist,
                naviSymbols: [
                    {to: "genres"},
                    {to: "albums", params: {genre: params.genre}},
                    {to: "upload-album"}
                ]
            });
        },
        showSongs: (params) => {
            setAppState({
                visible: {genres: false, albums: false, songs: true, artists: false, uploadPage: false},
                genre: params.genre, album: params.album, artist: params.artist,
                naviSymbols: [
                    {to: "genres"},
                    {to: "albums", params: {genre: params.genre, artist: params.artist}},
                    {to: "upload-album"}
                ]
            });
        },
        showUploadPage: (params) => {
            setAppState({
                visible: {genres: false, albums: false, songs: false, artists: false, uploadPage: true},
                genre: params.genre, album: params.album, artist: params.artist,
                naviSymbols: [
                    {to: "genres"},
                    {to: "albums", params: {genre: params.genre, artist: params.artist}}
                ]
            });
        }
    };

    return (
        <ViewContext.Provider value={{appConfig, appState, viewSwitcher}}>
            <nav className="navbar navbar-default navbar-fixed-top">
                <div className="container">
                    <h1 className="navbar-header site-title"><img src={logo} alt={appConfig?.title}/>{appConfig?.title}</h1>
                    <Navi symbols={appState.naviSymbols}/>
                </div>
            </nav>
            <main className="container">
                <Optional if={appState.visible.genres}>
                    <Genres/>
                </Optional>
                <Optional if={appState.visible.albums}>
                    <Albums/>
                </Optional>
                <Optional if={appState.visible.songs}>
                    <Songs/>
                </Optional>
                <Optional if={appState.visible.artists}>
                    <Artists/>
                </Optional>
                <Optional if={appState.visible.uploadPage}>
                    <UploadPage/>
                </Optional>
            </main>
        </ViewContext.Provider>
    );
}
