import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = context.coordinator.bannerView
        bannerView.backgroundColor = .clear
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = uiView.window?.rootViewController
        }
        context.coordinator.updateBanner(rootViewController: uiView.window?.rootViewController)
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        private var parent: BannerAdView
        private var isRequestInFlight = false
        
        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView()
            banner.adUnitID = parent.adUnitID
            // Keep a compact, classic bottom banner size on iPhone.
            banner.adSize = AdSizeBanner
            banner.delegate = self
            return banner
        }()
        
        init(_ parent: BannerAdView) {
            self.parent = parent
        }

        func updateBanner(rootViewController: UIViewController?) {
            if bannerView.rootViewController == nil {
                bannerView.rootViewController = rootViewController ?? currentRootViewController()
            }

            if bannerView.adUnitID != parent.adUnitID {
                bannerView.adUnitID = parent.adUnitID
            }

            if !isRequestInFlight, bannerView.rootViewController != nil {
                isRequestInFlight = true
                bannerView.load(Request())
            }
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
            #if DEBUG
            print("Banner ad successfully loaded")
            #endif
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            isRequestInFlight = false
            #if DEBUG
            print("Failed to load banner ad: \(error.localizedDescription)")
            #endif
            // Retry once after a short delay when placement has no immediate fill.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self else { return }
                self.updateBanner(rootViewController: self.bannerView.rootViewController)
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
}
