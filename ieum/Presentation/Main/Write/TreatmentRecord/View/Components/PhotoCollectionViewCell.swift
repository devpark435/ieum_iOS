import UIKit
import SnapKit
import Then

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.tintColor = Colors.Gray.g600
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Properties
    
    var onDelete: (() -> Void)?
    
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
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
    }
    
    private func setupLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.width.height.equalTo(20)
        }
    }
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    // MARK: - Actions
    
    @objc private func didTapDelete() {
        onDelete?()
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onDelete = nil
    }
}
