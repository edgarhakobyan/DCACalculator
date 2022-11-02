//
//  APIService.swift
//  DCACalculator
//
//  Created by Edgar on 04.10.22.
//

import Foundation
import Combine

struct APIService {
    
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    private let API_KEY = "52U7EJ1MBG14Z21C"
    
    func fetchSymbolPublisher(keyword: String) -> AnyPublisher<SearchResults, Error> {
        var query = ""
        let queryResult = parseQuery(text: keyword)
        switch queryResult {
        case .success(let str):
            query = str
        case .failure(let err):
            return Fail(error: err).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(query)&apikey=\(API_KEY)"
        
        let urlResult = parseUrl(str: urlString)
        switch urlResult {
        case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map( { $0.data } )
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        case .failure(let err):
            return Fail(error: err).eraseToAnyPublisher()
        }
    }
    
    func fetchTimeSeriesMonthlyAdjustedPublisher(keyword: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
        var query = ""
        let queryResult = parseQuery(text: keyword)
        switch queryResult {
        case .success(let str):
            query = str
        case .failure(let err):
            return Fail(error: err).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(query)&apikey=\(API_KEY)"
        
        print(urlString)
        
        let urlResult = parseUrl(str: urlString)
        switch urlResult {
        case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map( { $0.data } )
                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        case .failure(let err):
            return Fail(error: err).eraseToAnyPublisher()
        }
    }
    
    func parseQuery(text: String) -> Result<String, Error> {
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APIServiceError.encoding)
        }
    }
    
    func parseUrl(str: String) -> Result<URL, Error> {
        if let url = URL(string: str) {
            return .success(url)
        } else {
            return .failure(APIServiceError.badRequest)
        }
    }
}
