import { useContext } from 'react';
import RoundButton from './RoundButton.js';
import './NaviItem.css';
import ViewContext from './ViewContext.js';

function NaviItemUploadAlbum(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClick = () => viewSwitcher.showUploadPage({});
  return (
    <RoundButton onClick={onClick} className={props.className}>アップロード</RoundButton>
  );
}

function NaviItemGenre(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClick = () => viewSwitcher.showGenres();
  return (
    <RoundButton onClick={onClick} className={props.className}>ジャンル一覧</RoundButton>
  );
}

function NaviItemAlbums(props) {
  const { viewSwitcher } = useContext(ViewContext);
  let onClick;
  if (props.genre != null) {
    onClick = () => viewSwitcher.showAlbums({requestType: 'genre-albums', genre: props.genre});
  } else if (props.artist != null) {
    onClick = () => viewSwitcher.showAlbums({requestType: 'artist-albums', artist: props.artist});
  } else {
    return null;
  }
  return (
    <RoundButton onClick={onClick} className={props.className}>アルバム一覧</RoundButton>
  );
}

function NaviItemArtists(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClick = () => viewSwitcher.showArtists({genre: props.genre});
  return (
    <RoundButton onClick={onClick} className={props.className}>アーティスト一覧</RoundButton>
  );
}

function NaviItemArtistAlbums(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClickCallback = () => viewSwitcher.showAlbums({artist: props.artist});
  return (
    <RoundButton onClick={onClickCallback} className={props.className}>アルバム一覧</RoundButton>
  );
}

function NaviItemRecentlyCreatedAlbums(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClickCallback = () => viewSwitcher.showAlbums({requestType: 'recently-created-albums'});
  return (
    <RoundButton onClick={onClickCallback} className={props.className}>最近追加されたアルバム</RoundButton>
  );
}

function NaviItemRecentlyRequestedAlbums(props) {
  const { viewSwitcher } = useContext(ViewContext);
  const onClickCallback = () => viewSwitcher.showAlbums({requestType: 'recently-requested-albums'});
  return (
    <RoundButton onClick={onClickCallback} className={props.className}>最近聴いたアルバム</RoundButton>
  );
}

export default function NaviItem ({ to, params }) {
  const classNameValue = 'navbar-btn';
  
  if (to === 'genres') {
    return <NaviItemGenre/>;
  }
  
  if (to === 'albums') {
    if (params.genre != null) {
      return <NaviItemAlbums genre={params.genre} className={classNameValue}/>;
    } else if (params.artist != null) {
      return <NaviItemAlbums artist={params.artist} className={classNameValue}/>;
    } else {
      return null;
    }
  }

  if (to === 'artists') {
    if (params.genre != null) {
      return <NaviItemArtists genre={params.genre} className={classNameValue}/>;
    } else {
      return null;
    }
  }

  if (to === 'artistalbums') {
    if (params.artist != null) {
      return <NaviItemArtistAlbums artist={params.artist} className={classNameValue}/>;
    } else {
      return null;
    }
  }

  if (to === 'recently-created-albums') {
    return <NaviItemRecentlyCreatedAlbums className={classNameValue}/>;
  }

  if (to === 'recently-requested-albums') {
    return <NaviItemRecentlyRequestedAlbums className={classNameValue}/>;
  }

  if (to === 'upload-album') {
    return <NaviItemUploadAlbum className={classNameValue}/>;
  }
}

