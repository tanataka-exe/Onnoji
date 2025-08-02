import { useState, useRef, useContext } from 'react';
import ViewContext from './ViewContext.js';
import MessageBox from './MessageBox.js';

export default function UploadPage() {
  const formRef = useRef();
  const albumNameRef = useRef();
  const filesRef = useRef();
  const [ files, setFiles ] = useState([]);
  const [ uploading, setUploading ] = useState(false);
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  const [ showMessage, setShowMessage ] = useState(false);
  const [ messageText, setMessageText ] = useState("");
  
  async function submitForm(event) {
    event.preventDefault();
    if (files.length == 0) {
      return;
    }

    const albumName = albumNameRef.current.value;
    let formData = new FormData();
    console.log("album-title: " + albumName);
    formData.append('album-title', albumName);
    for (let i = 0; i < files.length; i++) {
      console.log("uploaded-file: " + JSON.stringify(files[i].name));
      formData.append('uploaded-file', files[i]);
    }
    setUploading(true);
    try {
      var response = await fetch(`http://${appConfig.apiHost}:${appConfig.apiPort}/api/v2/album`, {
        method: "POST",
        body: formData
      });
      const restext = await response.text();
      console.log(`${response.status}: ${restext}`);
      if (response.ok) {
        setMessageText(`成功: ${restext}`);
      } else {
        setMessageText(`失敗: ${restext}`);
      }
    } catch (err) {
      console.error(err);
      setMessageText("通信エラーが発生しました");
    }
    setUploading(false);
    setShowMessage(true);
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
    'display': 'flex',
    'flex-direction': 'column',
    'gap':  '1em',
    'text-align': 'start'
  };

  const formSubmitFieldsStyle = {
    'display': 'flex',
    'flex-direction': 'column',
    'justify-content': 'flex-end'
  };
  
  return (
    <div>
      <h1>アップロードするファイルを選択してください。</h1>
      <form onSubmit={submitForm} className="border p-4" style={formStyle} ref={formRef}>
        <div style={formInputFieldsStyle} className="border-right">
          <div className="form-group">
            <label htmlFor="album_name">アルバムのタイトルを入力してください</label>
            <input type="text" name="album-title" className="form-control form-control-lg" ref={albumNameRef} />
          </div>
          <div className="form-group">
            <label htmlFor="files">ファイルを選択してください</label>
            <input type="file" name="uploaded-files" className="form-control form-control-lg" ref={filesRef} onChange={selectFiles} multiple/>
          </div>
        </div>
        <div style={formSubmitFieldsStyle}>
          <input type="submit" className="btn btn-primary" value="アップロード"/>
        </div>
      </form>
      {/*メッセージボックス*/}
      <MessageBox
        show={showMessage}
        message={messageText}
        onOk={()=>setShowMessage(false)}
      />
    </div>
  );
}
