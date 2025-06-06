//
//  OceanSelectViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/28/25.
//

import UIKit
import Combine

class OceanSelectViewController: FDBaseViewController, StoryboardInstantiable, OceanSelectCellDelegate {
    
    private var viewModel: OceanSelectViewModel!
    
    var cancelBag = Set<AnyCancellable>()
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: life cycle
    static func create(with viewModel: OceanSelectViewModel) -> OceanSelectViewController {
        let view = OceanSelectViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind(to: viewModel)
        
        self.viewModel.viewDidLoad()
    }
    
    private func bind(to viewModel: OceanSelectViewModel) {
        viewModel.items.sink(receiveValue:{ [weak self] stations in
            self?.tableView.reloadData()
        }).store(in: &cancelBag)
    }
}

// MARK: - tableview
extension OceanSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OceanSelectCell.reuseIdentifier,
                                                       for: indexPath) as? OceanSelectCell else {
            assertionFailure("Cannot dequeue reusable cell \(OceanSelectCell.self) with reuseIdentifier: \(OceanSelectCell.reuseIdentifier)")
            return OceanSelectCell()
        }
        
        cell.delegate = self
        cell.fill(with: viewModel.items.value[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = viewModel.items.value[indexPath.row]
        viewModel.saveCheckList(!cellData.isChecked, model: cellData)
    }
    
    // cell delegate
    func onSelectRegion(_ selected: Bool, model: OceanStationModel) {
        viewModel.saveCheckList(selected, model: model)
    }
}
