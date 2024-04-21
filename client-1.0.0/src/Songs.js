import React, { useState, useEffect, useContext } from 'react';
import './Songs.css';
import conf from './conf.json';
import loadingGif from './images/loading.gif';
import noImagePngLarge from './images/empty-image200.png';
import blackPng from './images/black48.png';
import playGif from './images/playing.gif';
import pauseGif from './images/pausing.gif';
import playButtonPng from './images/play-button.png';
import pauseButtonPng from './images/pause-button.png';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

function formatAlbumDate(dates) {
    if (dates == null || dates.length === 0) {
        return '';
    } else {
        const min = Math.min(...dates);
        const max = Math.max(...dates);
        if (min === max) {
            return ` (${dates[0]})`;
        } else {
            return ` (${min}-${max})`;
        }
    }
}

const tableRowStyle = {
    verticalAlign: 'top',
    borderTop: 'rgba(255, 255, 255, 0.2) solid 1px',
    borderBottom: 'rgba(200, 200, 2220, 0.2) solid 2px',
    borderLeft: 'none',
    borderRight: 'none'
};

const tableHeaderRowStyle = {
    display: 'none'
};

export default function Songs({ appState }) {
    const viewSwitcher = useContext(ViewContext);
    const [ songs, setSongs ] = useState([]);
    const [ audioSrc, setAudioSrc ] = useState('');
    const [ currentIndex, setCurrentIndex ] = useState(0);
    const [ albumName, setAlbumName ] = useState('');
    const [ artistName, setArtistName ] = useState('');
    const [ albumDate, setAlbumDate ] = useState('');
    const [ artistDate, setArtistDate ] = useState('');
    const [ mimeType, setMimeType ] = useState('audio/mpeg');
    const displayValue = appState.visible.songs ? 'block' : 'none';
    const playedSongs = [];
    let albumId = null;
    let artistId = null;

    useEffect(() => {
        async function fetchData() {
            if (albumId != null || artistId != null) {
                let url;
                if (albumId != null) {
                    url = `http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/songs?album=${albumId}`;
                } else {
                    url = `http://${conf.apiAddress}:${conf.apiPort}/music/v1/list/songs?artist=${artistId}`;
                }
                const response = await fetch(url);
                if (response.ok) {
                    const json = await response.json();
                    setSongs(json.songs);
                    setAudioSrc(json.songs[0].file_url);
                    setAlbumName(json.songs[0].album_name);
                    setArtistName(json.songs[0].artist_name);
                    const dates = json.songs.filter(song => song.album_id === json.songs[0].album_id)
                          .filter(song => song.pub_date != null && song.pub_date > 0).map(song => song.pub_date);
                    setAlbumDate(formatAlbumDate(dates));
                    const artistDates = json.songs.filter(song => song.pub_date != null && song.pub_date > 0).map(song => song.pub_date);
                    setArtistDate(formatAlbumDate(artistDates));
                    setMimeType(json.songs[0].mime_type);
                } else {
                    console.log(response.text);
                }
            }
        }
        fetchData();
    }, [appState, albumId, artistId]);

    function addHistory() {
        console.log(audioSrc);
        if (playedSongs.includes(audioSrc)) {
            return;
        } else {
            playedSongs.push(audioSrc);
        }
        if (audioSrc !== '') {
            const audioSrcUrl = new URL(audioSrc);
            const params = new URLSearchParams(audioSrcUrl.search);
            const songId = params.get('id');
            const url = `http://${conf.apiAddress}:${conf.apiPort}/music/v1/add/history?id=${songId}`;
            console.log(url);
            fetch(url)
                .then((res) => res.json())
                .then(
                    (json) => {
                        console.log("result: " + json.toString());
                    },
                    (error) => {
                        console.log(error);
                    }
                );
        }
    }

    if (appState.albumId != null) {
        albumId = appState.albumId;
    }
    if (appState.artistId != null) {
        artistId = appState.artistId;
    }
    if (appState.albumId == null && appState.artistId == null) {
        console.log("ERROR: this location quires a parameter \"genre\" or \"artist\".");
        return null;
    }
    
    const playButtonStyle = {
        'border': 'none',
        'backgroundColor': 'transparent'
    };
    
    const getPlayer = () => {
        return document.getElementById('player');
    };

    const animationMethods = {
        start(index) {
            const gif = document.querySelectorAll('.playingIconColumn img')[index];
            gif.src = playGif;
        },

        stop(index) {
            const gif = document.querySelectorAll('.playingIconColumn img')[index];
            gif.src = blackPng;
        },

        pause(index) {
            const gif = document.querySelectorAll('.playingIconColumn img')[index];
            gif.src = pauseGif;
        }
    };
    
    const playButtonMethods = {
        setImage(index, image) {
            document.querySelectorAll('.playButtonColumn img')[index].src = image;
        },
        
        clicked(newIndex) {
            const player = getPlayer();
            console.log(`playbutton clicked (currentIndex = ${currentIndex}, newIndex = ${newIndex})`);
            if (newIndex === currentIndex) {
                console.log(`player.paused = ${player.paused}`);
                if (player.paused) {
                    this.playButtonClicked(newIndex);
                } else {
                    this.pauseButtonClicked(newIndex);
                }
            } else {
                this.playButtonClicked(newIndex);
            }
        },

        playButtonClicked(index) {
            const player = getPlayer();
            console.log('playButtonClicked');
            if (index === currentIndex) {
                player.play();
                playerMethods.play();
            } else {
                animationMethods.stop(currentIndex);
                this.setImage(currentIndex, playButtonPng);
                animationMethods.start(index);
                this.setImage(index, pauseButtonPng);
                setCurrentIndex(index);
                setAudioSrc(songs[index].file_url);
                setMimeType(songs[index].mime_type);
                player.autoplay = true;
            }
        },

        pauseButtonClicked(index) {
            console.log('pauseButtonClicked');
            const player = getPlayer();
            player.pause();
            playerMethods.pause();
        }
    };

    const playerMethods = {
        play() {
            console.log('playerMethod.play');
            animationMethods.start(currentIndex);
            playButtonMethods.setImage(currentIndex, pauseButtonPng);
            setAlbumName(songs[currentIndex].album_name);
            setArtistName(songs[currentIndex].artist_name);
            const dates = songs.filter(song => song.album_id === songs[currentIndex].album_id)
                  .filter(song => song.pub_date != null && song.pub_date > 0).map(song => song.pub_date);
            setAlbumDate(formatAlbumDate(dates));
            addHistory();
        },

        pause() {
            console.log('playerMethod.pause');
            if (getPlayer().ended) {
                animationMethods.stop(currentIndex);
            } else {
                animationMethods.pause(currentIndex);
            }
            playButtonMethods.setImage(currentIndex, playButtonPng);
        },
        
        prepared() {
            console.log('playerMethod.canPlayThrough');
            const player = getPlayer();
            if (player.autoplay) {
                console.log('onCanPlayThrough');
                player.play();
            }
        },

        ended() {
            const player = getPlayer();

            animationMethods.stop(currentIndex);
            playButtonMethods.setImage(currentIndex, playButtonPng);
            
            if (currentIndex < songs.length - 1) {
                console.log(`playerMethod.ended set currentIndex = ${currentIndex + 1}`);
                setCurrentIndex((currentIndex) => currentIndex + 1);
                playButtonMethods.playButtonClicked(currentIndex + 1);
                player.autoplay = true;
            } else {
                console.log('playerMethod.ended set currentIndex = 0');
                player.autoplay = false;
                setCurrentIndex(0);
            }
        }
    };

    function Artwork(props) {
        const normalStyle = {
            width: '400px',
            height: 'auto',
            position: 'relative',
            top: '0px',
            left: '0px',
            zIndex: 'inherit'
        };
        const modalStyle = {
            maxWidth: '80%',
            maxHeight: '80%',
            position: 'absolute',
            top: '10%',
            bottom: '10%',
            left: '10%',
            right: '10%',
            marginTop: 'auto',
            marginBottom: 'auto',
            marginLeft: 'auto',
            marginRight: 'auto',
            zIndex: '100'
        };
        const maskHiddenStyle = {
            display: 'none',
            zIndex: 'inherit'
        };
        const maskVisibleStyle = {
            display: 'block',
            width: '100%',
            height: '100%',
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            position: 'fixed',
            top: '0px',
            left: '0px',
            zIndex: '99'
        };
        const [ flag, setFlag ] = useState(false);
        const [ artworkStyle, setArtworkStyle ] = useState(normalStyle);
        const [ maskStyle, setMaskStyle ] = useState(maskHiddenStyle);
        function clickArtwork() {
            if (flag) {
                setArtworkStyle(normalStyle);
                setMaskStyle(maskHiddenStyle);
                setFlag(false);
            } else {
                setArtworkStyle(modalStyle);
                setMaskStyle(maskVisibleStyle);
                setFlag(true);
            }
        }
        return (
            <div>
                <div id="artwork-mask" style={maskStyle}></div>
                <img id="artwork" className="album-artwork img-thumbnail" onClick={clickArtwork} style={artworkStyle}
                     src={props.src} alt="song icon"/>
            </div>
        );
    }

    return (
        <div className="text-center" style={{display: displayValue}}>
            <h2>{appState.albumId != null ? albumName + albumDate : 'アーティスト: ' + artistName + artistDate}</h2>
            <p>{appState.albumId != null ? 'アーティスト: ' + artistName : albumName + albumDate}</p>
            <Artwork src={songs.length > currentIndex
                          ? (songs[currentIndex].artwork_url != null ? songs[currentIndex].artwork_url : noImagePngLarge)
                          : loadingGif}/>
            <audio
                id="player"
                controls
                src={audioSrc}
                type={mimeType}
                onPlay={playerMethods.play}
                onPause={playerMethods.pause}
                onCanPlayThrough={playerMethods.prepared}
                onEnded={playerMethods.ended}>
                あなたのブラウザーはオーディオ要素をサポートしていません。
            </audio>
            <table className="table table-borderless text-white">
                <thead>
                    <tr style={tableHeaderRowStyle}>
                        <th scope="col"></th>
                        <th scope="col">#</th>
                        <th scope="col"></th>
                        <th className="text-left">タイトル</th>
                        <th className="text-right" scope="col">再生時間</th>
                        <th className="text-left" scope="col">形式</th>
                    </tr>
                </thead>
                <tbody>
                    {songs.map((songData, index) => (
                        <tr style={tableRowStyle} key={songData.song_id.substring(0, 8)}>
                            <td className="playingIconColumn p-0 align-middle">
                                <img src={blackPng} className="m-0" width="48px" height="48px" alt="再生"/>
                            </td>
                            <td className="text-body numberColumn m-0 align-middle">{index + 1}</td>
                            <td className="playButtonColumn p-0 align-middle">
                                <button style={playButtonStyle} onClick={() => playButtonMethods.clicked(index)}>
                                    <img className="m-0" src={playButtonPng} alt="再生"/>
                                </button>
                            </td>
                            <td className="songTitleColumn text-start">
                                <h4 className="text-body">{songData.title}</h4>
                                <span className="song-list-artist-name text-body">
                                    <LinkButton onClick={() => viewSwitcher.showAlbums({requestType: 'artist-albums', artistId: songData.artist_id})}>
                                        {songData.artist_name}
                                    </LinkButton>
                                    {appState.hasOwnProperty("artistId")
                                     ? <span>: <LinkButton onClick={() => viewSwitcher.showSongs({albumId: songData.album_id})}>{songData.album_name}</LinkButton></span>
                                     : <span></span>}
                                    <span>{(songData.pub_date != null && Number(songData.pub_date) > 0) ? ' (' + songData.pub_date + ')' : ''}</span>
                                </span>
                            </td>
                            <td className="songTimeColumn text-right align-middle text-body">{songData.time_length}</td>
                            <td className="songTypeColumn text-left align-middle text-body">{songData.mime_type}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
