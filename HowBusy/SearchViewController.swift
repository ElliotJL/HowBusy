// File description: controls the search view, allowing users to browse the map and select venues to view

// Libraries
import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage

class SearchViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // Outlets from storyboard
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customAnnotation: CustomAnnotation!
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    // Constants/variables
    let locationManager = CLLocationManager()
    var regionCentred = false
    var venues = [Venue]()
    var selectedAnnotation: VenueAnnotation?
    var annotationVenue: Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets top bar title to logo image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 118, height: 30))
        imageView.image = UIImage(named: "howbusylogo30px.png")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        customAnnotation.isHidden = true
        
        // Requests use of user location on first launch
        locationManager.requestWhenInUseAuthorization()
        
        showActInd()
        
        // Updates user location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        addAnnotationsToMap()
        
        // Allows the custom annotation view to be tapped
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(self.loadVenuePage(_:)))
        customAnnotation.addGestureRecognizer(gestureRec)
        
        // Gives view time to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.hideActInd()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        // On each app launch, zoom view to user location
        if !regionCentred {
            let centre = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            let region = MKCoordinateRegion(center: centre, span: span)
            
            mapView.setRegion(region, animated: true)
            regionCentred = true
        }
        
        // Shows user location
        mapView.showsUserLocation = true
    }
    
    // Reuses annotations that go off the screen when the user moves around the map, or creates a new one if needed
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "VenueAnnotation"
        
        if annotation is VenueAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = false
                annotationView!.image = UIImage(named: "mapmarker")
                
                let button = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = button
                
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    
    // Fills custom annotation view objects with appropriate details and shows it when an annotation is tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Changes marker (colour)
        view.image = UIImage(named: "mapmarkerselected")
        
        // Finds selected venue by searching array for venue with matching coordinates
        selectedAnnotation = view.annotation as? VenueAnnotation
        let selectedLat = selectedAnnotation?.coordinate.latitude
        let selectedLong = selectedAnnotation?.coordinate.longitude
        annotationVenue = venues.first(where: { $0.latitude == selectedLat && $0.longitude == selectedLong })
        
        customAnnotation.titleLabel.text = annotationVenue!.title
        customAnnotation.addressLabel.text = annotationVenue!.address
        customAnnotation.venueImage.image = annotationVenue!.mainImage
        updateRating(venue: annotationVenue!)
        customAnnotation.ratingLabel.text = String(roundRating(rating: annotationVenue!.averageRating))
        updateCapacity(venue: annotationVenue!)
        let capacityPercentage = Int((Double((annotationVenue?.capacity)! * 100)/Double((annotationVenue?.maxCapacity)!)).rounded())
        if annotationVenue!.open {
            customAnnotation.capacityLabel.text = String("\(capacityPercentage)%")
        } else {
            customAnnotation.capacityLabel.text = "Closed"
        }
        
        customAnnotation.isHidden = false
    }
    
    // Hides custom annotation and changes marker (colour) when the map (not an annotation) is tapped
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "mapmarker")
        customAnnotation.isHidden = true
    }
    
    // Fetches venue information from the database and assigns to a venue instance, and adds to the venue array and the map
    func addAnnotationsToMap() {
        let ref = Database.database().reference().child("venues")
        ref.observe(.value) { (snapshot) in
            // Iterates over each child in database section so that every venue is added
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let key = child.key
                let title = child.childSnapshot(forPath: "title").value as! String
                let mainImageUrl = child.childSnapshot(forPath: "mainImageUrl").value as! String
                let vDescription = child.childSnapshot(forPath: "description").value as! String
                let mondayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Monday").value as! String
                let tuesdayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Tuesday").value as! String
                let wednesdayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Wednesday").value as! String
                let thursdayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Thursday").value as! String
                let fridayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Friday").value as! String
                let saturdayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Saturday").value as! String
                let sundayOH = child.childSnapshot(forPath: "openingHours").childSnapshot(forPath: "Sunday").value as! String
                let open = child.childSnapshot(forPath: "open").value as! Bool
                let address = child.childSnapshot(forPath: "address").value as! String
                let phone = child.childSnapshot(forPath: "phone").value as! String
                let email = child.childSnapshot(forPath: "email").value as! String
                let latitude = child.childSnapshot(forPath: "latitude").value as! Double
                let longitude = child.childSnapshot(forPath: "longitude").value as! Double
                let capacity = child.childSnapshot(forPath: "capacity").value as! Int
                let maxCapacity = child.childSnapshot(forPath: "maxCapacity").value as! Int
                let averageRating = child.childSnapshot(forPath: "averageRating").value as! Double
                
                // Uses URL from database to download image from storage
                let storageRef = Storage.storage().reference(forURL: mainImageUrl)
                storageRef.getData(maxSize: 1024 * 1024 * 1) { (data, error) in
                    if error != nil {
                        AlertController.alert(self, title: "Error", message: "Venue image couldn't be downloaded")
                        return
                    }
                    
                    let mainImage = UIImage(data: data!)
                    let venue = Venue(key: key, title: title, mainImageUrl: mainImageUrl, mainImage: mainImage!, vDescription: vDescription, mondayOH: mondayOH, tuesdayOH: tuesdayOH, wednesdayOH: wednesdayOH, thursdayOH: thursdayOH, fridayOH: fridayOH, saturdayOH: saturdayOH, sundayOH: sundayOH, open: open, address: address, phone: phone, email: email, latitude: latitude, longitude: longitude, capacity: capacity, maxCapacity: maxCapacity, averageRating: averageRating)
                    self.venues.append(venue)
                }
                
                let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                let annotation = VenueAnnotation(coordinate: coordinate)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    // Called each time the view appears to keep the capacity more updated (fetches from database and assigns to venue in array)
    func updateCapacity(venue: Venue) {
        let ref = Database.database().reference().child("venues")
        let venueKey = venue.key
        ref.observe(.value) { (snapshot) in
            if snapshot.hasChild(venueKey) {
                let newCapacity = snapshot.childSnapshot(forPath: venueKey).childSnapshot(forPath: "capacity").value as! Int
                venue.capacity = newCapacity
                let listVenue = self.venues.first(where: { $0.title == venue.title })
                listVenue?.capacity = newCapacity
            }
        }
    }
    
    // Called each time the view appears to keep the rating more updated (fetches from database and assigns to venue in array)
    func updateRating(venue: Venue) {
        let ref = Database.database().reference().child("venues")
        let venueKey = venue.key
        ref.observe(.value) { (snapshot) in
            if snapshot.hasChild(venueKey) {
                let newRating = snapshot.childSnapshot(forPath: venueKey).childSnapshot(forPath: "averageRating").value as! Double
                venue.averageRating = newRating
                let listVenue = self.venues.first(where: { $0.title == venue.title })
                listVenue?.averageRating = newRating
            }
        }
    }
    
    // Rounds the double to one decimal place, rather than zero (default)
    func roundRating(rating: Double) -> Double {
        let multRating = rating * 10
        let roundedRating = multRating.rounded()
        let divRating = roundedRating / 10
        return divRating
    }
    
    // Prepares segue by creating an instance of the venue view controller and assigning the selected venue variable to the venue's matching variable
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let venueVC = segue.destination as! VenueViewController
        venueVC.venue = annotationVenue
    }
    
    // Detects when the custom annotation has been tapped, and transitions the user to the venue page
    @objc func loadVenuePage(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "selectVenueSegue", sender: self)
    }
    
    // Shows activity indicator and disables user interaction
    func showActInd() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        actInd.startAnimating()
        actInd.isHidden = false
        actIndView.isHidden = false
    }
    
    // Hides activity indicator and enables user interaction
    func hideActInd() {
        actInd.stopAnimating()
        actInd.isHidden = true
        actIndView.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
