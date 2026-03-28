import UIKit
import SnapKit
import Then
import Combine

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel(feedRepository: FeedRepositoryImpl())
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let headerView = CalendarHeaderView()
    
    private let calendarGridView = CalendarGridView()
    
    private let statsView = CalendarStatsView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s100
        
        setupUI()
        setupLayout()
        setupCallbacks()
        bindViewModel()
        
        viewModel.viewDidLoad.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(calendarGridView)
        contentView.addSubview(statsView)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        calendarGridView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(400) // 6주 * 56 + 요일 헤더
        }
        
        statsView.snp.makeConstraints {
            $0.top.equalTo(calendarGridView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(140)
        }
    }
    
    private func setupCallbacks() {
        // 월 선택 버튼 탭
        headerView.onMonthTapped = { [weak self] in
            self?.showMonthPicker()
        }
        
        // 필터 선택
        headerView.onFilterSelected = { [weak self] filter in
            self?.viewModel.didSelectFilter.send(filter)
        }
        
        // 날짜 선택
        calendarGridView.onDateSelected = { [weak self] date in
            self?.viewModel.didSelectDate.send(date)
        }
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoadingIndicator() : self?.hideLoadingIndicator()
            }
            .store(in: &cancellables)
        
        // 현재 월 표시 업데이트
        viewModel.$currentMonth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.headerView.setMonth(self.viewModel.currentMonthString)
            }
            .store(in: &cancellables)
        
        // 캘린더 날짜 업데이트
        viewModel.$calendarDays
            .receive(on: DispatchQueue.main)
            .sink { [weak self] days in
                guard let self = self else { return }
                self.calendarGridView.configure(
                    with: days,
                    selectedFilter: self.viewModel.selectedFilter,
                    viewModel: self.viewModel
                )
            }
            .store(in: &cancellables)
        
        // 필터 변경 시 캘린더 업데이트
        viewModel.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                guard let self = self else { return }
                self.headerView.setSelectedFilter(filter)
                self.calendarGridView.configure(
                    with: self.viewModel.calendarDays,
                    selectedFilter: filter,
                    viewModel: self.viewModel
                )
                self.updateStats()
            }
            .store(in: &cancellables)
        
        // 통계 업데이트
        Publishers.CombineLatest(viewModel.$totalDaysInMonth, viewModel.$recordedDaysCount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] totalDays, recordedDays in
                guard let self = self else { return }
                self.statsView.configure(
                    totalDays: totalDays,
                    recordedDays: recordedDays,
                    selectedFilter: self.viewModel.selectedFilter
                )
            }
            .store(in: &cancellables)
    }
    
    private func updateStats() {
        statsView.configure(
            totalDays: viewModel.totalDaysInMonth,
            recordedDays: viewModel.recordedDaysCount,
            selectedFilter: viewModel.selectedFilter
        )
    }
    
    private func showLoadingIndicator() {
        calendarGridView.alpha = 0.4
        statsView.alpha = 0.4
    }
    
    private func hideLoadingIndicator() {
        UIView.animate(withDuration: 0.2) {
            self.calendarGridView.alpha = 1.0
            self.statsView.alpha = 1.0
        }
    }
    
    // MARK: - Month Picker
    
    private func showMonthPicker() {
        let pickerVC = MonthPickerViewController(selectedDate: viewModel.currentMonth)
        pickerVC.onDateSelected = { [weak self] date in
            self?.viewModel.didSelectMonth.send(date)
        }
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(pickerVC, animated: true)
    }
}

// MARK: - MonthPickerViewController

private class MonthPickerViewController: UIViewController {
    
    var onDateSelected: ((Date) -> Void)?
    
    // MARK: - Properties
    
    private var selectedYear: Int
    private var selectedMonth: Int
    
    // 년도 범위: 2020 ~ 현재년도 + 5
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(2020...(currentYear + 5))
    }()
    
    private let months: [Int] = Array(1...12)
    
    // MARK: - UI Components
    
    private let pickerView = UIPickerView()
    
    private let confirmButton = UIButton().then {
        $0.setTitle("선택", for: .normal)
        $0.setTitleColor(Colors.white, for: .normal)
        $0.backgroundColor = Colors.Gray.g950
        $0.layer.cornerRadius = 12
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Heading.h4)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "월 선택"
        $0.font = .ieum(UIFont.IeumFont.Heading.h3)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    // MARK: - Initializer
    
    init(selectedDate: Date) {
        let calendar = Calendar.current
        self.selectedYear = calendar.component(.year, from: selectedDate)
        self.selectedMonth = calendar.component(.month, from: selectedDate)
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
        setupPickerView()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(pickerView)
        view.addSubview(confirmButton)
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 현재 선택된 년/월로 스크롤
        if let yearIndex = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
    }
    
    // MARK: - Actions
    
    @objc private func didTapConfirm() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let date = Calendar.current.date(from: components) {
            onDateSelected?(date)
        }
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension MonthPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 년도, 월
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1: return months.count
        default: return 0
        }
    }
}

// MARK: - UIPickerViewDelegate

extension MonthPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(years[row])년"
        case 1: return "\(months[row])월"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: selectedYear = years[row]
        case 1: selectedMonth = months[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
}
