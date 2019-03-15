// File description: controls the more options view

// Libraries
import UIKit
import FirebaseAuth

class MoreViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets top bar title to logo image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 118, height: 30))
        imageView.image = UIImage(named: "howbusylogo30px.png")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    // Signs user out
    @IBAction func signOutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            AlertController.alert(self, title: "Error", message: "Sign out failed")
        }
        
        // Instantiates view controller to prevent storyboard segue causing navigation issues
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let login = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(login, animated: true, completion: nil)
    }
}
