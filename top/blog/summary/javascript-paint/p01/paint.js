'use strict';

let canvas;
let ctx;

function init() {
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');

    registerEvent();
}

function registerEvent() {
    canvas.addEventListener('mousedown', function(e) {
        if (e.button !== 0) return;

        const rect = e.target.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x + 1, y + 1);
        ctx.stroke();
    });
}

init();
