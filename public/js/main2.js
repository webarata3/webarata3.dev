(global => {
  const getOffsetY = (selector) => {
    const elm = document.querySelector(selector);
    const clientRect = elm.getBoundingClientRect();
    return clientRect.top;
  };

  const init = (selector, centerY, w) => {
    const LOCATIONS = [[0, 0], [w, centerY], [0, centerY * 2], [-w, centerY]];

    const articles = document.querySelectorAll(selector);
    for (let i = 1; i < articles.length; i++) {
      articles[i].style.position = 'absolute';
      articles[i].style.left = `${LOCATIONS[i][0]}px`;
      articles[i].style.top = `${LOCATIONS[i][1]}px`;
      articles[i].style.transform = `rotate(${90 * i}deg)`;
      articles[i].style.transformOrigin = 'left top';
    }
  };

  const setEvent = (selector, centerY) => {
    const urlMap = new Map();
    urlMap.set('', 0);
    urlMap.set('home', 0);
    urlMap.set('work', -90);
    urlMap.set('skills', 180);
    urlMap.set('link', 90);

    let currentDeg = 0;
    const mainElm = document.querySelector(selector);
    document.querySelectorAll('.nav a').forEach(anchor => {
      anchor.addEventListener('click', event => {
        event.preventDefault();
        const splits = anchor.href.split('#');
        const deg = urlMap.get(splits.length === 2 ? splits[1] : '');
        const sec = Math.abs(currentDeg - deg) / 90;
        currentDeg = deg;
        mainElm.style.transform = `rotate(${deg}deg)`;
        mainElm.style.transformOrigin = `0px ${centerY}px`;
        mainElm.style.transition = `all ${sec}s ease-out`;
        history.pushState(null, null, anchor.href);
      });
    });

    window.addEventListener('popstate', () => {
      const splits = window.location.href.split('#');
      const deg = urlMap.get(splits.length === 2 ? splits[1] : '');
      mainElm.style.transform = `rotate(${deg}deg)`;
      mainElm.style.transformOrigin = `0px ${centerY}px`;
      mainElm.style.transition = 'all 0.5s ease-out';
    });
  };

  const offsetY = getOffsetY('main');

  const CENTER_Y = 2000 + offsetY;
  const W = 2000 + offsetY;
  init('article', CENTER_Y, W);
  setEvent('main', CENTER_Y);
})(window);
