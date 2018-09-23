'use strict';

const liEls = document.querySelectorAll('.skill_list li');
let selectedLiEl = document.querySelector('.skill_list .selected');

const descriptionEls = document.querySelectorAll('.skill .description > div');
let selectedDescriptionEl = descriptionEls[0];

liEls.forEach((item, index) => {
  item.addEventListener('click', (event) => {
    if (item.classList.contains('selected')) return;
    selectedLiEl.classList.remove('selected');

    item.classList.add('selected');
    selectedLiEl = item;

    selectedDescriptionEl.classList.remove('show');
    selectedDescriptionEl.classList.add('hide');
    selectedDescriptionEl = descriptionEls[index];
    selectedDescriptionEl.classList.remove('hide');
    selectedDescriptionEl.classList.add('show');
  });
});
