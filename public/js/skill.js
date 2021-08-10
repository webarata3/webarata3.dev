(global => {
  const init = (tabButtonsSelector, tabContentSelector) => {
    const tabButtons = document.querySelectorAll(tabButtonsSelector);
    const tabContent = document.querySelector(tabContentSelector);
    const rotateTab = new RotateTab(tabButtons, tabContent);
  };

  const getPx = (elm, property) => {
    return parseInt(getComputedStyle(elm).getPropertyValue(property).replace('px', ''));
  };

  class RotateTab {
    constructor(tabButtons, tabContent) {
      this.tabButtons = tabButtons;
      this.tabContent = tabContent;
      this.h = getPx(this.tabButtons[0], 'height');
      this.r = getPx(this.tabContent, 'width') / 2;
      this.top = getPx(this.tabContent, 'top');
      this.left = getPx(this.tabContent, 'left');
      this.betweenAngle = 360 / this.tabButtons.length;
      this.#rotate(0, false);
      this.#setEvent();
    }

    #rotate(changeDeg, animation = true) {
      for (let i = 0; i < this.tabButtons.length; i++) {
        this.tabButtons[i].style.position = 'absolute';
        const w = getPx(this.tabButtons[i], 'width');
        this.tabButtons[i].style.top = `${this.top - this.h / 2}px`;
        this.tabButtons[i].style.left = `${this.left + this.r - w / 2}px`;

        const newAngle = (this.betweenAngle * i + changeDeg + 360) % 360;
        console.log(i, newAngle);
        this.tabButtons[i].style.transform = `rotate(${newAngle}deg)`;
        this.tabButtons[i].style.transformOrigin = `0 ${this.r}px`;
        this.tabButtons[i].dataset.deg = 360 - newAngle;
        if (animation) this.tabButtons[i].style.transition = 'transform 1s ease-out';

        const inner = this.tabButtons[i].querySelector('p');
        inner.style.transform = `rotate(-${newAngle}deg)`;
        inner.style.transformOrigin = '0 0';
        if (animation) inner.style.transition = 'transform 1s ease-out';
      }
    }

    #setEvent() {
      this.first = true;
      this.currentTab = null;
      this.currentContent = null;
      this.tabButtons.forEach(tabButton => {
        tabButton.addEventListener('click', () => {
          if (this.currentTab !== null) {
            this.currentContent.classList.add('skill__tab-content-init');
          }
          const content = document.querySelector(`#${tabButton.dataset.content}`);
          content.classList.remove('skill__tab-content-init');
          content.parentNode.style.borderColor = content.dataset.circleColor;
          this.currentTab = tabButton;
          this.currentContent = content;
          if (this.first) {
            this.first = false;
          } else {
            this.#rotate(tabButton.dataset.deg);
            console.log(tabButton.dataset.deg);
          }
        });
      });

      this.#clickFirstTabButton(this.tabButtons[0]);
    }

    #clickFirstTabButton(tabButton) {
      const event = document.createEvent('MouseEvents');
      event.initEvent('click', false, true);
      tabButton.dispatchEvent(event);
    }
  }

  init('#skillTabButtons > li', '.skill__tab-content');
})(window);
