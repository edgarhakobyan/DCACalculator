//
//  SearchTableViewCell.swift
//  DCACalculator
//
//  Created by Edgar on 30.09.22.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!

    func configure(with searchResult: SearchResult) {
        self.assetNameLabel.text = searchResult.name
        self.assetSymbolLabel.text = searchResult.symbol
        self.assetTypeLabel.text = "\(searchResult.type) \(searchResult.currency)"
    }
}
