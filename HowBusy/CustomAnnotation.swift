// File description: creates the custom map callout when an annotation is pressed

// Libraries
import UIKit
import FirebaseDatabase

class CustomAnnotation: UIView {

    // Outlets from storyboard
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    
    // Overrides two default inits and calls custom init
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        customInit()
    }
    
    // Loads .xib file, adds to the view and sets layout requirements
    func customInit() {
        Bundle.main.loadNibNamed("CustomAnnotation", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        ratingImage.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
    }

}
