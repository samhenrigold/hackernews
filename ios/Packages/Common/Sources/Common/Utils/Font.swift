import SwiftUI
import UIKit

public extension Font {
    /// Custom font variants for iA Writer Quattro.
    enum IAWriterQuattro {
        case thin       // 400 – use this for especially light text
        case regular    // 450 – our default, since 400 is too thin
        case medium     // 500
        case semibold   // 650
        case bold       // 700
        
        /// The PostScript name for the iA Writer Quattro variable font.
        /// (Make sure your font file’s embedded name matches.)
        public var fontName: String { "iAWriterQuattroV-Regular" }
        
        /// The weight value for the “wght” axis.
        public var weightValue: CGFloat {
            switch self {
            case .thin:     return 400
            case .regular:  return 450
            case .medium:   return 500
            case .semibold: return 650
            case .bold:     return 700
            }
        }
    }
    
    /// Returns a dynamic (i.e. Dynamic Type–friendly) iA Writer Quattro font.
    /// The font scales relative to the provided SwiftUI text style.
    static func iaWriterQuattro(_ type: IAWriterQuattro, textStyle: Font.TextStyle) -> Font {
        // Use the system’s preferred font size for the given text style as our base.
        let baseSize = UIFont.preferredFont(forTextStyle: textStyle.uiFontTextStyle).pointSize
        let baseDescriptor = UIFontDescriptor(name: type.fontName, size: baseSize)
        let variations = ["wght": type.weightValue, "SPCG": 0.0] // SPCG axis reserved for spacing.
        let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
        let descriptor = baseDescriptor.addingAttributes(attributes)
        let uiFont = UIFont(descriptor: descriptor, size: baseSize)
        // Scale the font appropriately for Dynamic Type.
        let scaledUIFont = UIFontMetrics(forTextStyle: textStyle.uiFontTextStyle).scaledFont(for: uiFont)
        return Font(scaledUIFont)
    }
    
    /// Returns a fixed-size iA Writer Quattro font.
    static func iaWriterQuattro(_ type: IAWriterQuattro, size: CGFloat) -> Font {
        let baseDescriptor = UIFontDescriptor(name: type.fontName, size: size)
        let variations = ["wght": type.weightValue, "SPCG": 0.0]
        let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
        let descriptor = baseDescriptor.addingAttributes(attributes)
        let uiFont = UIFont(descriptor: descriptor, size: size)
        return Font(uiFont)
    }
}

// MARK: - Dynamic Type Helpers

extension Font.TextStyle {
    /// Maps SwiftUI text styles to the corresponding UIFont.TextStyle
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
