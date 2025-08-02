import React from 'react';

export default function MessageBox({ show, message, onOk }) {
  const modalStyle = {
    display: show ? 'block' : 'none',
    position: 'fixed',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: 'white',
    border: '1px solid #ccc',
    borderRadius: '5px',
    padding: '2em',
    zIndex: 1000
  };

  const overlayStyle = {
    display: show ? 'block' : 'none',
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100vw',
    height: '100vh',
    backgroundColor: 'rgba(0,0,0,0.5)',
    zIndex: 999
  };

  return (
    <>
      <div style={overlayStyle}></div>
      <div style={modalStyle}>
        <p>{message}</p>
        <button className="btn btn-primary" onClick={onOk}>OK</button>
      </div>
    </>
  );
}

