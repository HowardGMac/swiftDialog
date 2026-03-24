//
//  BannerImageView.swift
//  Dialog
//
//  Created by Reardon, Bart  on 27/3/21.
//

import Foundation
import SwiftUI
import Textual

struct BannerImageView: View {

    @ObservedObject var observedData: DialogUpdatableContent

    //var bannerHeight: CGFloat = 0
    var bannerWidth: CGFloat = 0
    var maxBannerHeight: CGFloat = 130
    var minBannerHeight: CGFloat = 100

    let blurRadius: CGFloat = 5
    let opacity: CGFloat = 1 //0.8
    let blurOffset: CGFloat = 3

    init(observedDialogContent: DialogUpdatableContent) {
        self.observedData = observedDialogContent
        writeLog("Displaying banner image \(observedDialogContent.args.bannerImage.value)")
        bannerWidth = observedDialogContent.appProperties.windowWidth
        if observedDialogContent.args.bannerHeight.present {
            maxBannerHeight = observedDialogContent.args.bannerHeight.value.floatValue()
            minBannerHeight = maxBannerHeight
        }
    }

    var body: some View {
        ZStack {
            if observedData.args.bannerImage.value.range(of: "colo[u]?r=", options: .regularExpression) != nil {
                if let colourValue = observedData.args.bannerImage.value.split(usingRegex: "colo[u]?r=").last {
                    SolidColourView(colourValue: colourValue.split(usingRegex: ",").first ?? "accent",
                                    withGradient: colourValue.split(usingRegex: ",").last != "nogradient"
                    )
                    .frame(maxHeight: maxBannerHeight)
                }
            } else if observedData.args.bannerImage.value.range(of: "gradient=", options: .regularExpression) != nil {
                if let colourValues = observedData.args.bannerImage.value.split(usingRegex: "gradient=").last {
                    // angle degrees is the last element if it contains the text angle=, otherwise it's 90
                    GradientColourView(colourValues: colourValues.split(usingRegex: ":").first ?? "accent",
                                       angleDegrees: Double(colourValues.split(usingRegex: ":").last?.split(usingRegex: "angle=").last ?? "90") ?? 90 )
                    .frame(maxHeight: maxBannerHeight)
                }
            } else {
                DisplayImage(observedData.args.bannerImage.value, corners: false, showBackgroundOnError: true)
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: bannerWidth, alignment: .topLeading)
                    .frame(maxHeight: maxBannerHeight)
                    .frame(minHeight: minBannerHeight)
                    .clipped()
            }
            if observedData.args.bannerTitle.present {
                TitleView(observedData: observedData)
                    .shadow(radius: observedData.appProperties.titleFontShadow ? blurRadius : 0)
            }
        }
    }
}

