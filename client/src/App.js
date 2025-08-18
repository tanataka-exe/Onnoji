import React, { useState, useEffect, useRef } from 'react';
import Optional from "./Optional.js";
import useMediaQuery from "./useMediaQuery.js";
import UploadDialog from "./UploadDialog.js";
import goPreviousIcon from "./images/go-previous-symbolic.svg";
import sidebarShowIcon from "./images/sidebar-show-symbolic.svg";
import closeButtonIcon from "./images/application-exit-symbolic.svg";
import openMenuIcon from "./images/open-menu-symbolic.svg";
import "./App.css";
import "./App-narrow.css";
import "./App-middle.css";
import "./App-wider.css";
import playGif from "./images/playing.gif";
import pauseGif from "./images/pausing.gif";
import MessageBox from './MessageBox.js';

const Consts = {
  WINDOW_MIDDLE_WIDTH: 650,
  WINDOW_WIDE_WIDTH: 1000,
  LEFT_PANE_WIDE_WIDTH: "30%",
  LEFT_PANE_WIDE_MIN_WIDTH: "300px",
  LEFT_PANE_MIDDLE_WIDTH: "350px",
  LEFT_PANE_NARROW_WIDTH: "70%",
  CENTER_PANE_WIDE_WIDTH: "70%",
  CENTER_PANE_WIDE_MIN_WIDTH: "350px",
  CENTER_PANE_MIDDLE_WIDTH: "40%",
  CENTER_PANE_MIDDLE_MIN_WIDTH: "350px",
  CENTER_PANE_NARROW_WIDTH: "100%",
  RIGHT_PANE_WIDE_WIDTH: "100%",
  RIGHT_PANE_MIDDLE_WIDTH: "100%",
  RIGHT_PANE_NARROW_WIDTH: "100%",
  PAGE_TRANSITION: "0.2s",
  PLAYER_PANEL_HEIGHT: "116px",

  darkMaskZIndex: {
    LEFT_PANE_SHOWING: 9,
    DIALOG_SHOWING: 50,
    MESSAGE_SHOWING: 60
  },
  
  darkMaskStyle: {
    SHOWN: {
      display: "block",
      zIndex: 9, /* Consts.darkMaskZIndex.LEFT_PANE_SHOWING */
      position: "fixed",
      width: "100%",
      height: "100%",
      left: "0",
      top: "0",
      backgroundColor: "rgba(0.0, 0.0, 0.0, 0.5)"
    },
    HIDDEN: {
      display: "none"
    }
  }
}

function formatTimeLengthMillis(timeLengthMillis) {
  const hours = Math.floor(timeLengthMillis / 1000 / 60 / 60);
  const minutes = Math.floor(timeLengthMillis / 1000/ 60 % 60);
  const seconds = Math.floor(timeLengthMillis / 1000 % 60);
  if (hours > 0) {
    return `${hours}:${minutes}:${seconds}`;
  } else {
    return `${minutes}:${seconds}`
  }
}

export default function App() {
  // media query.
  const isWide = useMediaQuery("(width >= 1000px)");
  const isMid = useMediaQuery("(width >= 650px) and (width < 1000px)");
  const isNarrow = useMediaQuery("(width < 650px)");
  
  // State.
  const [ songListEventIndex, setSongListEventIndex ] = useState(-1);
  const [ currentIndex, setCurrentIndex ] = useState(0);
  const [ appConfig, setAppConfig ] = useState(null);
  const [ genres, setGenres ] = useState([]);
  const [ centerPaneTitle, setCenterPaneTitle ] = useState("");
  const [ rightPaneTitle, setRightPaneTitle ] = useState("");
  const [ albumList, setAlbumList ] = useState([]);
  const [ currentGenre, setCurrentGenre ] = useState("");
  const [ selectedAlbum, setSelectedAlbum ] = useState({});
  const [ songs, setSongs ] = useState([]);
  const [ audioSrc, setAudioSrc ] = useState(null);
  const [ mimeType, setMimeType ] = useState(null);
  const [ recentlyAddedAlbumCount, setRecentlyAddedAlbumCount ] = useState(0);

  // Player State.
  const [ panelOpen, setPanelOpen ] = useState(false);
  const [ progress, setProgress ] = useState(0); // 0..1
  const [ currentPlaylistId, setCurrentPlaylistId ] = useState(-1);
  const [ currentPlaylist, setCurrentPlaylist ] = useState({});
  const [ currentPlayingIndex, setCurrentPlayingIndex ] = useState(-1);

  // Styles (panes).
  const [ leftPaneStyle, setLeftPaneStyle ] = useState({});
  const [ centerPaneStyle, setCenterPaneStyle ] = useState({});
  const [ rightPaneStyle, setRightPaneStyle ] = useState({});
  const [ lightMaskStyle, setLightMaskStyle ] = useState({display: "none"});

  // Styles (header buttons).
  const [ leftCloseButtonStyle, setLeftCloseButtonStyle ] = useState({});
  const [ centerSidebarShowButtonStyle, setCenterSidebarShowButtonStyle ] = useState({});
  const [ rightReturnButtonStyle, setRightReturnButtonStyle ] = useState({});
  const [ sidemenuOpen, setSidemenuOpen ] = useState(false);
  const [ sidemenuStyle, setSidemenuStyle ] = useState({});

  // Styles (parts).
  const [ darkMaskStyle, setDarkMaskStyle ] = useState(Consts.darkMaskStyle.HIDDEN);
  const [ rightContentStyle, setRightContentStyle ] = useState({});
  const [ genreListStyle, setGenreListStyle ] = useState({display:"block"});
  const [ moreAlbumsButtonStyle, setMoreAlbumsButtonStyle ] = useState({display:"none"});
  const [ isUploadDialogShowing, setUploadDialogShowing ] = useState(false);

  // Refs.
  const playerRef = useRef(null);
  const albumListRef = useRef(null);
  const songListRef = useRef(null);
  const songArtworkRef = useRef(null);

  const leftPaneRef = useRef(null);
  const centerPaneRef = useRef(null);
  const rightPaneRef = useRef(null);
  const playerPanelRef = useRef(null);
  const sidemenuButtonRef = useRef(null);

  const darkMaskRef = useRef(null);
  
  // Message Box
  const [ showMessage, setShowMessage ] = useState(false);
  const [ messageBoxText, setMessageBoxText ] = useState("");
  
  function showLeftPane(isOpen) {
    if (isOpen) {
      if (isMid) {
        setLeftPaneStyle({width: Consts.LEFT_PANE_MIDDLE_WIDTH});
        setDarkMaskStyle(Consts.darkMaskStyle.SHOWN);
      } else if (isNarrow) {
        setLeftPaneStyle({width: Consts.LEFT_PANE_NARROW_WIDTH});
        setDarkMaskStyle(Consts.darkMaskStyle.SHOWN);
      }
    } else {
      if (isNarrow || isMid) {
        setLeftPaneStyle({width: 0});
        setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
      }
    }
  }
  
  function showCenterPane(isOpen) {
    if (isOpen) {
      if (isNarrow) {
        setCenterPaneStyle({width: Consts.CENTER_PANE_NARROW_WIDTH});
        setRightPaneStyle({width: 0});
      }
    } else {
      if (isNarrow) {
        setCenterPaneStyle({width: 0});
        setRightPaneStyle({width: Consts.RIGHT_PANE_NARROW_WIDTH});
      }
    }
  }

  // ここでモードを切り替えてJS処理を走らせる
  useEffect(() => {
    const mode = isWide ? "wide" : isMid ? "mid" : isNarrow ? "narrow" : null;
    if (mode === "wide") {
      console.log("wide");
      setLeftPaneStyle({});
      setCenterPaneStyle({});
      setRightPaneStyle({});
      setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
      setLeftCloseButtonStyle({
        display: "none"
      });
      setCenterSidebarShowButtonStyle({
        display: "none",
        border: "none",
      });
      setRightReturnButtonStyle({
        display: "none"
      });
    } else if (mode === "mid") {
      console.log("mid");
      setLeftPaneStyle({});
      setCenterPaneStyle({});
      setRightPaneStyle({});
      setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
      setLeftCloseButtonStyle({
        display: "block"
      });
      setCenterSidebarShowButtonStyle({
        display: "block",
        border: "none",
        backgroundColor: "inherit",
        display: "flex",
        alignItems: "center"
      });
      setRightReturnButtonStyle({
        display: "none"
      });
      if (centerPaneTitle == "") {
        showLeftPane(true);
      }
    } else if (mode === "narrow") {
      console.log("narrow");
      setLeftPaneStyle({});
      setCenterPaneStyle({});
      setRightPaneStyle({});
      setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
      setLeftCloseButtonStyle({
        display: "block"
      });
      setCenterSidebarShowButtonStyle({
        display: "block",
        border: "none",
        backgroundColor: "inherit",
        display: "flex",
        alignItems: "center"
      });
      setRightReturnButtonStyle({
        display: "grid"
      });
      if (rightPaneTitle == "") {
        showCenterPane(true);
      }
      if (centerPaneTitle == "") {
        showLeftPane(true);
      }
    }
  }, [isWide, isMid, isNarrow]);

  /* Fetch application configuration from server */
  useEffect(() => {
    const loadAppConfig = async () => {
      const response = await fetch('/config.json');
      if (response.ok) {
        setAppConfig(await response.json());
      } else {
        console.log("config is not found!");
      }
    };

    loadAppConfig();
  }, []);
  
  useEffect(() => {
    const a = playerRef.current;
    if (!a) return;

    const onTime = () => {
      if (!a.duration || !isFinite(a.duration)) {
        return;
      }
      setProgress(a.currentTime / a.duration);
    };
    const onPlay = () => {
      setPanelOpen(true);
    };

    a.addEventListener("timeupdate", onTime);
    a.addEventListener("play", onPlay);

    return () => {
      a.removeEventListener("timeupdate", onTime);
      a.removeEventListener("play", onPlay);
    };
  }, []);

  useEffect(() => {
    if (playerPanelRef.current) {
      const ro = new ResizeObserver(() => {
        const h = playerPanelRef.current?.offsetHeight ?? 0;
        document.documentElement.style.setProperty('--player-h', `${h}px`);
      });
      ro.observe(playerPanelRef.current);
      return () => ro.disconnect();
    }
  }, []);

  /* Fetch genre list */
  useEffect(() => {
    if (appConfig === null) {
      return;
    }
    const fetchData = async () => {
      const response = await fetch(`http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/genres`);
      if (response.ok) {
        const json = await response.json();
        setGenres(json.genres);
      } else {
        console.log(await response.text());
      }
    };
    fetchData();
  }, [appConfig]);

  useEffect(() => {
    if (sidemenuOpen) {
      setSidemenuStyle({
        display: "block",
      });
      const rect = sidemenuButtonRef.current.getBoundingClientRect();
      setLightMaskStyle({
        display: "block"
      });
      document.documentElement.style.setProperty('--side-menu-top', `${rect.bottom + 1}px`);
      document.documentElement.style.setProperty('--side-menu-left', `${rect.left + 1}px`);
    } else {
      setSidemenuStyle({
        display: "none"
      });
      setLightMaskStyle({
        display: "none"
      });
    }
  }, [sidemenuOpen]);
  
  async function arrangeAlbumList(albums) {
    for (let album of albums) {
      const artistRes = await fetch(
        `http://${appConfig.apiHost}:${appConfig.apiPort}${album.artists}`
      );
      if (artistRes.ok) {
        const artistJson = await artistRes.json();
        if (artistJson.artists.length > 0) {
          album.artists = artistJson.artists;
        } else {
          album.artists = null;
        }
      } else {
        console.log(await artistRes.text());
      }
    }
  }
  
  /* Fetch album list which are contained in the selected genre */
  useEffect(() => {
    if (!appConfig || !currentGenre) {
      return;
    }
    const fetchData = async () => {
      console.log("Genre " + currentGenre.genreName + " was selected");
      const response = await fetch(
        `http://${appConfig.apiHost}:${appConfig.apiPort}${currentGenre.albums}`
      );
      if (response.ok) {
        const json = await response.json();
        const albums = json.albums;
        await arrangeAlbumList(albums);
        setAlbumList(albums);
      } else {
        console.log(await response.text());
      }
    };
    setMoreAlbumsButtonStyle({"display":"none"});
    setRecentlyAddedAlbumCount(0);
    fetchData();
  }, [appConfig, currentGenre]);

  /* Fetch song list which are contained in the selected playlist */
  useEffect(() => {
    if (!appConfig || !selectedAlbum) {
      return;
    }
    const fetchData = async () => {
      console.log(selectedAlbum);
      const songsRes = await fetch(
        `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/playlist/${selectedAlbum.albumId}/songs`
      );
      
      if (songsRes.ok) {
        const songsJson = await songsRes.json();
        for (const song of songsJson.songs) {
          const artistsRes = await fetch(
            `http://${appConfig.apiHost}:${appConfig.apiPort}${song.artists}`
          );
          if (artistsRes.ok) {
            const artistsJson = await artistsRes.json();
            song.artists = artistsJson.artists;
          } else {
            song.artists = null
          }
          
          const genresRes = await fetch(
            `http://${appConfig.apiHost}:${appConfig.apiPort}${song.genres}`
          );
          const genresJson = await genresRes.json();
          song.genres = genresJson.genres;
        }
        
        setSongs(songsJson.songs);
        
        setRightContentStyle({
          backgroundImage:
          `url(http://${appConfig.apiHost}:${appConfig.apiPort}${songsJson.songs[0].artwork})`
        });

      }
    };
    
    fetchData();
  }, [appConfig, selectedAlbum]);

  useEffect(() => {
    if (selectedAlbum.albumId === currentPlaylistId) {
      for (const sibling of songListRef.current.children) {
        sibling.style.backgroundColor = null;
      }
      console.log("selectedAlbum.albumId === currentPlaylistId:");
      console.log(`  ${selectedAlbum.albumId} === ${currentPlaylistId}`);
      if (selectedAlbum.albumId === currentPlaylistId
          && currentPlayingIndex >= 0
          && songListRef.current.children.length > currentPlayingIndex) {
        songListRef.current.children[currentPlayingIndex].style.backgroundColor
          = "rgba(0.5, 0.5, 0.5, 0.2)";
      }
    }
  }, [songs]);
  
  useEffect(() => {
    if (panelOpen) {
      leftPaneRef.current.classList.add("panel-padding-added");
      centerPaneRef.current.classList.add("panel-padding-added");
      rightPaneRef.current.classList.add("panel-padding-added");
    } else {
      leftPaneRef.current.classList.remove("panel-padding-added");
      centerPaneRef.current.classList.remove("panel-padding-added");
      rightPaneRef.current.classList.remove("panel-padding-added");
    }
  }, [panelOpen]);
  
  // 進捗バーでシーク
  const onSeek = (v) => {
    const a = playerRef.current;
    if (!a || !a.duration) return;
    a.currentTime = v * a.duration;
    setProgress(v);
  };

  // 再生/一時停止、前後スキップ（雛形）
  const onToggle = () => {
    const a = playerRef.current;
    if (!a) return;
    if (a.paused) a.play().catch(()=>{});
    else a.pause();
  };
  
  const onPrev = () => {
    playerMethods.prev();
  };
  
  const onNext = () => {
    playerMethods.next();
  };
  
  useEffect(() => {
    if (audioSrc != null) {
      const audioReload = async () => {
        try {
          playerRef.current.pause();
          playerRef.current.load();
          await playerRef.current.play();
        } catch (e) {
          if (e.name === "NotAllowedError") {
            console.log("NotAllowedError");
          }
        }
      };
      audioReload();
    }
  }, [audioSrc]);

  useEffect(() => {
    console.log("setCurrentPlayingIndex(-1)");
    setCurrentPlayingIndex(-1);
  }, [currentPlaylistId]);
  
  useEffect(() => {
  }, [currentPlaylist]);

  useEffect(() => {
    if (currentPlayingIndex >= 0) {
      for (const sibling of songListRef.current.children) {
        sibling.style.backgroundColor = null;
      }
      songListRef.current.children[currentPlayingIndex].style.backgroundColor
        = "rgba(0.5, 0.5, 0.5, 0.2)";
      setPanelOpen(true);
      setAudioSrc(`http://${appConfig.apiHost}:${appConfig.apiPort}${currentPlaylist[currentPlayingIndex].stream}`);
    }
  }, [currentPlaylistId, currentPlayingIndex]);

  function onSidemenuButtonClicked() {
    setSidemenuOpen(!sidemenuOpen);
  }
  
  function onRecentlyAddedAlbumClicked() {
    setCenterPaneTitle("最近追加したアルバム");
    setRecentlyAddedAlbumCount(20);
  }

  useEffect(() => {
    if (!appConfig) {
      return;
    }
    if (recentlyAddedAlbumCount === 0) {
      return;
    }
    const fetchData = async () => {
      const res = await fetch(
        `http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/recently-registered/1-${recentlyAddedAlbumCount}/albums`
      );
      if (res.ok) {
        const json = await res.json();
        const albums = json.albums;
        await arrangeAlbumList(albums);
        setAlbumList(albums);
        if (isNarrow) {
          setLeftPaneStyle({width: 0});
        } else if (isMid) {
          setLeftPaneStyle({width: 0});
        }
        setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
      }
    };
    setMoreAlbumsButtonStyle({"display":"block"});
    fetchData();
  }, [recentlyAddedAlbumCount]);

  function moreRecentlyAddedAlbums() {
    setRecentlyAddedAlbumCount(recentlyAddedAlbumCount + 20);
  }

  function onUploadButtonClicked() {
    setSidemenuOpen(false);
    displayUploadDialog();
  }

  function displayUploadDialog() {
    setDarkMaskStyle({
      ...Consts.darkMaskStyle.SHOWN,
      zIndex: Consts.darkMaskZIndex.DIALOG_SHOWING
    });
    setUploadDialogShowing(true);
  }

  function closeUploadDialog() {
    if (isWide) {
      setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
    } else {
      setDarkMaskStyle(Consts.darkMaskStyle.SHOWN);
    }
    setUploadDialogShowing(false);
  }
  
  function onPlaylistButtonClicked() {

  }
  
  function onGenreLabelClicked() {
    console.log("genre label was cliecked.");
    setGenreListStyle({
      display: (genreListStyle.display === "none" ? "block" : "none")
    });
  }
  
  function onGenreClicked(genre) {
    if (!genre || !genre.genreName) {
      return;
    }
    setCenterPaneTitle(genre.genreName + "のアルバム");
    setCurrentGenre(genre);
    if (isNarrow) {
      setLeftPaneStyle({width: 0});
    } else if (isMid) {
      setLeftPaneStyle({width: 0});
    }
    setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
  }

  function onAlbumClicked(e, album) {
    try {
      setSelectedAlbum(album);
      setRightPaneTitle(`アルバム: ${album.albumName}`);
      const targetListItem = e.currentTarget.parentElement;
      for (const listItem of albumListRef.current.children) {
        if (listItem.id === targetListItem.id) {
          if (!listItem.classList.contains("selected")) {
            listItem.classList.add("selected");
          }
        } else if (listItem.classList.contains("selected")) {
          listItem.classList.remove("selected");
        }
      }
      showCenterPane(false);
    } catch (e) {
      console.log("Error!");
    }
  }

  function onSidebarButtonClicked() {
    showLeftPane(true);
  }

  function onPreviousButtonClicked() {
    showCenterPane(true);
  }

  function onLeftCloseButtonClicked() {
    showLeftPane(false);
  }

  function onDarkMaskClicked() {
    if (isNarrow || isMid) {
      if (darkMaskStyle.zIndex == Consts.darkMaskZIndex.LEFT_PANE_SHOWING) {
        showLeftPane(false);
      }
    }
  }
  
  const songListMethods = {
    onMouseEnter: (e, index) => {
    },

    onMouseLeave: (e, index) => {
      setSongListEventIndex(-1);
    },

    onMouseDown: (e, index) => {
      setSongListEventIndex(index);
    },

    onMouseUp: (e, index) => {
      if (songListEventIndex >= 0) {
        for (const sibling of songListRef.current.children) {
          sibling.classList.remove("selected");
        }
        e.currentTarget.classList.add("selected");
        setCurrentPlaylistId(selectedAlbum.albumId);
        setCurrentPlaylist(JSON.parse(JSON.stringify(songs)));
        setTimeout(() => {
          playerRef.current.autoplay = true;
          setCurrentPlayingIndex(index);
          console.log("song was selected.");
        }, 0);
      }
      setSongListEventIndex(-1);
    }
  };
  
  const playerMethods = {
    play: () => {
      console.log('playerMethod.play');
      //addHistory();
    },

    prev: () => {
      if (currentPlayingIndex > 0) {
        setCurrentPlayingIndex(currentPlayingIndex => currentPlayingIndex - 1);
      }
    },

    next: () => {
      this.ended();
    },
    
    pause: () => {
      console.log('playerMethod.pause');
    },
    
    prepared: () => {
    },

    ended: () => {
      console.log("music ended");
      console.log("currentPlayingIndex < currentPlaylist.length - 1");
      console.log(`  ${currentPlayingIndex} < ${currentPlaylist.length - 1}`);
      if (currentPlayingIndex < (currentPlaylist.length - 1)) {
        console.log(`playerMethod.ended set currentIndex = ${currentIndex + 1}`);
        setCurrentPlayingIndex(currentPlayingIndex => currentPlayingIndex + 1);
      } else {
        console.log('playerMethod.ended set currentIndex = 0');
        setCurrentPlayingIndex(-1);
      }
    }
  };
  
  async function addHistory() {
    try {
      const songId = currentPlaylist[currentPlayingIndex].songId;
      const historyRes = await fetch(`http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/history/${songId}`, {method: "POST"});
      const historyJson = await historyRes.json();
      console.log("addHistory result: " + JSON.stringify(historyJson));
    } catch (error) {
      console.log("ERROR: " + JSON.stringify(error));
    }
  }

  function onMouseDownMenuMask() {
    if (sidemenuOpen) {
      setSidemenuOpen(false);
    }
  }

  function showMessageBox(message) {
    setDarkMaskStyle({...Consts.darkMaskStyle.SHOWN, zIndex: Consts.darkMaskZIndex.MESSAGE_SHOWING});
    setMessageBoxText(message);
    setShowMessage(true);
  }

  function closeMessageBox() {
    setShowMessage(false);
    if (isUploadDialogShowing) {
      setDarkMaskStyle({...Consts.darkMaskStyle.SHOWN, zIndex: Consts.darkMaskZIndex.DIALOG_SHOWING});
    } else {
      setDarkMaskStyle(Consts.darkMaskStyle.HIDDEN);
    }
  }
  
  return (
    <>
      <div className="app-main" style={{height:"100%"}}>
        <div id="left-pane" className="left-pane" style={leftPaneStyle} ref={leftPaneRef}>
          <div className="header">
            <div id="left-header-left-button">
              <h1>音之時 ~Onnoji~</h1>
            </div>
            <div>
            </div>
            <div id="left-header-right-button">
              <button id="sidebar-menu-button" onClick={onSidemenuButtonClicked} ref={sidemenuButtonRef}>
                <img src={openMenuIcon} alt="三"/>
              </button>
              <button id="sidebar-close-button" onClick={onLeftCloseButtonClicked} style={leftCloseButtonStyle}>
                <img src={closeButtonIcon} alt="X"/>
              </button>
            </div>
          </div>
          <div className="left-pane-contentarea">
            <h2>
              <button id="playlist-show-button" className="header-button" onClick={onPlaylistButtonClicked}>
                プレイリスト
              </button>
            </h2>
            <h2>
              <button id="recently-added-album-button" className="header-button"
                      onClick={onRecentlyAddedAlbumClicked}>
                最近追加したアルバム
              </button>
            </h2>
            <h2><button id="genre-button" className="header-button"
                        onClick={onGenreLabelClicked}>ジャンル</button></h2>
            <ul className="genre-list" style={genreListStyle}>
              {genres.map(genre => (
                <li key={genre.genreId}>
                  <button className="genre-button" onClick={() => onGenreClicked(genre)}>
                    {genre.genreName}
                  </button>
                  <span style={{display:"none"}}>{JSON.stringify(genre)}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
        <div id="center-pane" className="center-pane" style={centerPaneStyle} ref={centerPaneRef}>
          <div className="header">
            <div id="center-header-left-button">
              <button id="center-header-sidebar-show-button" onClick={onSidebarButtonClicked}
                      style={centerSidebarShowButtonStyle}>
                <img src={sidebarShowIcon} style={{height:"16px",width:"16px"}} alt="<>"/>
              </button>
            </div>
            <div>
              <h2>{centerPaneTitle}</h2>
            </div>
            <div id="center-header-right-button">
            </div>
          </div>
          <div className="center-pane-contentarea">
            <Optional if={albumList != null}>
              <ul ref={albumListRef} className="playlist-list">
                {albumList.map(album => (
                  <li id={`album-${album.albumId}`}
                      key={album.albumId} className="">
                    <button className="playlist-button" onClick={(e) => onAlbumClicked(e, album)}>
                      <img className="playlist-artwork" alt="artwork"
                           src={`http://${appConfig.apiHost}:${appConfig.apiPort}${album.artwork}`}/>
                      <div>
                        <h3>{album.albumName}</h3>
                        <h4>
                          {album.artists?.map(artist => artist.artistName).slice(0,5).join(", ")}
                          {album.artists?.length >= 5 ? ", etc." : null}
                        </h4>
                        {/*TODO:<h4>{album.pubDate}</h4>*/}
                      </div>
                    </button>
                    <span style={{display:"none"}}>{JSON.stringify(album)}</span>
                  </li>
                ))}
              </ul>
              <button className="more-albums-button" style={moreAlbumsButtonStyle} onClick={moreRecentlyAddedAlbums}>{"+"}</button>
            </Optional>
          </div>
        </div>
        <div id="right-pane" className="right-pane" style={rightPaneStyle} ref={rightPaneRef}>
          <div className="header">
            <div id="right-header-left-buttons">
              <button id="right-pane-return-button" onClick={onPreviousButtonClicked} style={rightReturnButtonStyle}>
                <img src={goPreviousIcon} alt="<"/>
              </button>
            </div>
            <div>
              <h2>{rightPaneTitle}</h2>
            </div>
            <div id="right-header-right-buttons">
            </div>
          </div>
          <div className="right-pane-contentarea" style={rightContentStyle}>
            <Optional if={songs != null && songs.length > 0}>
              <div className="background-mask">
                <div className="song-artwork-container">
                  <img className="song-artwork" ref={songArtworkRef} alt="song"
                       src={songs != null && songs.length > 0
                            ? `http://${appConfig.apiHost}:${appConfig.apiPort}${songs[0].artwork}`
                            : null}/>
                </div>
                <div className="song-table" style={{display:"flex",flexDirection:"column",gap:"3px"}} ref={songListRef}>
                  {songs.map((song, index) => (
                    <div key={song.songId ?? index} id={`song-${song.songId}`}
                         className={`song-list-item${song.songId === currentPlaylist[currentPlayingIndex]?.songId ? " selected" : ""}`}
                         onMouseEnter={(e) => songListMethods.onMouseEnter(e, index)}
                         onMouseLeave={(e) => songListMethods.onMouseLeave(e, index)}
                         onMouseDown={(e) => songListMethods.onMouseDown(e, index)}
                         onMouseUp={(e) => songListMethods.onMouseUp(e, index)}>
                      <div className="song-track-number" style={{flexGrow:0}}>
                        <h3>{index + 1}</h3>
                      </div>
                      <div style={{flexGrow:4}}>
                        <h3 className="song-title">{song.title}</h3>
                        <div className="song-artists">
                          {song.artists != null
                           ? (song.artists.map(artist => artist.artistName).slice(0,3).join(", "))
                           : "unknown artists"}
                          {song.artists != null && song.pubDate != null ? ' ' : null}
                          {song.pubDate != null ? ("(" + song.pubDate + ")") : null}
                        </div>
                        <span style={{display:"none"}}>{JSON.stringify(song)}</span>
                      </div>
                      <div>
                        {currentPlaylistId === selectedAlbum.albumId && currentPlayingIndex === index
                         ? <img src={!playerRef.current.paused ? playGif : pauseGif} height="22px" width="22px"/>
                         : null}
                      </div>
                      <div className="song-length" style={{flexGrow:0}}>
                        {formatTimeLengthMillis(song.timeLengthMilliseconds)}
                      </div>
                    </div>
                  ))}
                </div>
              </div> {/*background-mask*/}
            </Optional>
          </div>
        </div>
      </div>
      <div className={`player-panel ${panelOpen ? "open" : ""}`} role="region" aria-label="Now playing controls" ref={playerPanelRef}>
        <audio id="player"
               ref={playerRef}
               src={audioSrc}
               type={mimeType}
               onPlay={playerMethods.play}
               onPause={playerMethods.pause}
               onCanPlayThrough={playerMethods.prepared}
               onEnded={playerMethods.ended}>
          あなたのブラウザーはオーディオ要素をサポートしていません。
        </audio>
        <div className="player-title">
          <div>
          </div>
          <div>
            {currentPlaylist[currentPlayingIndex]?.title}
            {currentPlaylist[currentPlayingIndex] && currentPlaylist[currentPlayingIndex].artists
             ? " (" + currentPlaylist[currentPlayingIndex].artists?.map(artist => artist.artistName).join(", ") + ")"
             : null}
          </div>
          <div>
            {formatTimeLengthMillis(Math.floor(playerRef.current?.currentTime) * 1000)}
          </div>
        </div>
        <div className="player-indicator">
          <input
            type="range"
            min={0}
            max={1000}
            value={Math.round(progress * 1000)}
            onChange={(e) => onSeek(Number(e.currentTarget.value) / 1000)}
            aria-label="Seek"
          />
        </div>
        <div className="player-buttons">
          <div className="player-buttons-1"></div>
          <div className="player-buttons-2">
            <button className="btn prev" aria-label="Previous" onClick={onPrev}>⏮</button>
            <button className="btn play" aria-label="Play/Pause" onClick={onToggle}>⏯</button>
            <button className="btn next" aria-label="Next" onClick={onNext}>⏭</button>
          </div>
          <div className="player-buttons-3">
          </div>
        </div>
      </div>
      {/* アップロード・ダイアログ */}
      {isUploadDialogShowing ? 
       <UploadDialog appConfig={appConfig}
                     onClose={closeUploadDialog}
                     onMessage={(message) => showMessageBox(message)}/> : null}
      {/* サイド・メニュー (左ペインのメニューボタンを押すと表示する */}
      <div id="side-menu" className="light-shadow" style={sidemenuStyle}>
        <ul>
          <li>
            <button id="add-new-album-button" className="header-button" onClick={onUploadButtonClicked}>
              アルバムをアップロード
            </button>
          </li>
        </ul>
      </div>
      {/* 暗いスクリーン・マスク */}
      <div id="dark-mask" className="dark-mask" style={darkMaskStyle} onMouseDown={onDarkMaskClicked}></div> 
      {/* 明るいスクリーン・マスク */}
      <div id="light-mask" className="light-mask" style={lightMaskStyle} onMouseDown={onMouseDownMenuMask}></div>
      {/*メッセージボックス*/}
      {showMessage ?
       <MessageBox
         message={messageBoxText}
         onOk={closeMessageBox}/>
       : null}
    </>
  );
}
