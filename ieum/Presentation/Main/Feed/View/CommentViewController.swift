import UIKit
import SnapKit
import Then
import Combine

final class CommentViewController: DimmedViewController {
    
    // MARK: - Properties
    
    private let viewModel: CommentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var containerBottomConstraint: Constraint?
    private lazy var containerHeight: CGFloat = view.frame.height * 0.8
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let headerView = UIView()
    
    private let dragHandleView = UIView().then {
        $0.backgroundColor = Colors.Gray.g300
        $0.layer.cornerRadius = 2.5
    }
    
    private let headerLabel = UILabel().then {
        $0.text = "댓글"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0) // Space for input
    }
    
    private let commentInputView = CommentInputView()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShow()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(headerView)
        headerView.addSubview(dragHandleView)
        headerView.addSubview(headerLabel)
        
        containerView.addSubview(tableView)
        containerView.addSubview(commentInputView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            // Start below screen
            self.containerBottomConstraint = $0.bottom.equalToSuperview().offset(containerHeight).constraint
            $0.height.equalTo(containerHeight)
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        dragHandleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        headerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        commentInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.high) // Adjust with keyboard
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
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
        headerView.addGestureRecognizer(panGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bindViewModel() {
        viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$replyingTo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comment in
                if comment != nil {
                    self?.commentInputView.focus()
                    // Optional: Update input placeholder or show indicator
                }
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
                containerBottomConstraint?.update(offset: translation.y)
                view.layoutIfNeeded()
            }
        case .ended:
            if translation.y > 150 {
                animateDismiss()
            } else {
                // Snap back
                containerBottomConstraint?.update(offset: 0)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
    
    private func animateShow() {
        containerBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.dimmedOverlayView.alpha = 1
        }
    }
    
    private func animateDismiss() {
        commentInputView.resign()
        containerBottomConstraint?.update(offset: containerHeight)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
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
            // Show confirmation toast/alert?
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        // Since container is at bottom (offset 0), we move inputView up
        // But inputView is inside container. 
        // If container is not full height, keyboard might cover it.
        // Container height is 80% screen.
        // We should move the whole container up or just the input view?
        // If we move input view up, it might cover table view content.
        // Usually, the container stays, but its bottom is constrained to keyboard top.
        // My container constraint is bottom of superview.
        
        containerBottomConstraint?.update(offset: -keyboardHeight)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        containerBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
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
        
        if indexPath.row == 0 {
            // Parent Comment
            cell.configure(
                username: comment.nickname,
                content: comment.content,
                date: "1분 전", // Mock
                isReply: false
            )
            
            cell.onReplyTapped = { [weak self] in
                self?.viewModel.didTapReply.send(comment)
            }
            
            cell.onMenuTapped = { [weak self] in
                self?.showReportActionSheet(for: comment.id)
            }
            
        } else {
            // Reply
            let reply = comment.replies[indexPath.row - 1]
            cell.configure(
                username: reply.nickname,
                content: reply.content,
                date: "1분 전",
                isReply: true
            )
            
            cell.onMenuTapped = { [weak self] in
                self?.showReportActionSheet(for: reply.id)
            }
            // Replies to replies? Usually not supported or flattened.
            // Model supports nesting but UI usually 1 level deep.
        }
        
        return cell
    }
}

