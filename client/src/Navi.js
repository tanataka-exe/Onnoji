import NaviItem from './NaviItem.js';
import './Navi.css';

export default function Navi({ symbols }) {
    const naviFilter = (symbol) => {
        if (symbol.to === 'albums') {
            if (symbol.params.genreId != null || symbol.params.artistId != null) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    };
    
    return (
        <div className="nav btn-group">
            {symbols.filter(naviFilter).map((symbol) => (
                <NaviItem key={'nav-' + symbol.to} to={symbol.to} params={symbol.params}/>
            ))}
        </div>
    );
}
