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
      this.currentAngles = Array(this.tabButtons.length);
      for (let i = 0; i < this.currentAngles.length; i++) {
        this.currentAngles[i] = 360 / this.currentAngles.length * i;
      }

      this.#rotate(0, false);
      this.#setEvent();
    }

    #rotate(changeAngle, animation = true) {
      for (let i = 0; i < this.tabButtons.length; i++) {
        this.tabButtons[i].style.position = 'absolute';
        const w = getPx(this.tabButtons[i], 'width');
        this.tabButtons[i].style.top = `${this.top - this.h / 2}px`;
        this.tabButtons[i].style.left = `${this.left + this.r - w / 2}px`;

        const newAngle = (this.currentAngles[i] + changeAngle + 360) % 360;
        this.tabButtons[i].style.transform = `rotate(${newAngle}deg)`;
        this.tabButtons[i].style.transformOrigin = `0 ${this.r}px`;
        this.currentAngles[i] = newAngle;
        if (animation) this.tabButtons[i].style.transition = 'transform 0.5s ease-out';

        const inner = this.tabButtons[i].querySelector('p');
        inner.style.transform = `rotate(-${newAngle}deg)`;
        inner.style.transformOrigin = '0 0';
        if (animation) inner.style.transition = 'transform 0.5s ease-out';
      }
    }

    #setEvent() {
      this.first = true;
      this.currentTab = null;
      this.currentContent = null;
      this.tabButtons.forEach((tabButton, index) => {
        tabButton.addEventListener('click', () => {
          if (this.currentTab !== null) {
            this.currentTab.querySelector('p').classList.remove('skill__tab-button-inner--selected');
            this.currentContent.classList.add('skill__tab-content-init');
          }
          const content = document.querySelector(`#${tabButton.dataset.content}`);
          content.classList.remove('skill__tab-content-init');
          content.parentNode.style.borderColor = content.dataset.circleColor;
          tabButton.querySelector('p').classList.add('skill__tab-button-inner--selected');
          this.currentTab = tabButton;
          this.currentContent = content;
          if (this.first) {
            this.first = false;
          } else {
            this.#rotate(360 - this.currentAngles[index]);
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
