// File description: controls the sign in view, allows returning users to sign in

// Libraries
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInViewController: UIViewController, UITextFieldDelegate {

    // Outlets from storyboard
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    // Variables
    var staffEmails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    // When the view appears, checks if there is a user still logged in from previous run - if so, transitions user to appropriate section of application based on email
    override func viewDidAppear(_ animated: Bool) {
        showActInd()
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            loadStaffEmails()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                super.viewDidAppear(true)
                let userEmail = currentUser?.email
                if self.staffEmails.contains(userEmail!) {
                    self.performSegue(withIdentifier: "signInToVenueSegue", sender: self)
                    self.hideActInd()
                } else {
                    self.performSegue(withIdentifier: "signInToMainSegue", sender: self)
                    self.hideActInd()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hideActInd()
        }
        
    }
    
    // Signs user in
    @IBAction func signInTapped(_ sender: UIButton) {
        showActInd()
        
        // Ensures that all text fields are filled, otherwise throws error informing user
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            AlertController.alert(self, title: "Error", message: "Please fill in all form fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user: User?, error) in
            if error != nil {
                AlertController.alert(self, title: "Error", message: "Email/password combination not recognised")
                self.hideActInd()
                return
            }
            
            self.loadStaffEmails()
            
            // Sends user to appropriate section of application based on email
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.staffEmails.contains(email) {
                    self.performSegue(withIdentifier: "signInToVenueSegue", sender: self)
                    self.hideActInd()
                } else {
                    self.performSegue(withIdentifier: "signInToMainSegue", sender: self)
                    self.hideActInd()
                }
            }
            
        })
    }
    
    // If an area away from the keyboard is tapped, the keyboard hides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // If the return button is tapped on the keyboard, it acts as if the sign in button has been tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signInTapped(signInButton)
        return true
    }
    
    // Fetches the emails specifically for staff to sign in to the capacity update section from the database and adds to the array
    func loadStaffEmails() {
        let emailRef = Database.database().reference().child("staffEmails")
        emailRef.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.value as! String
                self.staffEmails.append(email)
            }
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

