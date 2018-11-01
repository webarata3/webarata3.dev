'use strict';

const works = document.querySelectorAll('.works > div > article');
const worksCount = works.length;

function resetPosition(position) {
  works.forEach((work, index) => {
    const loc = index + position;
    work.style.left = 180 + loc * 500 + 'px';
    let scale = loc >= 0 ? 1 - 0.5 * loc : 1 + 0.5 * loc;
    scale = scale < 0 ? 0 : scale;
    work.style.transform = `scale(${scale}, ${scale})`;
    console.log(scale);
    if (scale === 1.0) {
      work.style.boxShadow = '2px 2px 4px';
    } else {
      work.style.boxShadow = 'none';
    }
  });
}

let position = 0;
resetPosition(position);

const moveLeftEl = document.querySelector('.moveLeft');
const moveRightEl = document.querySelector('.moveRight');

moveLeftEl.addEventListener('click', () => {
  if (position === -(worksCount - 1)) return;
  works.forEach((elm, index) => {
    elm.style.animation = `left${index + position + 1} 0.6s ease 0s 1 normal forwards`;
  });
  position--;
  resetPosition(position);
});

moveRightEl.addEventListener('click', () => {
  if (position === 0) return;
  works.forEach((elm, index) => {
    elm.style.animation = `right${index + position + 2} 0.6s ease 0s 1 normal forwards`;
  });
  position++;
  resetPosition(position);
});
