'use strict';

let canvas;
let ctx;

let canvasState;

class CanvasState {
    constructor() {
        this.drawing = false;
        this.x = 0;
        this.y = 0;
        this.beforeX = 0;
        this.beforeY = 0;
    }

    setPos(e) {
        const rect = e.target.getBoundingClientRect();
        this.x = e.clientX - rect.left;
        this.y = e.clientY - rect.top;
    }

    movePos() {
        this.beforeX = this.x;
        this.beforeY = this.y;
    }
}

function init() {
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');

    canvasState = new CanvasState();

    registerEvent();
}

function registerEvent() {
    canvas.addEventListener('mousedown', function(e) {
        if (e.button !== 0) return;

        canvasState.setPos(e);
        canvasState.movePos();
        canvasState.drawing = true;
    });

    canvas.addEventListener('mousemove', function(e) {
        if (!canvasState.drawing) return;

        canvasState.setPos(e);

        ctx.beginPath();
        ctx.moveTo(canvasState.beforeX, canvasState.beforeY);
        ctx.lineTo(canvasState.x, canvasState.y);
        ctx.stroke();

        canvasState.movePos();
    });

    canvas.addEventListener('mouseup', function(e) {
        canvasState.drawing = false;
    });
}

init();
