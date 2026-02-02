import UIKit
import SnapKit
import Then
import Combine

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.white
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let headerView = CalendarHeaderView()
    
    private let calendarGridView = CalendarGridView()
    
    private let statsView = CalendarStatsView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
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
            $0.height.equalTo(120)
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
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
    }
    
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
    
    init(selectedDate: Date) {
        super.init(nibName: nil, bundle: nil)
        datePicker.date = selectedDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        view.addSubview(titleLabel)
        view.addSubview(datePicker)
        view.addSubview(confirmButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    @objc private func didTapConfirm() {
        onDateSelected?(datePicker.date)
        dismiss(animated: true)
    }
}
