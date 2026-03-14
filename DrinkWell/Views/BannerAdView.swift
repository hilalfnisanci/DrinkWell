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
        private var hasLoaded = false
        
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
            if bannerView.rootViewController == nil, let rootViewController {
                bannerView.rootViewController = rootViewController
            }

            if bannerView.adUnitID != parent.adUnitID {
                bannerView.adUnitID = parent.adUnitID
            }

            if !hasLoaded, bannerView.rootViewController != nil {
                bannerView.load(Request())
                hasLoaded = true
            }
        }
        
        // MARK: - BannerViewDelegate
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            #if DEBUG
            print("Banner ad successfully loaded")
            #endif
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            #if DEBUG
            print("Failed to load banner ad: \(error.localizedDescription)")
            #endif
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
