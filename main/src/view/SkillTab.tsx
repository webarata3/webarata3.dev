import { CSSProperties, useEffect, useRef, useState } from "react";
import { ContentInfo, SkillTabName } from "../util/SkillTypes";

type Props = {
  tabName: SkillTabName,
  contentInfo: ContentInfo | null,
  deg: number,
  clickCallback: (deg: number, tabName: SkillTabName) => void
};

const SkillTab = ({ tabName, contentInfo, deg, clickCallback }: Props): React.ReactElement => {
  const tabRef = useRef<HTMLLIElement | null>(null);;

  const [tabHeight, setTabHeight] = useState<number | null>(null);
  const [tabWidth, setTabWidth] = useState<number | null>(null);

  useEffect(() => {
    if (tabRef === null || tabRef.current === null) return;

    setTabHeight(tabRef.current.clientHeight);
    setTabWidth(tabRef.current.clientWidth);
  }, [tabRef]);

  const getTabStyle = (): CSSProperties => {
    if (contentInfo === null) return {};
    if (tabHeight === null) return {};
    if (tabWidth === null) return {};
    return {
      top: `${contentInfo.top - tabHeight / 2}px`,
      left: `${contentInfo.left + contentInfo.r - tabWidth / 2}px`,
      transform: `rotate(${deg}deg)`,
      transformOrigin: `0 ${contentInfo.r}px`,
      transition: 'transform 0.5s ease-out'
    };
  };

  const getTabInnerStyle = (): CSSProperties => {
    return {
      transform: `rotate(${-1 * deg}deg)`,
      transformOrigin: '0 0',
      transition: 'transform 0.5s ease-out'
    };
  };

  return (
    <li
      ref={tabRef}
      style={getTabStyle()}
      className="skill__tab-button">
      <a className={`skill__tab-button-inner${deg % 360 === 0 ? ' skill__tab-button-inner--selected' : ''
        }`}
        style={getTabInnerStyle()}
        onClick={() => clickCallback(deg, tabName)}>{tabName}</a>
    </li>
  );
};

export default SkillTab;
