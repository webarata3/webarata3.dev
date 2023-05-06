import { Link } from "react-router-dom";
import mainStyle from "../util/Util";
import { CSSProperties, useState } from "react";

type Props = {
  deg: number,
  top: number,
  left: number;
};

type WorkTabName = 'ICa残高照会' | 'クリーン白山' | 'KExcelAPI';

const workTabNames: WorkTabName[] = ['ICa残高照会', 'クリーン白山', 'KExcelAPI'];

const Work = ({ deg, top, left }: Props): React.ReactElement => {
  const [center, setCenter] = useState<number>(0);

  const getContentStyle = (index: number): CSSProperties => {
    const left = 200 + (index - center) * 500;

    let scale: number;
    if (index === center) {
      scale = 1.0;
    } else if (index - 1 === center || index + 1 === center) {
      scale = 0.333
    } else {
      scale = 0.0;
    }

    return {
      bottom: 0,
      left: `${left}px`,
      transform: `scale(${scale}, ${scale})`,
      filter: `${index === center ? 'none' : 'blur(5px)'}`
    };
  };

  return (
    <article className="main__content"
      style={mainStyle(deg, top, left)}>
      <div className="main__inner">
        <header className="main__header">
          <h2 className="main__title">work</h2>
          <nav className="nav">
            <ul className="header__nav">
              <li className="header__nav-item">
                <Link to="/" className="header__nav-link">home</Link>
              </li>
              <li className="header__nav-item">
                <Link to="/skill" className="header__nav-link">skill</Link>
              </li>
              <li className="header__nav-item">
                <Link to="/link" className="header__nav-link">link</Link>
              </li>
            </ul>
          </nav>
        </header>
        <section className="work">
          <ul className="work__buttons">
            {
              workTabNames.map((v, index) =>
                <li key={index}
                  className={`work__buttons-item${index === center ?
                    ' work__buttons-item--selected' : ''}`}
                  onClick={() => setCenter(index)}>{v}</li>)
            }
          </ul>
          <div className="work__tab-contents">
            {
              WORK_TAB_CONTENTS.map((v, index) =>
                <div key={index} className="work__content"
                  style={getContentStyle(index)}>
                  {v}
                </div>
              )
            }
          </div>
        </section>
      </div>
    </article>);
};

const WORK_TAB_CONTENTS = [
  (<>
    <h3 className="work__content-title">
      <span>ICa残高照会</span>
      <span className="work__content-type">Androidアプリ</span>
      <div className="work__icon-area">
        <a href="https://play.google.com/store/apps/details?id=dev.webarata3.app.ica_reader"
          target="_blank" rel="noreferrer"
          className="main__link work__icon-link">
          <img src="image/up-right-from-square-solid.svg" alt="別ウィンドウで開くアイコン" className="work__icon" />
        </a>
        <a href="https://github.com/webarata3/ica_reader"
          target="_blank" rel="noreferrer"
          className="main__link work__icon-link">
          <img src="image/github.svg" alt="GitHubのアイコン" className="work__icon" />
        </a>
      </div>
    </h3>
    <div className="work__tech">
      <h3 className="work__tech-title">使用技術</h3>
      <ul className="work__tech-list">
        <li className="work__tech-item">Flutter</li>
        <li className="work__tech-item">Dart</li>
      </ul>
    </div>
    <div className="work__description">
      <div>
        <p className="work__description-text">北陸鉄道バスのICaの残高照会アプリです。</p>
        <p className="work__description-text">以前も作っていましたが、Flutterで書き直しました。</p>
      </div>
      <img className="work__image" src="image/ica_reader.webp"
        alt="ICa Readerの画面イメージ" />
    </div>
  </>),
  (<>
    <h3 className="work__content-title">
      <span>クリーン白山</span>
      <span className="work__content-type">Webアプリ</span>
      <div className="work__icon-area">
        <a href="https://clean.hakusan.app"
          target="_blank" rel="noreferrer"
          className="main__link work__icon-link">
          <img src="image/up-right-from-square-solid.svg" alt="別ウィンドウで開くアイコン" className="work__icon" />
        </a>
        <a href="https://github.com/webarata3/clean-hakusan"
          target="_blank" rel="noreferrer"
          className="main__link work__icon-link">
          <img src="image/github.svg" alt="GitHubのアイコン" className="work__icon" />
        </a>
      </div>
    </h3>
    <div className="work__tech">
      <h3 className="work__tech-title">使用技術</h3>
      <ul className="work__tech-list">
        <li className="work__tech-item">HTML</li>
        <li className="work__tech-item">CSS</li>
        <li className="work__tech-item">Elm</li>
        <li className="work__tech-item">JavaScript</li>
        <li className="work__tech-item">Java</li>
      </ul>
    </div>
    <div className="work__description">
      <div>
        <p className="work__description-text">石川県白山市のゴミ収集日程のアプリです。</p>
        <p className="work__description-text">
          <span>データの取得は市のサイトをスクレイピングしています。スクレイピングには</span>
          <a href="https://jsoup.org" className="main__link">jsoup</a>
          <span>を使用しています。</span>
        </p>
        <p className="work__description-text">アプリ自体はPWAとして作成しています。</p>
      </div>
      <img className="work__image" src="image/clean-hakusan-app.webp"
        alt="クリーン白山の画面イメージ" />
    </div>
  </>),
  (<>
    <h3 className="work__content-title">
      <span>KExcelAPI</span>
      <span className="work__content-type">ライブラリ</span>
      <div className="work__icon-area">
        <a href="https://github.com/webarata3/KExcelAPI"
          target="_blank" rel="noreferrer"
          className="main__link work__icon-link">
          <img src="image/github.svg" alt="GitHubのアイコン" className="work__icon" />
        </a>
      </div>
    </h3>
    <div className="work__tech">
      <h3 className="work__tech-title">使用技術</h3>
      <ul className="work__tech-list">
        <li className="work__tech-item">Kotlin</li>
        <li className="work__tech-item">Apache POI</li>
      </ul>
    </div>
    <div className="work__description">
      <div>
        <p className="workd__description-text">POIをかんたんに扱うためのライブラリです。</p>
      </div>
    </div>
  </>)
];

export default Work;
