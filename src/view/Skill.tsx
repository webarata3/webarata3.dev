import { useEffect, useRef, useState } from "react";
import mainStyle from "../util/Util";
import { ContentInfo } from "../util/SkillTypes";
import SkillTab from "./SkillTab";
import { SkillTabName } from "../util/SkillTypes";
import { Link } from "react-router-dom";

type Props = {
  deg: number,
  top: number,
  left: number
};

const SKILL_TAB_NAMES: SkillTabName[] = ['Java', 'HTML / CSS', 'JavaScript', 'Elm', 'Python', 'Flutter / Dart'];
const BETWEEN_DEG = Math.floor(360 / SKILL_TAB_NAMES.length);

const Skill = ({ deg, top, left }: Props): React.ReactElement => {
  const [degs, setDegs] = useState<number[] | null>(null);
  const skillRef = useRef<HTMLDivElement | null>(null);
  const [contentInfo, setContentInfo] = useState<ContentInfo | null>(null);
  const tabRef = useRef<HTMLUListElement | null>(null);
  const [currentTabName, setCurrentTabName] = useState<SkillTabName>(SKILL_TAB_NAMES[0]);

  useEffect(() => {
    const initDegs = [];
    for (let i = 0; i < SKILL_TAB_NAMES.length; i++) {
      initDegs.push(Math.floor(BETWEEN_DEG * i));
    }
    setDegs(initDegs);
  }, []);

  useEffect(() => {
    if (skillRef === null || skillRef.current === null) return;
    const clientRect = skillRef.current.getBoundingClientRect();

    const top = parseInt(getComputedStyle(skillRef.current).getPropertyValue('top').replace('px', ''));
    const left = parseInt(getComputedStyle(skillRef.current).getPropertyValue('left').replace('px', ''));
    setContentInfo({
      top: top,
      left: left,
      height: clientRect.height,
      r: Math.floor(clientRect.width / 2)
    });
  }, [skillRef]);

  const clickTab = (deg: number, tabName: SkillTabName): void => {
    if (degs === null) return;
    const newDegs = degs.slice(0, degs.length);
    const deg360 = deg % 360;
    const changeDeg = deg360 < 180
      ? -deg360
      : 360 - deg360;
    for (let i = 0; i < newDegs.length; i++) {
      newDegs[i] = newDegs[i] + changeDeg;
    }
    setDegs(newDegs);
    setCurrentTabName(tabName);
  };

  return (
    <article className="main__content"
      style={mainStyle(deg, top, left)}>
      <header className="main__header">
        <h2 className="main__title">home</h2>
        <nav className="nav">
          <ul className="header__nav">
            <li className="header__nav-item">
              <Link to="/skill" className="header__nav-link">skill</Link>
            </li>
            <li className="header__nav-item">
              <Link to="/work" className="header__nav-link">work</Link>
            </li>
            <li className="header__nav-item">
              <Link to="/link" className="header__nav-link">link</Link>
            </li>
          </ul>
        </nav>
      </header>
      <div className="main__inner">
        <section>
          <div className="skill">
            <ul className="skill__tab-buttons" ref={tabRef}>
              {
                SKILL_TAB_NAMES.map((v, index) =>
                  <SkillTab
                    key={index}
                    tabName={v}
                    contentInfo={contentInfo}
                    deg={degs === null ? 0 : degs[index]}
                    clickCallback={clickTab}
                  />
                )
              }
            </ul>
            <div className="skill__tab-content" ref={skillRef}>
              <div className="skill__content">
                {
                  SKILL_CONTENT_MAP.get(currentTabName) ?? <></>
                }
              </div>
            </div>
          </div>
        </section>
      </div>
    </article>
  );
};

const SKILL_CONTENT_MAP = new Map<SkillTabName, React.ReactElement>([
  ['Java',
    (<>
      <h3 className="skill__tab-title">Java</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★★★</span>
      </div>
      <div>
        <p className="skill__content-p">Java 1.1から使っています。</p>
        <p className="skill__content-p">
          <span>10年程度Webアプリを作っていました。Webのフレームワークとしては</span>
          <a href="https://struts.apache.org/" className="main__link">SAStruts</a>
          <span>、</span>
          <a href="https://spring.io/" className="main__link">Spring MVC</a>
          <span>あたり。ORマッパは</span>
          <a href="http://s2dao.seasar.org/ja/" className="main__link">S2Dao</a>
          <span>と、</span>
          <a href="https://blog.mybatis.org/" className="main__link">MyBatis</a>
          <span>を使っていました。</span>
        </p>
        <p className="skill__content-p">
          <span>最近は</span>
          <a href="https://micronaut.io/" className="main__link">Micronaut</a>
          <span>を使うことが多いです。</span>
        </p>
        <p className="skill__content-p">
          <a href="https://openjdk.java.net/jeps/392" className="main__link">Packaging Tool</a>
          <span>が出てからはSwingアプリを作ったりもしています。</span>
        </p>
      </div>
    </>)
  ],
  ['HTML / CSS',
    <>
      <h3 className="skill__tab-title">HTML / CSS</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★★★</span>
      </div>
      <div>
        <p className="skill__content-p">このサイトくらいのHTMLやCSSは書けます。</p>
        <p className="skill__content-p">
          <span>Webアプリを作っていたこともあるので、HTMLやCSSで困ることは（新しいものは日々勉強ですが）あまりありません。</span>
        </p>
      </div>
    </>],
  ['JavaScript',
    <>
      <h3 className="skill__tab-title">JavaScript</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★★☆</span>
      </div>
      <div>
        <p className="skill__content-p">バニラJavaScriptはそこそこ書けます。</p>
        <p className="skill__content-p">
          <span>規模が大きいものを作るときはReactで作っています。</span>
        </p>
      </div>
    </>],
  ['Elm',
    <>
      <h3 className="skill__tab-title">Elm</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★☆☆</span>
      </div>
      <div>
        <p className="skill__content-p">文法は一通り学習したことがあります。</p>
      </div>
    </>],
  ['Python',
    <>
      <h3 className="skill__tab-title">Python</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★☆☆</span>
      </div>
      <div>
        <p className="skill__content-p"></p>
      </div>
    </>],
  ['Flutter / Dart',
    <>
      <h3 className="skill__tab-title">Flutter / Dart</h3>
      <div className="skill__level">
        <span className="skill__level-title">レベル</span>
        <span className="skill__level-star">★☆☆</span>
      </div>
      <div>
        <p className="skill__content-p"></p>
      </div>
    </>],
]);

export default Skill;
