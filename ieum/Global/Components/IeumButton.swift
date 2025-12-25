import UIKit
import SnapKit
import Then

class IeumButton: UIButton {
    
    // MARK: - Types
    
    struct Style {
        let backgroundColor: UIColor
        let borderColor: UIColor
        let titleColor: UIColor
    }
    
    // MARK: - Properties
    
    private var styles: [UInt: Style] = [:]
    
    // MARK: - Initializer
    
    init(title: String? = nil, radius: CGFloat = 12) {
        super.init(frame: .zero)
        
        if let title = title {
            setTitle(title, for: .normal)
        }
        
        setupBaseStyle(radius: radius)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupBaseStyle(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.borderWidth = 1.0 // 테두리 두께 기본값
        titleLabel?.font = .ieum(UIFont.IeumFont.Btn.medium)
        
        // 기본 스타일 (아무것도 설정 안했을 때)
        setStyle(backgroundColor: Colors.Primary.green, titleColor: Colors.white, for: .normal)
        setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
    }
    
    private func setupLayout() {
        // 내부 높이 제약조건 제거 (외부에서 유연하게 설정 가능하도록)
    }
    
    // MARK: - Configuration Methods
    
    /// 상태별 스타일을 설정합니다.
    /// - Parameters:
    ///   - backgroundColor: 배경색
    ///   - borderColor: 테두리색 (기본값 투명)
    ///   - titleColor: 텍스트색
    ///   - state: 적용할 버튼 상태 (.normal, .highlighted, .disabled)
    func setStyle(backgroundColor: UIColor, borderColor: UIColor = Colors.transparent, titleColor: UIColor, for state: UIControl.State) {
        let style = Style(backgroundColor: backgroundColor, borderColor: borderColor, titleColor: titleColor)
        styles[state.rawValue] = style
        
        // setTitleColor는 UIButton 기본 기능 사용
        self.setTitleColor(titleColor, for: state)
        
        // 현재 상태가 방금 설정한 state라면 즉시 업데이트
        if self.state == state {
            updateAppearance()
        }
        
        // Normal 상태 설정 시, 다른 상태가 비어있으면 기본값으로 활용할 수도 있음 (선택사항)
        if state == .normal {
            updateAppearance()
        }
    }
    
    // MARK: - State Handling
    
    private func updateAppearance() {
        // 현재 상태에 맞는 스타일 찾기
        // highlighted나 disabled가 없으면 normal 스타일을 따르도록 폴백 로직 추가 가능
        let currentState = self.state
        
        var style: Style?
        
        // selected 상태 처리 추가
        if currentState.contains(.disabled) {
            style = styles[UIControl.State.disabled.rawValue]
        } else if currentState.contains(.selected) {
            style = styles[UIControl.State.selected.rawValue]
        } else if currentState.contains(.highlighted) {
            style = styles[UIControl.State.highlighted.rawValue]
        } else {
            style = styles[UIControl.State.normal.rawValue]
        }
        
        // 스타일이 없으면 Normal로 폴백
        if style == nil {
            style = styles[UIControl.State.normal.rawValue]
        }
        
        guard let finalStyle = style else { return }
        
        self.backgroundColor = finalStyle.backgroundColor
        self.layer.borderColor = finalStyle.borderColor.cgColor
    }
    
    // 상태 변경 감지하여 스타일 업데이트
    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }
    
    override var isHighlighted: Bool {
        didSet { updateAppearance() }
    }
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
}
