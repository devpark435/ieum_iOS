import UIKit
import SnapKit
import Then
import Combine

final class FeedViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = FeedViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
            print("더 알아보기 탭")
        }
        
        floatingActionButton.onTapped = { [weak self] in
            self?.viewModel.didTapWritePost.send()
        }
        
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateTableViewHeight()
            }
            .store(in: &cancellables)
    }
    
    private func updateTableViewHeight() {
        let cellHeight: CGFloat = 500 // 임시 높이
        let totalHeight = CGFloat(viewModel.posts.count) * cellHeight
        tableView.snp.updateConstraints {
            $0.height.equalTo(totalHeight)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapNotification() {
        // TODO: 알림 리스트 화면으로 이동
        print("알림 아이콘 탭")
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
        let firstImageUrl = post.images.first?.url
        cell.configure(
            username: post.userNickname,
            imageUrl: firstImageUrl,
            caption: post.content,
            isLiked: post.isLiked,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount
        )
        
        cell.onLikeTapped = {
            // TODO: 좋아요 API 호출
            print("좋아요 탭: \(post.id)")
        }
        
        cell.onCommentTapped = {
            // TODO: 댓글 화면으로 이동
            print("댓글 탭: \(post.id)")
        }
        
        cell.onBookmarkTapped = {
            // TODO: 북마크 API 호출
            print("북마크 탭: \(post.id)")
        }
        
        cell.onShareTapped = {
            // TODO: 공유 기능
            print("공유 탭: \(post.id)")
        }
        
        cell.onMenuTapped = {
            // TODO: 메뉴 표시
            print("메뉴 탭: \(post.id)")
        }
        
        cell.onSeeMoreTapped = {
            // TODO: 전체 텍스트 보기
            print("더보기 탭: \(post.id)")
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

