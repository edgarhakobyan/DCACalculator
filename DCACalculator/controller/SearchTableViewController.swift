//
//  SearchTableViewController.swift
//  DCACalculator
//
//  Created by Edgar on 30.09.22.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        return cell
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
