
import Foundation
import WebKit


class SearchVM: NSObject {
    
    private(set) weak var search: MileusSearch!
    
    var updateCoordinates: (() -> Void)?
    let urlHandler: () -> URL
    
    private let inputSanitizer = InputSanitizer()
    
    init(search: MileusSearch, urlHandler: @escaping () -> URL) {
        self.search = search
        self.urlHandler = urlHandler
    }
    
    deinit {
        debugPrint("DEINIT: \(String(describing: self))")
    }
    
    func getURL() -> URL {
        return urlHandler()
    }
    
    func getOrigin() -> String? {
        if let location = search.origin {
            return formatLocation(location: location)
        }
        return nil
    }
    
    func getDestination() -> String? {
        if let location = search.destination {
            return formatLocation(location: location)
        }
        return nil
    }
    
    func coordinatesUpdated() {
        updateCoordinates?()
    }
    
    func didFinish() {
        DispatchQueue.main.async { [unowned self] in
            self.search?.delegate?.mileusDidFinish(self.search)
        }
    }
    
    func openSearch(data: [String : String]) {
        guard let rawSearchType = data["search_type"], let searchType = MileusSearchType(raw: rawSearchType)  else {
            return
        }
        guard let origin = search.origin, let destination = search.destination else {
            return
        }
        let searchDate = MileusSearchData(type: searchType, origin: origin, destination: destination)
        DispatchQueue.main.async {
            self.search?.delegate?.mileus(self.search, showSearch: searchDate)
        }
    }
    
    func openTaxiRide() {
        DispatchQueue.main.async {
            self.search?.delegate?.mileusShowTaxiRide(self.search)
        }
    }
    
    private func formatLocation(location: MileusLocation) -> String {
        return "{'lat': \(location.latitude), 'lon': \(location.longitude), 'address': '\(inputSanitizer.sanitizeJS(location.address))', 'accuracy': \(location.accuracy)}"
    }
    
}


extension SearchVM: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == SearchView.WebViewJSConstants.openSearch {
            guard let jsonString = message.body as? String else {
                return
            }
            guard let data = jsonString.data(using: .utf8) else {
                return
            }
            guard let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : String] else {
                return
            }
            DispatchQueue.main.async {
                self.openSearch(data: dic)
            }
        } else if message.name == SearchView.WebViewJSConstants.openTaxiRide {
            DispatchQueue.main.async {
                self.openTaxiRide()
            }
        }
    }
    
}
