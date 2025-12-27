import UIKit
import SnapKit
import Then

/// 플로팅 액션 버튼 (글쓰기 버튼)
final class FloatingActionButton: UIButton {
    
    // MARK: - Properties
    
    var onTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let iconImageView = UIImageView().then {
        $0.image = Images.Icon.pencil
        $0.tintColor = Colors.white
        $0.contentMode = .scaleAspectFit
    }
    
    private let customTitleLabel = UILabel().then {
        $0.text = "글쓰기"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.white
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = Colors.Slate.s900
        layer.cornerRadius = 24
        
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(customTitleLabel)
        addSubview(contentStackView)
    }
    
    private func setupLayout() {
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
    
    private func setupActions() {
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapButton() {
        onTapped?()
    }
}

