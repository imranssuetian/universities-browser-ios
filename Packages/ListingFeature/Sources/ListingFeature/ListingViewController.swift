import UIKit
import SwiftUI

final class ListingViewController: UIHostingController<ListingView> {

    init(presenter: ListingPresenter) {
        super.init(rootView: ListingView(presenter: presenter))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Universities"
        navigationItem.largeTitleDisplayMode = .always
    }
}
