import UIKit
import SnapKit
import Then

final class CommentCell: UITableViewCell {
    
    static let identifier = "CommentCell"
    
    // MARK: - Properties
    
    var onReplyTapped: (() -> Void)?
    var onMenuTapped: (() -> Void)?
    
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
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall) // Adjust font as needed
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
    
    private let menuButton = UIButton().then {
        $0.setImage(Images.Icon.ellipsis, for: .normal)
        $0.tintColor = Colors.Gray.g400
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
        contentView.addSubview(menuButton)
        
        contentStackView.addArrangedSubview(usernameLabel)
        contentStackView.addArrangedSubview(commentLabel)
        contentStackView.addArrangedSubview(footerStackView)
        
        footerStackView.addArrangedSubview(dateLabel)
        footerStackView.addArrangedSubview(replyButton)
    }
    
    private func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(menuButton.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(20)
        }
    }
    
    private func setupActions() {
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(username: String, content: String, date: String, isReply: Bool) {
        usernameLabel.text = username
        commentLabel.text = content
        // TODO: Format date
        // dateLabel.text = date 
        
        if isReply {
            profileImageView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(52) // Indent
                $0.width.height.equalTo(24) // Smaller profile for reply?
            }
            replyButton.isHidden = true // Or keep it if nested replies allowed (usually 1 level deep)
        } else {
            profileImageView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.width.height.equalTo(32)
            }
            replyButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapReply() {
        onReplyTapped?()
    }
    
    @objc private func didTapMenu() {
        onMenuTapped?()
    }
}

