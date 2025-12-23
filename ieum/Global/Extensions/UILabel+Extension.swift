import UIKit

extension UILabel {
    
    /// 행간(LineHeight)을 포함하여 텍스트와 폰트를 설정합니다.
    func setIeumText(_ text: String?, style: UIFont.FontDescription, color: UIColor? = nil) {
        guard let text = text else {
            self.text = nil
            return
        }
        
        let font = UIFont.ieum(style)
        self.font = font
        if let color = color {
            self.textColor = color
        }
        
        if let lineHeightPercent = style.lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            let lineHeightMultiple = lineHeightPercent / 100.0
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
             paragraphStyle.alignment = self.textAlignment
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedString.length))
            
            self.attributedText = attributedString
        } else {
            self.text = text
        }
    }
}
