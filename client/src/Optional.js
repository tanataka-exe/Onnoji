function Optional(props) {
  if (props["if"]) {
    return (<>{props.children}</>);
  } else {
    return <></>;
  }
}

export default Optional;
