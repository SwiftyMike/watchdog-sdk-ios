
import UIKit
import MileusWatchdogKit


class FormVM {
    
    var accessToken: String? {
        didSet {
            config.accessToken = accessToken
        }
    }
    var originAddress: String!
    @LocationWrapper(value: "50.091266")
    var originLatitude: String!
    @LocationWrapper(value: "14.438927")
    var originLongitude: String!
    var destinationAddress: String!
    @LocationWrapper(value: "50.121765629793295")
    var destinationLatitude: String!
    @LocationWrapper(value: "14.489431312606477")
    var destinationLongitude: String!
    
    var mileusSearch: MileusWatchdogSearch?
    var mileusMarketValidation: MileusMarketValidation?
    var searchData: MileusWatchdogSearchData?
    
    private let config: Config
    
    init() {
        config = Config.shared
        accessToken = config.accessToken
        
#if DEBUG
        accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhaSI6MTIzNDUsInBuIjoiZHVtbXktcGFydG5lciIsInBlaSI6ImV4dGVybmFsLXBhc3Nlbmdlci1ib3QiLCJpYXQiOjE1ODg3NjIyNjZ9.FnBB0IJLSa76h8zaTnbZ1qDCTnSlZbplnEq64TbY2FE"
#endif
        
        originAddress = "Prague - Nové Město"
        destinationAddress = "Not Prague center"
    }
    
    func getOrigin() -> MileusWatchdogLocation {
        return MileusWatchdogLocation(address: originAddress,
                              latitude: $originLatitude,
                              longitude: $originLongitude
        )
    }
    
    func getDestination() -> MileusWatchdogLocation {
        return MileusWatchdogLocation(address: destinationAddress,
                              latitude: $destinationLatitude,
                              longitude: $destinationLongitude
        )
    }
    
    func search(from: UIViewController, delegate: MileusWatchdogSearchFlowDelegate) -> UIViewController {
        try! MileusWatchdogKit.configure(partnerName: "ios-test-app", accessToken: getToken(), environment: .development)
        mileusSearch = try! MileusWatchdogSearch(delegate: delegate, origin: getOrigin(), destination: getDestination())
        
        return mileusSearch!.show(from: from)
    }
    
    func validation(from: UIViewController, delegate: MileusMarketValidationFlowDelegate) -> UIViewController {
        try! MileusWatchdogKit.configure(partnerName: "ios-test-app", accessToken: getToken(), environment: .development)
        mileusMarketValidation = try! MileusMarketValidation(delegate: delegate, origin: getOrigin(), destination: getDestination())
        
        return mileusMarketValidation!.show(from: from)
    }
    
    func updateLocation(location: MileusWatchdogLocation) {
        guard let data = searchData else {
            return
        }
        switch data.type {
        case .origin:
            mileusSearch?.updateOrigin(location: location)
        case .destination:
            mileusSearch?.updateDestination(location: location)
        }
    }
    
    @inline(__always)
    private func getToken() -> String {
        (accessToken?.isEmpty ?? true) ? "unknown-token-ios-test-app" : accessToken!
    }
    
}
