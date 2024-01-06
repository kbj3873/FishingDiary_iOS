//
//  PointDateListViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/11.
//

import UIKit
import Combine

class PointDateListViewController: UIViewController, StoryboardInstantiable {
    
    private var viewModel: PointDateListViewModel!
    
    var cancelBag = Set<AnyCancellable>()   // > combine
    
    @IBOutlet var tableView: UITableView!
    
    static func create(with viewModel: PointDateListViewModel) -> PointDateListViewController {
        let view = PointDateListViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - private function
extension PointDateListViewController {
    private func bind(to viewModel: PointDateListViewModel) {
        viewModel.items.sink(receiveValue: { [weak self] dateList in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }).store(in: &cancelBag)
    }
}

// MARK: - tableview
extension PointDateListViewController: UITableViewDelegate, UITableViewDataSource {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PointDateCell.reuseIdentifier,
                                                       for: indexPath) as? PointDateCell else {
            assertionFailure("Cannot dequeue reusable cell \(PointDateCell.self) with reuseIdentifier: \(PointDateCell.reuseIdentifier)")
            return PointDateCell()
        }
        
        cell.fill(with: viewModel.items.value[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}

// MARK: - Extension UIViewController for show TrackMapViewController
/*
extension UIViewController {
    func showPointListView() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PointDateListViewController") as? PointDateListViewController {
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
}
*/
