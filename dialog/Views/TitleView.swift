//
//  TitleView.swift
//  Dialog
//
//  Created by Reardon, Bart  on 19/3/21.
//

import Foundation
import SwiftUI
import Textual

struct TitleView: View {

    @ObservedObject var observedData: DialogUpdatableContent
    
    var textAlignment: HorizontalAlignment = .center
    var frameAlignment: Alignment = .center
    var textOffset: CGFloat = 0
    
    init(observedData: DialogUpdatableContent) {
        self.observedData = observedData
        self.textOffset = observedData.appProperties.titleFontOffset
        
        switch observedData.appProperties.titleFontAlignment.lowercased() {
        case "left":
            self.textAlignment = .leading
            self.frameAlignment = .leading
        case "right":
            self.textAlignment = .trailing
            self.frameAlignment = .trailing
            if observedData.appProperties.titleFontOffset > 0 {
                // When using offsets and right alignment we want to ensure the offset is in the correct direction
                self.textOffset = observedData.appProperties.titleFontOffset * -1
            }
        default:
            self.textAlignment = .center
            self.frameAlignment = .center
        }
    }

    var body: some View {
            VStack(alignment: textAlignment) {
                InlineText(observedData.args.titleOption.value, parser: ColoredMarkdownParser())
                    .font(
                        observedData.appProperties.titleFontName.isEmpty ?
                            .system(size: observedData.appProperties.titleFontSize, weight: observedData.appProperties.titleFontWeight) :
                                .custom(observedData.appProperties.titleFontName, size: observedData.appProperties.titleFontSize)
                    )
                    .accessibilityHint(observedData.args.titleOption.value)
                    
                if observedData.args.subTitleOption.present {
                    InlineText(observedData.args.subTitleOption.value, parser: ColoredMarkdownParser())
                        .font(
                            observedData.appProperties.titleFontName.isEmpty ?
                                .system(size: observedData.appProperties.titleFontSize-10, weight: observedData.appProperties.titleFontWeight) :
                                    .custom(observedData.appProperties.titleFontName, size: observedData.appProperties.titleFontSize-10)
                        )
                        .accessibilityHint(observedData.args.subTitleOption.value)
                }
                    
            }
            .fontWeight(observedData.appProperties.titleFontWeight)
            .foregroundColor(observedData.appProperties.titleFontColour)
            .padding(appDefaults.topPadding)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .offset(x: textOffset)
    }
}

extension Text {
    func titleFont(fontName: String = "", fontSize: CGFloat = 30, fontWeight: Font.Weight = .bold) -> Text {
        if fontName.isEmpty {
            return self
                .font(.system(size: fontSize, weight: fontWeight))
        }
        return self
            .font(.custom(fontName, size: fontSize))
            .fontWeight(fontWeight)
    }
}
