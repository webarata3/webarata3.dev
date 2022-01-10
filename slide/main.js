const tabButtonElms = document.querySelectorAll('#tabButtons > li');
const tabContentElms = document.querySelectorAll('#tabContents > div');

let currentTab = null;

tabButtonElms.forEach((tabButtonElm, index) => {
  tabButtonElm.addEventListener('click', () => {
    if (currentTab !== null) {
      currentTab.classList.remove('work__buttons-item--selected');
    }
    tabButtonElm.classList.add('work__buttons-item--selected');
    changeTab(index);

    currentTab = tabButtonElm;
  });
});

const changeTab = center => {
  tabContentElms.forEach((tabContentElm, index) => {
    if (center === index) {
      changeStyle(tabContentElm, 0, 200, 1, false);
    } else if (center - 1 === index) {
      changeStyle(tabContentElm, 0, -300, 0.333, true);
    } else if (center + 1 === index) {
      changeStyle(tabContentElm, 0, 700, 0.333, true);
    } else if (center - 1 > index) {
      changeStyle(tabContentElm, 0, -300, 0.0, true);
    } else if (center + 1 < index) {
      changeStyle(tabContentElm, 0, 700, 0.0, true);
    }
  });
};

const changeStyle = (elm, bottom, left, scale, filter) => {
  elm.style.bottom = `${bottom}px`;
  elm.style.left = `${left}px`;
  elm.style.transform = `scale(${scale}, ${scale})`;
  if (filter) {
    elm.style.filter = 'grayscale(80%)';
  } else {
    elm.style.filter = 'none';
  }
};

changeTab(0);
setTimeout(() => {
  tabContentElms.forEach(elm => elm.classList.add('content-second'));
}, 100);
