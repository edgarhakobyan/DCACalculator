//
//  DCAService.swift
//  DCACalculator
//
//  Created by Edgar on 04.11.22.
//

import Foundation

struct DCAService {
    func calculate(asset: Asset,
                   initialInvestmentAmount: Double,
                   monthlyDollarCostAmount: Double,
                   initialDateInvestmentIndex: Int) -> DCAResult {
        
        let latestSharePrice = getLatestSharePrice(asset: asset)
        let numberOfShares = getNumberOfShares(asset: asset, initialInvestmentAmount: initialInvestmentAmount, monthlyDollarCostAmount: monthlyDollarCostAmount, initialDateInvestmentIndex: initialDateInvestmentIndex)
        
        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        let investmentAmount = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount, monthlyDollarCostAmount: monthlyDollarCostAmount, initialDateInvestmentIndex: initialDateInvestmentIndex)
        
        let isProfitable = currentValue > investmentAmount
        
        return DCAResult(currentValue: currentValue,
                         investmentAmount: investmentAmount,
                         gain: 0,
                         yield: 0,
                         annualReturn: 0,
                         isProfitable: isProfitable)
    }
    
    private func getInvestmentAmount(initialInvestmentAmount: Double,
                                     monthlyDollarCostAmount: Double,
                                     initialDateInvestmentIndex: Int) -> Double {
        
        let dollarCostAveragingAmount = initialDateInvestmentIndex.doubleValue * monthlyDollarCostAmount
        let totalAmount = initialInvestmentAmount + dollarCostAveragingAmount
        return totalAmount
    }
    
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    private func getLatestSharePrice(asset: Asset) -> Double {
        return asset.timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
    }
    
    private func getNumberOfShares(asset: Asset,
                                   initialInvestmentAmount: Double,
                                   monthlyDollarCostAmount: Double,
                                   initialDateInvestmentIndex: Int) -> Double {
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfos()[initialDateInvestmentIndex].adjustedOpen
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        var totalShares = initialInvestmentShares
        asset.timeSeriesMonthlyAdjusted.getMonthInfos().prefix(initialDateInvestmentIndex).forEach { monthInfo in
            let dcaInvestmentShares = monthlyDollarCostAmount / monthInfo.adjustedOpen
            totalShares += dcaInvestmentShares
        }
        return totalShares
    }
}
