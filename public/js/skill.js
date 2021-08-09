(global => {
  const init = (tabButtonsSelector) => {
    initTab(tabButtonsSelector);
  };

  const initTab = (tabButtonsSelector) => {
    const tabButtons = document.querySelectorAll(tabButtonsSelector);

    let currentTab = null;
    let currentContent = null;
    tabButtons.forEach(tabButton => {
      tabButton.addEventListener('click', () => {
        if (currentTab !== null) {
          currentContent.classList.remove('skill__tab-content');
          currentContent.classList.add('skill__tab-content-init');
        }
        const content = document.querySelector(`#${tabButton.dataset.content}`);
        content.classList.remove('skill__tab-content-init');
        content.classList.add('skill__tab-content');
        currentTab = tabButton;
        currentContent = content;
      });
    });

    clickFirstTabButton(tabButtons[0]);
  };

  const clickFirstTabButton = (tabButton) => {
    const event = document.createEvent('MouseEvents');
    event.initEvent('click', false, true);
    tabButton.dispatchEvent(event);
  };

  init('#skillTabButtons > li');
})(window);
