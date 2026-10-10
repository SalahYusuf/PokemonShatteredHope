extends RefCounted

const SPECIES_PATH := "res://data/species.json"
var species: Dictionary = {}

func load_species() -> bool:
    if not FileAccess.file_exists(SPECIES_PATH):
        push_error("Species file is missing: " + SPECIES_PATH)
        return false
    var text_data: String = FileAccess.get_file_as_string(SPECIES_PATH)
    var parsed: Variant = JSON.parse_string(text_data)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Invalid species JSON")
        return false
    species = parsed
    return true

func get_species(species_id: String) -> Dictionary:
    return species.get(species_id, {})
