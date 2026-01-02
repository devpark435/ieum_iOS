import UIKit
import SnapKit
import Then

final class RecordItemView: UIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Slate.s900
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
    }
    
    private let plusButton = UIButton().then {
        $0.setImage(UIImage(named: "circleplus-icon"), for: .normal)
    }
    
    // MARK: - Initializer
    
    init(iconName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(plusButton)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(18)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
        }
        
        plusButton.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.trailing.equalToSuperview().inset(18)
            $0.width.height.equalTo(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(plusButton)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}

