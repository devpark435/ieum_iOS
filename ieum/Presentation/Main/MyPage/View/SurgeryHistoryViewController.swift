import UIKit
import SnapKit
import Then
import Combine

final class SurgeryHistoryViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = SurgeryHistoryViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    var onComplete: (([SurgeryRequest], Bool) -> Void)?
    private var initialSurgeries: [Surgery]?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "수술하신 내용을\n알려주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.Slate.s50
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let addButton = IeumButton(title: "수술이력 추가 +").then {
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g600, for: .normal)
    }
    
    private let privacyChip = PrivacyChip()
    
    private let completeButton = IeumButton(title: "완료").then {
        $0.setStyle(backgroundColor: Colors.Lime.l100, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Colors.Lime.l200.cgColor
        $0.isEnabled = false
    }
    
    // MARK: - Initializer
    
    convenience init(initialSurgeries: [Surgery]?, onComplete: @escaping ([SurgeryRequest], Bool) -> Void) {
        self.init()
        self.initialSurgeries = initialSurgeries
        self.onComplete = onComplete
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s50
        
        setupUI()
        setupLayout()
        setupCollectionView()
        bindViewModel()
        
        if let initialSurgeries = initialSurgeries {
            viewModel.setupInitialData(initialSurgeries)
        } else {
            viewModel.didTapAddHistory.send()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.Slate.s50
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Colors.Gray.g950
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(addButton)
        view.addSubview(privacyChip)
        view.addSubview(completeButton)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top).offset(-16)
        }
        
        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(privacyChip.snp.top).offset(-16)
            $0.height.equalTo(56)
        }
        
        privacyChip.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top).offset(-16)
        }
        
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(72)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SurgeryHistoryCell.self, forCellWithReuseIdentifier: SurgeryHistoryCell.identifier)
    }
    
    private func bindViewModel() {
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        
        privacyChip.onCheckChanged = { [weak self] isChecked in
            self?.viewModel.didChangePrivacy.send(isChecked)
        }
        
        viewModel.$historyItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isCompleteButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: completeButton)
            .store(in: &cancellables)
        
        viewModel.navigateToComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] surgeries, isPrivate in
                self?.onComplete?(surgeries, isPrivate)
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        viewModel.didTapAddHistory.send()
    }
    
    @objc private func didTapComplete() {
        viewModel.didTapComplete.send()
    }
}

// MARK: - UICollectionViewDataSource

extension SurgeryHistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.historyItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurgeryHistoryCell.identifier, for: indexPath) as? SurgeryHistoryCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.historyItems[indexPath.item]
        cell.configure(date: item.date, description: item.description)
        
        cell.onDelete = { [weak self] in
            self?.viewModel.didTapDeleteHistory.send(indexPath.item)
        }
        
        cell.onDateChanged = { [weak self] date in
            self?.viewModel.didUpdateDate.send((index: indexPath.item, date: date))
        }
        
        cell.onDescriptionChanged = { [weak self] description in
            self?.viewModel.didUpdateDescription.send((index: indexPath.item, description: description))
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SurgeryHistoryViewController: UICollectionViewDelegate {
    // Delegate methods can be added here if needed
}

