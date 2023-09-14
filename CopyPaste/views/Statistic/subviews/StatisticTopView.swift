//
//  StatisticTopView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 27.06.2023.
//

import UIKit
struct StatisticPickerModel{
  var years: [String] = []
  var months: [(name: String, calendarNumber: Int)] = []
  var selected: (year: Int, month: Int) = (0,0) {
    didSet {
      print(selected)
    }
  }
}
class StatisticTopView: UIView {
  var model: StatisticModel!
  var emit: ((StatisticPickerModel) -> Void)?
  
  private var pendingRequestWorkItem: DispatchWorkItem?
  private lazy var monthPickerView: UIPickerView! = {
    monthPickerView = UIPickerView()
    monthPickerView.subviews.last?.backgroundColor = .clear
    return monthPickerView
  }()
  
  private lazy var nextMonth: CustomButton! = {
    let settings = ControllSettings()
    settings.subviewAngle = 270
    let button = ViewBuilder.init(icon: .icon(name: .arrow, settings: settings)).makeButton()
    button.tag = -1
    return button
  }()
  
  private lazy var previouseMonth: CustomButton! = {
    let settings = ControllSettings()
    settings.subviewAngle = 90
    let button = ViewBuilder.init(icon: .icon(name: .arrow, settings: settings)).makeButton()
    button.tag = 1
    return button
  }()
  
  init(){
    super.init(frame: .zero)
    monthPickerView.delegate = self
    monthPickerView.dataSource = self
    setupViews()
    configureViews()
  }
  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    monthPickerView.selectRow(model.dateModel.selected.month, inComponent: 0, animated: false)
  }

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    setButtonState()
  }
 
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setButtonState() {
//    previouseMonth.controlState = model.selected.month == 0 ? .active : .disabled
//    nextMonth.controlState = model.selected.month == model.months.count - 1 ? .active : .disabled
  }
  
  @objc private func changeMonth(sender: UIButton) {
    let selectedMonth = model.dateModel.selected.month + sender.tag
    let monthes =  model.statisticsMmonths[model.dateModel.selected.year].value
    var selected = model.dateModel!.selected
    if selectedMonth > -1 && selectedMonth < monthes.count {
      selected.month = selectedMonth
    } else if selectedMonth < 0 {
      let yearIndex = model.dateModel.selected.year - 1
      if yearIndex  < 0 { return }
      selected = (yearIndex, model.statisticsMmonths[yearIndex].value.count)
    } else if selectedMonth > monthes.count - 1 {
      let yearIndex = model.dateModel.selected.year + 1
      if yearIndex > model.statisticsMmonths.count - 1 { return }
      selected = (yearIndex, 0)
    }
    model.dateModel!.selected = selected
    monthPickerView.selectRow(selected.month, inComponent: 0, animated: true)
    showNext()
  }
  
  func showNext(){
    pendingRequestWorkItem?.cancel()
    let requestWorkItem = DispatchWorkItem { [weak self] in
       guard let self = self else {return}
       self.emit?(self.model.dateModel!)
    }
    pendingRequestWorkItem = requestWorkItem
    DispatchQueue.global(qos: .background).asyncAfter(
      deadline: .now() + .milliseconds(300),
      execute: requestWorkItem
    )
  }
}

private extension StatisticTopView {
  
  func setupViews(){
    let daysView = makeWeekDays()
    addSubview(daysView)
    addSubview(monthPickerView)
    [previouseMonth, nextMonth].forEach{
      addSubview($0)
    }
    addConstraintsWithFormat("H:|[v0]|", views: daysView)
    addConstraintsWithFormat("H:|[v0(>=130,<=240)]-(>=0)-[v1(40)]-[v2(40)]|", options: [.alignAllCenterY], views: monthPickerView, previouseMonth, nextMonth)
    addConstraintsWithFormat("V:|[v0]-[v1]|", views: monthPickerView, daysView)
    monthPickerView.reloadAllComponents()
  }
  
  func configureViews(){
    
    previouseMonth.addTarget(self, action: #selector(changeMonth), for: .touchDown)
    nextMonth.addTarget(self, action: #selector(changeMonth), for: .touchDown)
  }

  func makeWeekDays() -> UIView {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = .autoupdatingCurrent
    let days = calendar.shortWeekdaySymbols
    let monthView = UIView()
    let str = (0...days.count-1).map{"[v\($0)(==v0)]"}.joined(separator: "-")
    let daysViews = days.map{
      let lbl = UILabel()
      lbl.text = $0
      lbl.textAlignment = .center
      monthView.addSubview(lbl)
      monthView.addConstraintsWithFormat("V:|[v0]|", views: lbl)
      return lbl
    }
    monthView.addConstraintsWithFormat("H:|\(str)|", views: daysViews)
    return monthView
  }

  
}
 extension StatisticTopView: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return model.dateModel.months.count
    } else {
      return model.dateModel.years.count
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return model.dateModel.months[row].name
    } else {
      return model.dateModel.years[row]
    }
  }
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                   inComponent component: Int) {
     model.dateModel.selected.month = row
     showNext()
   }
   
}
