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
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    
    @Published private var searchQuery = String()
    @Published private var mode: Mode = .onboarding

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
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
                    self.tableView.reloadData()
                }.store(in: &subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] mode in
            switch (mode) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        if let searchResults = self.searchResults {
            cell.configure(with: searchResults.items[indexPath.row])
        }
        return cell
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
