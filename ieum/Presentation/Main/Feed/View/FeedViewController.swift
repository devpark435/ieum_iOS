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
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.white
    }
    
    private let contentView = UIView()
    
    private let filterChipView = FilterChipView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let adCardView = AdCardView()
    
    private let tableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(FeedPostCell.self, forCellReuseIdentifier: FeedPostCell.identifier)
    }
    
    private let floatingActionButton = FloatingActionButton()
    
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
        
        let notificationButton = UIBarButtonItem(
            image: Images.Icon.notification,
            style: .plain,
            target: self,
            action: #selector(didTapNotification)
        ).then {
            $0.tintColor = Colors.Gray.g950
        }
        navigationItem.rightBarButtonItem = notificationButton
        
        navigationController?.navigationBar.backgroundColor = Colors.white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(filterChipView)
        contentView.addSubview(adCardView)
        contentView.addSubview(tableView)
        
        view.addSubview(floatingActionButton)
        // 버튼이 다른 뷰 위에 표시되도록
        view.bringSubviewToFront(floatingActionButton)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        filterChipView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        adCardView.snp.makeConstraints {
            $0.top.equalTo(filterChipView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(adCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(500) // 임시 높이, 실제로는 셀 높이에 따라 동적으로 계산
            $0.bottom.equalToSuperview().inset(16)
        }
        
        floatingActionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        filterChipView.onFilterSelected = { [weak self] filter in
            self?.viewModel.didSelectFilter.send(filter)
        }
        
        adCardView.onLearnMoreTapped = {
            // TODO: 광고 상세 화면으로 이동
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
        
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateTableViewHeight()
            }
            .store(in: &cancellables)
    }
    
    private func updateTableViewHeight() {
        // 테이블 뷰 높이 업데이트
        // 셀의 높이가 동적이므로 contentSize를 사용하여 업데이트하거나,
        // 테이블 뷰의 제약조건을 bottom에 맞추고 스크롤 가능하게 변경해야 할 수도 있음.
        // 현재 구조: ScrollView -> ContentView -> TableView (isScrollEnabled=false)
        
        tableView.layoutIfNeeded() // 레이아웃 갱신
        let totalHeight = tableView.contentSize.height
        
        tableView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapNotification() {
        // TODO: 알림 리스트 화면으로 이동
    }
    
    private func showWritePostBottomSheet() {
        let bottomSheet = WritePostBottomSheet()
        
        // 전체 화면을 덮도록 설정 (네비게이션 바 포함)
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
        
        // 애니메이션 없이 present (모달 내부에서 애니메이션 처리)
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
        cell.configure(with: post)
        
        // 셀 확장 상태 업데이트
        cell.onSeeMoreTapped = { [weak self] in
            guard let self = self else { return }
            
            // 테이블 뷰 갱신 (셀 높이 재계산)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            // 전체 높이 재조정 (약간의 딜레이를 주어 애니메이션 완료 후 정확한 크기 계산)
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
        }
        
        cell.onLikeTapped = {
            // TODO: 좋아요 API 호출
        }
        
        cell.onCommentTapped = { [weak self] in
            // 댓글 화면으로 이동
            self?.viewModel.didTapComment.send(post.id)
        }
        
        cell.onBookmarkTapped = {
            // TODO: 북마크 API 호출
        }
        
        cell.onShareTapped = {
            // TODO: 공유 기능
        }
        
        cell.onMenuTapped = {
            // TODO: 메뉴 표시
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

