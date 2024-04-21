import { useContext } from 'react';
import emptyImage from './images/empty-image200.png';
import './Albums.css';
import './AlbumData.css';
import ViewContext from './ViewContext.js';
import LinkButton from './LinkButton.js';

function ArtistLink(props) {
    const viewSwitcher = useContext(ViewContext);
    const params = {
        requestType: 'artist-albums',
        artistId: props.artist.artist_id,
    };
    return (
        <LinkButton onClick={() => viewSwitcher.showAlbums(params)}>
            <span className="artist-name">{props.artist.artist_name}</span>
        </LinkButton>
    );
};

function ArtistList(props) {
    if (!props.linkArtist) {
        return <span></span>;
    }

    return (
        <div>
            {props.albumData.artists.slice(0, 3).map((artist, index) => (
                <div key={props.albumData.album_id + ':' + artist.artist_id}>
                    <ArtistLink artist={artist} genreId={props.genre}/>
                    <span>
                        {index < (props.albumData.artists.length - 1) ? ', ' : ''}
                    </span>
                </div>
            ))}{props.albumData.artists.length > 3 ? ' etc.' : ''}
        </div>
    );
};

function AlbumTitle ({children}) {
    const title = children;
    
    if (title.length >= 50) {
        return (
            <div className="mytooltip">
                <h4>{title.substring(0, 50) + '...'}</h4>
                <span className="mytooltiptext">{title}</span>
            </div>
        );
    } else {
        return (
            <h4>{title}</h4>
        );
    }
};

export default function AlbumData(props) {
    const viewSwitcher = useContext(ViewContext);
    const albumData = props.albumData;
    const linkArtist = props.linkArtist === 'true';
    const genreId = props.genre;
    const artistId = props.artist;
    let songsParam = {};
    songsParam.albumId = albumData.album_id;
    if (genreId != null) {
        songsParam.genreId = genreId;
    }
    if (artistId != null) {
        songsParam.artistId =  artistId;
    }
    return (
        <div className="album-list-item">
            <div>
                <LinkButton onClick={() => viewSwitcher.showSongs(songsParam)}>
                    <img className="img-thumbnail" src={albumData.album_artwork ?? emptyImage} alt="album icon"/>
                </LinkButton>
            </div>
            <div>
                <LinkButton onClick={() => viewSwitcher.showSongs(songsParam)}>
                    <AlbumTitle>{albumData.album_name}</AlbumTitle>
                </LinkButton>
                <ArtistList albumData={albumData} genre={genreId} linkArtist={linkArtist}/>
            </div>
        </div>
    );
}
