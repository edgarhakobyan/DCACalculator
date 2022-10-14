//
//  APIService.swift
//  DCACalculator
//
//  Created by Edgar on 04.10.22.
//

import Foundation
import Combine

struct APIService {
    private let API_KEY = "52U7EJ1MBG14Z21C"
    
    func fetchSymbolPublisher(keyword: String) -> AnyPublisher<SearchResults, Error> {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keyword)&apikey=\(API_KEY)"
        
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map( { $0.data } )
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
