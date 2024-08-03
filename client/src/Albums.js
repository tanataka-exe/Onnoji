import { useContext } from 'react';
import GenreAlbums from './GenreAlbums.js';
import ArtistAlbums from './ArtistAlbums.js';
import RecentlyCreatedAlbums from './RecentlyCreatedAlbums.js';
import RecentlyRequestedAlbums from './RecentlyRequestedAlbums.js';
import ViewContext from './ViewContext.js';

export default function Albums() {
  const { appConfig, appState, viewSwitcher } = useContext(ViewContext);
  switch (appState.requestType) {
  default:
  case 'genre-albums':
    return <GenreAlbums/>
  case 'artist-albums':
    return <ArtistAlbums/>
  case 'recently-created-albums':
    return <RecentlyCreatedAlbums/>
  case 'recently-requested-albums':
    return <RecentlyRequestedAlbums/>
  }
}
