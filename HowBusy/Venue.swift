// File description: creates a new venue with all necessary information

// Libraries
import UIKit

// Custom venue object, which holds all required information for a venue
class Venue: NSObject {

    // Variables
    var key: String
    var title: String
    var mainImageUrl: String
    var mainImage: UIImage
    var vDescription: String
    var mondayOH: String
    var tuesdayOH: String
    var wednesdayOH: String
    var thursdayOH: String
    var fridayOH: String
    var saturdayOH: String
    var sundayOH: String
    var open: Bool
    var address: String
    var phone: String
    var email: String
    var latitude: Double
    var longitude: Double
    var capacity: Int
    var maxCapacity: Int
    var averageRating: Double
    
    // Required initialisation of variables
    init(key: String, title: String, mainImageUrl: String, mainImage: UIImage, vDescription: String, mondayOH: String, tuesdayOH: String, wednesdayOH: String, thursdayOH: String, fridayOH: String, saturdayOH: String, sundayOH: String, open: Bool, address: String, phone: String, email: String, latitude: Double, longitude: Double, capacity: Int, maxCapacity: Int, averageRating: Double) {
        self.key = key
        self.title = title
        self.mainImageUrl = mainImageUrl
        self.mainImage = mainImage
        self.vDescription = vDescription
        self.mondayOH = mondayOH
        self.tuesdayOH = tuesdayOH
        self.wednesdayOH = wednesdayOH
        self.thursdayOH = thursdayOH
        self.fridayOH = fridayOH
        self.saturdayOH = saturdayOH
        self.sundayOH = sundayOH
        self.open = open
        self.address = address
        self.phone = phone
        self.email = email
        self.latitude = latitude
        self.longitude = longitude
        self.capacity = capacity
        self.maxCapacity = maxCapacity
        self.averageRating = averageRating
        super.init()
    }
    
}
