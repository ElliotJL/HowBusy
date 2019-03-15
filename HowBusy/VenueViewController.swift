// File description: controls the venue view, displays all information about the venue that was selected

// Libraries
import UIKit
import FirebaseDatabase
import FirebaseAuth

class VenueViewController: UIViewController {
    
    // Variables
    var venue: Venue?
    
    // Outlets from storyboard
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favouriteImage: UIButton!
    @IBOutlet weak var capacityLabel: UILabel!
    
    @IBOutlet weak var ratingOne: UIButton!
    @IBOutlet weak var ratingTwo: UIButton!
    @IBOutlet weak var ratingThree: UIButton!
    @IBOutlet weak var ratingFour: UIButton!
    @IBOutlet weak var ratingFive: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        showActInd()
        super.viewDidLoad()
        
        // Sets top bar title to logo image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 118, height: 30))
        imageView.image = UIImage(named: "howbusylogo30px.png")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        // Sets images to appropriate colours
        ratingImage.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
        ratingOne.tintColor = .gray
        ratingTwo.tintColor = .gray
        ratingThree.tintColor = .gray
        ratingFour.tintColor = .gray
        ratingFive.tintColor = .gray
        setFavouriteImage()
        setRatingImages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateRatingLabel()
        }
        
        // Sets objects on page to match variables from venue passed through segue
        titleLabel.text = venue!.title
        let capacityPercentage = Int((Double(venue!.capacity * 100)/Double(venue!.maxCapacity)).rounded())
        if venue!.open {
            capacityLabel.font = capacityLabel.font.withSize(30)
            capacityLabel.text = String("\(capacityPercentage)%")
        } else {
            capacityLabel.font = capacityLabel.font.withSize(20)
            capacityLabel.text = "Closed"
        }
        descriptionLabel.text = venue!.vDescription
        mondayLabel.text = "Monday: \(venue!.mondayOH)"
        tuesdayLabel.text = "Tuesday: \(venue!.tuesdayOH)"
        wednesdayLabel.text = "Wednesday: \(venue!.wednesdayOH)"
        thursdayLabel.text = "Thursday: \(venue!.thursdayOH)"
        fridayLabel.text = "Friday: \(venue!.fridayOH)"
        saturdayLabel.text = "Saturday: \(venue!.saturdayOH)"
        sundayLabel.text = "Sunday: \(venue!.sundayOH)"
        addressLabel.text = venue!.address
        phoneLabel.text = "Telephone: \(venue!.phone)"
        emailLabel.text = "Email: \(venue!.email)"
    }
    
    // Either adds venue to user's favourites or removes, depending on whether it has previously been favourited or not
    @IBAction func favouriteTapped(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(uid!).child("favourites")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.hasChild(self.venue!.key) {
                ref.child(self.venue!.key).setValue(self.venue!.title)
                self.setFavouriteImage()
            } else {
                ref.child(self.venue!.key).removeValue()
                self.setFavouriteImage()
            }
        }
    }
    
    // Sets favourite image to filled or empty on each view load, depending on whether it is a favourite or not (fetches from database)
    func setFavouriteImage() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(uid!).child("favourites")
        ref.observe(.value) { (snapshot) in
            if snapshot.hasChild(self.venue!.key) {
                let image1 = UIImage(named: "hearticon.png")!.withRenderingMode(.alwaysTemplate)
                self.favouriteImage.setImage(image1, for: .normal)
                self.favouriteImage.tintColor = .red
            } else {
                let image2 = UIImage(named: "hearticonoutline.png")!.withRenderingMode(.alwaysTemplate)
                self.favouriteImage.setImage(image2, for: .normal)
                self.favouriteImage.tintColor = .red
            }
        }
    }
    
    // Fetches a previous rating value from the database if the user has rated the venue before
    func setRatingImages() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("venues").child(venue!.key).child("ratings")
        ref.observe(.value) { (snapshot) in
            if snapshot.hasChild(uid!) {
                let count = Int(snapshot.childSnapshot(forPath: uid!).value as! Double)
                self.changeRatingStarCount(count: count)
            }
        }
    }
    
    // Calls functions with appropriate parameters based on which star is tapped
    @IBAction func ratingOneTapped(_ sender: UIButton) {
        changeRatingStarCount(count: 1)
        addUserRating(rating: 1.0)
        updateRatingLabel()
    }
    
    @IBAction func ratingTwoTapped(_ sender: UIButton) {
        changeRatingStarCount(count: 2)
        addUserRating(rating: 2.0)
        updateRatingLabel()
    }
    
    @IBAction func ratingThreeTapped(_ sender: UIButton) {
        changeRatingStarCount(count: 3)
        addUserRating(rating: 3.0)
        updateRatingLabel()
    }
    
    @IBAction func ratingFourTapped(_ sender: UIButton) {
        changeRatingStarCount(count: 4)
        addUserRating(rating: 4.0)
        updateRatingLabel()
    }
    
    @IBAction func ratingFiveTapped(_ sender: UIButton) {
        changeRatingStarCount(count: 5)
        addUserRating(rating: 5.0)
        updateRatingLabel()
    }
    
    // Changes stars to grey or yellow based on which has been tapped to represent the rating
    func changeRatingStarCount(count: Int) {
        switch count {
        case 1:
            ratingOne.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingTwo.tintColor = .gray
            ratingThree.tintColor = .gray
            ratingFour.tintColor = .gray
            ratingFive.tintColor = .gray
        case 2:
            ratingOne.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingTwo.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingThree.tintColor = .gray
            ratingFour.tintColor = .gray
            ratingFive.tintColor = .gray
        case 3:
            ratingOne.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingTwo.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingThree.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingFour.tintColor = .gray
            ratingFive.tintColor = .gray
        case 4:
            ratingOne.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingTwo.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingThree.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingFour.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingFive.tintColor = .gray
        case 5:
            ratingOne.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingTwo.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingThree.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingFour.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
            ratingFive.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
        default:
            ratingOne.tintColor = .gray
            ratingTwo.tintColor = .gray
            ratingThree.tintColor = .gray
            ratingFour.tintColor = .gray
            ratingFive.tintColor = .gray
        }
    }
    
    // Adds user's rating to the database
    func addUserRating(rating: Double) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("venues").child(venue!.key).child("ratings")
        ref.child(uid!).setValue(rating)
    }
    
    // Fetches venue ratings from database, calculates average and displays it
    func updateRatingLabel() {
        showActInd()
        var ratingTotal = 0.0
        var ratingCount = 0.0
        var averageRating = 0.0
        let ref = Database.database().reference().child("venues").child(venue!.key)
        ref.child("ratings").observe(.value) { (snapshot) in
            if snapshot.childrenCount == 1 {
                ratingTotal = 0.0
                ratingCount = 1.0
            } else {
                // Iterates over children, fetches the rating (value), adds to the total variable and increments the count
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    // Ignores decoy rating (in place to prevent 'ratings' child from disappearing, which would cause crashes when trying to find nil values)
                    if child.key != "decoyRatingKey" {
                        ratingTotal += child.value as! Double
                        ratingCount += 1.0
                    }
                }
            }
        }
        
        // Calculates average rating, adds to database and sets label
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            averageRating = ratingTotal/ratingCount
            if averageRating != 0.0 {
                ref.child("averageRating").setValue(self.roundRating(rating: averageRating))
                self.ratingLabel.text = String(self.roundRating(rating: averageRating))
            } else {
                self.ratingLabel.text = "---"
            }
            self.hideActInd()
            UIApplication.shared.endIgnoringInteractionEvents() // Bug fix, hideActInd() call would not re-enable user interaction
        }
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
