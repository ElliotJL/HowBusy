// File description: creates a custom table cell to allow extra features and reusability

// Libraries
import UIKit

// A custom cell created on the storyboard
class CustomFavouriteCell: UITableViewCell {
    
    // Outlets from storyboard
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingImage.tintColor = UIColor(red: 1.00, green: 0.90, blue: 0.16, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
