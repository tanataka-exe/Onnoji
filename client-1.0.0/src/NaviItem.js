import { useContext } from 'react';
import RoundButton from './RoundButton.js';
import './NaviItem.css';
import ViewContext from './ViewContext.js';

function NaviItemGenre(props) {
    const viewSwitcher = useContext(ViewContext);
    const onClick = () => viewSwitcher.showGenres();
    return (
        <RoundButton onClick={onClick} className={props.className}>ジャンル一覧</RoundButton>
    );
}

function NaviItemAlbums(props) {
    const viewSwitcher = useContext(ViewContext);
    let onClick;
    if (props.genreId != null) {
        onClick = () => viewSwitcher.showAlbums({requestType: 'genre-albums', genreId: props.genreId});
    } else if (props.artistId != null) {
        onClick = () => viewSwitcher.showAlbums({requestType: 'artist-albums', artistId: props.artistId});
    } else {
        return null;
    }
    return (
        <RoundButton onClick={onClick} className={props.className}>アルバム一覧</RoundButton>
    );
}

function NaviItemArtists(props) {
    const viewSwitcher = useContext(ViewContext);
    const onClick = () => viewSwitcher.showArtists({genreId: props.genreId});
    return (
        <RoundButton onClick={onClick} className={props.className}>アーティスト一覧</RoundButton>
    );
}

function NaviItemArtistAlbums(props) {
    const viewSwitcher = useContext(ViewContext);
    const onClickCallback = () => viewSwitcher.showAlbums({artistId: props.artistId});
    return (
        <RoundButton onClick={onClickCallback} className={props.className}>アルバム一覧</RoundButton>
    );
}

function NaviItemRecentlyCreatedAlbums(props) {
    const viewSwitcher = useContext(ViewContext);
    const onClickCallback = () => viewSwitcher.showAlbums({requestType: 'recently-created-albums'});
    return (
        <RoundButton onClick={onClickCallback} className={props.className}>最近追加されたアルバム</RoundButton>
    );
}

function NaviItemRecentlyRequestedAlbums(props) {
    const viewSwitcher = useContext(ViewContext);
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
        if (params.genreId != null) {
            return <NaviItemAlbums genreId={params.genreId} className={classNameValue}/>;
        } else if (params.artistId != null) {
            return <NaviItemAlbums artistId={params.artistId} className={classNameValue}/>;
        } else {
            return null;
        }
    }

    if (to === 'artists') {
        if (params.genreId != null) {
            return <NaviItemArtists genreId={params.genreId} className={classNameValue}/>;
        } else {
            return null;
        }
    }

    if (to === 'artistalbums') {
        if (params.artistId != null) {
            return <NaviItemArtistAlbums artistId={params.artistId} className={classNameValue}/>;
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
}

