import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        get("/", ":lat", ":lng") { req in
            guard let lat = req.parameters["lat"]?.double,
                let lng = req.parameters["lng"]?.double else {
                    throw Abort.badRequest
            }
            guard let key = self.config["keys", "google-maps-geocoding-api-key"]?.string else {
                throw Abort.serverError
            }
            let res = try self.client.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=\(key)")
            let results = res.json?["results"]?.array
            let firstResult = results?.first?.object
            let addressComponents = firstResult?["address_components"]?.array
            let isInBerlin = addressComponents?.contains { addressComponent -> Bool in
                let isLocality = addressComponent.object?["types"]?.array?.contains("locality") ?? false
                let isBerlin = addressComponent.object?["long_name"] == "Berlin"
                return isLocality && isBerlin
                } ?? false
            let isInGermany = addressComponents?.contains { addressComponent -> Bool in
                let isCountry = addressComponent.object?["types"]?.array?.contains("country") ?? false
                let isGermany = addressComponent.object?["long_name"] == "Germany"
                return isCountry && isGermany
                } ?? false
            return String(isInBerlin && isInGermany)
        }
    }
    
}
