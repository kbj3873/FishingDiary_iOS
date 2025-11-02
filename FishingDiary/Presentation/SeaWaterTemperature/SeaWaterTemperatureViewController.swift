//
//  SeaWaterTemperatureViewController.swift
//  FishingDiary
//
//  Created by Y0000591 on 2024/03/06.
//

import UIKit
import Combine

class SeaWaterTemperatureViewController: UIViewController, StoryboardInstantiable {

    private var viewModel: SeaWaterTemperatureViewModel!
    
    private var seaWaterTemperatureListInfomation = PassthroughSubject<SeaWaterTemperatureRequestModel, Never>()
    
    var cancelBag = Set<AnyCancellable>()   // > combine
    
    @IBOutlet var seaTextfield: UITextField!
    @IBOutlet var observTextfield: UITextField!
    
    @IBOutlet var surTitleLabel: UILabel!
    @IBOutlet var surTempLabel: UILabel!
    @IBOutlet var midTitleLabel: UILabel!
    @IBOutlet var midTempLabel: UILabel!
    @IBOutlet var botTitleLabel: UILabel!
    @IBOutlet var botTempLabel: UILabel!
    
    @IBOutlet var surScrollView: UIScrollView!
    @IBOutlet var tempSurView: UIView!
    @IBOutlet var midScrollView: UIScrollView!
    @IBOutlet var tempMidView: UIView!
    @IBOutlet var bottomScrollView: UIScrollView!
    @IBOutlet var tempBotView: UIView!
    
    @IBOutlet var surDateLabelStackView: UIStackView!
    @IBOutlet var midDateLabelStackView: UIStackView!
    @IBOutlet var botDateLabelStackView: UIStackView!
    
    var seaPickerView = ToolbarPickerView()
    var observPickerView = ToolbarPickerView()
    
    let seaList = Sea.allCases
    let westList = WestObserv.allCases
    let eastList = EastObserv.allCases
    let southList = SouthObserv.allCases
    
    var selectedSea: Sea = .west {
        didSet(oldVal) {
            seaTextfield.text = self.selectedSea.rawValue
            if self.selectedSea != oldVal {
                observTextfield.text = "선택"
                selectedObserv = WestObserv.none
                observPickerView.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    var selectedObserv: Observ = WestObserv.none {
        didSet(oldVal) {
            if self.selectedObserv.cd != oldVal.cd {
                observTextfield.text = self.selectedObserv.title
            }
        }
    }
    
    // MARK: - Lifecyle
    
    static func create(with viewModel: SeaWaterTemperatureViewModel) -> SeaWaterTemperatureViewController {
        let view = SeaWaterTemperatureViewController.instantiateViewController(boardName: .seaWaterTempurature)
        view.viewModel = viewModel
        
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
        
        
        
        createPickerView(
            pickerView: self.seaPickerView,
            textfield: self.seaTextfield,
            tag: 0
        )
        
        createPickerView(
            pickerView: self.observPickerView,
            textfield: self.observTextfield,
            tag: 1
        )
    }
}

extension SeaWaterTemperatureViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ToolbarPickerViewDelegate {
    private func createPickerView(pickerView: ToolbarPickerView, textfield: UITextField, tag: Int) {
        pickerView.tag = tag
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.toolbarDelegate = self
        textfield.inputView = pickerView
        textfield.inputAccessoryView = pickerView.toolbar
    }
    
    func didTapDone(pickerView: ToolbarPickerView) {
        self.view.endEditing(true)
        
        if pickerView.tag == 1 {
            self.clearViews()
            if selectedSea.id.count > 0 && selectedObserv.cd.count > 0 {
                self.loadSeaWaterTemperatureList(gruNam: selectedSea.id, staCde: selectedObserv.cd)
                //viewModel.fetTempuratureData(gruNam: selectedSea.id, staCde: selectedObserv.cd)
            }
        }
    }
    
    func didTapCancel(pickerView: ToolbarPickerView) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == seaPickerView {
            return seaList.count
        } 
        
        else { ///pickerView == observPickerView
            switch selectedSea {
            case .none:
                return 0
            case .west:
                return westList.count
            case .east:
                return eastList.count
            case .south:
                return southList.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == seaPickerView {
            return seaList[row].rawValue
        }
        
        else { ///pickerView == observPickerView
            switch selectedSea {
            case .none:
                return westList[0].rawValue
            case .west:
                return westList[row].rawValue
            case .east:
                return eastList[row].rawValue
            case .south:
                return southList[row].rawValue
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == seaPickerView {
            selectedSea = seaList[row]
        }
        
        else { ///pickerView == observPickerView
            switch selectedSea {
            case .none:
                selectedObserv = westList[0]
            case .west:
                selectedObserv = westList[row]
            case .east:
                selectedObserv = eastList[row]
            case .south:
                selectedObserv = southList[row]
            }
        }
    }
}

extension SeaWaterTemperatureViewController {
    private func bind(to viewModel: SeaWaterTemperatureViewModel) {
        
        viewModel.tempItems.sink(receiveValue:{ [weak self] tempList in
            guard let self = self else { return }
            
            self.setTitleLabels(
                label: self.surTitleLabel,
                title: "표층수온",
                depList: tempList.map { $0.surDep }
            )
            self.setTitleLabels(
                label: self.midTitleLabel,
                title: "중층수온",
                depList: tempList.map { $0.midDep }
            )
            self.setTitleLabels(
                label: self.botTitleLabel,
                title: "저층수온",
                depList: tempList.map { $0.botDep }
            )
            
            self.setCurrentTempLabels(
                label: surTempLabel,
                tempList: tempList.map { $0.surTemp }
            )
            self.setCurrentTempLabels(
                label: midTempLabel,
                tempList: tempList.map { $0.midTemp }
            )
            self.setCurrentTempLabels(
                label: botTempLabel,
                tempList: tempList.map { $0.botTemp }
            )
            
            self.setDateLabels(
                dateList: tempList.map { String($0.dateTime) }, 
                stackView: self.surDateLabelStackView
            )
            self.setDateLabels(
                dateList: tempList.map { String($0.dateTime) },
                stackView: self.midDateLabelStackView
            )
            self.setDateLabels(
                dateList: tempList.map { String($0.dateTime) },
                stackView: self.botDateLabelStackView
            )
            
            self.setGraphBackground(
                temps: tempList.map { $0.surTemp },
                graphV: self.tempSurView
            )
            self.setGraphBackground(
                temps: tempList.map { $0.midTemp },
                graphV: self.tempMidView
            )
            self.setGraphBackground(
                temps: tempList.map { $0.botTemp }, 
                graphV: self.tempBotView
            )
            
            self.tempSurView.addSubview(
                ZeddLineGraph(frame:    tempSurView.bounds,
                              values:   tempList.map { $0.surTemp },
                              color:    UIColor.blue)
            )
            self.tempMidView.addSubview(
                ZeddLineGraph(frame:    tempMidView.bounds,
                              values:   tempList.map { $0.midTemp },
                              color:    UIColor.green)
            )
            self.tempBotView.addSubview(
                ZeddLineGraph(frame:    tempBotView.bounds,
                              values:   tempList.map { $0.botTemp },
                              color:    UIColor.purple)
            )
        }).store(in: &cancelBag)
         
    }
    
    private func loadSeaWaterTemperatureList(gruNam: String, staCde: String) {
        viewModel.fetchTempuratureData(gruNam: gruNam, staCde: staCde)
    }
}

extension SeaWaterTemperatureViewController {
    private func setTitleLabels(label: UILabel, title: String, depList: [Float]) {
        var dep: Float = -1
        for m in depList {
            if m > 0 {
                dep = m
                break
            }
        }
        
        label.text = dep < 0 ? title : String(format: "\(title) (수심 %.1fm)", dep)
    }
    
    private func setCurrentTempLabels(label: UILabel, tempList: [CGFloat]) {
        let list = tempList.filter { $0 > 0 }  // > -99 더미 온도 데이터 제외
        if let tempurature = list.last {
            label.text = String(format: "수온 %.1f", tempurature)
        } else {
            label.text = ""
        }
        label.sizeToFit()
    }
    
    // > 202404090000 -> 자정시간 날짜 월/일 변환하기 ex)4/9
    private func setDateLabels(dateList: [String], stackView: UIStackView) {
        let dayTimes = dateList.filter { $0.hasSuffix("0000") } // > 자정시간
        var labelTextList = [String]()
        
        for day in dayTimes {
            let month = Int(day.subStrings(from: 4, to: 5))!
            let day = Int(day.subStrings(from: 6, to: 7))!
            labelTextList.append(String(format: "%d/%d", month, day))
        }
        
        for text in labelTextList {
            let label = UILabel()
            label.text = text
            label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14.0)
            label.widthAnchor.constraint(equalToConstant: stackView.frame.width / CGFloat(labelTextList.count)).isActive = true
            stackView.addArrangedSubview(label)
        }
    }
    
    private func setGraphBackground(temps: [CGFloat], graphV: UIView) {
        let tempList = temps.filter { $0 > 0 }  // > -99 더미 온도 데이터 제외
        if tempList.count == 0 { return }
        
        let width = graphV.bounds.width
        let height = graphV.bounds.height
        
        let min = Int(tempList.min()!) - 1
        let max = Int(tempList.max()!) + 1
        let linesCnt = max - min + 1
        let weight = height / CGFloat(linesCnt - 1)      // > 그래프 가중치
        
        for i in 0..<linesCnt {
            let lineV = UIView(frame: CGRect(x: 0.0, y: (CGFloat(i) * weight), width: width - 8.0, height: 0.5))
            lineV.backgroundColor = UIColor.lightGray
            let label = UILabel(frame: CGRect(x: -12.0, y: (CGFloat(i) * weight) - 6, width: 12, height: 10))
            label.text = String(format: "%d", max - i)
            label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 10.0)
            graphV.addSubview(lineV)
            graphV.addSubview(label)
        }
    }
    
    private func clearViews() {
        self.surDateLabelStackView.subviews.forEach { $0.removeFromSuperview() }
        self.midDateLabelStackView.subviews.forEach { $0.removeFromSuperview() }
        self.botDateLabelStackView.subviews.forEach { $0.removeFromSuperview() }
        
        self.tempSurView.subviews.forEach { $0.removeFromSuperview() }
        self.tempMidView.subviews.forEach { $0.removeFromSuperview() }
        self.tempBotView.subviews.forEach { $0.removeFromSuperview() }
    }
}


class ZeddLineGraph: UIView {
    var values: [CGFloat] = []
    var color: UIColor?
    
    init(frame: CGRect, values: [CGFloat], color: UIColor) {
        super.init(frame: frame)
        self.values = values
        self.color = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let tempList = values.filter { $0 > 0 }  // > -99 더미 온도 데이터 제외
        if tempList.count == 0 {
            self.addEmptyView(parentView: self)
            return
        }
        
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        let min = Int(tempList.min()!) - 1
        let max = Int(tempList.max()!) + 1
        let linesCnt = max - min + 1
        
        let graphWeight: CGFloat = self.bounds.height / CGFloat(linesCnt-1) // > 단위 온도 1도의 실제 그래프 높이 값
        
        let xOffset: CGFloat = self.frame.width / CGFloat(values.count)
        
        var currentX: CGFloat = 0
        
        path.move(to: CGPoint(x: currentX, y: (self.frame.height - ((self.values[0] - CGFloat(min)) * graphWeight))))
        
        var validPoint = false
        for i in 0..<values.count {
            currentX += xOffset
            
            let value = self.values[i]
            if value >= 0 {
                let newPosition: CGPoint = CGPoint(x: currentX,
                                                   y: (self.frame.height - ((value - CGFloat(min)) * graphWeight)))
                if !validPoint {
                    path.move(to: newPosition)
                } else {
                    path.addLine(to: newPosition)
                }
                validPoint = true
            }
            
            else if value == -90 { // > 중간에 시간 누락된 데이터
                if validPoint {
                    //print("\(path.cgPath.currentPoint.y)")
                    let newPosition: CGPoint = CGPoint(x: currentX,
                                                       y: path.cgPath.currentPoint.y)
                    path.addLine(to: newPosition)
                }
                //validPoint = true
            }
            
            else {                  // > 오늘 날짜 더미 데이터
                validPoint = false
            }
        }
        
        layer.fillColor = nil
        layer.strokeColor = color!.cgColor
        layer.lineWidth = 2.5
        layer.path = path.cgPath
        self.layer.addSublayer(layer)
        
        self.addMaxTempuratureLabel(temp: tempList.max()!, parentView: self)
        self.addMinTempuratureLabel(temp: tempList.min()!, parentView: self)
    }
    
    private func addMaxTempuratureLabel(temp: CGFloat, parentView: UIView) {
        let label = UILabel(frame: CGRectZero)
        label.text = String(format: "주간최고: %.1f", temp)
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12.0)
        label.sizeToFit()
        parentView.addSubview(label)
        label.center = CGPoint(
            x: parentView.bounds.width - (label.bounds.width / 2),
            y: 2.0 + (label.bounds.height / 2)
        )
    }
    
    private func addMinTempuratureLabel(temp: CGFloat, parentView: UIView) {
        let label = UILabel(frame: CGRectZero)
        label.text = String(format: "주간최저: %.1f", temp)
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12.0)
        label.sizeToFit()
        parentView.addSubview(label)
        label.center = CGPoint(
            x: parentView.bounds.width - (label.bounds.width / 2),
            y: parentView.bounds.height - (label.bounds.height / 2) - 2.0
        )
    }
    
    
    private func addEmptyView(parentView: UIView) {
        let label = UILabel(frame: CGRectZero)
        label.text = "수온정보가 없습니다."
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 10.0)
        label.sizeToFit()
        self.addSubview(label)
        label.center = CGPoint(x: parentView.bounds.width / 2, y: parentView.bounds.height / 2)
    }
}
