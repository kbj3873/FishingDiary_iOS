//
//  MainViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit
import Combine

class MainViewController: FDBaseViewController, StoryboardInstantiable {

    private var viewModel: MainViewModel!
    
    var cancelBag = Set<AnyCancellable>()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyOceanView: UIView!
    @IBOutlet var appleMapBtn: UIButton!
    @IBOutlet var kakaoMapBtn: UIButton!
    
    var mapBtns: [UIButton]?
    
    let refreshControl = UIRefreshControl()
    
    // MARK: life cycle
    static func create(with viewModel: MainViewModel) -> MainViewController {
        let view = MainViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initViews()
        self.bind(to: viewModel)
        
        //self.viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.viewDidLoad()
    }

    // MARK: action
    @IBAction func actionOceanSelectedList(_ sender: Any) {
        viewModel.didSelectOceanSelctedView()
    }
    
    @IBAction func actionSelectMap(_ sender: UIButton) {
        guard let btns = mapBtns else { return }
        for btn in btns {
            btn.isSelected = (btn.tag == sender.tag) ? true:false
        }
        
        FDAppManager.shared.setMapTp(sender.tag)
    }
    
    @IBAction func actionOceanInfo(_ sender: UIButton) {
        viewModel.didSelectTemperature()
    }
    
    @IBAction func actionPoint(_ sender: UIButton) {
        viewModel.didSelectPointList()
    }
    
    @IBAction func actionMapTracking(_ sender: UIButton) {
        viewModel.didSelectTrackMapView()
    }
}

extension MainViewController {
    private func initViews() {
        self.usingKeyboard = true
        self.mapBtns = [appleMapBtn, kakaoMapBtn]
        self.initRefresh()
    }
    
    private func bind(to viewModel: MainViewModel) {
        viewModel.items.sink(receiveValue:{ [weak self] stations in
            if stations.oceanStations.count > 1 {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                
                self?.emptyOceanView.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.emptyOceanView.isHidden = false
                self?.tableView.isHidden = true
            }
        }).store(in: &cancelBag)
    }
    
    private func initRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .systemGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        viewModel.fetchRisaList()
    }
}

// MARK: - tableview
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.oceanStations.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TempuratureCell.reuseIdentifier,
                                                       for: indexPath) as? TempuratureCell else {
            assertionFailure("Cannot dequeue reusable cell \(TempuratureCell.self) with reuseIdentifier: \(TempuratureCell.reuseIdentifier)")
            return TempuratureCell()
        }
        
        cell.fill(with: viewModel.items.value.oceanStations[indexPath.row])
        
        return cell
    }
}

