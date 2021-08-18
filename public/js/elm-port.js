app.ports.getOffset.subscribe(function (id) {
  const elem = document.querySelector(`#${id}`);
  const top = parseInt(getComputedStyle(elem).getPropertyValue('top').replace('px', ''));
  const left = parseInt(getComputedStyle(elem).getPropertyValue('left').replace('px', ''));
  app.ports.getOffsetReceiver.send({ top: top, left: left });
});

app.ports.getComputedHeight.subscribe(function (id) {
  const elem = document.querySelector(`#${id}`);
  const height = parseInt(getComputedStyle(elem).getPropertyValue('height').replace('px', ''));
  app.ports.getComputedHeightReceiver.send(height);
});
