'use strict';

const panels = document.querySelectorAll('.skill .panel');
panels.forEach((value, index) => {
  value.style.top = index * 30 + 'px';
  value.style.left = index * 60 + 'px';

  value.addEventListener('click', event => {
    panels.forEach(el => {
      if (el !== value) {
        if (el.classList.contains('active')) {
          el.classList.remove('active');
          el.classList.add('inactive');
        } else {
          el.classList.remove('inactive');
        }
      }
    });
    if (value.classList.contains('active')) {
      value.classList.remove('active');
      value.classList.add('inactive');
    } else {
      value.classList.add('active');
      value.classList.remove('inactive');
    }
  });
});
