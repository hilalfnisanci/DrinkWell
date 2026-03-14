import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let availableWidth: CGFloat
    
    init(adUnitID: String, availableWidth: CGFloat) {
        self.adUnitID = adUnitID
        self.availableWidth = availableWidth
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
        context.coordinator.updateBanner(width: availableWidth, rootViewController: uiView.window?.rootViewController)
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        private var parent: BannerAdView
        private var lastAppliedWidth: CGFloat = 0
        
        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView()
            banner.adUnitID = parent.adUnitID
            banner.delegate = self
            return banner
        }()
        
        init(_ parent: BannerAdView) {
            self.parent = parent
        }

        func updateBanner(width: CGFloat, rootViewController: UIViewController?) {
            let validWidth = max(width, 0)
            guard validWidth > 0 else { return }

            if bannerView.rootViewController == nil, let rootViewController {
                bannerView.rootViewController = rootViewController
            }

            if bannerView.adUnitID != parent.adUnitID {
                bannerView.adUnitID = parent.adUnitID
            }

            // Reload only when width changes meaningfully to avoid noisy repeated requests.
            if abs(lastAppliedWidth - validWidth) > 1 {
                bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: validWidth)
                bannerView.load(Request())
                lastAppliedWidth = validWidth
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
