import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 広告管理（バナー + インタースティシャル）
///
/// インタースティシャルは1セッションにつき最大1回表示。
/// セッション = アプリがフォアグラウンドに来てから完全にバックグラウンドに移行するまで。
class AdManager {
  AdManager._();

  // テスト広告ユニットID（リリース時に差し替え）
  static const _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static InterstitialAd? _interstitialAd;
  static bool _interstitialShownThisSession = false;

  /// AdMob SDK を初期化し、リクエスト設定を適用
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        maxAdContentRating: MaxAdContentRating.pg,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // バナー広告
  // ---------------------------------------------------------------------------

  /// 結果画面用のバナー広告を生成
  static BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // インタースティシャル広告
  // ---------------------------------------------------------------------------

  /// インタースティシャル広告を事前読み込み
  static void preloadInterstitial() {
    if (_interstitialShownThisSession || _interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// インタースティシャル広告を表示（セッション内1回限り）
  ///
  /// 広告がロード済みかつ未表示の場合のみ表示する。
  /// 戻り値: 広告を表示した場合 true
  static bool showInterstitialIfReady() {
    if (_interstitialShownThisSession || _interstitialAd == null) return false;

    _interstitialAd!.show();
    _interstitialShownThisSession = true;
    _interstitialAd = null;
    return true;
  }

  /// セッションリセット（AppLifecycleState.resumed で呼ぶ）
  static void resetSession() {
    _interstitialShownThisSession = false;
    preloadInterstitial();
  }

  /// リソース解放
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
