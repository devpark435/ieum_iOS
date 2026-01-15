import UIKit
import SnapKit
import Then
import Combine

final class MyPostsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyPostsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let filterChipView = FilterChipView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let tableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(FeedPostCell.self, forCellReuseIdentifier: FeedPostCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    // MARK: - Initializer
    
    init(viewModel: MyPostsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        setupUI()
        setupLayout()
        setupTableView()
        bindViewModel()
        
        viewModel.viewDidLoad.send()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(filterChipView)
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        filterChipView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(filterChipView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
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
        
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension MyPostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostCell.identifier, for: indexPath) as? FeedPostCell else {
            return UITableViewCell()
        }
        
        let post = viewModel.posts[indexPath.row]
        cell.configure(with: post)
        
        // Expanded logic (Simplified from FeedViewController)
        cell.onSeeMoreTapped = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyPostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
