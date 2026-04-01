import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = SharedBannerAdService.shared.bannerView(for: adUnitID)
        bannerView.backgroundColor = .clear
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        SharedBannerAdService.shared.updateBanner(
            adUnitID: adUnitID,
            rootViewController: uiView.window?.rootViewController
        )
    }
}

final class SharedBannerAdService: NSObject, BannerViewDelegate {
    static let shared = SharedBannerAdService()

    private var isRequestInFlight = false
    private var hasLoadedAd = false
    private var lastLoadedAdUnitID: String?

    private lazy var sharedBannerView: BannerView = {
        let banner = BannerView()
        banner.adSize = AdSizeBanner
        banner.delegate = self
        banner.backgroundColor = .clear
        return banner
    }()

    private override init() {
        super.init()
    }

    func bannerView(for adUnitID: String) -> BannerView {
        if sharedBannerView.adUnitID != adUnitID {
            sharedBannerView.adUnitID = adUnitID
            hasLoadedAd = false
            lastLoadedAdUnitID = nil
        }

        if sharedBannerView.superview != nil {
            sharedBannerView.removeFromSuperview()
        }

        return sharedBannerView
    }

    func updateBanner(adUnitID: String, rootViewController: UIViewController?) {
        if sharedBannerView.adUnitID != adUnitID {
            sharedBannerView.adUnitID = adUnitID
            hasLoadedAd = false
            lastLoadedAdUnitID = nil
        }

        if sharedBannerView.rootViewController == nil {
            sharedBannerView.rootViewController = rootViewController ?? currentRootViewController()
        } else if rootViewController != nil {
            sharedBannerView.rootViewController = rootViewController
        }

        let needsLoad = !hasLoadedAd || lastLoadedAdUnitID != adUnitID
        guard !isRequestInFlight, needsLoad, sharedBannerView.rootViewController != nil else {
            return
        }

        isRequestInFlight = true
        sharedBannerView.load(Request())
    }

    private func currentRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }

    // MARK: - BannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        isRequestInFlight = false
        hasLoadedAd = true
        lastLoadedAdUnitID = bannerView.adUnitID
        #if DEBUG
        print("Banner ad successfully loaded")
        #endif
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        isRequestInFlight = false
        hasLoadedAd = false
        #if DEBUG
        print("Failed to load banner ad: \(error.localizedDescription)")
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard
                let self,
                let adUnitID = bannerView.adUnitID,
                !adUnitID.isEmpty
            else { return }

            self.updateBanner(adUnitID: adUnitID, rootViewController: bannerView.rootViewController)
        }
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        #if DEBUG
        print("Banner impression recorded")
        #endif
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        #if DEBUG
        print("Banner will present full-screen content")
        #endif
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        #if DEBUG
        print("Banner will dismiss full-screen content")
        #endif
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        #if DEBUG
        print("Banner dismissed full-screen content")
        #endif
    }
}
