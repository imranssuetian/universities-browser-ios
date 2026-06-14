import UIKit
import SwiftUI
import Combine

final class DetailsViewController: UIViewController {

    private let presenter: DetailsPresenter
    private var cancellables = Set<AnyCancellable>()

    private lazy var refreshButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.clockwise"),
        style: .plain,
        target: self,
        action: #selector(didTapRefresh)
    )

    private lazy var loadingButton: UIBarButtonItem = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        return UIBarButtonItem(customView: indicator)
    }()

    init(presenter: DetailsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = refreshButton

        embedContent()
        bind()
    }

    private func embedContent() {
        let host = UIHostingController(rootView: DetailsView(presenter: presenter))
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }

    private func bind() {

        presenter.$isRefreshing
            .receive(on: RunLoop.main)
            .sink { [weak self] isRefreshing in
                guard let self else { return }
                self.navigationItem.rightBarButtonItem = isRefreshing ? self.loadingButton : self.refreshButton
            }
            .store(in: &cancellables)
    }

    @objc private func didTapRefresh() {
        presenter.refresh()
    }
}
