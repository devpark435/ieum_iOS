import UIKit
import SnapKit
import Then

/// 광고 카드 뷰
final class AdCardView: UIView {
    
    // MARK: - Properties
    
    var onLearnMoreTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.Gray.g100
        $0.layer.cornerRadius = 12
    }
    
    private let iconImageView = UIImageView().then {
        $0.image = Images.Icon.hospital
        $0.tintColor = Colors.Primary.green
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "회복이 필요하다면, 요양병원도 고려해보세요"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
    }
    
    private let learnMoreButton = UIButton().then {
        $0.setTitle("더 알아보기▶", for: .normal)
        $0.setTitleColor(Colors.Primary.lightGreen, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.backgroundColor = Colors.Primary.lightGreen.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    private let pageIndicatorView = UIView().then {
        $0.backgroundColor = Colors.Gray.g400
        $0.layer.cornerRadius = 2
    }
    
    private let pageIndicatorView2 = UIView().then {
        $0.backgroundColor = Colors.Gray.g400
        $0.layer.cornerRadius = 2
    }
    
    private let indicatorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
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
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(learnMoreButton)
        
        indicatorStackView.addArrangedSubview(pageIndicatorView)
        indicatorStackView.addArrangedSubview(pageIndicatorView2)
        addSubview(indicatorStackView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(learnMoreButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        learnMoreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        pageIndicatorView.snp.makeConstraints {
            $0.width.equalTo(4)
            $0.height.equalTo(4)
        }
        
        pageIndicatorView2.snp.makeConstraints {
            $0.width.equalTo(4)
            $0.height.equalTo(4)
        }
        
        indicatorStackView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        learnMoreButton.addTarget(self, action: #selector(didTapLearnMore), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapLearnMore() {
        onLearnMoreTapped?()
    }
}

