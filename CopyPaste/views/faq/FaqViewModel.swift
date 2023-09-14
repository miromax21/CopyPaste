//
//  ViewModel.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 06.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
import UIKit

class FaqViewModel: BaseViewModel {
  var model =  FaqProjectModel()
  var items: Dynamic<[ExpandableCels<FaqCell.M>]> = Dynamic([])
  func initDatasource() {
    model.load()
    let dataItems = model.data.map {
      return ExpandableCels<FaqCellTypeEnum>(
        isExpanded: false,
        sectionName: $0.title,
        names: $0.items.map{
          let cell: FaqCellTypeEnum!
          if $0.type == "image" {
            let ratio = Double($0.options?[FaqItem.OptionKeys.ratio.rawValue] ?? "1.0")
            cell = FaqCellTypeEnum.image(url: $0.value, ratio: ratio, options: $0.options)
          } else {
            cell = FaqCellTypeEnum.text(text: $0.value)
          }
          return cell
        }
      )
    }
    items.value = dataItems
  }

  func start() -> UIViewController {
    let view = FaqViewController()
    view.viewModel = self
    return view
  }
}
