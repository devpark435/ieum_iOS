import UIKit
import WebKit
import SnapKit
import Then

final class PrivacyPolicyViewController: UIViewController {
    
    // MARK: - Constants
    
    private let privacyPolicyURL = "https://southern-dash-bc7.notion.site/2f7a0853c74280b7b6a1d7a0172cbdac"
    
    // MARK: - UI Components
    
    private let webView = WKWebView().then {
        $0.backgroundColor = Colors.white
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = Colors.Gray.g600
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        setupNavigationBar()
        setupUI()
        setupLayout()
        loadPrivacyPolicy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "개인정보 처리방침"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.white
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.Gray.g950,
            .font: UIFont.ieum(UIFont.IeumFont.Heading.h4)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        backButton.tintColor = Colors.Gray.g950
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI() {
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        webView.navigationDelegate = self
    }
    
    private func setupLayout() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadPrivacyPolicy() {
        guard let url = URL(string: privacyPolicyURL) else { return }
        let request = URLRequest(url: url)
        loadingIndicator.startAnimating()
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension PrivacyPolicyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("WebView loading failed: \(error.localizedDescription)")
    }
}
