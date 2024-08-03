function RoundButton(props) {
  return (
    <button className={'btn btn-primary btn-sm ' + props.className} onClick={props.onClick}>
      {props.children}
    </button>
  );
}

export default RoundButton;
