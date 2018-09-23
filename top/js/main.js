'use strict';

const modalEl = document.getElementById('modal');
const navEl = document.querySelector('nav');

document.getElementById('menuButton').addEventListener('click', (event) => {
  navEl.classList.remove('hide');
  navEl.classList.add('show');
  modalEl.classList.remove('hide');
  modalEl.classList.add('show');
});

modalEl.addEventListener('click', (event) => {
  navEl.classList.remove('show');
  navEl.classList.add('hide');
  modalEl.classList.remove('show');
  modalEl.classList.add('hide');
});
