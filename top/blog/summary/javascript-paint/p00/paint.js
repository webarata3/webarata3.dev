'use strict';

let canvas;
let ctx;

let canvasState;

let color;
let lineWidth;
let lineWidthRange;
let opacity;
let opacityRange;
let drawToolList;

class CanvasState {
    constructor() {
        this.currentDrawTool = 'pen';
        this.imageData = null;
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

const drawTool = {
    pen: {
        draw: function () {
            ctx.beginPath();
            ctx.moveTo(canvasState.beforeX, canvasState.beforeY);
            ctx.lineTo(canvasState.x, canvasState.y);
            ctx.stroke();
            canvasState.movePos();
        }
    },
    line: {
        draw: function () {
            ctx.putImageData(canvasState.imageData, 0, 0);
            ctx.beginPath();
            ctx.moveTo(canvasState.beforeX, canvasState.beforeY);
            ctx.lineTo(canvasState.x, canvasState.y);
            ctx.stroke();
        }
    },
    circle: {
        draw: function () {
            ctx.putImageData(canvasState.imageData, 0, 0);
            ctx.beginPath();
            ctx.arc(canvasState.beforeX, canvasState.beforeY, Math.abs(canvasState.x - canvasState.beforeX), 0, Math.PI * 2, false);
            ctx.stroke();
        }
    },
    fillCircle: {
        draw: function () {
            ctx.putImageData(canvasState.imageData, 0, 0);
            ctx.beginPath();
            ctx.arc(canvasState.beforeX, canvasState.beforeY, Math.abs(canvasState.x - canvasState.beforeX), 0, Math.PI * 2, false);
            ctx.fill();
        }
    },
    rect: {
        draw: function () {
            ctx.putImageData(canvasState.imageData, 0, 0);
            ctx.strokeRect(canvasState.beforeX, canvasState.beforeY, canvasState.x - canvasState.beforeX, canvasState.y - canvasState.beforeY);
        }
    },
    fillRect: {
        draw: function () {
            ctx.putImageData(canvasState.imageData, 0, 0);
            ctx.fillRect(canvasState.beforeX, canvasState.beforeY, canvasState.x - canvasState.beforeX, canvasState.y - canvasState.beforeY);
        }
    }
};

function init() {
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');

    color = document.getElementById('color');
    lineWidth = document.getElementById('lineWidth');
    lineWidthRange = document.getElementById('lineWidthRange');
    opacity = document.getElementById('opacity');
    opacityRange = document.getElementById('opacityRange');
    drawToolList = document.querySelectorAll('[name="drawTool"]');

    canvasState = new CanvasState();

    registerEvent();
}

function registerEvent() {
    canvas.addEventListener('mousedown', function(e) {
        if (e.button !== 0) return;
        canvasState.setPos(e);

        canvasState.imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

        canvasState.movePos();
        canvasState.drawing = true;
    });

    canvas.addEventListener('mousemove', function(e) {
        if (!canvasState.drawing) return;

        canvasState.setPos(e);

        drawTool[canvasState.currentDrawTool].draw();
    });

    canvas.addEventListener('mouseup', function(e) {
        canvasState.drawing = false;
    });

    color.addEventListener('change', function(e) {
        ctx.strokeStyle = e.target.value;
        ctx.fillStyle = e.target.value;
    });

    lineWidth.addEventListener('change', function (e) {
        changeLineWidth(e);
        lineWidthRange.value = e.target.value;
    });

    lineWidthRange.addEventListener('change', function (e) {
        changeLineWidth(e);
        lineWidth.value = e.target.value;
    });

    opacity.addEventListener('change', function (e) {
        changeOpacity(e);
        opacityRange.value = e.target.value;
    });

    opacityRange.addEventListener('change', function (e) {
        changeOpacity(e);
        opacity.value = e.target.value;
    });

    for (let i = 0; i < drawToolList.length; i++) {
        drawToolList[i].addEventListener('click', function (e) {
            canvasState.currentDrawTool = e.target.value;
        });
    }
}

// 数値であるかチェック
function isNumber(val) {
    if (val == null || val.trim() === '') {
        return false;
    }
    return !isNaN(val);
}

function changeLineWidth(e) {
    const num = e.target.value;
    if (!isNumber(num)) return;
    const lineWidthValue = parseInt(num, 10);
    if (lineWidthValue < 1 || lineWidthValue > 100) return;
    ctx.lineWidth = lineWidthValue;
}

function changeOpacity(e) {
    const num = e.target.value;
    if (!isNumber(num)) return;
    const opacityValue = parseFloat(num);
    if (opacityValue < 0 || opacityValue > 1) return;
    ctx.globalAlpha = opacityValue;
}

init();
