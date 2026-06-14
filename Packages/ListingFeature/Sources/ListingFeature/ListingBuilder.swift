import UIKit
import DomainKit

public enum ListingBuilder {

    @MainActor
    public static func build(
        useCase: FetchUniversitiesUseCase,
        country: String,
        navigationController: UINavigationController,
        detailsBuilder: @escaping (University, @escaping RefreshSelectedUniversity) -> UIViewController
    ) -> UIViewController {
        let interactor = ListingInteractor(useCase: useCase, country: country)
        let router = ListingRouter(
            navigationController: navigationController,
            detailsBuilder: detailsBuilder
        )
        let presenter = ListingPresenter(interactor: interactor, router: router)
        return ListingViewController(presenter: presenter)
    }
}
