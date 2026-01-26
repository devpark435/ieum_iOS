import UIKit
import SnapKit
import Then
import Combine

final class CommentViewController: DimmedViewController {
    
    // MARK: - Properties
    
    private let viewModel: CommentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // 키보드 처리를 위한 Bottom Constraint
    private var containerBottomConstraint: Constraint?
    
    // 모달이 올라왔을 때의 Top 위치 (화면 상단에서 20% 내려온 위치)
    private lazy var topOffset: CGFloat = view.frame.height * 0.2
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let dragHandleView = UIView().then {
        $0.backgroundColor = Colors.Gray.g300
        $0.layer.cornerRadius = 2.5
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0) // Content Padding
    }
    
    private let commentInputView = CommentInputView()
    
    private let emptyStateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.setIeumText("아직 댓글이 없습니다", 
                        style: UIFont.IeumFont.Text.bodySmall, 
                        color: Colors.Gray.g400)
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    init(viewModel: CommentViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial state for animation
        backgroundImageView.alpha = 0
        dimmedOverlayView.alpha = 0
        
        setupUI()
        setupLayout()
        setupActions()
        bindViewModel()
        setupKeyboardObservers()
        
        viewModel.viewDidLoad.send()
        
        // 중요: 뷰가 로드되면 화면 아래로 내려놓음 (높이는 유지됨)
        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShow()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(dragHandleView)
        containerView.addSubview(tableView)
        containerView.addSubview(emptyStateLabel)
        containerView.addSubview(commentInputView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        // 제약조건은 "화면에 보이는 상태"를 기준으로 고정합니다.
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            // Top 고정 (키보드가 올라와도 상단은 움직이지 않음)
            $0.top.equalToSuperview().offset(topOffset)
            // Bottom은 키보드에 따라 움직임
            self.containerBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        
        dragHandleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        // Input View pinned to bottom of container
        commentInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview() // Moves with container bottom
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(dragHandleView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(commentInputView.snp.top)
        }
        
        emptyStateLabel.snp.makeConstraints {
            $0.top.equalTo(dragHandleView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(commentInputView.snp.top)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapGesture)
        
        let containerTap = UITapGestureRecognizer(target: self, action: nil) // Block tap
        containerView.addGestureRecognizer(containerTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bindViewModel() {
        // Comments 업데이트
        Publishers.CombineLatest(viewModel.$comments, viewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comments, isLoading in
                guard let self = self else { return }
                
                let isEmpty = comments.isEmpty && !isLoading
                self.emptyStateLabel.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                
                if !isEmpty {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$replyingTo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comment in
                if comment != nil {
                    self?.commentInputView.focus()
                }
            }
            .store(in: &cancellables)
        
        viewModel.commentPostedSuccessfully
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.commentInputView.clearText()
            }
            .store(in: &cancellables)
        
        // 좋아요 상태 변경 시 UI 업데이트
        viewModel.$likes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // 좋아요 상태가 변경되면 테이블뷰 리로드
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.navigateToEdit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] editInfo in
                self?.showEditComment(id: editInfo.id, content: editInfo.content)
            }
            .store(in: &cancellables)
            
        commentInputView.onSendTapped = { [weak self] text in
            self?.viewModel.didTapSend.send(text)
            self?.commentInputView.resign()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackground() {
        animateDismiss()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        
        switch gesture.state {
        case .changed:
            if isDraggingDown {
                // 제약조건 대신 transform으로 이동
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if translation.y > 150 {
                animateDismiss()
            } else {
                // Snap back
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = .identity
                }
            }
        default:
            break
        }
    }
    
    private func animateShow() {
        // transform을 초기화하여 원래 위치로 올림
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.dimmedOverlayView.alpha = 1
        }
    }
    
    private func animateDismiss() {
        commentInputView.resign()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            // 화면 아래로 이동
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.dimmedOverlayView.alpha = 0
            self.backgroundImageView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    private func showReportActionSheet(for commentId: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { [weak self] _ in
            self?.viewModel.didTapReport.send(commentId)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showEditComment(id: Int, content: String) {
        let alert = UIAlertController(title: "댓글 수정", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = content
            textField.placeholder = "댓글을 입력하세요"
        }
        
        let saveAction = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newContent = textField.text,
                  !newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            self.viewModel.updateComment(id: id, content: newContent)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmation(for commentId: Int) {
        let alert = UIAlertController(title: "댓글 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.didTapDelete.send(commentId)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        // 키보드 높이만큼 Bottom Constraint을 올림 (컨테이너 높이가 줄어들며 입력창이 딸려 올라감)
        containerBottomConstraint?.update(inset: keyboardHeight)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        // Bottom Constraint 복구
        containerBottomConstraint?.update(inset: 0)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper
    
    private func formatRelativeTime(from timestamp: Int) -> String {
        let now = Int(Date().timeIntervalSince1970)
        let diff = now - timestamp
        
        if diff < 60 {
            return "방금 전"
        } else if diff < 3600 {
            return "\(diff / 60)분 전"
        } else if diff < 86400 {
            return "\(diff / 3600)시간 전"
        } else if diff < 604800 {
            return "\(diff / 86400)일 전"
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: date)
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 (Parent) + Replies
        return 1 + (viewModel.comments[section].replies.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        let comment = viewModel.comments[indexPath.section]
        let likeInfo = viewModel.likes[indexPath.row == 0 ? comment.id : comment.replies[indexPath.row - 1].id] ?? (false, 0)
        
        if indexPath.row == 0 {
            // Parent Comment
            let isMyComment = viewModel.isMyComment(comment)
            
            cell.configure(
                username: comment.nickname,
                content: comment.content,
                date: formatRelativeTime(from: comment.createdAt),
                isReply: false,
                isLiked: likeInfo.isLiked,
                likeCount: likeInfo.count,
                isMyComment: isMyComment
            )
            
            cell.onReplyTapped = { [weak self] in
                self?.viewModel.didTapReply.send(comment)
            }
            
            cell.onMenuTapped = { [weak self] in
                self?.showReportActionSheet(for: comment.id)
            }
            
            cell.onEditTapped = { [weak self] in
                self?.showEditComment(id: comment.id, content: comment.content)
            }
            
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteConfirmation(for: comment.id)
            }
            
            cell.onLikeTapped = { [weak self] in
                self?.viewModel.didTapLike.send(comment.id)
            }
            
        } else {
            // Reply
            let reply = comment.replies[indexPath.row - 1]
            let replyLikeInfo = viewModel.likes[reply.id] ?? (false, 0)
            let isMyReply = viewModel.isMyComment(reply)
            
            cell.configure(
                username: reply.nickname,
                content: reply.content,
                date: formatRelativeTime(from: reply.createdAt),
                isReply: true,
                isLiked: replyLikeInfo.isLiked,
                likeCount: replyLikeInfo.count,
                isMyComment: isMyReply
            )
            
            cell.onMenuTapped = { [weak self] in
                self?.showReportActionSheet(for: reply.id)
            }
            
            cell.onEditTapped = { [weak self] in
                self?.showEditComment(id: reply.id, content: reply.content)
            }
            
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteConfirmation(for: reply.id)
            }
            
            cell.onLikeTapped = { [weak self] in
                self?.viewModel.didTapLike.send(reply.id)
            }
        }
        
        return cell
    }
}
