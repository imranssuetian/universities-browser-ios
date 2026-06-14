import UIKit
import DomainKit

public enum DetailsBuilder {

    @MainActor
    public static func build(
        university: University,
        refresh: @escaping RefreshSelectedUniversity
    ) -> UIViewController {
        let interactor = DetailsInteractor(refresh: refresh)
        let presenter = DetailsPresenter(university: university, interactor: interactor)
        return DetailsViewController(presenter: presenter)
    }
}
