import React from "react";

const mainStyle = (deg: number, top: number, left: number): React.CSSProperties => {
  return {
    position: 'absolute',
    top: `${top}px`,
    left: `${left}px`,
    transform: `rotate(${deg}deg)`,
    transformOrigin: 'left top'
  };
};

export default mainStyle;
