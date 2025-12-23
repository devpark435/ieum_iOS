import UIKit
import SnapKit
import Then

class IeumButton: UIButton {
    
    // MARK: - Properties
    
    private let title: String
    private let type: ButtonType
    
    enum ButtonType {
        case primary
        case secondary
        case square
        case plain
        
        var backgroundColor: UIColor {
            switch self {
            case .primary: return Colors.Primary.green
            case .secondary: return Colors.Primary.lightGreen
            case .square: return Colors.Primary.navy
            case .plain: return Colors.transparent
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .primary: return Colors.white
            case .secondary: return Colors.Gray.g950
            case .square: return Colors.white
            case .plain: return Colors.Gray.g950
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .square: return 8
            default: return 16
            }
        }
    }
    
    // MARK: - Initializer
    
    init(title: String, type: ButtonType = .primary) {
        self.title = title
        self.type = type
        super.init(frame: .zero)
        
        setupStyle()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupStyle() {
        self.setTitle(title, for: .normal)
        self.setTitleColor(type.titleColor, for: .normal)
        self.backgroundColor = type.backgroundColor
        self.layer.cornerRadius = type.cornerRadius
        self.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.medium)
    }
    
    private func setupLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
}
