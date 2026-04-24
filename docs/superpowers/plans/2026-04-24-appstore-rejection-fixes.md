# App Store 리젝 방지 수정 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apple 로그인 버튼을 공식 ASAuthorizationAppleIDButton으로 교체하고, 회원가입 전 개인정보/이용약관 동의 화면을 추가하여 App Store 심사 리젝 가능성을 제거한다.

**Architecture:** 두 가지 독립적인 수정. (1) LoginViewController의 커스텀 Apple 버튼을 ASAuthorizationAppleIDButton으로 교체. (2) SignUpCoordinator 진입점에 ConsentViewController를 삽입하여 Step1 이전에 동의를 받는다.

**Tech Stack:** UIKit, SnapKit, Then, AuthenticationServices, WKWebView

---

## 파일 맵

| 작업 | 파일 | 변경 유형 |
|------|------|-----------|
| Task 1 | `ieum/Presentation/Auth/Login/View/LoginViewController.swift` | Modify |
| Task 2 | `ieum/Presentation/Auth/SignUp/Consent/View/ConsentViewController.swift` | **Create** |
| Task 3 | `ieum/Presentation/Coordinator/SignUpCoordinator.swift` | Modify |

---

## Task 1: Apple 로그인 버튼 교체

**Files:**
- Modify: `ieum/Presentation/Auth/Login/View/LoginViewController.swift`

### 배경
현재 `LoginViewController`는 `UIButton`으로 직접 만든 커스텀 Apple 버튼을 사용 중.
Apple 가이드라인 상 Sign in with Apple 버튼은 반드시 `ASAuthorizationAppleIDButton`을 써야 함.
`import AuthenticationServices`는 이미 파일 상단에 있음.

- [ ] **Step 1: 커스텀 appleLoginButton을 ASAuthorizationAppleIDButton으로 교체**

`ieum/Presentation/Auth/Login/View/LoginViewController.swift` 에서 아래 코드를 찾아 교체:

```swift
// 제거할 코드 (기존)
private let appleLoginButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .black
    config.baseForegroundColor = .white
    config.image = UIImage(systemName: "apple.logo")
    config.imagePadding = 10
    config.imagePlacement = .leading
    
    var container = AttributeContainer()
    container.font = .ieum(UIFont.IeumFont.Btn.large)
    config.attributedTitle = AttributedString("Apple로 계속하기", attributes: container)
    
    config.background.cornerRadius = 16
    config.cornerStyle = .fixed
    
    $0.configuration = config
}
```

```swift
// 추가할 코드 (교체)
private let appleLoginButton = ASAuthorizationAppleIDButton(type: .continue, style: .black).then {
    $0.cornerRadius = 16
}
```

- [ ] **Step 2: setupActions에서 타겟 유지 확인**

`setupActions()`에 이미 `appleLoginButton.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)`가 있으므로 변경 불필요.
`ASAuthorizationAppleIDButton`은 `UIControl` 서브클래스라 `addTarget`이 그대로 동작함.

- [ ] **Step 3: setupLayout 높이 조정 확인**

현재 레이아웃:
```swift
[appleLoginButton, kakaoLoginButton].forEach { button in
    button.snp.makeConstraints {
        $0.height.equalTo(56)
    }
}
```
`ASAuthorizationAppleIDButton`은 높이 제약을 외부에서 줄 수 있음. 위 코드 그대로 유지해도 무방.

- [ ] **Step 4: 빌드 후 로그인 화면에서 Apple 버튼 시각 확인**

시뮬레이터 실행 → 로그인 화면에서 "Apple로 계속하기" 공식 버튼이 렌더링되는지 확인.

- [ ] **Step 5: 커밋**

```bash
git add ieum/Presentation/Auth/Login/View/LoginViewController.swift
git commit -m "fix: Apple 로그인 버튼을 ASAuthorizationAppleIDButton으로 교체"
```

---

## Task 2: ConsentViewController 생성

**Files:**
- Create: `ieum/Presentation/Auth/SignUp/Consent/View/ConsentViewController.swift`

### 화면 구성
- 상단: 로고 + 제목 ("서비스를 이용하기 위해\n아래 약관에 동의해 주세요")
- 전체 동의 체크박스 (IeumCheckbox)
- 구분선
- (필수) 이용약관 동의 체크박스 + "보기" 버튼 → SafariVC 오픈
- (필수) 개인정보 처리방침 동의 체크박스 + "보기" 버튼 → PrivacyPolicyViewController push
- 하단: "다음" IeumButton (두 필수 항목 모두 체크 시 활성화)

### URL 상수
- 개인정보 처리방침: `https://southern-dash-bc7.notion.site/2f7a0853c74280b7b6a1d7a0172cbdac`
- 이용약관: 동일한 Notion URL 사용 (배포 전 실제 URL로 교체 필요)

- [ ] **Step 1: 파일 생성 및 기본 구조 작성**

`ieum/Presentation/Auth/SignUp/Consent/View/ConsentViewController.swift` 를 아래 내용으로 생성:

```swift
import UIKit
import SafariServices
import SnapKit
import Then

final class ConsentViewController: UIViewController {

    // MARK: - Properties

    var onConsented: (() -> Void)?

    private var isTermsAgreed = false {
        didSet { updateAllAgreedState(); updateNextButton() }
    }
    private var isPrivacyAgreed = false {
        didSet { updateAllAgreedState(); updateNextButton() }
    }

    private let termsURL = URL(string: "https://southern-dash-bc7.notion.site/2f7a0853c74280b7b6a1d7a0172cbdac")!
    private let privacyURL = URL(string: "https://southern-dash-bc7.notion.site/2f7a0853c74280b7b6a1d7a0172cbdac")!

    // MARK: - UI Components

    private let logoImageView = UIImageView().then {
        $0.image = Images.Icon.appbarLogo
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.text = "서비스를 이용하기 위해\n아래 약관에 동의해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
    }

    private let allAgreeCheckbox = IeumCheckbox(title: "전체 동의")

    private let divider = UIView().then {
        $0.backgroundColor = Colors.Slate.s200
    }

    private let termsRow = ConsentRowView(title: "(필수) 이용약관 동의")
    private let privacyRow = ConsentRowView(title: "(필수) 개인정보 처리방침 동의")

    private let nextButton = IeumButton(title: "다음").then {
        $0.setStyle(backgroundColor: Colors.Lime.l400, borderColor: Colors.Lime.l200, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        setupUI()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(allAgreeCheckbox)
        view.addSubview(divider)
        view.addSubview(termsRow)
        view.addSubview(privacyRow)
        view.addSubview(nextButton)
    }

    private func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        allAgreeCheckbox.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        divider.snp.makeConstraints {
            $0.top.equalTo(allAgreeCheckbox.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        termsRow.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        privacyRow.snp.makeConstraints {
            $0.top.equalTo(termsRow.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }

    private func setupActions() {
        allAgreeCheckbox.onCheckChanged = { [weak self] isChecked in
            guard let self else { return }
            // 전체 동의 → 개별 항목 모두 체크/해제
            self.isTermsAgreed = isChecked
            self.isPrivacyAgreed = isChecked
            self.termsRow.setChecked(isChecked)
            self.privacyRow.setChecked(isChecked)
        }

        termsRow.onCheckChanged = { [weak self] isChecked in
            self?.isTermsAgreed = isChecked
        }

        privacyRow.onCheckChanged = { [weak self] isChecked in
            self?.isPrivacyAgreed = isChecked
        }

        termsRow.onViewTapped = { [weak self] in
            guard let self else { return }
            let safari = SFSafariViewController(url: self.termsURL)
            self.present(safari, animated: true)
        }

        privacyRow.onViewTapped = { [weak self] in
            guard let self else { return }
            let safari = SFSafariViewController(url: self.privacyURL)
            self.present(safari, animated: true)
        }

        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    // MARK: - Logic

    private func updateAllAgreedState() {
        let allAgreed = isTermsAgreed && isPrivacyAgreed
        // onCheckChanged 루프 방지: isChecked 직접 set (callback 없이)
        if allAgreeCheckbox.isChecked != allAgreed {
            allAgreeCheckbox.isChecked = allAgreed
        }
    }

    private func updateNextButton() {
        nextButton.isEnabled = isTermsAgreed && isPrivacyAgreed
    }

    // MARK: - Actions

    @objc private func didTapNext() {
        onConsented?()
    }
}
```

- [ ] **Step 2: ConsentRowView 헬퍼 뷰를 같은 파일 하단에 추가**

`ConsentViewController.swift` 하단에 이어서 추가:

```swift
// MARK: - ConsentRowView

final class ConsentRowView: UIView {

    var onCheckChanged: ((Bool) -> Void)?
    var onViewTapped: (() -> Void)?

    private let checkbox = IeumCheckbox()

    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyS)
        $0.textColor = Colors.Gray.g700
    }

    private let viewButton = UIButton().then {
        $0.setTitle("보기", for: .normal)
        $0.setTitleColor(Colors.Gray.g400, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodyS)
    }

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(checkbox)
        addSubview(titleLabel)
        addSubview(viewButton)
    }

    private func setupLayout() {
        checkbox.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        viewButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        checkbox.onCheckChanged = { [weak self] isChecked in
            self?.onCheckChanged?(isChecked)
        }
        viewButton.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
    }

    func setChecked(_ checked: Bool) {
        checkbox.isChecked = checked
    }

    @objc private func didTapView() {
        onViewTapped?()
    }
}
```

- [ ] **Step 3: 빌드 오류 없는지 확인**

Xcode에서 빌드 (`Cmd+B`). 오류 없으면 다음 진행.

---

## Task 3: SignUpCoordinator에 Consent 화면 연결

**Files:**
- Modify: `ieum/Presentation/Coordinator/SignUpCoordinator.swift`

현재 `start()` → `showStep1()` 구조를 `start()` → `showConsent()` → `showStep1()`으로 변경.

- [ ] **Step 1: showConsent() 메서드 추가 및 start() 수정**

`SignUpCoordinator.swift` 에서:

```swift
// 수정 전
func start() {
    showStep1()
}
```

```swift
// 수정 후
func start() {
    showConsent()
}

func showConsent() {
    let viewController = ConsentViewController()
    viewController.onConsented = { [weak self] in
        self?.showStep1()
    }
    navigationController.setViewControllers([viewController], animated: false)
    navigationController.setNavigationBarHidden(true, animated: false)
}
```

- [ ] **Step 2: 빌드 확인**

Xcode `Cmd+B`. 오류 없으면 시뮬레이터 실행.

- [ ] **Step 3: 동작 확인**

1. 앱 실행 → 로그인 화면 → 카카오 또는 Apple 로그인 → 동의 화면 진입 확인
2. 두 체크박스 모두 체크 전에는 "다음" 버튼 비활성화 확인
3. 전체 동의 체크 시 두 항목 모두 체크 확인
4. "보기" 탭 시 SFSafariViewController로 Notion 페이지 열림 확인
5. "다음" 탭 → Step 1 (역할 선택) 화면으로 이동 확인

- [ ] **Step 4: 커밋**

```bash
git add ieum/Presentation/Auth/SignUp/Consent/View/ConsentViewController.swift
git add ieum/Presentation/Coordinator/SignUpCoordinator.swift
git commit -m "feat: 회원가입 전 이용약관/개인정보 동의 화면 추가"
```

---

## Task 4: 최종 확인 및 PR

- [ ] **Step 1: 전체 흐름 최종 테스트**

| 체크 항목 | 확인 |
|-----------|------|
| 로그인 화면 Apple 버튼이 공식 ASAuthorizationAppleIDButton으로 표시됨 | |
| 회원가입 시작 시 동의 화면 먼저 노출됨 | |
| 필수 항목 미동의 시 다음 버튼 비활성화 | |
| 전체 동의 체크박스 연동 정상 동작 | |
| "보기" 버튼으로 약관 내용 확인 가능 | |
| 동의 후 기존 회원가입 Step 1~7 흐름 정상 동작 | |

- [ ] **Step 2: 커밋 & 푸시 & PR**

```bash
git push origin main
```

> ⚠️ 배포 전 이용약관 실제 URL이 생기면 `ConsentViewController.swift`의 `termsURL` 상수를 업데이트할 것.

---

## 자가 검토

- **Spec coverage:** Task 1(Apple 버튼), Task 2(동의 화면 UI), Task 3(Coordinator 연결), Task 4(최종 검증) — 모든 요구사항 커버
- **Placeholder 없음:** 모든 코드 완전히 작성됨
- **타입 일관성:** `ConsentRowView`, `IeumCheckbox`, `IeumButton` 모두 기존 컴포넌트 재활용, 인터페이스 일치
