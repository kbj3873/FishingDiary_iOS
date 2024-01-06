//
//  MainViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/08/31.
//

import UIKit

class MainViewController: UIViewController, StoryboardInstantiable {

    private var viewModel: MainViewModel!
    
    // MARK: life cycle
    static func create(with viewModel: MainViewModel) -> MainViewController {
        let view = MainViewController.instantiateViewController(boardName: .main)
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: action
    
    @IBAction func actionPoint(_ sender: UIButton) {
        viewModel.didSelectPointList()
    }
    
    @IBAction func actionMapTracking(_ sender: UIButton) {
        viewModel.didSelectTrackMapView()
    }
}

