import UIKit
import SnapKit
import Then

final class TreatmentDetailRowView: UIView {
    
    // MARK: - UI Components
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Slate.s900
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM) // Bold or Medium implied
        $0.textColor = Colors.Slate.s900
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500 // Assuming subtitle color
        $0.numberOfLines = 0
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.Slate.s200
    }
    
    // MARK: - Initializer
    
    init(iconName: String, title: String, content: String) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configure(iconName: iconName, title: title, content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(dividerView)
        addSubview(contentLabel)
    }
    
    private func setupLayout() {
        // [Icon] Title
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
        }
        
        // Divider below header
        dividerView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // Content
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8) // Spacing between rows
        }
    }
    
    private func configure(iconName: String, title: String, content: String) {
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
        contentLabel.text = content
    }
}

