import UIKit
import SnapKit
import Then
import Combine

final class FeedViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: FeedViewModel
    private weak var coordinator: FeedCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(viewModel: FeedViewModel, coordinator: FeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let tableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(FeedPostCell.self, forCellReuseIdentifier: FeedPostCell.identifier)
    }
    
    private let typeFilterChipView = FilterChipView(items: ["전체", "일상 기록", "치료 기록"]).then {
        $0.backgroundColor = Colors.white
    }
    
    // TODO: 첫 배포 이후 diagnosis 필터 및 광고 카드 복원
    // private let diagnosisFilterChipView = FilterChipView(items: ["전체", "직장암", "대장암", "간이식", "기타"]).then {
    //     $0.backgroundColor = Colors.white
    // }
    // private let adCardView = AdCardView()
    
    private let floatingActionButton = FloatingActionButton()

    private let refreshControl = IeumRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        setupNavigationBar()
        setupUI()
        setupLayout()
        setupTableView()
        bindViewModel()
        
        viewModel.viewDidLoad.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let logoImageView = UIImageView(image: Images.Icon.appbarLogo).then {
            $0.contentMode = .scaleAspectFit
        }
        let logoItem = UIBarButtonItem(customView: logoImageView)
        navigationItem.leftBarButtonItem = logoItem
        
        // TODO: 알림 기능 추후 추가 예정
//        let notificationButton = UIBarButtonItem(
//            image: Images.Icon.notification,
//            style: .plain,
//            target: self,
//            action: #selector(didTapNotification)
//        ).then {
//            $0.tintColor = Colors.Gray.g950
//        }
//        navigationItem.rightBarButtonItem = notificationButton
        
        navigationController?.navigationBar.backgroundColor = Colors.white
        navigationController?.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.white
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationController?.navigationBar.layer.shadowColor = Colors.Slate.s900.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        navigationController?.navigationBar.layer.shadowRadius = 13
        navigationController?.navigationBar.layer.shadowOpacity = 0.05
        navigationController?.navigationBar.layer.masksToBounds = false
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(floatingActionButton)
        view.bringSubviewToFront(floatingActionButton)
    }

    private func setupLayout() {
        tableView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        floatingActionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        setupTableHeaderView()
    }

    @objc private func handleRefresh() {
        viewModel.viewDidLoad.send()
    }
    
    private func setupTableHeaderView() {
        let headerContainer = UIView()
        
        headerContainer.addSubview(typeFilterChipView)
        
        typeFilterChipView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        headerContainer.layoutIfNeeded()
        let headerHeight = typeFilterChipView.frame.maxY + 16
        headerContainer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)
        
        tableView.tableHeaderView = headerContainer
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = tableView.tableHeaderView else { return }
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let headerSize = headerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        if headerView.frame.size.height != headerSize.height {
            headerView.frame.size.height = headerSize.height
            tableView.tableHeaderView = headerView
        }
    }
    
    private func bindViewModel() {
        typeFilterChipView.onFilterSelected = { [weak self] filter in
            self?.viewModel.didSelectFilter.send(filter)
        }
        
        floatingActionButton.onTapped = { [weak self] in
            self?.viewModel.didTapWritePost.send()
        }
        
        viewModel.showWritePost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showWritePostBottomSheet()
            }
            .store(in: &cancellables)
            
        viewModel.navigateToComments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tuple in
                self?.coordinator?.showComments(postId: tuple.0, postType: tuple.1)
            }
            .store(in: &cancellables)
        
        viewModel.showReportReasonPicker
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.showReportReasonActionSheet(for: post)
            }
            .store(in: &cancellables)

        viewModel.showBlockAfterReport
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.showBlockAfterReportAlert(for: post)
            }
            .store(in: &cancellables)
        
        viewModel.navigateToEdit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                guard let self = self else { return }
                switch post.type {
                case .wellness:
                    self.coordinator?.showEditTreatmentRecord(post: post)
                case .daily:
                    self.coordinator?.showEditDailyRecord(post: post)
                case .all:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
    }
    
    // TODO: 알림 기능 추후 추가 예정
//    @objc private func didTapNotification() {
//    }
    
    private func showDeleteConfirmation(for post: Post) {
        let alert = UIAlertController(
            title: "게시글 삭제",
            message: "정말로 이 게시글을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.didTapDelete.send(post)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showBlockAfterReportAlert(for post: Post) {
        let alert = UIAlertController(
            title: "신고 완료",
            message: "신고가 접수되었습니다.\n\(post.userNickname)님의 게시물을 차단할까요?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "차단하기", style: .destructive) { [weak self] _ in
            self?.viewModel.didTapBlock.send(post)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showBlockConfirmation(for post: Post) {
        let alert = UIAlertController(
            title: "사용자 차단",
            message: "\(post.userNickname)님을 차단하면 해당 유저의 게시물이 더 이상 표시되지 않습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "차단", style: .destructive) { [weak self] _ in
            self?.viewModel.didTapBlock.send(post)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showReportReasonActionSheet(for post: Post) {
        let bottomSheet = ReportReasonBottomSheet()
        bottomSheet.onSelectReason = { [weak self] reason in
            self?.viewModel.didSelectReportReason.send((post, reason))
        }
        present(bottomSheet, animated: false)
    }
    
    private func showWritePostBottomSheet() {
        let bottomSheet = WritePostBottomSheet()
        
        bottomSheet.modalPresentationStyle = .overFullScreen
        
        bottomSheet.onSelectTreatmentRecord = { [weak self] in
            self?.dismiss(animated: false) {
                self?.coordinator?.showTreatmentRecord()
            }
        }
        
        bottomSheet.onSelectDailyRecord = { [weak self] in
            self?.dismiss(animated: false) {
                self?.coordinator?.showDailyRecord()
            }
        }
        
        present(bottomSheet, animated: false)
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostCell.identifier, for: indexPath) as? FeedPostCell else {
            return UITableViewCell()
        }
        
        let post = viewModel.posts[indexPath.row]
        let isMyPost = viewModel.isMyPost(post)
        cell.configure(with: post, isMyPost: isMyPost)
        
        cell.onSeeMoreTapped = { [weak self] in
            guard let self = self else { return }
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.didTapLike.send(post.id)
        }
        
        cell.onCommentTapped = { [weak self] in
            self?.viewModel.didTapComment.send(post.id)
        }
        
        // TODO: 스크랩/공유 기능 추후 추가 예정
//        cell.onBookmarkTapped = {
//        }
//
//        cell.onShareTapped = {
//        }
        
        cell.onEditTapped = { [weak self] post in
            self?.viewModel.didTapEdit.send(post)
        }
        
        cell.onDeleteTapped = { [weak self] post in
            self?.showDeleteConfirmation(for: post)
        }
        
        cell.onReportTapped = { [weak self] post in
            self?.viewModel.didTapReport.send(post)
        }

        cell.onBlockTapped = { [weak self] post in
            self?.showBlockConfirmation(for: post)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastRow = viewModel.posts.count - 1
        guard lastRow >= 0 else { return }
        
        if indexPaths.contains(where: { $0.row >= lastRow - 3 }) {
            viewModel.loadMore.send()
        }
    }
}
