import React, { useState, useEffect } from 'react';
import './App.css';
import Genres from './Genres.js';
import Albums from './Albums.js';
import Songs from './Songs.js';
import Artists from './Artists.js';
import Navi from './Navi.js';
import ViewContext from "./ViewContext.js";
import conf from './conf.json';
import logo from './images/onnoji-logo.png';
import Optional from './Optional.js';

export default function App() {
    const [ appState, setAppState ] = useState({
        visible: {
            genres: true,
            albums: false,
            songs: false,
            artists: false
        },
        genreId: null,
        albumId: null,
        artistId: null,
        naviSymbols: [
            { to: "recently-created-albums" },
            { to: "recently-requested-albums" }
        ]
    });

    useEffect(() => {
        window.scrollTo(0, 0);
    }, [appState]);
    
    const viewSwitcher = {
        showGenres: () => {
            setAppState({
                visible: {
                    genres: true,
                    albums: false,
                    songs: false,
                    artists: false
                },
                genreId: null,
                albumId: null,
                artistId: null,
                naviSymbols: [
                    {
                        to: "recently-created-albums"
                    },
                    {
                        to: "recently-requested-albums"
                    }
                ]
            });
        },
        showAlbums: (params) => {
            setAppState({
                requestType: params.requestType,
                visible: {
                    genres: false,
                    albums: true,
                    songs: false,
                    artists: false
                },
                genreId: params.genreId,
                albumId: params.albumId,
                artistId: params.artistId,
                naviSymbols: [
                    {
                        to: "genres"
                    },
                    {
                        to: "artists",
                        params: {
                            genreId: params.genreId
                        }
                    }
                ]
            });
        },
        showArtists: (params) => {
            setAppState({
                visible: {
                    genres: false,
                    albums: false,
                    songs: false,
                    artists: true
                },
                genreId: params.genreId,
                albumId: params.albumId,
                artistId: params.artistId,
                naviSymbols: [
                    {
                        to: "genres"
                    },
                    {
                        to: "albums",
                        params: {
                            genreId: params.genreId
                        }
                    }                       
                ]
            });
        },
        showSongs: (params) => {
            setAppState({
                visible: {
                    genres: false,
                    albums: false,
                    songs: true,
                    artists: false
                },
                genreId: params.genreId,
                albumId: params.albumId,
                artistId: params.artistId,
                naviSymbols: [
                    {
                        to: "genres"
                    },
                    {
                        to: "albums",
                        params: {
                            genreId: params.genreId,
                            artistId: params.artistId
                        }
                    }
                ]
            });
        }
    };

    return (
        <ViewContext.Provider value={viewSwitcher}>
            <nav className="navbar navbar-default navbar-fixed-top">
                <div className="container">
                    <h1 className="navbar-header site-title"><img src={logo}/>{conf.title}</h1>
                    <Navi symbols={appState.naviSymbols}/>
                </div>
            </nav>
            <main className="container">
                <Optional if={appState.visible.genres}>
                    <Genres appState={appState}/>
                </Optional>
                <Optional if={appState.visible.albums}>
                    <Albums appState={appState}/>
                </Optional>
                <Optional if={appState.visible.songs}>
                    <Songs appState={appState}/>
                </Optional>
                <Optional if={appState.visible.artists}>
                    <Artists appState={appState}/>
                </Optional>
            </main>
        </ViewContext.Provider>
    );
}
