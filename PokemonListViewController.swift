import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate, PokemonViewControllerDelegate {
    var pokemon: [PokemonListResult] = []
    var searchResults: [PokemonListResult] = []
    var caughtPokemon: [String: Bool] = [:]
    
    @IBOutlet var searchBar: UISearchBar!
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    func updateCaughtStatus(data: [String : Bool]) {
        for (name, caught) in data {
            caughtPokemon.updateValue(caught, forKey: name)
        }
        print(caughtPokemon)
    }
    
    // populate searchResults matching searchText
    func getSearchResult(searchText: String) {
        searchResults = []
        for item in pokemon {
            if item.name.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces)) || searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                searchResults.append(item)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getSearchResult(searchText: searchText)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                // also initialise the search results with empty string
                self.getSearchResult(searchText: "")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
        
        searchBar.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: searchResults[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = searchResults[index].url
            destination.delegate = self
            destination.caught = false
            if let caught = caughtPokemon[searchResults[index].name] {
                destination.caught = caught
            }
        }
    }
}
