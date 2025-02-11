import SwiftUI
import UIKit

// Returns a base font size for a given SwiftUI text style.
private func baseFontSize(for textStyle: Font.TextStyle) -> CGFloat {
    switch textStyle {
    case .largeTitle:  return 34
    case .title:       return 28
    case .title2:      return 22
    case .title3:      return 20
    case .headline:    return 17
    case .subheadline: return 15
    case .body:        return 17
    case .callout:     return 16
    case .footnote:    return 13
    case .caption:     return 12
    case .caption2:    return 11
    @unknown default:  return 17
    }
}

extension Font.TextStyle {
    /// Maps SwiftUI text styles to their corresponding UIFont.TextStyle.
    var uiFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
}

public extension Font {
    enum IBMPlexSans {
        case regular
        case medium
        case bold
        
        /// Returns the PostScript name for the font variant.
        public var name: String {
            switch self {
            case .regular: return "IBMPlexSans-Regular"
            case .medium:  return "IBMPlexSans-Medium"
            case .bold:    return "IBMPlexSans-Bold"
            }
        }
    }
    
    /// Returns an IBM Plex Sans font with dynamic scaling.
    static func ibmPlexSans(_ type: IBMPlexSans, textStyle: Font.TextStyle) -> Font {
        let baseSize = baseFontSize(for: textStyle)
        return .custom(type.name, size: baseSize, relativeTo: textStyle)
    }
    
    /// Returns an IBM Plex Sans font with a fixed size.
    static func ibmPlexSans(_ type: IBMPlexSans, size: CGFloat) -> Font {
        .custom(type.name, size: size)
    }
    
    enum IAWriterQuattro {
        case regular
        case medium
        case semibold
        case bold
        
        /// The PostScript name for the iA Writer Quattro font.
        public var fontName: String { "iAWriterQuattroV-Regular" }
        
        /// The weight value for the variable font's "wght" axis.
        public var weightValue: CGFloat {
            switch self {
            case .regular:  return 450
            case .medium:   return 500
            case .semibold: return 650
            case .bold:     return 700
            }
        }
    }
    
    /// Returns an iA Writer Quattro font with dynamic scaling.
    static func iaWriterQuattro(_ type: IAWriterQuattro, textStyle: Font.TextStyle) -> Font {
        let baseSize = baseFontSize(for: textStyle)
        let baseDescriptor = UIFontDescriptor(name: type.fontName, size: baseSize)
        let variations = ["wght": type.weightValue, "SPCG": 0.0]
        let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
        let descriptorWithVariation = baseDescriptor.addingAttributes(attributes)
        let uiFont = UIFont(descriptor: descriptorWithVariation, size: baseSize)
        let scaledUIFont = UIFontMetrics(forTextStyle: textStyle.uiFontTextStyle).scaledFont(for: uiFont)
        return Font(scaledUIFont)
    }
    
    /// Returns an iA Writer Quattro font with a fixed size.
    static func iaWriterQuattro(_ type: IAWriterQuattro, size: CGFloat) -> Font {
        let baseDescriptor = UIFontDescriptor(name: type.fontName, size: size)
        let variations = ["wght": type.weightValue, "SPCG": 0.0]
        let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
        let descriptorWithVariation = baseDescriptor.addingAttributes(attributes)
        let uiFont = UIFont(descriptor: descriptorWithVariation, size: size)
        return Font(uiFont)
    }
}
