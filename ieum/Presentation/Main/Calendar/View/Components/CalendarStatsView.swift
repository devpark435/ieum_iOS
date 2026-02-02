import UIKit
import SnapKit
import Then

final class CalendarStatsView: UIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.Slate.s50
        $0.layer.cornerRadius = 16
    }
    
    private let statsLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g800
        $0.numberOfLines = 2
    }
    
    private let emojiImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "feeling-good")
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g600
        $0.numberOfLines = 2
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
        containerView.addSubview(statsLabel)
        containerView.addSubview(emojiImageView)
        containerView.addSubview(descriptionLabel)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        emojiImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        statsLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalTo(emojiImageView.snp.leading).offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(statsLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(emojiImageView.snp.leading).offset(-16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(totalDays: Int, recordedDays: Int, selectedFilter: CalendarRecordType?) {
        // 통계 텍스트 업데이트
        let highlightText = "\(totalDays)일 중 \(recordedDays)일"
        let fullText = "\(highlightText) 작성완료"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: Colors.Primary.green, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont.ieum(UIFont.IeumFont.Heading.h3), range: nsRange)
        }
        
        statsLabel.attributedText = attributedString
        
        // 설명 텍스트 업데이트
        let filterName = selectedFilter?.title ?? "기록"
        descriptionLabel.text = "내 몸의 흐름을 조금씩 기록하고 있어요.\n이 기록이 회복의 리듬이 될 거예요."
        
        // 이모지 업데이트 (필터에 따라)
        if let filter = selectedFilter {
            emojiImageView.image = UIImage(named: filter.iconName)
        } else {
            emojiImageView.image = UIImage(named: "feeling-good")
        }
    }
}
