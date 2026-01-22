import UIKit
import SnapKit
import Then
import Kingfisher

/// 피드 포스트 셀
final class FeedPostCell: UITableViewCell {
    
    static let identifier = "FeedPostCell"
    
    // MARK: - Properties
    
    var onLikeTapped: (() -> Void)?
    var onCommentTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onMenuTapped: (() -> Void)?
    var onSeeMoreTapped: (() -> Void)?
    
    private var isLiked = false
    private var isBookmarked = false
    private var isExpanded = false
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Primary.lightGreen
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private let usernameLabel = UILabel().then {
        $0.text = "user_1"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
    }
    
    private let menuButton = UIButton().then {
        $0.setImage(Images.Icon.ellipsis, for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let postImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
    }
    
    // Action Buttons
    private let leftActionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private let rightActionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private let likeButton = UIButton().then {
        $0.setImage(Images.Icon.heart, for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let commentButton = UIButton().then {
        $0.setImage(Images.Icon.message, for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let bookmarkButton = UIButton().then {
        $0.setImage(Images.Icon.bookmark, for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let shareButton = UIButton().then {
        $0.setImage(Images.Icon.share, for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    // MARK: - Content Views
    
    // Daily Post Content (Simple Text)
    private let dailyContentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 3
    }
    
    // Wellness Post Content (Structured)
    private let wellnessContainerView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
    }
    
    // Common See More Button
    private let seeMoreButton = UIButton().then {
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.contentHorizontalAlignment = .left
    }
    
    // Date Label
    private let dateLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall) // Caption size?
        $0.textColor = Colors.Gray.g400
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = Colors.white
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(menuButton)
        contentView.addSubview(postImageView)
        
        contentView.addSubview(leftActionStackView)
        contentView.addSubview(rightActionStackView)
        
        leftActionStackView.addArrangedSubview(likeButton)
        leftActionStackView.addArrangedSubview(commentButton)
        
        rightActionStackView.addArrangedSubview(bookmarkButton)
        rightActionStackView.addArrangedSubview(shareButton)
        
        contentView.addSubview(dailyContentLabel)
        contentView.addSubview(wellnessContainerView)
        contentView.addSubview(seeMoreButton)
        contentView.addSubview(dateLabel)
    }
    
    private func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalTo(profileImageView)
        }
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(profileImageView)
            $0.width.height.equalTo(24)
        }
        
        postImageView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        leftActionStackView.snp.makeConstraints {
            $0.top.equalTo(postImageView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
        }
        
        rightActionStackView.snp.makeConstraints {
            $0.top.equalTo(postImageView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        commentButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        bookmarkButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        shareButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        // Content Areas (Initially Hidden or 0 height)
        // They will be remade in configure()
        
        seeMoreButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
            // Top/Bottom dynamic
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.top.equalTo(seeMoreButton.snp.bottom).offset(4)
        }
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    
    private func createMoodRow(mood: Int) -> UIView {
        let container = UIView()
        
        let stack = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        
        // Mood Icon & Text
        // Assuming mood int maps to some assets or text
        let moodText: String
        let moodIconName: String
        
        switch mood {
        case 1: moodText = "아주 좋아요"; moodIconName = "feeling-very-good"
        case 2: moodText = "좋아요"; moodIconName = "feeling-good"
        case 3: moodText = "보통이에요"; moodIconName = "feeling-normal"
        case 4: moodText = "나빠요"; moodIconName = "feeling-bad"
        case 5: moodText = "아주 나빠요"; moodIconName = "feeling-very-bad"
        default: moodText = "보통이에요"; moodIconName = "feeling-normal"
        }
        
        let iconView = UIImageView(image: UIImage(named: moodIconName)).then {
            $0.contentMode = .scaleAspectFit
        }
        
        let label = UILabel().then {
            $0.text = "오늘의 기분 : \(moodText)"
            $0.font = .ieum(UIFont.IeumFont.Text.bodySmall) // Bold title-like?
            $0.textColor = Colors.Gray.g950
        }
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        container.addSubview(stack)
        
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        return container
    }
    
    private func createTreatmentItemView(item: Post.DisplayItem) -> UIView {
        let container = UIView()
        
        let headerStack = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }
        
        let iconView = UIImageView(image: UIImage(named: item.iconName)).then {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = Colors.Gray.g950
        }
        
        let titleLabel = UILabel().then {
            $0.text = item.title
            $0.font = .ieum(UIFont.IeumFont.Text.bodyM) // Title Font
            $0.textColor = Colors.Gray.g950
        }
        
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleLabel)
        
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        // Status Badge Logic
        var statusView: UIView?
        
        switch item.type {
        case .medication(let isTaken):
            let badge = UIView()
            let stack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 4
                $0.alignment = .center
            }
            
            let iconName = isTaken ? "checkmark.circle.fill" : "xmark.circle.fill"
            let iconColor = isTaken ? Colors.Green.g500 : Colors.Gray.g400
            let text = isTaken ? "복용 완료" : "미복용"
            // Text color change to Black for better readability
            let textColor = Colors.Gray.g950 
            
            let sIcon = UIImageView(image: UIImage(systemName: iconName)).then {
                $0.tintColor = iconColor
                $0.contentMode = .scaleAspectFit
            }
            let sLabel = UILabel().then {
                $0.text = text
                $0.textColor = textColor
                $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
            }
            
            stack.addArrangedSubview(sIcon)
            stack.addArrangedSubview(sLabel)
            badge.addSubview(stack)
            
            sIcon.snp.makeConstraints { $0.width.height.equalTo(16) }
            stack.snp.makeConstraints { $0.edges.equalToSuperview() }
            
            statusView = badge
            
        case .diet(let amount):
            let badge = UIView()
            let stack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 4
                $0.alignment = .center
            }
            
            // Map amount to asset
            let assetName: String
            switch amount {
            case .wellEaten: assetName = "meal-good"
            case .smallAmount: assetName = "meal-small"
            case .barelyEaten: assetName = "meal-poor"
            }
            
            let sIcon = UIImageView(image: UIImage(named: assetName)).then {
                $0.contentMode = .scaleAspectFit
            }
            let sLabel = UILabel().then {
                $0.text = amount.displayName
                $0.textColor = Colors.Gray.g950
                $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
            }
            
            stack.addArrangedSubview(sIcon)
            stack.addArrangedSubview(sLabel)
            badge.addSubview(stack)
            
            sIcon.snp.makeConstraints { $0.width.height.equalTo(16) }
            stack.snp.makeConstraints { $0.edges.equalToSuperview() }
            
            statusView = badge
            
        case .basic:
            break
        }
        
        if let statusView = statusView {
            headerStack.addArrangedSubview(UIView()) // Spacer
            headerStack.addArrangedSubview(statusView)
        }
        
        // Content Label
        let contentLabel = UILabel().then {
            $0.text = item.content
            $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall) // Content Font
            $0.textColor = Colors.Gray.g950
            $0.numberOfLines = 3 // Default to 3 lines
            $0.tag = 100 // Tag to identify content label
        }
        
        container.addSubview(headerStack)
        
        // Medication might not have content text displayed if it's empty
        let hasContent = !item.content.isEmpty
        if hasContent {
            container.addSubview(contentLabel)
        }
        
        headerStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        if hasContent {
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(headerStack.snp.bottom).offset(4)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            headerStack.snp.makeConstraints {
                $0.bottom.equalToSuperview() // If no content, header is bottom
            }
        }
        
        return container
    }
    
    // MARK: - Configuration
    
    func configure(with post: Post) {
        usernameLabel.text = post.userNickname
        isLiked = post.isLiked
        
        // Reset State
        isExpanded = false
        dailyContentLabel.numberOfLines = 3
        dailyContentLabel.isHidden = true
        wellnessContainerView.isHidden = true
        wellnessContainerView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        seeMoreButton.setTitle("더보기", for: .normal)
        
        // Date
        let date = Date(timeIntervalSince1970: TimeInterval(post.createdAt))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        dateLabel.text = formatter.string(from: date)
        
        // Image
        if let images = post.images, let firstImage = images.first, let imageURL = URL(string: firstImage.url) {
            postImageView.isHidden = false
            postImageView.backgroundColor = Colors.Gray.g200
            postImageView.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
            postImageView.snp.remakeConstraints {
                $0.top.equalTo(profileImageView.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(300)
            }
        } else {
            postImageView.isHidden = true
            postImageView.kf.cancelDownloadTask()
            postImageView.image = nil
            postImageView.snp.remakeConstraints {
                $0.top.equalTo(profileImageView.snp.bottom).offset(0)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0)
            }
        }
        
        // Layout anchor for content
        let contentTopAnchor = postImageView.isHidden ? profileImageView.snp.bottom : postImageView.snp.bottom
        // Actually, Actions are below image. Content is below Actions.
        leftActionStackView.snp.remakeConstraints {
            $0.top.equalTo(contentTopAnchor).offset(12)
            $0.leading.equalToSuperview()
        }
        rightActionStackView.snp.remakeConstraints {
            $0.top.equalTo(contentTopAnchor).offset(12)
            $0.trailing.equalToSuperview()
        }
        
        let actionBottomAnchor = leftActionStackView.snp.bottom
        
        // --- Content Logic ---
        
        var showSeeMore = false
        
        if post.type == .daily {
            // Daily Post
            dailyContentLabel.isHidden = false
            dailyContentLabel.text = post.content
            dailyContentLabel.numberOfLines = 3
            
            dailyContentLabel.snp.remakeConstraints {
                $0.top.equalTo(actionBottomAnchor).offset(12)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            // Check if text is long
            // Roughly 80 chars or contains newlines might exceed 3 lines
            if let content = post.content {
                showSeeMore = content.count > 80 || content.contains("\n")
            }
            
        } else if post.type == .wellness {
            // Wellness Post
            wellnessContainerView.isHidden = false
            
            // 1. Mood (Index 0)
            if let mood = post.mood {
                let moodView = createMoodRow(mood: mood)
                wellnessContainerView.addArrangedSubview(moodView)
            }
            
            // 2. Items (Index 1...)
            let items = post.displayItems
            for item in items {
                let itemView = createTreatmentItemView(item: item)
                wellnessContainerView.addArrangedSubview(itemView)
            }
            
            // Layout Constraints
            wellnessContainerView.snp.remakeConstraints {
                $0.top.equalTo(actionBottomAnchor).offset(12)
                $0.leading.trailing.equalToSuperview()
            }
            
            // Initial Visibility & See More Logic
            // Rule: Show Mood (Idx 0) + First Item (Idx 1, max 3 lines).
            // Hide subsequent items (Idx 2+).
            // If there are subsequent items OR first item is long -> Show See More.
            
            if items.count > 1 {
                // If we have more than 1 item (e.g. Symptoms + Medication), we definitely need See More
                // because we are hiding the 2nd item onwards.
                showSeeMore = true
            } else if let firstItemContent = items.first?.content {
                // If only 1 item, check if it's long
                if firstItemContent.count > 80 || firstItemContent.contains("\n") {
                    showSeeMore = true
                }
            }
            
            // Apply Initial State
            for (index, view) in wellnessContainerView.arrangedSubviews.enumerated() {
                if index == 0 {
                    // Mood: Always visible
                    view.isHidden = false
                } else if index == 1 {
                    // First Item: Visible, max 3 lines initially
                    view.isHidden = false
                    if let label = view.viewWithTag(100) as? UILabel {
                        label.numberOfLines = 3
                    }
                } else {
                    // Subsequent Items: Hidden initially
                    view.isHidden = true
                }
            }
        }
        
        seeMoreButton.isHidden = !showSeeMore
        
        seeMoreButton.snp.remakeConstraints {
            if !dailyContentLabel.isHidden {
                $0.top.equalTo(dailyContentLabel.snp.bottom).offset(4)
            } else {
                $0.top.equalTo(wellnessContainerView.snp.bottom).offset(4)
            }
            $0.leading.equalToSuperview()
            $0.height.equalTo(showSeeMore ? 20 : 0)
        }
        
        updateLikeButton()
    }
    
    func toggleExpand() {
        isExpanded.toggle()
        
        if !dailyContentLabel.isHidden {
            // Daily Expand
            dailyContentLabel.numberOfLines = isExpanded ? 0 : 3
        } else if !wellnessContainerView.isHidden {
            // Wellness Expand
            // Loop through subviews to update visibility and lines
            for (index, view) in wellnessContainerView.arrangedSubviews.enumerated() {
                if index == 0 { continue } // Mood is always visible
                
                if index == 1 {
                    // First Item: Toggle lines
                    if let label = view.viewWithTag(100) as? UILabel {
                        label.numberOfLines = isExpanded ? 0 : 3
                    }
                } else {
                    // Subsequent Items: Toggle visibility
                    view.isHidden = !isExpanded
                }
            }
        }
        
        seeMoreButton.setTitle(isExpanded ? "접기" : "더보기", for: .normal)
    }
    
    private func updateLikeButton() {
        let image = isLiked ? Images.Icon.heartFill : Images.Icon.heart
        let color = isLiked ? Colors.Red.r500 : Colors.Gray.g950
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = color
    }
    
    private func updateBookmarkButton() {
        let image = isBookmarked ? Images.Icon.bookmarkFill : Images.Icon.bookmark
        bookmarkButton.setImage(image, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func didTapLike() {
        isLiked.toggle()
        updateLikeButton()
        onLikeTapped?()
    }
    
    @objc private func didTapComment() {
        onCommentTapped?()
    }
    
    @objc private func didTapBookmark() {
        isBookmarked.toggle()
        updateBookmarkButton()
        onBookmarkTapped?()
    }
    
    @objc private func didTapShare() {
        onShareTapped?()
    }
    
    @objc private func didTapMenu() {
        onMenuTapped?()
    }
    
    @objc private func didTapSeeMore() {
        toggleExpand()
        onSeeMoreTapped?()
    }
}
