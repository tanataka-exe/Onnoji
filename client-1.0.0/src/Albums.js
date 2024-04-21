import GenreAlbums from './GenreAlbums.js';
import ArtistAlbums from './ArtistAlbums.js';
import RecentlyCreatedAlbums from './RecentlyCreatedAlbums.js';
import RecentlyRequestedAlbums from './RecentlyRequestedAlbums.js';

export default function Albums(props) {
    switch (props.appState.requestType) {
    default:
    case 'genre-albums':
        return <GenreAlbums appState={props.appState}/>
    case 'artist-albums':
        return <ArtistAlbums appState={props.appState}/>
    case 'recently-created-albums':
        return <RecentlyCreatedAlbums appState={props.appState}/>
    case 'recently-requested-albums':
        return <RecentlyRequestedAlbums appState={props.appState}/>
    }
}
