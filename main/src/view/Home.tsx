import { Link } from "react-router-dom";
import mainStyle from "../util/Util";

type Props = {
  deg: number,
  top: number,
  left: number
};

const Home = ({ deg, top, left }: Props): React.ReactElement => {
  return (
    <article className="main__content"
      style={mainStyle(deg, top, left)}>
      <div className="main__inner">
        <div className="home__main">
          <nav className="nav main__nav">
            <ul>
              <li className="main__nav-item">
                <Link to="/work" className="main__nav-link">work</Link>
              </li>
              <li className="main__nav-item">
                <Link to="/skill" className="main__nav-link">skill</Link>
              </li>
              <li className="main__nav-item">
                <Link to="/link" className="main__nav-link">link</Link>
              </li>
            </ul>
          </nav>
          <section className="history">
            <h3 className="history__title">更新履歴</h3>
            <ul>
              <li className="main__li">
                <time dateTime="2021-09-03" className="history__time">2022/09/03</time>
                <span>WorkにICa残高照会を追加</span>
              </li>
              <li className="main__li">
                <time dateTime="2021-08-16" className="history__time">2022/08/16</time>
                <span>公開</span>
              </li></ul>
          </section>
        </div>
        <footer className="footer">
          <div className="footer__inner">
            <div className="footer__credit">
              <Link to="/privacy" className="main__link">プライバシーポリシー</Link>
              <Link to="/credit" className="main__link">クレジット</Link>
            </div>
            <p>
              <small>©2022 webarata3（ARATA Shinichi）</small>
            </p>
          </div>
        </footer>
      </div>
    </article>);
};

export default Home;
