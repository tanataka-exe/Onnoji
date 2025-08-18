import React from 'react';

export default function MessageBox({ show, message, onOk }) {
  const modalStyle = {
    display: 'block',
    position: 'fixed',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: 'white',
    border: '1px solid #ccc',
    borderRadius: '5px',
    padding: '2em',
    zIndex: 70
  };

  const overlayStyle = {
    display: 'block',
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100vw',
    height: '100vh',
    backgroundColor: 'rgba(0,0,0,0.3)',
    zIndex: 55
  };

  return (
    <>
      {/*<div style={overlayStyle}></div>*/}
      <div className="dialog" style={modalStyle}>
        <p>{message}</p>
        <button className="dialog-button" onClick={onOk}>OK</button>
      </div>
    </>
  );
}

