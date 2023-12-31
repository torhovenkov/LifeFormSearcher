//
//  SearchTableViewController.swift
//  LifeFormSearcher
//
//  Created by Vladyslav Torhovenkov on 23.06.2023.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchItems: [SearchItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text else { return }
        Task {
            do {
                try await fetchResults(with: query)
                tableView.reloadData()
            } catch {
                let alert = UIAlertController(title: "Ooops", message: "Please, try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            }
        }
    }
    
    func fetchResults(with query: String) async throws {
        self.searchItems = try await SearchModelsController.shared.fetchResults(with: query)
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)

        var configuration = cell.defaultContentConfiguration()
        configuration.text = searchItems[indexPath.row].title
        configuration.secondaryText = searchItems[indexPath.row].commonName
        cell.contentConfiguration = configuration
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

     
    @IBSegueAction func showDetail(_ coder: NSCoder, sender: Any?) -> DetailLifeFormViewController? {
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        let item = searchItems[indexPath.row]
        
        return DetailLifeFormViewController(coder: coder, id: item.id, lifeFormTitle: item.title, lifeFormCommonName: item.commonName)
        
    }
    
 
    

}
