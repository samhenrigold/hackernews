//
// HNFont.swift
//
// A custom font system for iA Writer Quattro—modeled after NYTSwiftFont—that
// supports both dynamic type and weight interpolation via a custom environment key.
//
// Usage Examples:
//
//   // Using a fixed size:
//   Text("Hello")
//       .hnFont(.iaWriter(16))   // defaults to scaling relative to .body
//
//   // Using a system text style with dynamic type & weight override:
//   Text(voteCount)
//       .hnFont(.subheadline, weight: hasVoted ? .bold : .regular)
//
//   // In UIKit:
//   label.font = HNFont.iaWriter(16, relativeTo: .headline).uiFont
//

import SwiftUI
import CoreText
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Bundle.module Fallback

extension Bundle {
    static var hnModule: Bundle {
        return Bundle(for: HNFontBundleToken.self)
    }
}

private final class HNFontBundleToken {}

// MARK: - _CustomFont Protocol

/// A protocol for types that can produce a custom font.
public protocol _CustomFont {
    /// Returns a custom font with the given parameters.
    /// - Parameters:
    ///   - name: The primary font name.
    ///   - accessibilityBoldName: The alternate font name to use when accessibility bold is enabled.
    ///   - bundle: The bundle containing the font file.
    ///   - size: The base size.
    ///   - relativeTo: The text style to scale relative to (or nil for fixed sizing).
    ///   - file: The file from which this is called (for debugging).
    ///   - line: The line number.
    static func custom(
        withName name: String,
        accessibilityBoldName: String?,
        bundle: Bundle,
        size: CGFloat,
        relativeTo style: Font.TextStyle?,
        file: StaticString,
        line: UInt
    ) -> Self
}

// MARK: - HNFont

/// A custom font token that produces both SwiftUI.Font and platform fonts.
/// It carries an optional “wght” override that lets you adjust or even interpolate weight.
public struct HNFont: Sendable, _CustomFont {
    
    enum Properties {
        case custom(name: String,
                    accessibilityBoldName: String?,
                    bundle: Bundle,
                    size: CGFloat,
                    style: Font.TextStyle?,
                    file: StaticString,
                    line: UInt,
                    weightOverride: CGFloat?)  // optional numeric override for the variable “wght” axis
        case system(style: Font.TextStyle, design: Font.Design?, weight: Font.Weight?)
        case systemFixed(size: CGFloat, weight: Font.Weight?, design: Font.Design?)
    }
    
    let properties: Properties
    
    init(_ properties: Properties) {
        self.properties = properties
    }
    
    // MARK: _CustomFont Conformance
    
    public static func custom(
        withName name: String,
        accessibilityBoldName: String?,
        bundle: Bundle,
        size: CGFloat,
        relativeTo style: Font.TextStyle?,
        file: StaticString,
        line: UInt
    ) -> HNFont {
        return HNFont(.custom(name: name,
                              accessibilityBoldName: accessibilityBoldName,
                              bundle: bundle,
                              size: size,
                              style: style,
                              file: file,
                              line: line,
                              weightOverride: nil))
    }
    
    // MARK: Weight Override
    
    /// Returns a new HNFont token with the “wght” axis override set.
    func withWeight(_ weight: CGFloat) -> HNFont {
        switch properties {
        case .custom(let name, let accessibilityBoldName, let bundle, let size, let style, let file, let line, _):
            return HNFont(.custom(name: name,
                                  accessibilityBoldName: accessibilityBoldName,
                                  bundle: bundle,
                                  size: size,
                                  style: style,
                                  file: file,
                                  line: line,
                                  weightOverride: weight))
        default:
            return self
        }
    }
    
    // MARK: SwiftUI Conversion
    
    /// Converts this token into a SwiftUI.Font.
    public func swiftUIFont(legibilityWeight: LegibilityWeight? = nil) -> Font {
        switch properties {
        case .custom(let name, let accessibilityBoldName, let bundle, let size, let style, let file, let line, let weightOverride):
            bundle.loadFontsIfNecessary(file: file, line: line)
            
            let finalName: String = {
                #if canImport(UIKit)
                if let legWeight = legibilityWeight, legWeight == .bold, let alt = accessibilityBoldName {
                    return alt
                }
                #endif
                return name
            }()
            
            if let style = style {
                if let weightOverride = weightOverride {
                    // Build a UIFontDescriptor with the “wght” axis override.
                    let baseDescriptor = UIFontDescriptor(name: finalName, size: size)
                    let variations = ["wght": weightOverride]
                    let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
                    let descriptor = baseDescriptor.addingAttributes(attributes)
                    let uiFont = UIFont(descriptor: descriptor, size: size)
                    let scaled = UIFontMetrics(forTextStyle: style.uiFontTextStyle).scaledFont(for: uiFont)
                    return Font(scaled)
                } else {
                    return Font.custom(finalName, size: size, relativeTo: style)
                }
            } else {
                if let weightOverride = weightOverride {
                    let baseDescriptor = UIFontDescriptor(name: finalName, size: size)
                    let variations = ["wght": weightOverride]
                    let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
                    let descriptor = baseDescriptor.addingAttributes(attributes)
                    let uiFont = UIFont(descriptor: descriptor, size: size)
                    return Font(uiFont)
                } else {
                    return Font.custom(finalName, fixedSize: size)
                }
            }
            
        case .system(let style, let design, let weight):
            return Font.system(style, design: design).weight(weight ?? .regular)
            
        case .systemFixed(let size, let weight, let design):
            return Font.system(size: size, weight: weight, design: design)
        }
    }
}

#if canImport(UIKit)
public extension HNFont {
    /// Returns a UIKit font (UIFont) corresponding to this HNFont.
    var uiFont: UIFont {
        switch properties {
        case .custom(let name, let accessibilityBoldName, let bundle, let size, let style, let file, let line, let weightOverride):
            bundle.loadFontsIfNecessary(file: file, line: line)
            let finalName: String = {
                if UIAccessibility.isBoldTextEnabled, let alt = accessibilityBoldName {
                    return alt
                }
                return name
            }()
            if let style = style {
                if let weightOverride = weightOverride {
                    let baseDescriptor = UIFontDescriptor(name: finalName, size: size)
                    let variations = ["wght": weightOverride]
                    let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
                    let descriptor = baseDescriptor.addingAttributes(attributes)
                    let uiFont = UIFont(descriptor: descriptor, size: size)
                    return UIFontMetrics(forTextStyle: style.uikitTextStyle).scaledFont(for: uiFont)
                } else {
                    let baseFont = UIFont(name: finalName, size: size) ?? UIFont.systemFont(ofSize: size)
                    return UIFontMetrics(forTextStyle: style.uikitTextStyle).scaledFont(for: baseFont)
                }
            } else {
                if let weightOverride = weightOverride {
                    let baseDescriptor = UIFontDescriptor(name: finalName, size: size)
                    let variations = ["wght": weightOverride]
                    let attributes = [UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations]
                    let descriptor = baseDescriptor.addingAttributes(attributes)
                    return UIFont(descriptor: descriptor, size: size)
                } else {
                    return UIFont(name: finalName, size: size) ?? UIFont.systemFont(ofSize: size)
                }
            }
            
        case .system(let style, _, _):
            let baseFont = UIFont.preferredFont(forTextStyle: style.uikitTextStyle)
            return baseFont
        case .systemFixed(let size, let weight, _):
            return UIFont.systemFont(ofSize: size, weight: weight?.uikitWeight ?? .regular)
        }
    }
}

private extension Font.TextStyle {
    var uikitTextStyle: UIFont.TextStyle {
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

private extension Font.Weight {
    var uikitWeight: UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin:       return .thin
        case .light:      return .light
        case .regular:    return .regular
        case .medium:     return .medium
        case .semibold:   return .semibold
        case .bold:       return .bold
        case .heavy:      return .heavy
        case .black:      return .black
        default:          return .regular
        }
    }
}
#endif

// MARK: - Convenience iA Writer Constructors

public extension Font {
    /// Returns an iA Writer font token.
    ///
    /// This is the unified entry point. When you supply a fixed size, it creates a token that scales
    /// relative to the provided text style (defaulting to .body). The default “regular” weight is 450.
    static func iaWriter(
        _ size: CGFloat,
        relativeTo style: Font.TextStyle? = .body,
        file: StaticString = #file,
        line: UInt = #line
    ) -> HNFont {
        return HNFont.custom(
            withName: "iAWriterQuattroV-Regular",
            accessibilityBoldName: nil,
            bundle: .hnModule,
            size: size,
            relativeTo: style,
            file: file,
            line: line
        ).withWeight(450)
    }
    
    /// Returns an iA Writer font token based solely on a text style.
    ///
    /// This overload uses the preferred font size for the given text style.
    static func iaWriter(
        relativeTo style: Font.TextStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) -> HNFont {
        let baseFont = UIFont.preferredFont(forTextStyle: style.uikitTextStyle)
        return Self.iaWriter(baseFont.pointSize, relativeTo: style, file: file, line: line)
    }
}

// MARK: - Custom Environment Key for Font Weight Override

private struct HNFontWeightKey: EnvironmentKey {
    static let defaultValue: Font.Weight? = nil
}

extension EnvironmentValues {
    var hnFontWeight: Font.Weight? {
        get { self[HNFontWeightKey.self] }
        set { self[HNFontWeightKey.self] = newValue }
    }
}

// MARK: - HNFont View Modifiers

public extension View {
    /// Applies an HNFont token to the view.
    /// - Parameters:
    ///   - hnFont: The custom font token.
    ///   - legibilityWeight: An optional legibility weight override.
    func hnFont(_ hnFont: HNFont, legibilityWeight: LegibilityWeight? = nil) -> some View {
        modifier(HNFontViewModifier(hnFont: hnFont, legibilityWeightOverride: legibilityWeight))
    }
    
    /// Overload that accepts a system text style and an optional weight override.
    /// This convenience maps the text style to an iA Writer token using dynamic type.
    func hnFont(
        _ textStyle: Font.TextStyle,
        weight: Font.Weight? = nil,
        legibilityWeight: LegibilityWeight? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> some View {
        var token = Font.iaWriter(relativeTo: textStyle, file: file, line: line)
        if let weight = weight {
            token = token.withWeight(mapFontWeight(weight))
        }
        return self.hnFont(token, legibilityWeight: legibilityWeight)
    }
}

/// A helper that maps SwiftUI Font.Weight to numeric values for the “wght” axis.
private func mapFontWeight(_ weight: Font.Weight) -> CGFloat {
    switch weight {
    case .ultraLight: return 400
    case .thin:       return 400
    case .light:      return 425
    case .regular:    return 450
    case .medium:     return 500
    case .semibold:   return 625
    case .bold:       return 700
    case .heavy:      return 775
    case .black:      return 900
    default:          return 450
    }
}

private struct HNFontViewModifier: ViewModifier {
    let hnFont: HNFont
    let legibilityWeightOverride: LegibilityWeight?
    
    @Environment(\.legibilityWeight) private var legibilityWeightEnv
    @Environment(\.hnFontWeight) private var envFontWeight
    
    init(hnFont: HNFont, legibilityWeightOverride: LegibilityWeight? = nil) {
        self.hnFont = hnFont
        self.legibilityWeightOverride = legibilityWeightOverride
    }
    
    func body(content: Content) -> some View {
        let legibilityWeight = legibilityWeightOverride ?? legibilityWeightEnv
        let adjustedFont: HNFont = {
            if let envFontWeight = envFontWeight {
                return hnFont.withWeight(mapFontWeight(envFontWeight))
            } else {
                return hnFont
            }
        }()
        return content.font(adjustedFont.swiftUIFont(legibilityWeight: legibilityWeight))
    }
}

// MARK: - Bundle Font Loading (Simplified)

private extension Bundle {
    /// Loads fonts from this bundle if they haven’t been registered yet.
    /// (Implement registration via CTFontManagerRegisterFontURLs as needed.)
    func loadFontsIfNecessary(file: StaticString, line: UInt) {
        // In this simplified example, we assume fonts are already registered.
    }
}
