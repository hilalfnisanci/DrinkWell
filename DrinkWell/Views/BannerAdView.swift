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
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    class Coordinator: NSObject, BannerViewDelegate {
        let parent: BannerAdView
        
        private(set) lazy var bannerView: BannerView = {
            let banner = BannerView()
            
            // Get screen width for adaptive banner
            let frame = UIScreen.main.bounds
            let viewWidth = frame.size.width
            
            // Set adaptive banner size
            banner.adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
            
            banner.adUnitID = parent.adUnitID
            
            // Get root view controller using modern approach
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                banner.rootViewController = window.rootViewController
            }
            
            banner.delegate = self
            
            // Load the ad
            let request = Request()
            
            banner.load(request)
            
            return banner
        }()
        
        init(_ parent: BannerAdView) {
            self.parent = parent
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
