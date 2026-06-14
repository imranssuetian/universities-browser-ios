import UIKit
import DomainKit
import NetworkKit
import PersistenceKit
import ListingFeature
import DetailsFeature

@MainActor
enum CompositionRoot {

    static let country = "United Arab Emirates"

    static func makeRootViewController() -> UIViewController {
        let useCase = makeUseCase()
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let listing = ListingBuilder.build(
            useCase: useCase,
            country: country,
            navigationController: navigationController,
            detailsBuilder: { university, refresh in
                DetailsBuilder.build(university: university, refresh: refresh)
            }
        )

        navigationController.viewControllers = [listing]
        return navigationController
    }

    private static func makeUseCase() -> FetchUniversitiesUseCase {
        let remote = UniversityRemoteDataSource()
        let cache = CoreDataUniversityCache()
        let repository = UniversityRepositoryImpl(remote: remote, cache: cache)
        return DefaultFetchUniversitiesUseCase(repository: repository)
    }
}
