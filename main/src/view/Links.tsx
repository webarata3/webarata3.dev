import { Link } from "react-router-dom";
import mainStyle from "../util/Util";

type Props = {
  deg: number,
  top: number,
  left: number
};

const Links = ({ deg, top, left }: Props): React.ReactElement => {
  return (
    <article className="main__content"
      style={mainStyle(deg, top, left)}>
      <div className="main__inner">
        <header className="main__header">
          <h2 className="main__title">link</h2>
          <nav className="nav">
            <ul className="header__nav">
              <li className="header__nav-item">
                <Link to="/home" className="header__nav-link">home</Link>
              </li>
              <li className="header__nav-item">
                <Link to="/work" className="header__nav-link">work</Link>
              </li>
              <li className="header__nav-item">
                <Link to="/skill" className="header__nav-link">skill</Link>
              </li>
            </ul>
          </nav>
        </header>
        <div>
          <a href="https://twitter.com/webarata3" target="_blank" className="work__icon-link">
            <svg className="work__icon"><use xlinkHref="../image/twitter.svg#twitter"></use></svg>
          </a>
          <a href="https://github.com/webarata3" target="_blank" className="work__icon-link">
            <svg className="work__icon"><use xlinkHref="../image/github.svg#github"></use></svg>
          </a>
        </div>
      </div>
    </article>
  );
};

export default Links;
