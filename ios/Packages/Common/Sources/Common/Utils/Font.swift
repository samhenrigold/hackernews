import SwiftUI
import UIKit

public extension Font {
  enum IBMPlexSans {
    case regular
    case medium
    case bold

    public var name: String {
      switch self {
      case .regular: "IBMPlexSans-Regular"
      case .medium: "IBMPlexSans-Medium"
      case .bold: "IBMPlexSans-Bold"
      }
    }
  }

  enum IBMPlexMono {
    case regular
    case medium
    case bold

    public var name: String {
      switch self {
      case .regular: "IBMPlexMono-Regular"
      case .medium: "IBMPlexMono-Medium"
      case .bold: "IBMPlexMono-Bold"
      }
    }
  }

  static func ibmPlexSans(_ type: IBMPlexSans, size: CGFloat) -> Font {
    .custom(type.name, size: size)
  }
  
  enum IAWriterQuattro {
    case regular
    case medium
    case bold

    /// The postscript name for the variable font file.
    public var fontName: String { "iAWriterQuattroV-Regular" }

    /// The weight value to pass to the variable font’s “wght” axis.
    public var weightValue: CGFloat {
      switch self {
      case .regular: return 400
      case .medium:  return 500
      case .bold:    return 700
      }
    }
  }
  
  /// Creates a SwiftUI Font backed by a UIFont that applies the variable weight.
  static func iaWriterQuattro(_ type: IAWriterQuattro, size: CGFloat) -> Font {
    // Create a UIFontDescriptor for the base font.
    let baseDescriptor = UIFontDescriptor(name: type.fontName, size: size)
    // Create a variation dictionary for the weight axis.
    let variations = ["wght": type.weightValue]
    // kCTFontVariationAttribute is the key Core Text uses for variable fonts.
    let attributes = [
      UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations
    ]
    // Add the variation settings to the font descriptor.
    let descriptorWithVariation = baseDescriptor.addingAttributes(attributes)
    // Create a UIFont from the descriptor.
    let uiFont = UIFont(descriptor: descriptorWithVariation, size: size)
    // Return a SwiftUI Font that wraps the UIFont.
    return Font(uiFont)
  }
}
