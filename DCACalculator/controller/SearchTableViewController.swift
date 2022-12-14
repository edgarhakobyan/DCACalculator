//
//  SearchTableViewController.swift
//  DCACalculator
//
//  Created by Edgar on 30.09.22.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController, UIAnimateble {
    
    private enum Mode {
        case onboarding
        case seach
    }
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter a company name or symbol"
        searchController.searchBar.autocapitalizationType = .allCharacters
        return searchController
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    
    @Published private var searchQuery = String()
    @Published private var mode: Mode = .onboarding

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                self.apiService.fetchSymbolPublisher(keyword: searchQuery).sink { (completion) in
                    self.hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        print("finished")
                    }
                } receiveValue: { results in
                    self.searchResults = results
                    self.tableView.isScrollEnabled = true
                    self.tableView.reloadData()
                }.store(in: &subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .seach:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? SearchTableViewCell {
            if let searchResults = self.searchResults {
                cell.configure(with: searchResults.items[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = searchResults {
            let searchResult = searchResults.items[indexPath.row]
            handleSelection(searchResult: searchResult)
        }
    }
    
    private func handleSelection(searchResult: SearchResult) {
        showLoadingAnimation()
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keyword: searchResult.symbol).sink { [weak self] (completion) in
            self?.hideLoadingAnimation()
            switch completion {
            case .failure(let err):
                print("ERROR \(err)")
            case .finished:
                print("finished")
            }
        } receiveValue: { [weak self] (result) in
            self?.hideLoadingAnimation()
            let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: result)
            self?.performSegue(withIdentifier: "segueToCalculatorView", sender: asset)
            self?.searchController.searchBar.text = nil
        }.store(in: &subscribers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCalculatorView",
           let destinationVC = segue.destination as? CalculatorTableViewController,
           let asset = sender as? Asset {
            destinationVC.asset = asset
        }
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.mode = .seach
    }
}
