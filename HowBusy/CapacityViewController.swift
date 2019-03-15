// File description: controls the venue staff's view where capacity can be changed etc.

// Libraries
import UIKit
import FirebaseDatabase
import FirebaseAuth

class CapacityViewController: UIViewController {

    // Outlets from storyboard
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var maxCapacityLabel: UILabel!
    @IBOutlet weak var changeStatusButton: UIButton!
    @IBOutlet weak var plusOneButton: UIButton!
    @IBOutlet weak var plusFiveButton: UIButton!
    @IBOutlet weak var minusOneButton: UIButton!
    @IBOutlet weak var minusFiveButton: UIButton!
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    // Constants/variables
    let currentUserEmail = Auth.auth().currentUser!.email
    let staffEmailRef = Database.database().reference().child("staffEmails")
    let venueRef = Database.database().reference().child("venues")
    var venueKey: String?
    var venueTitle: String?
    var venueCapacity: Int?
    var venueMaxCapacity: Int?
    var open: Bool?
    
    override func viewDidLoad() {
        showActInd()
        showVenueDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            super.viewDidLoad()
            // Sets labels and buttons to match venue information
            self.titleLabel.text = self.venueTitle
            if self.open! {
                self.capacityLabel.text = String(self.venueCapacity!)
                self.changeStatusButton.backgroundColor = UIColor(red: 0.96, green: 0.11, blue: 0.15, alpha: 1.0)
                self.changeStatusButton.setTitle("Change to closed", for: .normal)
            } else {
                self.capacityLabel.text = "Closed"
                self.changeStatusButton.backgroundColor = UIColor(red: 0.26, green: 0.91, blue: 0.19, alpha: 1.0)
                self.changeStatusButton.setTitle("Change to open", for: .normal)
            }
            self.maxCapacityLabel.text = "/\(String(self.venueMaxCapacity!))"
            self.setCapacityButtons()
            self.hideActInd()
        }
        
    }
    
    // Adds 1 to capacity
    @IBAction func plusOneTapped(_ sender: UIButton) {
        venueCapacity! += 1
        capacityLabel.text = String(venueCapacity!)
        venueRef.child(venueKey!).child("capacity").setValue(venueCapacity)
        setCapacityButtons()
    }
    
    // Adds 5 to capacity
    @IBAction func plusFiveTapped(_ sender: UIButton) {
        venueCapacity! += 5
        capacityLabel.text = String(venueCapacity!)
        venueRef.child(venueKey!).child("capacity").setValue(venueCapacity)
        setCapacityButtons()
    }
    
    // Subtracts 1 from capacity
    @IBAction func minusOneTapped(_ sender: UIButton) {
        venueCapacity! -= 1
        capacityLabel.text = String(venueCapacity!)
        venueRef.child(venueKey!).child("capacity").setValue(venueCapacity)
        setCapacityButtons()
    }
    
    // Subtracts 5 from capacity
    @IBAction func minusFiveTapped(_ sender: UIButton) {
        venueCapacity! -= 5
        capacityLabel.text = String(venueCapacity!)
        venueRef.child(venueKey!).child("capacity").setValue(venueCapacity)
        setCapacityButtons()
    }
    
    // Changes venue status between closed and open when the button is pressed
    @IBAction func changeStatusTapped(_ sender: UIButton) {
        if open! {
            self.capacityLabel.text = "Closed"
            changeStatusButton.backgroundColor = UIColor(red: 0.26, green: 0.91, blue: 0.19, alpha: 1.0)
            changeStatusButton.setTitle("Change to open", for: .normal)
            venueRef.child(venueKey!).child("open").setValue(false)
            venueCapacity! = 0
            venueRef.child(venueKey!).child("capacity").setValue(venueCapacity)
            open = false
            setCapacityButtons()
        } else {
            capacityLabel.text = String(self.venueCapacity!)
            changeStatusButton.backgroundColor = UIColor(red: 0.96, green: 0.11, blue: 0.15, alpha: 1.0)
            changeStatusButton.setTitle("Change to closed", for: .normal)
            venueRef.child(venueKey!).child("open").setValue(true)
            open = true
            setCapacityButtons()
        }
    }
    
    // Signs user out
    @IBAction func signOutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            AlertController.alert(self, title: "Error", message: "Sign out failed")
        }
        
        // Transitions user to sign in page
        self.performSegue(withIdentifier: "venueSignOutSegue", sender: self)
    }
    
    // Fetches venue information from Firebase Database
    func showVenueDetails() {
        staffEmailRef.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if (child.value as! String) == self.currentUserEmail {
                    self.venueKey = child.key
                    self.venueRef.observe(.value) { (snapshot) in
                        for vChild in snapshot.children.allObjects as! [DataSnapshot] {
                            if vChild.key == self.venueKey {
                                self.venueTitle = vChild.childSnapshot(forPath: "title").value as? String
                                self.venueCapacity = vChild.childSnapshot(forPath: "capacity").value as? Int
                                self.venueMaxCapacity = vChild.childSnapshot(forPath: "maxCapacity").value as? Int
                                self.open = vChild.childSnapshot(forPath: "open").value as? Bool
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Ensures that buttons are disabled when pressing again would go below zero or above the venue's maximum
    func setCapacityButtons() {
        if open! {
            if venueCapacity! == 0 {
                minusOneButton.isEnabled = false
            } else {
                minusOneButton.isEnabled = true
            }
            
            if venueCapacity! < 5 {
                minusFiveButton.isEnabled = false
            } else {
                minusFiveButton.isEnabled = true
            }
            
            if venueCapacity! == venueMaxCapacity! {
                plusOneButton.isEnabled = false
            } else {
                plusOneButton.isEnabled = true
            }
            
            if venueCapacity! > (venueMaxCapacity! - 5) {
                plusFiveButton.isEnabled = false
            } else {
                plusFiveButton.isEnabled = true
            }
        } else {    // Disables all buttons, as the venue is closed so capacity does not need to be changed
            plusOneButton.isEnabled = false
            plusFiveButton.isEnabled = false
            minusOneButton.isEnabled = false
            minusFiveButton.isEnabled = false
        }
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
