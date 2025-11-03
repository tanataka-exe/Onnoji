import { useState, useEffect, useRef } from 'react';
import './UploadDialog.css';
import closeButtonIcon from './images/application-exit-symbolic.svg';

export default function UploadDialog(props) {
  const formRef = useRef();
  const albumNameRef = useRef();
  const filesRef = useRef();
  const [ files, setFiles ] = useState([]);
  const [ uploading, setUploading ] = useState(false);
  const [ isSubmitButtonDisabled, setSubmitButtonDisabled ] = useState(false);

  async function submitFormTest(event) {
    event.preventDefault();
    const albumName = albumNameRef.current.value;
    console.log(`albumName : ${albumName}`);
    console.log(`files.length : ${files.length}`);
    let messageText = "";
    if (albumName == "") {
      messageText = "アルバム名が空なんだが";
      props.onMessage(messageText, false);
      console.log("dialog close");
      return;
    }
    setSubmitButtonDisabled(true);
    props.onMessage("テスト", true);
  }
  
  async function submitForm(event) {
    event.preventDefault();
    const albumName = albumNameRef.current.value;
    console.log(`albumName : ${albumName}`);
    console.log(`files.length : ${files.length}`);
    let messageText = "";
    if (albumName == "" || files.length == 0) {
      if (albumName == "") {
        messageText = "アルバム名が空なんだが";
      } else if (files.length == 0) {
        messageText = "ファイルが選択されていない";
      }
      props.onMessage(messageText, false);
      console.log("dialog close");
      return;
    }
    let formData = new FormData();
    console.log("album-title: " + albumName);
    formData.append('album-title', albumName);
    for (let i = 0; i < files.length; i++) {
      console.log("uploaded-file: " + JSON.stringify(files[i].name));
      formData.append('uploaded-file', files[i]);
    }
    setUploading(true);
    setSubmitButtonDisabled(true);
    try {
      var response = await fetch(`http://${props.appConfig.apiHost}:${props.appConfig.apiPort}/api/v2/album`, {
        method: "POST",
        body: formData
      });
      const restext = await response.text();
      console.log(`${response.status}: ${restext}`);
      if (response.ok) {
        messageText = `成功: ${restext}`;
      } else {
        messageText = `失敗: ${restext}`;
      }
    } catch (err) {
      console.error(err);
      messageText = "通信エラーが発生しました";
    }
    props.onMessage(messageText, true);
    setUploading(false);
  }

  function selectFiles(event) {
    console.log(event);
    setFiles(event.target.files);
  }

  const formStyle = {
    'display': 'flex',
    'flex-direction': 'row',
    'gap':  '2em',
    'max-width': '600px',
    'margin': '0 auto 0 auto',
    'text-align': 'start'
  };

  const formInputFieldsStyle = {
    display: 'grid',
    gridTemplateRows: '1fr 1fr',
    gridTemplateColumns: '1fr 1fr',
    'gap':  '1em',
    'text-align': 'start',
    'width': '100%'
  };

  const formSubmitFieldsStyle = {
    'display': 'flex',
    'flex-direction': 'column',
    'justify-content': 'flex-end'
  };

  return (
    <div className="upload-dialog light-shadow">
      <div className="upload-dialog-content">
        <div className="dialog-header">
          <h1>アップロードするファイルを選択してください。</h1>
          <button onClick={props.onClose}><img src={closeButtonIcon}/></button>
        </div>
        <form onSubmit={submitForm} style={formStyle} ref={formRef}>
          <div style={formInputFieldsStyle} className="border-right">
            <div className="form-group" style={{gridRow:'1 / 2', gridColumn:'1 / 3'}}>
              <label htmlFor="album_name">アルバムのタイトルを入力してください</label>
              <input type="text" name="album-title" className="form-control form-control-lg" ref={albumNameRef} />
            </div>
            <div className="form-group" style={{gridRow:'2 / 3', gridColumn: '1 / 2'}}>
              <label htmlFor="files">ファイルを選択してください</label>
              <input type="file" name="uploaded-files" className="form-control form-control-lg" ref={filesRef} onChange={selectFiles} multiple/>
            </div>
            <div style={{girdRow: '2 / 3', gridColumn: '2 / 3',display:'grid',alignItems: 'center'}}>
              <input type="submit" className="btn btn-primary" disabled={isSubmitButtonDisabled} value="アップロード"/>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
