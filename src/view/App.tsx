import React, { useEffect, useRef, useState } from 'react';
import Header from './Header';
import Home from './Home';
import Work from './Work';
import Skill from './Skill';
import Links from './Links';
import { useLocation } from 'react-router-dom';
import Privacy from './Privacy';
import Credit from './Credit';

const THRESHOLD = 2000;

const App = (): React.ReactElement => {
  const location = useLocation();
  const mainRef = useRef<HTMLDivElement | null>(null);
  const [y, setY] = useState<number>(0);
  const [center, setCenter] = useState<{ x: number, y: number } | null>(null);
  const [mainCss, setMainCss] = useState<React.CSSProperties>({});

  useEffect(() => {
    if (mainRef === null || mainRef.current === null) return;
    const mainY = mainRef.current.getBoundingClientRect().y;
    setY(Math.floor(mainY));
    setCenter({
      x: THRESHOLD + mainY,
      y: THRESHOLD + mainY
    });
  }, [mainRef]);

  useEffect(() => {
    if (center === null) return;
    switch (location.pathname) {
      case '/work':
        document.title = 'work - webarata3.dev';
        setMainCss({
          transform: `rotate(-90deg)`,
          transformOrigin: `0 ${center.y}px`,
          transition: 'all 1s ease-out'
        });
        break;
      case '/skill':
        document.title = 'skill - webarata3.dev';
        setMainCss({
          transform: `rotate(180deg)`,
          transformOrigin: `0 ${center.y}px`,
          transition: 'all 1s ease-out'
        });
        break;
      case '/link':
        document.title = 'link - webarata3.dev';
        setMainCss({
          transform: `rotate(90deg)`,
          transformOrigin: `0 ${center.y}px`,
          transition: 'all 1s ease-out'
        });
        break;
      default:
        document.title = 'webarata3.dev';
        setMainCss({
          transform: `rotate(0)`,
          transformOrigin: `0 ${center.y}px`,
          transition: 'all 1s ease-out'
        });
    }
  }, [location, center]);

  return <>
    <Header />
    <main className="main" style={mainCss} ref={mainRef}>
      <Home deg={0} top={0} left={0} />
      <Work deg={90}
        top={THRESHOLD + y} left={THRESHOLD + y} />
      <Skill deg={180}
        top={(THRESHOLD + y) * 2} left={0} />
      <Links deg={-90}
        top={THRESHOLD + y}
        left={-(THRESHOLD + y)} />
    </main>
    {
      location.pathname === '/privacy'
        ? <Privacy />
        : <></>
    }
    {
      location.pathname === '/credit'
        ? <Credit />
        : <></>
    }
  </>
};

export default App;
