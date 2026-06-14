import DomainKit

enum ListingViewState: Equatable {
    case loading
    case loaded([University])
    case empty
    case error(message: String)
}
