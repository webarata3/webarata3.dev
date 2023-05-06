import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const Privacy = (): React.ReactElement => {
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
      <div className="dialog__wrapper" onClick={onClickClose}></div>
      <div className={`dialog__main${open ? ' dialog__main-open' : ''}`}
        onTransitionEnd={() => {
          if (!open) navigate('/home');
        }}>
        <div className="dialog__header">
          <h2 className="dialog__title">プライバシーポリシー</h2>
          <button type="button" className="dialog__close-button"
            onClick={onClickClose}>
            <svg className="dialog__close-icon">
              <use xlinkHref="image/close.svg#close"></use>
            </svg>
          </button>
        </div>
        <div className="dialog__content">
          <p className="policy__p">当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を使用しています。このGoogleアナリティクスはデータの収集のためにCookieを使用しています。このデータは匿名で収集されており、個人を特定するものではありません。</p>
          <p className="policy__p"><span>この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。この規約に関しての詳細は</span><a href="https://marketingplatform.google.com/about/analytics/terms/jp/" target="_blank" rel="noreferrer" className="main__link">Googleアナリティクスサービス利用規約のページ</a><span>や</span><a href="https://policies.google.com/technologies/ads?hl=ja" target="_blank" rel="noreferrer" className="main__link">Googleポリシーと規約ページ</a><span>をご覧ください。</span></p>
        </div>
      </div>
    </div>
  );
};

export default Privacy;
