//
//  PointDataListViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/11.
//

import UIKit
import Combine

class PointDataListViewController: UIViewController, StoryboardInstantiable {
    private var viewModel: PointDataListViewModel!
    
    var cancelBag = Set<AnyCancellable>()
    
    @IBOutlet var tableView: UITableView!
    
    static func create(with viewModel: PointDataListViewModel) -> PointDataListViewController {
        let view = PointDataListViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind(with: viewModel)
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
extension PointDataListViewController {
    private func bind(with viewModel: PointDataListViewModel) {
        viewModel.items.sink(receiveValue: { [weak self] pointDataList in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }).store(in: &cancelBag)
    }
}

// MARK: - tableview
extension PointDataListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PointDataCell.reuseIdentifer, for: indexPath) as! PointDataCell
        
        cell.fill(with: viewModel.items.value[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectPoint(at: indexPath.row)
    }
}

// MARK: - Extension UIViewController for show PointDataListViewController
extension UIViewController {
    func showPointDetailListView(path: URL) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PointDataListViewController") as? PointDataListViewController {
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }
}
