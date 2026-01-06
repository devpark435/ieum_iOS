import UIKit
import SnapKit
import Then

final class TreatmentDetailRow: UIView {
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Slate.s900
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Slate.s900
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
    }
    
    init(item: Post.DisplayItem) {
        super.init(frame: .zero)
        setupUI(item: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(item: Post.DisplayItem) {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        iconImageView.image = UIImage(named: item.iconName)
        titleLabel.text = item.title
        contentLabel.text = item.content
        
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}

