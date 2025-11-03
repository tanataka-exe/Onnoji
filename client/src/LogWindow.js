import './LogWindow.css';
import closeButtonIcon from './images/application-exit-symbolic.svg';
import ScrollableArea from './ScrollableArea.js';

export default function LogWindow(props) {
  function checkLogList() {
    console.log(props.logList);
    return props.logList != null && typeof(props.logList) == "object" && props.logList.length > 0;
  }
  
  return (
    <div className="log-window light-shadow">
      <div className="log-window-content">
        <div className="dialog-header">
          <h1>ログ</h1>
          <button onClick={props.onClose}><img src={closeButtonIcon}/></button>
        </div>
        <div style={{height:"70dvh"}}>
          <ScrollableArea direction="vertical">
            {checkLogList() ? 
             <ul>
               {props.logList.slice(-50).map(logText => (
                 <li>{`${logText[0]} : ${logText[1]}`}</li>
               ))}
             </ul>
             : null}
          </ScrollableArea>
        </div>
      </div>
    </div>
  );
}
