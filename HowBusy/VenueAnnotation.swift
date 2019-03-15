// File description: creates a new annotation for custom coordinates and reusability

// Libraries
import UIKit
import MapKit

// Custom annotation object to hold just a coordinate
class VenueAnnotation: NSObject, MKAnnotation {
    
    // Variables
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
}
