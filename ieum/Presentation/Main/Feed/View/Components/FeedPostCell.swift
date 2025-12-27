import UIKit
import SnapKit
import Then

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
    
    private let captionLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 3
    }
    
    private let seeMoreButton = UIButton().then {
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.contentHorizontalAlignment = .left
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
        
        contentView.addSubview(captionLabel)
        contentView.addSubview(seeMoreButton)
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
        
        captionLabel.snp.makeConstraints {
            $0.top.equalTo(leftActionStackView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        seeMoreButton.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(20)
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
    
    // MARK: - Configuration
    
    func configure(
        username: String,
        imageUrl: String?,
        caption: String,
        isLiked: Bool = false,
        likesCount: Int = 0,
        commentsCount: Int = 0
    ) {
        usernameLabel.text = username
        captionLabel.text = caption
        self.isLiked = isLiked
        
        // TODO: 이미지 URL로부터 이미지 로드 (Kingfisher 등 사용 예정)
        if let imageUrl = imageUrl {
            // 임시로 placeholder 표시
            postImageView.image = nil
            postImageView.backgroundColor = Colors.Gray.g200
        } else {
            postImageView.image = nil
            postImageView.backgroundColor = Colors.Gray.g200
        }
        
        updateLikeButton()
        // TODO: 좋아요/댓글 수 표시 추가
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
        onSeeMoreTapped?()
    }
}

