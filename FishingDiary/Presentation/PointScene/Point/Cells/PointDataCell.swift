//
//  PointDataCell.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/11.
//

import UIKit

class PointDataCell: UITableViewCell {
    
    static let reuseIdentifer = "PointDataCell"
    
    @IBOutlet var pointLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with viewModel: PointDataListItemViewModel) {
        pointLb.text = viewModel.dataName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
