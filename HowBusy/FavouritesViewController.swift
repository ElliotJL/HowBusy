// File description: controls the favourites view, shows venues that user has added to favourites

// Libraries
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

// Normal UIViewControllers with table views inside require the Delegate and Data Source extensions
class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets from storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noFavouritesView: UIView!
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    // Variables
    var favouritesList = [String]()
    var selectedVenue: Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets top bar title to logo image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 118, height: 30))
        imageView.image = UIImage(named: "howbusylogo30px.png")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        // Sets delegate and data source so table view knows where to get information from
        tableView.delegate = self
        tableView.dataSource = self
        // Adds blank view to bottom of table to prevent extra lines
        let footerView = UIView()
        footerView.tintColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
        tableView.tableFooterView = footerView
        // Adds message behind table for when no cells are added (no favourites)
        tableView.backgroundView = noFavouritesView
        tableView.backgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
    }
    
    // Loads favourites every time the view is navigated to, rather than just the first load
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadFavourites()
    }
    
    func loadFavourites() {
        showActInd()
        // Clears list to prevent duplicates
        favouritesList.removeAll()
        // Finds user ID and gets reference to user favourites in Firebase Database to add favourites to list
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users").child(uid).child("favourites")
        ref.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                // Ensures that decoy venue isn't added
                if child.key != "decoyVenueKey" {
                    self.favouritesList.append(child.key)
                }
            }
        }
        // Reloads table once database has been read
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.reloadData()
            self.hideActInd()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Shows 'No favourites' if there are no cells, else it hides
        if favouritesList.count == 0 {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        
        // Number of cells equals the number of venues in favourites list
        return favouritesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Creates reusable cell and downcasts it as a custom favourite cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomFavouriteCell
        
        // Fetches information of venues in favourites list from the database and assigns to appropriate cell objects
        let ref = Database.database().reference().child("venues")
        ref.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.key == self.favouritesList[indexPath.row] {
                    cell.titleLabel.text = child.childSnapshot(forPath: "title").value as? String
                    cell.addressLabel.text = child.childSnapshot(forPath: "address").value as? String
                    let averageRating = child.childSnapshot(forPath: "averageRating").value as? Double
                    cell.ratingLabel.text = String(self.roundRating(rating: averageRating!))
                    let open = child.childSnapshot(forPath: "open").value as? Bool
                    let capacity = child.childSnapshot(forPath: "capacity").value as? Int
                    let maxCapacity = child.childSnapshot(forPath: "maxCapacity").value as? Int
                    let capacityPercentage = Int((Double(capacity! * 100)/Double(maxCapacity!)).rounded())
                    if open! {
                        cell.capacityLabel.text = "\(capacityPercentage)%"
                    } else {
                        cell.capacityLabel.text = "Closed"
                    }
                    
                    // Fetches URL from database and uses it to download image from storage
                    let mainImageUrl = child.childSnapshot(forPath: "mainImageUrl").value as! String
                    let storageRef = Storage.storage().reference(forURL: mainImageUrl)
                    storageRef.getData(maxSize: 1024 * 1024 * 1) { (data, error) in
                        if error != nil {
                            AlertController.alert(self, title: "Error", message: "Venue image couldn't be downloaded")
                            return
                        }
                        
                        let mainImage = UIImage(data: data!)
                        cell.venueImage.image = mainImage
                    }
                }
            }
        }
        
        return cell
    }
    
    // Ensures that 'no favourites' view can be seen when it displays
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .clear
    }
    
    // When a venue cell is selected, a database fetch is done to assign all venue details to constants, then assigns them to a venue variable which will be passed to the venue view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActInd()
        let venueKey = favouritesList[indexPath.row]
        let ref = Database.database().reference().child("venues")
        ref.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.key == venueKey {
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
                    
                    let storageRef = Storage.storage().reference(forURL: mainImageUrl)
                    storageRef.getData(maxSize: 1024 * 1024 * 1) { (data, error) in
                        if error != nil {
                            AlertController.alert(self, title: "Error", message: "Venue image couldn't be downloaded")
                            return
                        }
                        
                        let mainImage = UIImage(data: data!)
                        self.selectedVenue = Venue(key: venueKey, title: title, mainImageUrl: mainImageUrl, mainImage: mainImage!, vDescription: vDescription, mondayOH: mondayOH, tuesdayOH: tuesdayOH, wednesdayOH: wednesdayOH, thursdayOH: thursdayOH, fridayOH: fridayOH, saturdayOH: saturdayOH, sundayOH: sundayOH, open: open, address: address, phone: phone, email: email, latitude: latitude, longitude: longitude, capacity: capacity, maxCapacity: maxCapacity, averageRating: averageRating)
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hideActInd()
            self.tableView.deselectRow(at: indexPath, animated: true)
            // Sends user to page of venue selected
            self.performSegue(withIdentifier: "favouriteToVenueSegue", sender: self)
        }
    }
    
    // Prepares segue by creating an instance of the venue view controller and assigning the selected venue variable to the venue's matching variable
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let venueVC = segue.destination as! VenueViewController
        venueVC.venue = selectedVenue
    }
    
    // Rounds the double to one decimal place, rather than zero (default)
    func roundRating(rating: Double) -> Double {
        let multRating = rating * 10
        let roundedRating = multRating.rounded()
        let divRating = roundedRating / 10
        return divRating
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
