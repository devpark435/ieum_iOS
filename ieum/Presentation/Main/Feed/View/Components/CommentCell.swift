import UIKit
import SnapKit
import Then

final class CommentCell: UITableViewCell {
    
    static let identifier = "CommentCell"
    
    // MARK: - Properties
    
    var onReplyTapped: (() -> Void)?
    var onMenuTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200 // Placeholder color
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }
    
    private let usernameLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g950
    }
    
    private let commentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Gray.g800
        $0.numberOfLines = 0
    }
    
    private let footerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Gray.g400
        $0.text = "1분 전" // Mock
    }
    
    private let replyButton = UIButton().then {
        $0.setTitle("답글 달기", for: .normal)
        $0.setTitleColor(Colors.Gray.g500, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
    }
    
    // TODO: 댓글 좋아요 API에 isLiked/likesCount가 추가되면 다시 활성화
    private let likeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        $0.isHidden = true
    }
    
    private let likeButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 14)
        $0.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        $0.tintColor = Colors.Gray.g400
    }
    
    private let likeCountLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Gray.g400
        $0.text = "0"
    }
    
    // Using UIButton for menu interaction, but configured for UIMenu if possible, 
    // or just trigger the onMenuTapped callback to show external dropdown/action sheet.
    // User requested "Dropdown like" behavior.
    // We can attach a UIMenu to this button for iOS 14+.
    let menuButton = UIButton().then {
        $0.setImage(Images.Icon.ellipsis, for: .normal)
        $0.tintColor = Colors.Gray.g400
        $0.showsMenuAsPrimaryAction = true
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
        contentView.addSubview(contentStackView)
        contentView.addSubview(likeStackView) // Right side
        
        contentStackView.addArrangedSubview(usernameLabel)
        contentStackView.addArrangedSubview(commentLabel)
        contentStackView.addArrangedSubview(footerStackView)
        
        footerStackView.addArrangedSubview(dateLabel)
        footerStackView.addArrangedSubview(replyButton)
        
        likeStackView.addArrangedSubview(likeButton)
        likeStackView.addArrangedSubview(likeCountLabel)
        
        // Menu button position?
        // Usually top right. Like button is usually near content or separate.
        // User didn't specify position, assuming standard layout.
        // Like button and count usually below comment or to the right.
        // Let's put Like on the right side of the cell (Instagram style: small heart on right).
        // Menu button? Maybe Next to Like? Or Top Right.
        // Let's put Menu Top Right, Like Center Right vertically or aligned with content.
        
        contentView.addSubview(menuButton)
    }
    
    private func setupLayout() {
        // Updated margins to 24
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24) // 24pt
            $0.width.height.equalTo(32)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-24) // 24pt
            $0.width.height.equalTo(20)
        }
        
        likeStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview() // Center vertically or align?
            // Usually Instagram puts heart on the far right, vertically centered to content.
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        // Adjust content stack to not overlap with like/menu
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(likeStackView.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        // Since Menu is Top Right, and Like is Right (vertically centered?), they might overlap.
        // Let's adjust: Menu is for "Report", Like is for interaction.
        // If we follow Instagram: Heart is small on the right. Reply is in footer.
        // "..." is usually visible on long press or swipe, or small icon.
        // Let's put Menu next to User name or Top Right.
        
        // Re-adjusting layout:
        // [Profile] [Name ... Menu]
        //           [Content]
        //           [Date Reply]           [Like Heart]
        
        menuButton.snp.remakeConstraints {
            $0.centerY.equalTo(usernameLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.height.equalTo(20)
        }
        
        likeStackView.snp.remakeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(4) // Align with footer?
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        // Actually, Instagram puts the heart to the right of the comment text block.
        // Let's keep it simple:
        // Content takes available width minus padding.
        // Menu is top right.
        // Like button... maybe inside footer? Or right side.
        // User said: "댓글엔 좋아요 달 수 있어야하고 좋아요 카운트도 있어야해"
        // Let's put Like Stack on the right side, vertically centered.
        
        likeStackView.snp.remakeConstraints {
            $0.centerY.equalTo(contentView)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        contentStackView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(likeStackView.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        // Menu button needs to be somewhere.
        // If we use UIMenu on "...", where is it?
        // Let's put it next to date in footer? Or top right?
        // Top right conflicts with Like stack if centered.
        // Let's put Menu top right, Like stack bottom right?
        // Or Menu is part of the content stack (Name row).
        
        // Let's try:
        // [Profile] [Name]         [Menu]
        //           [Content]
        //           [Date Reply]   [Like Heart]
        
        menuButton.snp.remakeConstraints {
            $0.top.equalTo(profileImageView)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.height.equalTo(16)
        }
        
        likeStackView.snp.remakeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(contentStackView)
        }
        
        // Re-adjust content stack trailing
        contentStackView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(menuButton.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func setupActions() {
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        // Menu button action handled via UIMenu assignment in configure or here
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(username: String, content: String, date: String, isReply: Bool, isLiked: Bool, likeCount: Int, isMyComment: Bool) {
        usernameLabel.text = username
        commentLabel.text = content
        // dateLabel.text = date
        
        likeCountLabel.text = "\(likeCount)"
        let heartImage = isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = isLiked ? Colors.Red.r500 : Colors.Gray.g400
        likeCountLabel.textColor = isLiked ? Colors.Red.r500 : Colors.Gray.g400
        
        if isReply {
            profileImageView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(52) // Indent + 24 margin base? (24 + 28 = 52)
                $0.width.height.equalTo(24)
            }
            replyButton.isHidden = true
        } else {
            profileImageView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(24)
                $0.width.height.equalTo(32)
            }
            replyButton.isHidden = false
        }
        
        setupMenu(isMyComment: isMyComment)
    }
    
    private func setupMenu(isMyComment: Bool) {
        if isMyComment {
            let editAction = UIAction(title: "수정", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.onEditTapped?()
            }
            
            let deleteAction = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.onDeleteTapped?()
            }
            
            menuButton.menu = UIMenu(title: "", children: [editAction, deleteAction])
        } else {
            let reportAction = UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive) { [weak self] _ in
                self?.onMenuTapped?()
            }
            
            menuButton.menu = UIMenu(title: "", children: [reportAction])
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapReply() {
        onReplyTapped?()
    }
    
    @objc private func didTapLike() {
        onLikeTapped?()
    }
}
