import UIKit
import SnapKit
import Then

final class MoodImageCell: UICollectionViewCell {
    
    static let identifier = "MoodImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        // 그림자 등 스타일은 선택된 셀에만 적용하거나 전체 적용
        $0.layer.shadowColor = Colors.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageName: String, isSelected: Bool) {
        imageView.image = UIImage(named: imageName)
        // 선택 여부에 따라 크기나 투명도 조절 가능
        imageView.alpha = isSelected ? 1.0 : 0.3
        // 크기 애니메이션은 CollectionView Layout이나 ScrollView Delegate에서 처리하는 게 더 부드러움
    }
}

