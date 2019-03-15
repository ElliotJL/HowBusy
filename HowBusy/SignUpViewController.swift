// File description: controls the sign up view, allows new users to sign up

// Libraries
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // Outlets from storyboard
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var actIndView: UIView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        showActInd()
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        hideActInd()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        showActInd()
        
        // Ensures that all text fields are filled, otherwise throws error informing user
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            AlertController.alert(self, title: "Error", message: "Please fill in all form fields")
            return
        }
        
        // Ensures that passwords match, otherwise throws error informing user
        if confirmPassword == password {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
                if error != nil {
                    AlertController.alert(self, title: "Error", message: "Sign up failed")
                    return
                }
                
                guard let uid = user?.uid else {
                    AlertController.alert(self, title: "Error", message: "User ID not found")
                    print("User ID not found")
                    return
                }
                
                // Adds new user to database and creates required children
                let ref = Database.database().reference()
                let newUserReference = ref.child("users").child(uid)
                let values = ["email": email]
                newUserReference.updateChildValues(values, withCompletionBlock: { (dbError, ref) in
                    if dbError != nil {
                        AlertController.alert(self, title: "Error", message: "Failed to save user to database")
                        return
                    }
                })
                let addFavourites = newUserReference.child("favourites")
                // Adds decoy venue to ensure that favourites child doesn't disappear, causing crashes when trying to access nil values in favourites view controller (decoy is programmatically ignored when loading favourites)
                let decoyVenueTitle = "decoyVenueTitle"
                let favouriteArray = ["decoyVenueKey": decoyVenueTitle]
                addFavourites.updateChildValues(favouriteArray, withCompletionBlock: { (dbError, ref) in
                    if dbError != nil {
                        AlertController.alert(self, title: "Error", message: "Failed to save user to database")
                        return
                    }
                })
                
                self.hideActInd()
                // Sends user to main part of application
                self.performSegue(withIdentifier: "signUpToMainSegue", sender: self)
            })
        } else {
            hideActInd()
            AlertController.alert(self, title: "Error", message: "Passwords do not match")
        }
    
    }

    // If an area away from the keyboard is tapped, the keyboard hides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // If the return button is tapped on the keyboard, it acts as if the sign up button has been tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signUpTapped(signUpButton)
        return true
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
