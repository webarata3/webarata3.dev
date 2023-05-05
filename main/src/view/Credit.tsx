import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const Credit = (): React.ReactElement => {
  const [open, setOpen] = useState<Boolean>(false);
  const navigate = useNavigate();

  useEffect(() => {
    setTimeout(() => {
      setOpen(true);
    }, 200);
  }, []);

  const onClickClose = () => {
    setOpen(false);
  };

  return (
    <div>
      <div className="dialog__wrapper"></div>
      <div className={`dialog__main${open ? ' dialog__main-open' : ''}`}
        onTransitionEnd={() => {
          if (!open) navigate('/home');
        }}>
        <div className="dialog__header">
          <h2 className="dialog__title">クレジット</h2>
          <button type="button" className="dialog__close-button"
            onClick={onClickClose}>
            <svg className="dialog__close-icon">
              <use xlinkHref="image/close.svg#close"></use>
            </svg>
          </button>
        </div>
        <div className="dialog__content">
          <div className="credit__license">
            <h2 className="credit__license-title">
              <a href="https://react.dev/" className="main__link">React</a>
            </h2>
            <pre className="credit__license-content">{`
MIT License

Copyright (c) Meta Platforms, Inc. and affiliates.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.`}
            </pre>
          </div>
          <div className="credit__license">
            <h2 className="credit__license-title">
              <a href="https://reactrouter.com/en/main" className="main__link">React Router</a>
            </h2>
            <pre className="credit__license-content">{`
MIT License

Copyright (c) React Training LLC 2015-2019 Copyright (c) Remix Software Inc. 2020-2021 Copyright (c) Shopify Inc. 2022-2023

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.`}
            </pre>
          </div>
          <div className="credit__license">
            <h2 className="credit__license-title">
              <a href="https://fontawesome.com/license/free" className="main__link">Font Awesome Free License</a>
            </h2>
            <pre className="credit__license-content">CC BY 4.0 License</pre>
          </div>
          <div className="credit__license">
            <h2 className="credit__license-title">
              <a href="https://fonts.google.com/noto/specimen/Noto+Sans+JP?query=Noto+san" className="main__link">Noto Sans Japanese</a>
            </h2>
            <pre className="credit__license-content">Open Font License</pre>
          </div>
          <div className="credit__license">
            <h2 className="credit__license-title"><a href="https://fonts.google.com/specimen/Poiret+One?query=Poiret" className="main__link">Poiret One</a>
            </h2>
            <pre className="credit__license-content">Open Font License</pre>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Credit;
