import React, { useState, useEffect, useContext, useRef } from 'react';
import './Songs.css';
import loadingGif from './images/loading.gif';
import noImagePngLarge from './images/empty-image200.png';
import blackPng from './images/black48.png';
import playGif from './images/playing.gif';
import pauseGif from './images/pausing.gif';
import playButtonPng from './images/play-button.png';
import pauseButtonPng from './images/pause-button.png';
import ViewContext from './ViewContext.js';
import Button from 'react-bootstrap/Button';

function formatTimeLength(timeLengthMillisec) {
  const milliSec = timeLengthMillisec % 1000;
  const allSeconds = Math.round(timeLengthMillisec / 1000);
  const seconds = allSeconds % 60;
  const allMinutes = Math.floor(allSeconds / 60);
  const minutes = allMinutes % 60;
  const hours = Math.floor(allMinutes / 60);
  if (hours > 0) {
    return String(hours) + ':' + String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
  } else {
    return String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
  }
}

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

export default function Songs() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const playerRef = useRef(null);
  const [ songs, setSongs ] = useState([]);
  const [ audioSrc, setAudioSrc ] = useState('');
  const [ currentIndex, setCurrentIndex ] = useState(0);
  //const [ albumDate, setAlbumDate ] = useState('');
  //const [ artistDate, setArtistDate ] = useState('');
  const [ mimeType, setMimeType ] = useState('audio/mpeg');
  const displayValue = appState.visible.songs ? 'block' : 'none';
  const playedSongs = [];
  const baseUrl = `http://${appConfig?.apiHost}:${appConfig?.apiPort}`;
  console.log("get songs appState: " + JSON.stringify(appState));

  useEffect(() => {
    const fetchData = async () =>  {
      if (appState.album != null || appState.artist != null) {
        let url;
        if (appState.album != null) {
          url = `${baseUrl}${appState.album.songs}`;
        } else if (appState.artist != null) {
          url = `${baseUrl}${appState.artist.songs}`;
        } else {
          return;
        }
        const songsResponse = await fetch(url);
        if (!songsResponse.ok) {
          console.log(songsResponse.text);
          return;
        }
        const songsJson = await songsResponse.json();
        const songList = songsJson.songs;
        for (let i = 0; i < songList.length; i++) {
          try {
            const song = songList[i];
            if (appState.album != null) {
              try {
                const artistResponse = await fetch(`${baseUrl}${song.artists}`);
                const artistJson = await artistResponse.json();
                song.artists = artistJson.artists;
              } catch (err) {
                console.log(err);
                song.artists = [];
              }
            }
            if (appState.artist != null) {
              try {
                const albumResponse = await fetch(`${baseUrl}${song.albums}`);
                const albumJson = await albumResponse.json();
                song.albums = albumJson.albums;
              } catch (err) {
                song.albums = [];
              }
            }
            try {
              const genresResponse = await fetch(`${baseUrl}${song.genres}`);
              const genresJson = await genresResponse.json();
              song.genres = genresJson.genres;
            } catch (err) {
              song.genres = [];
            }
          } catch (err) {
            console.log(err);
            songList[i].artists = [];
            songList[i].albums = [];
            songList[i].genres = [];
          }
        }
        setSongs(songList);
        setAudioSrc(`${baseUrl}${songsJson.songs[0].stream}`);
        setMimeType(songsJson.songs[0].mimeType);
      }
    };
    fetchData();
  }, [appConfig, appState]);

  async function addHistory() {
    console.log(audioSrc);
    if (playedSongs.includes(audioSrc)) {
      return;
    } else {
      playedSongs.push(audioSrc);
    }
    if (audioSrc !== '') {
      try {
        const audioSrcUrl = new URL(audioSrc);
        const songId = songs[currentIndex].songId;
        const url = `${baseUrl}/api/v2/history/${songId}`;
        console.log(url);
        const historyRes = await fetch(url, {method: "POST"});
        const historyJson = await historyRes.json();
        console.log("result: " + JSON.stringify(historyJson));
      } catch (error) {
        console.log(error);
      }
    }
  }

  const playButtonStyle = {
    'border': 'none',
    'backgroundColor': 'transparent'
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
      const player = playerRef.current;
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
      const player = playerRef.current;
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
        setAudioSrc(baseUrl + songs[index].stream);
        setMimeType(songs[index].mimeType);
        player.autoplay = true;
      }
    },

    pauseButtonClicked(index) {
      console.log('pauseButtonClicked');
      const player = playerRef.current;
      player.pause();
      playerMethods.pause();
    }
  };

  const playerMethods = {
    play() {
      console.log('playerMethod.play');
      animationMethods.start(currentIndex);
      playButtonMethods.setImage(currentIndex, pauseButtonPng);
      //setAlbumName(appState.album.albumName);
      //setArtistName(songs[currentIndex].artist_name);
      //const dates = songs.filter(song => song.album_id === songs[currentIndex].album_id)
      //    .filter(song => song.pub_date != null && song.pub_date > 0).map(song => song.pub_date);
      //setAlbumDate(formatAlbumDate(dates));
      addHistory();
    },

    pause() {
      console.log('playerMethod.pause');
      if (playerRef.current.ended) {
        animationMethods.stop(currentIndex);
      } else {
        animationMethods.pause(currentIndex);
      }
      playButtonMethods.setImage(currentIndex, playButtonPng);
    },
    
    prepared() {
      console.log('playerMethod.canPlayThrough');
      const player = playerRef.current;
      if (player.autoplay) {
        console.log('onCanPlayThrough');
        player.play();
      }
    },

    ended() {
      const player = playerRef.current;

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
      height: '400px',
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
      <h2>{
        appState.album != null
          ? appState.album?.albumName /* + albumDate*/
          : 'アーティスト: ' + appState.artist?.artistName /* + artistDate*/
      }</h2>
      {appState.album != null
       ? <>
           <span>{'アーティスト: '}
             <Button variant="link" onClick={() => viewSwitcher.showAlbums({requestType: 'artist-albums', artist: appState.artist})}>
               {appState.artist?.artistName}
             </Button>
           </span>
           <span>{'ジャンル: '}
             <Button variant="link" onClick={() => viewSwitcher.showAlbums({genre: appState.genre})}>
               {appState.genre?.genreName}
             </Button>
           </span>
         </>
       : <p>{appState.album?.albumName}</p> /* + albumDate */
      }
      <Artwork src={songs.length > currentIndex
                    ? (songs[currentIndex].artwork != null ?
                       `http://${appConfig.apiHost}:${appConfig.apiPort}${songs[currentIndex].artwork}` : noImagePngLarge)
                    : loadingGif}/>
      {songs != null ?
       <audio
         id="player"
         controls
         ref={playerRef}
         src={audioSrc}
         type={mimeType}
         onPlay={playerMethods.play}
         onPause={playerMethods.pause}
         onCanPlayThrough={playerMethods.prepared}
         onEnded={playerMethods.ended}>
         あなたのブラウザーはオーディオ要素をサポートしていません。
       </audio>
       : <></>}
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
          {songs.map((song, index) => (
            <tr style={tableRowStyle} key={song.songId}>
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
                <h4 className="text-body">{song.title}</h4>
                <span className="song-list-artist-name text-body">
                  {appState.album != null &&
                   song.artists.map(artist =>
                     <Button variant="link" onClick={() => viewSwitcher.showAlbums({requestType: 'artist-albums', artist: artist})}>
                       <span className="h6">{artist.artistName}</span>
                     </Button>
                   )}
                  {song.genres.map((genre) => 
                     <Button variant="link" key={genre.genreId} onClick={() => viewSwitcher.showAlbums({genre: genre})}>
                       <span className="h6">{genre.genreName}</span>
                     </Button>
                   )}
                  {appState.album == null &&
                   song.albums.map((albumData, index) => 
                     <Button variant="link" key={albumData.albumId} onClick={() => viewSwitcher.showSongs({album: albumData})}>
                       {albumData.albumName}
                     </Button>
                   )}
                </span>
              </td>
              <td className="songTimeColumn text-right align-middle text-body"f>{formatTimeLength(song.timeLengthMilliseconds)}</td>
              <td className="songTypeColumn text-left align-middle text-body">{song.mimeType}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
