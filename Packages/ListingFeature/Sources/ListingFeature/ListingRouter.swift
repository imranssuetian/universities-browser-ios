import UIKit
import DomainKit

@MainActor
final class ListingRouter: ListingRouting {

    private weak var navigationController: UINavigationController?
    private let detailsBuilder: (University, @escaping RefreshSelectedUniversity) -> UIViewController

    init(
        navigationController: UINavigationController,
        detailsBuilder: @escaping (University, @escaping RefreshSelectedUniversity) -> UIViewController
    ) {
        self.navigationController = navigationController
        self.detailsBuilder = detailsBuilder
    }

    func showDetails(for university: University, refresh: @escaping RefreshSelectedUniversity) {
        let details = detailsBuilder(university, refresh)
        navigationController?.pushViewController(details, animated: true)
    }
}
