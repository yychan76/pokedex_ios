import UIKit

protocol PokemonViewControllerDelegate: NSObjectProtocol {
    func updateCaughtStatus(data: [String: Bool])
}

class PokemonViewController: UIViewController {
    var image: UIImage!
    var url: String!
    var id: Int!
    var name: String!
    var caught: Bool!
    weak var delegate: PokemonViewControllerDelegate?

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var catchButton: UIButton!

    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    @IBAction func toggleCatch() {
        caught.toggle()
        setButtonText(caught: caught)
        if let delegate = delegate {
            delegate.updateCaughtStatus(data: [name: caught])
        }
    }
    
    func setButtonText(caught: Bool) {
        if caught {
            catchButton.setTitle("Release", for: .normal)
        } else {
            catchButton.setTitle("Catch", for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        descriptionTextView.text = ""

        loadPokemon()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.name = result.name
                    self.id = result.id
                    self.loadDescription(id: self.id)
                    do {
                        let imageData = try Data(contentsOf: URL(string: result.sprites.front_default)!)
                        self.image = UIImage(data: imageData)
                        self.imageView.image = self.image
                    } catch let error {
                        print(error)
                    }
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    self.setButtonText(caught: self.caught)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }

    func loadDescription(id: Int?) {
        guard let id = id else {
            return
        }
        
        let url = "https://pokeapi.co/api/v2/pokemon-species/\(id)/"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PokemonDescriptionResult.self, from: data)
                DispatchQueue.main.async {
                    var descriptions: [String] = []
                    for entry in result.flavor_text_entries {
                        if entry.language.name == "en" {
                            descriptions.append( entry.flavor_text.replacingOccurrences(of: "[\\n\\f]", with: " ", options: [.regularExpression]) + "\n")
                        }
                    }
                    descriptions = Array(NSOrderedSet(array: descriptions)) as! [String]
                    self.descriptionTextView.text = descriptions.joined()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
