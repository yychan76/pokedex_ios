import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: PokemonSprites
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct PokemonSprites: Codable {
    let front_default: String
}

struct PokemonDescriptionResult: Codable {
    let flavor_text_entries: [PokemonDescriptionText]
}

struct PokemonDescriptionText: Codable {
    let flavor_text: String
    let language: PokemonDescriptionLanguage
}

struct PokemonDescriptionLanguage: Codable {
    let name: String
}
