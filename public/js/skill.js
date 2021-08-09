(global => {
  const init = (tabButtonsSelector, tabContentSelector) => {
    const tabButtons = document.querySelectorAll(tabButtonsSelector);
    const tabContent = document.querySelector(tabContentSelector);

    placementTab(tabButtons, tabContent);
    initTab(tabButtons);
  };

  const getPx = (elm, property) => {
    return parseInt(getComputedStyle(elm).getPropertyValue(property).replace('px', ''));
  };

  const placementTab = (tabButtons, tabContent) => {
    const r = getPx(tabContent, 'width') / 2;
    const top = getPx(tabContent, 'top');
    const left = getPx(tabContent, 'left');

    const count = tabButtons.length;
    const betweenDeg = 2 / count * Math.PI;
    const baseX = 0;
    const baseY = r;
    for (let i = 0; i < count; i++) {
      let theta = i * betweenDeg;
      let x = baseX * Math.cos(theta) - baseY * Math.sin(theta);
      let y = baseX * Math.sin(theta) + baseY * Math.cos(theta);
      tabButtons[i].style.position = 'absolute';
      const w = getPx(tabButtons[i], 'width');
      const h = getPx(tabButtons[i], 'height');
      if (x < 0) x = x - w;
      if (y > 0) y = y + h;
      if (x === 0) x = x - (w / 2);
      tabButtons[i].style.top = `${-y + r + top}px`;
      tabButtons[i].style.left = `${x + r + left}px`;
    }
  };

  const initTab = tabButtons => {
    let currentTab = null;
    let currentContent = null;
    tabButtons.forEach(tabButton => {
      tabButton.addEventListener('click', () => {
        if (currentTab !== null) {
          currentContent.classList.add('skill__tab-content-init');
        }
        const content = document.querySelector(`#${tabButton.dataset.content}`);
        content.classList.remove('skill__tab-content-init');
        currentTab = tabButton;
        currentContent = content;
      });
    });

    clickFirstTabButton(tabButtons[0]);
  };

  const clickFirstTabButton = tabButton => {
    const event = document.createEvent('MouseEvents');
    event.initEvent('click', false, true);
    tabButton.dispatchEvent(event);
  };

  init('#skillTabButtons > li', '.skill__tab-content');
})(window);
