//
//  TempuratureCell.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/24/24.
//

import UIKit

class TempuratureCell: UITableViewCell {
    
    static let reuseIdentifier = "TempuratureCell"
    
    @IBOutlet var oceanName: UILabel!
    @IBOutlet var surTempurature: UILabel!
    @IBOutlet var midTempurature: UILabel!
    @IBOutlet var botTempurature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with stationModel: OceanStationModel) {
        oceanName.text = stationModel.stationName
        surTempurature.text = stationModel.surTempurature
        midTempurature.text = stationModel.midTempurature
        botTempurature.text = stationModel.botTempurature
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
