'use strict';

const works = document.querySelectorAll('.works > article');
let position = 0;

function resetPosition(position) {
  works.forEach((work, index) => {
    const loc = index + position;
    work.classList.remove('work');
    work.style.left = 180 + loc * 500 + 'px';
    let scale = loc >= 0 ? 1 - 0.5 * loc : 1 + 0.5 * loc;
    scale = scale < 0 ? 0 : scale;
    work.style.transform = `scale(${scale}, ${scale})`;
  });
}

resetPosition(position);

document.querySelector('main').addEventListener('click', event => {
  if (event.button === 0 && !event.shiftKey) {
    works.forEach((elm, index) => {
      elm.style.animation = `left${index + position + 1} 0.6s ease 0s 1 normal forwards`;
    });
    position--;
    resetPosition(position);
  } else if (event.shiftKey) {
    works.forEach((elm, index) => {
      elm.style.animation = `right${index + position + 2} 0.6s ease 0s 1 normal forwards`;
    });
    position++;
    resetPosition(position);
  }
});
