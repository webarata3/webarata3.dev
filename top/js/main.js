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

const userAgent = window.navigator.userAgent.toLowerCase();

const warningMs = `
<div id="warning">!!! お使いのブラウザでは、このサイトの情報が正しく表示されません。</div>
 <div id="ms">
  <img src="/image/chrome.png">
  <div class="chrome">
  <div>Google Chromeを今すぐお試しください</div>
 <div>Windows 10のための高速で安全なブラウザー</div>
 </div>
 <div class="confirm_chrome">
  <span>いいえ結構です</span>
  <a href="https://www.google.com/intl/ja_ALL/chrome/">今すぐ使う</a>
 </div>
</div>`;

if (userAgent.indexOf('edge') !== -1) {
  const ms = document.createElement('div');
  ms.innerHTML = warningMs;

  const body = document.querySelector('body');
  body.insertBefore(ms, body.firstChild);
}
