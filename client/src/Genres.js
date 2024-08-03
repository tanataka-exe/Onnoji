import React, { useState, useEffect, useContext, useRef } from 'react';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import './Genres.css';
import ViewContext from './ViewContext.js';
import uploadIcon from './images/genre-upload-icon.png';

const delay = ms => new Promise(res => setTimeout(res, ms));

function UploadDialog({genre, show, onComplete}) {

  const { appConfig } = useContext(ViewContext);
  const [ file, setFile ] = useState(null);

  async function uploadGenreIcon(iconFile) {
    let formData = new FormData();
    if (file == null) {
      alert("ファイルを選択してから実行してください");
      return false;
    }
    formData.append('uploaded-file', file);
    const url = `http://${appConfig.apiHost}:${appConfig.apiPort}${genre.icon}`;
    console.log(url);
    const response = await fetch(url, {
      method: "POST",
      body: formData
    });
    const json = await response.json();
    onComplete();
    console.log('result of uploading a genre icon: ' + JSON.stringify(json));
    return true;
  }

  function selectFile(event) {
    setFile(event.target.files[0]);
  }

  const iconFileRef = useRef();
  const handleClose = () => show.set(false);
  const handleUpload = async () => {
    const isCompleted = await uploadGenreIcon();
    show.set(false)
    if (isCompleted) {
      await delay(100);
      alert("アイコンの変更が完了しました。");
    }
  };
  
  return (
    <Modal show={show.value} onHide={handleClose}>
      <Modal.Header closeButton>
        <Modal.Title>アイコンのアップロード</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <form>
          <div className="form-group">
            <label htmlFor="uploaded-files">アップロードするファイルを選んでください。</label>
            <input type="file" name="uploaded-files" className="form-control form-control-lg" onChange={selectFile} ref={iconFileRef}/>
          </div>
        </form>
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={handleClose}>
          キャンセル
        </Button>
        <Button variant="primary" onClick={handleUpload}>
          変更する
        </Button>
      </Modal.Footer>
    </Modal>
  );
}

function GenreItem({genre}) {
  const { appConfig, viewSwitcher } = useContext(ViewContext);
  const [ showDialog, setShowDialog ] = useState(false);
  function refreshIconSrc() {
    return `http://${appConfig.apiHost}:${appConfig.apiPort}${genre.icon}?${new Date().getTime()}`;
  }
  const [ iconSrc, setIconSrc ] = useState(refreshIconSrc());
  const containerStyle = {
    'position': 'relative'
  };
  const buttonStyle = {
    'position': 'absolute',
    'top': '0',
    'right': '0',
    'zindex': -1,
    'visibility': 'hidden'
  };
  const uploadButtonRef = useRef();
  const imgStyle = {
    'position': 'absolute',
    'top': '0',
    'right': '0'
  };
  return (
    <>
      <div>
        <div style={containerStyle}
             onMouseEnter={() => uploadButtonRef.current.style.visibility = 'visible'}
             onMouseLeave={() => uploadButtonRef.current.style.visibility = 'hidden'}>
          <div style={imgStyle}>
            <img className="genre-icon rounded-circle" src={iconSrc} width="160px" height="160px" alt="genre icon"/>
            <h3>{genre.genreName}</h3>
            <Button variant="link" onClick={() => viewSwitcher.showAlbums({genre})}>
              アルバム一覧を見る
            </Button>
            <Button variant="link" onClick={() => viewSwitcher.showArtists({genre})}>
              アーティスト一覧を見る
            </Button>
          </div>
          <Button variant="link" style={buttonStyle} onClick={() => setShowDialog(true)}  ref={uploadButtonRef}>
            <img src={uploadIcon}/>
          </Button>
        </div>
      </div>
      <UploadDialog genre={genre} show={{value: showDialog, set: setShowDialog}} onComplete={() => setIconSrc(refreshIconSrc())}/>
    </>
  );
}

export default function Genres() {
  const [genres, setGenres] = useState([]);
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const displayValue = appState?.visible.genres ? 'block' : 'none';

  useEffect(() => {
    if (appConfig == null) {
      return;
    }

    const fetchData = async () => {
      const response = await fetch(`http://${appConfig?.apiHost}:${appConfig?.apiPort}/api/v2/genres`);
      if (response.ok) {
        const json = await response.json();
        setGenres(json.genres);
      } else {
        console.log(await response.text());
      }
    };
    
    fetchData();
    
  }, [appConfig?.apiHost, appConfig?.apiPort]);

  if (appConfig == null) {
    return;
  }

  const fetchData = async () => {
    const response = await fetch(`http://${appConfig?.apiHost}:${appConfig?.apiPort}/api/v2/genres`);
    if (response.ok) {
      const json = await response.json();
      setGenres(json.genres);
    } else {
      console.log(await response.text());
    }
  };
  
  return (
    <div style={{display: displayValue}}>
      <h2>ジャンル一覧</h2>
      <ul className="genre-list">
        {genres.map((genre) => (
          <li key={"genre" + genre.genreId} className="genre-list-item text-center">
            <GenreItem genre={genre}/>
          </li>
        ))}
      </ul>
    </div>
  );
}
