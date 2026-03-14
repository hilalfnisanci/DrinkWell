import SwiftUI

struct BottomBannerAdContainer: View {
    var body: some View {
        if let bannerAdUnitID = AdConfiguration.bannerAdUnitID {
            VStack(spacing: 0) {
                Divider()
                BannerAdView(adUnitID: bannerAdUnitID)
                    .frame(height: 50)
                    .background(Color(UIColor.systemBackground))
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
