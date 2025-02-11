import SwiftUI
import WidgetKit

public enum ThemeContext {
    case app
    case widget
}

@MainActor
@Observable
public final class Theme {
    private static let useSystemFontKey = "useSystemFont"
    private static let useMonospacedKey = "useMonospaced"
    private static let commentFontSizeKey = "commentFontSize"
    private static let titleFontSizeKey = "titleFontSize"
    
    public static let defaultCommentFontSize: Double = 12
    public static let minCommentFontSize: Double = 10
    public static let maxCommentFontSize: Double = 18
    
    public static let defaultTitleFontSize: Double = 16
    public static let defaultWidgetTitleFontSize: Double = 13
    public static let minTitleFontSize: Double = 14
    public static let maxTitleFontSize: Double = 22
    
    private let context: ThemeContext
    
    public var useSystemFont: Bool {
        didSet {
            UserDefaults.standard.set(useSystemFont, forKey: Self.useSystemFontKey)
        }
    }
    
    public var useMonospaced: Bool {
        didSet {
            UserDefaults.standard.set(useMonospaced, forKey: Self.useMonospacedKey)
        }
    }
    
    public var commentFontSize: Double {
        didSet {
            let clamped = commentFontSize.clamped(to: Self.minCommentFontSize...Self.maxCommentFontSize)
            if clamped != commentFontSize {
                commentFontSize = clamped
            }
            UserDefaults.standard.set(commentFontSize, forKey: Self.commentFontSizeKey)
        }
    }
    
    public var commentFontSizeText: String {
        String(format: "%.1f", commentFontSize)
    }
    
    public var titleFontSize: Double {
        didSet {
            let clamped = titleFontSize.clamped(to: Self.minTitleFontSize...Self.maxTitleFontSize)
            if clamped != titleFontSize {
                titleFontSize = clamped
            }
            UserDefaults.standard.set(titleFontSize, forKey: Self.titleFontSizeKey)
        }
    }
    
    /// Returns the font for titles. Uses a default widget size in widget context.
    public var titleFont: Font {
        let size = context == .app ? titleFontSize : Self.defaultWidgetTitleFontSize
        return userMonoFont(size: size, weight: .bold)
    }
    
    /// Returns the font for comment text.
    public var commentTextFont: Font {
        userMonoFont(size: commentFontSize, weight: .regular)
    }
    
    /// Returns the font for comment authors.
    public var commentAuthorFont: Font {
        userMonoFont(size: commentFontSize, weight: .bold)
    }
    
    public var commentMetadataFont: Font {
        userSansFont(size: commentFontSize, weight: .medium)
    }
    
    /// Returns a monospaced font for UI text. If monospacing is disabled, the sans-serif font is used.
    public func userMonoFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if !useMonospaced {
            return userSansFont(size: size, weight: weight)
        }
        if useSystemFont {
            return .system(size: size, weight: weight, design: .default)
        }
        switch weight {
        case .regular:
            return .iaWriterQuattro(.regular, size: size)
        case .bold:
            return .iaWriterQuattro(.bold, size: size)
        case .medium:
            return .iaWriterQuattro(.medium, size: size)
        default:
            return .iaWriterQuattro(.regular, size: size)
        }
    }
    
    /// Returns a sans-serif font for UI text.
    public func userSansFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
    
    public init(context: ThemeContext = .app) {
        self.context = context
        self.useSystemFont = UserDefaults.standard.object(forKey: Self.useSystemFontKey) as? Bool ?? false
        self.useMonospaced = UserDefaults.standard.object(forKey: Self.useMonospacedKey) as? Bool ?? true
        self.commentFontSize = UserDefaults.standard.object(forKey: Self.commentFontSizeKey) as? Double ?? Self.defaultCommentFontSize
        self.titleFontSize = UserDefaults.standard.object(forKey: Self.titleFontSizeKey) as? Double ?? Self.defaultTitleFontSize
    }
}

extension Double {
  fileprivate func clamped(to range: ClosedRange<Double>) -> Double {
    min(max(self, range.lowerBound), range.upperBound)
  }
}
