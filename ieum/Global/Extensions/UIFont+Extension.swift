import UIKit

extension UIFont {
    
    // MARK: - Font System
    
    struct IeumFont {
        
        // MARK: - Label
        static let label = style(size: 15, weight: .medium, lineHeight: nil)
        
        // MARK: - Button (btn)
        enum Btn {
            static let large = style(size: 20, weight: .semibold, lineHeight: nil)
            static let medium = style(size: 17, weight: .bold, lineHeight: nil)
            static let small = style(size: 15, weight: .bold, lineHeight: nil)
        }
        
        // MARK: - Heading
        enum Heading {
            static let h1 = style(size: 28, weight: .bold, lineHeight: 130)
            static let h2 = style(size: 24, weight: .bold, lineHeight: nil)
            static let h3 = style(size: 20, weight: .bold, lineHeight: nil)
            static let h4 = style(size: 18, weight: .bold, lineHeight: nil)
            static let h5 = style(size: 17, weight: .bold, lineHeight: 130)
        }
        
        // MARK: - Text
        enum Text {
            static let bodyM = style(size: 17, weight: .semibold, lineHeight: 140)
            static let bodyXSmall = style(size: 15, weight: .regular, lineHeight: 140)
        }
        
        // MARK: - Helper
        enum Helper {
            static let characterCount = style(size: 14, weight: .semibold, lineHeight: nil)
            
            enum AboveBtn {
                static let m = style(size: 14, weight: .regular, lineHeight: nil)
                static let l = style(size: 18, weight: .regular, lineHeight: nil)
            }
        }
        
        // MARK: - Input
        enum Input {
            static let placeholder = style(size: 20, weight: .semibold, lineHeight: nil)
        }
        
        private static func style(size: CGFloat, weight: UIFont.Weight, lineHeight: CGFloat?) -> FontDescription {
            return FontDescription(size: size, weight: weight, lineHeight: lineHeight)
        }
    }
    
    struct FontDescription {
        let size: CGFloat
        let weight: UIFont.Weight
        let lineHeight: CGFloat? // % 단위 (예: 130 = 130%)
    }
    
    static func ieum(_ style: FontDescription) -> UIFont {
        if let font = UIFont(name: "PretendardVariable", size: style.size) {
            return font
        }
        return .systemFont(ofSize: style.size, weight: style.weight)
    }
}
