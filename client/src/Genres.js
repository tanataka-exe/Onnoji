import React, { useState, useEffect, useContext, useRef } from 'react';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import './Genres.css';
import ViewContext from './ViewContext.js';
import uploadIcon from './images/genre-upload-icon.png';

async function uploadGenreIcon(genre, iconFile) {
  const { appConfig } = useContext(ViewContext);
  let formData = new FormData();
  formData.append('uploaded-file', files[0]);
  const response = await fetch(`http://${appConfig.apiHost}:${appConfig.apiPort}${genre.uploadIcon}`, {
    method: "POST",
    body: formData
  });
  const json = await response.json();
  console.log('result of uploading a genre icon: ' + JSON.stringify(json));
}

function UploadDialog({show}) {

  const [ files, setFiles ] = useState([]);

  function selectFile(event) {
    setFile(event.target.files);
  }

  const iconFileRef = useRef();
  const handleClose = () => show.set(false);
  const handleUpload = async () => {
    await uploadGenreIcon(iconFileRef.current.value);
    show.set(false)
  };
  
  return (
    <Modal show={show.value} onHide={handleClose}>
      <Modal.Header closeButton>
        <Modal.Title>アイコンのアップロード</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <form>
          <div className="form-group">
            <label htmlFor="uploaded-files">アップロードするファイルを選んでください。</p>
            <input type="file" name="uploaded-files" className="form-control form-control-lg" onChange={selectFile} ref={iconFileRef}/>
          </div>
        </form>
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={handleClick}>
          Close
        </Button>
        <Button variant="primary" onClick={handleUpload}>
          Save Changes
        </Button>
      </Modal.Footer>
    </Modal>
  );
}

function GenreItem({genre}) {
  const { appConfig, viewSwitcher } = useContext(ViewContext);
  const [ showDialog, setShowDialog ] = useState(false);
  const iconSrc = `http://${appConfig.apiHost}:${appConfig.apiPort}${genre.icon}`;
  const containerStyle = {
    'position': 'relative'
  };
  const buttonStyle = {
    'position': 'absolute',
    'top': '0',
    'right': '0'
  };
  const imgStyle = {
    'position': 'absolute',
    'top': '0',
    'right': '0'
  };
  return (
    <div>
      <div style={containerStyle}>
        <Button variant="link" style={buttonStyle} onClick{() => setShowDialog(true)}>
          <img src={uploadIcon}/>
        </Button>
        <img className="genre-icon rounded-circle" style={imgStyle} src={iconSrc} width="160px" height="160px" alt="genre icon"/>
      </div>
      <h3>{genre.genreName}</h3>
      <Button variant="link" onClick={() => viewSwitcher.showAlbums({genre})}>
        アルバム一覧を見る
      </Button>
      <Button variant="link" onClick={() => viewSwitcher.showArtists({genre})}>
        アーティスト一覧を見る
      </Button>
    </div>

    <UploadDialog show={{value: showDialog, set: setShowDialog}}/>
  );
}

export default function Genres() {
  const { appConfig, viewSwitcher } = useContext(ViewContext);
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
