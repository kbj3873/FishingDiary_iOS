//
//  PointDateCell.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/11.
//

import UIKit

class PointDateCell: UITableViewCell {

    static let reuseIdentifier = "PointDateCell"
    
    @IBOutlet var dayLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with viewModel: PointDateListItemViewModel) {
        dayLb.text = viewModel.date
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
