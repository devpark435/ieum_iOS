import UIKit
import SnapKit
import Then

final class AddPhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "AddPhotoCollectionViewCell"
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.Slate.s50
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "circleplus-icon")
        $0.contentMode = .scaleAspectFit
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
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 특별한 처리 불필요
    }
}
