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
    
    // 커스텀 타이틀 라벨 (가운데 정렬을 위해 사용)
    private let customTitleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Btn.large) // 기본 폰트 Large
        $0.textAlignment = .center
    }
    
    // 뱃지 뷰 (병기 표시용)
    private let badgeView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20 // 40x40 기준
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }
    
    private let badgeLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Btn.large) // 뱃지도 Large
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    // 컨텐츠 스택뷰 (타이틀 + 뱃지)
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10 // 뱃지와 타이틀 사이 간격 10
        $0.alignment = .center
        $0.distribution = .fill
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Initializer
    
    init(title: String? = nil, radius: CGFloat = 12) {
        super.init(frame: .zero)
        
        if let title = title {
            // setTitle 대신 커스텀 라벨 사용
            customTitleLabel.text = title
            // 접근성을 위해 기본 title도 설정하지만 hidden 처리 등 고려
            setTitle(title, for: .normal)
            setTitleColor(.clear, for: .normal) // 기본 타이틀 숨김
        }
        
        setupBaseStyle(radius: radius)
        setupLayout()
        setupBadge()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if state == .normal {
            customTitleLabel.text = title
            super.setTitleColor(.clear, for: .normal)
        }
    }
    
    // MARK: - Setup
    
    private func setupBaseStyle(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.borderWidth = 1.0
        // titleLabel?.font = .ieum(UIFont.IeumFont.Btn.medium) // 사용 안함
        
        // 그림자 적용 (radius가 0보다 클 때만 적용하거나 항상 적용)
        if radius > 0 {
            layer.shadowColor = UIColor(hex: "#C2C2C2").cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 30 // Blur 30에 해당
        }
        
        setStyle(backgroundColor: Colors.Primary.green, titleColor: Colors.white, for: .normal)
        setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
    }
    
    private func setupLayout() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(customTitleLabel)
        contentStackView.addArrangedSubview(badgeView)
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            // 좌우 여백 확보 (긴 텍스트 대응)
            $0.leading.greaterThanOrEqualToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    private func setupBadge() {
        badgeView.addSubview(badgeLabel)
        
        badgeView.snp.makeConstraints {
            $0.width.height.equalTo(40) // 40x40 원형
        }
        
        badgeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - Configuration Methods
    
    func setStyle(backgroundColor: UIColor, borderColor: UIColor = Colors.transparent, titleColor: UIColor, for state: UIControl.State) {
        let style = Style(backgroundColor: backgroundColor, borderColor: borderColor, titleColor: titleColor)
        styles[state.rawValue] = style
        
        // 커스텀 라벨 색상 변경을 위해 저장해두고 updateAppearance에서 처리
        if self.state == state || (state == .normal && styles[self.state.rawValue] == nil) {
            updateAppearance()
        }
    }
    
    /// 뱃지 텍스트 설정 (nil이면 숨김)
    func setBadge(text: String?) {
        if let text = text {
            badgeLabel.text = text
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
    }
    
    // MARK: - State Handling
    
    private func updateAppearance() {
        let currentState = self.state
        
        var style: Style?
        
        if currentState.contains(.disabled) {
            style = styles[UIControl.State.disabled.rawValue]
        } else if currentState.contains(.selected) {
            style = styles[UIControl.State.selected.rawValue]
        } else if currentState.contains(.highlighted) {
            style = styles[UIControl.State.highlighted.rawValue]
        } else {
            style = styles[UIControl.State.normal.rawValue]
        }
        
        if style == nil {
            style = styles[UIControl.State.normal.rawValue]
        }
        
        guard let finalStyle = style else { return }
        
        self.backgroundColor = finalStyle.backgroundColor
        self.layer.borderColor = finalStyle.borderColor.cgColor
        self.customTitleLabel.textColor = finalStyle.titleColor
    }
    
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
