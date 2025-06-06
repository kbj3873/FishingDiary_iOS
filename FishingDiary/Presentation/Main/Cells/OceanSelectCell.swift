//
//  OceanSelectCell.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/28/25.
//

import UIKit

protocol OceanSelectCellDelegate {
    func onSelectRegion(_ selected: Bool, model: OceanStationModel)
}

class OceanSelectCell: UITableViewCell {

    static let reuseIdentifier = "OceanSelectCell"
    
    var delegate: OceanSelectCellDelegate?
    
    var viewModel: OceanStationModel!
    
    @IBOutlet var oceanName: UILabel!
    @IBOutlet var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCheckButtonState()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    func fill(with viewModel: OceanStationModel) {
        
        self.viewModel = viewModel
        
        oceanName.text = self.viewModel.stationName
        checkButton.isSelected = self.viewModel.isChecked
    }
    
    private func setCheckButtonState() {
        checkButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
        checkButton.setImage(UIImage(named: "checkbox_selected"), for: .selected)
        
        checkButton.setTitle(nil, for: .normal)
        checkButton.setTitle(nil, for: .highlighted)
        checkButton.setTitle(nil, for: .selected)
        
        checkButton.setAttributedTitle(nil, for: .normal)
        checkButton.setAttributedTitle(nil, for: .highlighted)
        checkButton.setAttributedTitle(nil, for: .selected)
        
        checkButton.titleLabel?.isHidden = true
    }
    
    @IBAction func actionChecked(_ sender: Any) {
        if let button = sender as? UIButton {
            button.isSelected = !button.isSelected
            
            if let handler = delegate {
                handler.onSelectRegion(button.isSelected, model: self.viewModel)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
