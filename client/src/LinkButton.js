function LinkButton(props) {
  return (
    <button className={'btn btn-link ' + props.className} onClick={props.onClick}>
      {props.children}
    </button>
  );
}

export default LinkButton;
