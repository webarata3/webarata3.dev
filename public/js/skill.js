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
    const MARGIN = 5;

    const count = tabButtons.length;
    const betweenDeg = 2 / count * Math.PI;
    const baseX = 0;
    const baseY = r;

    const tabContents = Array.from(tabContent.childNodes).filter(node => node.nodeType === Node.ELEMENT_NODE);
    for (let i = 0; i < count; i++) {
      let theta = i * betweenDeg;
      let x = Math.round(baseX * Math.cos(theta) - baseY * Math.sin(theta));
      let y = Math.round(baseX * Math.sin(theta) + baseY * Math.cos(theta));
      tabButtons[i].style.position = 'absolute';
      const w = getPx(tabButtons[i], 'width');
      const h = getPx(tabButtons[i], 'height');
      if (x < 0) x = x - w;
      if (y > 0) y = y + h;
      // 横が中心の場合上下に少し間隔を空ける
      if (x === 0) {
        x = x - (w / 2);
        y = y + (y <= 0 ? -MARGIN : MARGIN);
      }
      tabButtons[i].style.top = `${-y + r + top}px`;
      tabButtons[i].style.left = `${x + r + left}px`;
      const charaRgb = hsvToRgb(Math.round(theta * 57.2958), 1.0, 0.8);
      const circleRgb = hsvToRgb(Math.round(theta * 57.2958), 0.7, 1.0);
      const tabButtonColor = `rgb(${charaRgb.r}, ${charaRgb.g}, ${charaRgb.b})`;
      tabButtons[i].style.color = tabButtonColor;
      tabButtons[i].style.borderColor = tabButtonColor;
      tabContents[i].dataset.circleColor = `rgb(${circleRgb.r}, ${circleRgb.g}, ${circleRgb.b})`;
    }
  };

  const hsvToRgb = (h, s, v) => {
    const max = v;
    const min = max - ((s / 255) * max);
    const rgb = { 'r': 0, 'g': 0, 'b': 0 };

    h = h % 360;

    if (s === 0) {
      rgb.r = v * 255;
      rgb.g = v * 255;
      rgb.b = v * 255;
      return rgb;
    }

    const dh = Math.floor(h / 60);
    const p = v * (1 - s);
    const q = v * (1 - s * (h / 60 - dh));
    const t = v * (1 - s * (1 - (h / 60 - dh)));

    switch (dh) {
      case 0: rgb.r = v; rgb.g = t; rgb.b = p; break;
      case 1: rgb.r = q; rgb.g = v; rgb.b = p; break;
      case 2: rgb.r = p; rgb.g = v; rgb.b = t; break;
      case 3: rgb.r = p; rgb.g = q; rgb.b = v; break;
      case 4: rgb.r = t; rgb.g = p; rgb.b = v; break;
      case 5: rgb.r = v; rgb.g = p; rgb.b = q; break;
    }

    rgb.r = Math.round(rgb.r * 255);
    rgb.g = Math.round(rgb.g * 255);
    rgb.b = Math.round(rgb.b * 255);
    return rgb;
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
        content.parentNode.style.borderColor = content.dataset.circleColor;
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
