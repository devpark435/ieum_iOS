import UIKit
import SnapKit
import Then

final class RecordShareView: UIView {
    
    // MARK: - Properties
    
    var isChecked: Bool = false {
        didSet {
            updateCheckBoxState()
        }
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "share-icon")
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var checkBoxButton = UIButton().then {
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s300.cgColor
        $0.backgroundColor = Colors.white
        $0.setImage(nil, for: .normal)
        $0.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "커뮤니티에 공유"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Slate.s900
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "체크하시면 커뮤니티에 공개됩니다."
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        containerView.addSubview(checkBoxButton)
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
        
        checkBoxButton.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.trailing.equalToSuperview().inset(18)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(checkBoxButton.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCheckBox() {
        isChecked.toggle()
    }
    
    private func updateCheckBoxState() {
        if isChecked {
            checkBoxButton.backgroundColor = Colors.Emerald.e600
            checkBoxButton.layer.borderWidth = 0
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
            let checkImage = UIImage(systemName: "checkmark", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            checkBoxButton.setImage(checkImage, for: .normal)
        } else {
            checkBoxButton.backgroundColor = Colors.white
            checkBoxButton.layer.borderWidth = 1
            checkBoxButton.layer.borderColor = Colors.Slate.s300.cgColor
            checkBoxButton.setImage(nil, for: .normal)
        }
    }
}

