//
//  StatisticLayouts\.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 21.04.2023.
//

import Foundation
import UIKit
extension CalendarSectionConfigurator {
  enum SectionLayoutEnum: SectionLayoutProtocol {
    static let key = "modeType"
    case none
    case calendar(CalendarDay?)
    case graphic(CalendarDay?)
   // case month(String?)
    case tvSet
    
    var layoutSection: (_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
      switch self {
      case .calendar: return createUsualCalendarSection
      case .graphic: return createStatisticSection
 //     case .month: return createMonthSection
      case .none: fatalError("set NSCollectionLayoutSection")
      case .tvSet: return createTvSetSection
      }
    }
    var type: String {
      switch self {
      case .calendar: return "calendar"
      case .graphic: return "graphic"
//      case .month: return "month"
      default: return ""
      }
    }
    
    init(type: Int) {
      switch type {
      case 0: self = .calendar(nil)
      case 1: self = .graphic(nil)
//      case 2: self = .month(nil)
      default: self = .none
      }
    }
  }
}

private extension CalendarSectionConfigurator.SectionLayoutEnum {
  
  private func createUsualCalendarSection(_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(1/7))
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let layoutSection = NSCollectionLayoutSection(group: group)
    
    layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 10, bottom: 10, trailing: 10)
    
    layoutSection.decorationItems = [
      //     NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.identifier)
    ]
    
    return layoutSection
  }
  
  private func createStatisticSection(_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let size: CGFloat = 20
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size*2),
                                          heightDimension: .absolute(210))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .absolute(220))
    // item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: size / 2, bottom: 0, trailing: size / 2)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
    
    //    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
    //    let header = NSCollectionLayoutBoundarySupplementaryItem(
    //      layoutSize: headerSize,
    //      elementKind: "header",
    //      alignment: .top
    //    )
    
    //  section.boundarySupplementaryItems = [header]
    
    return section
  }
  
  private func createMonthSection(_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    
    let itemSize = NSCollectionLayoutSize(
      widthDimension: NSCollectionLayoutDimension.fractionalWidth(0.25),
      heightDimension: .absolute(25))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .absolute(20))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    
    return section
  }
  
  private func createTvSetSection(_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(60))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    return section
  }
}
