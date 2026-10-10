extends Control

const Database = preload("res://scripts/pokemon_db.gd")
const Pokemon = preload("res://scripts/pokemon.gd")
const SAVE_PATH := "user://sandbox_save.json"

var db = Database.new()
var mon = Pokemon.new()
var info: RichTextLabel
var log_label: Label

func _ready() -> void:
    if not db.load_species():
        push_error("Unable to start: missing species data")
        return
    _build_ui()
    _refresh("Welcome to the Shattered Hope Core Sandbox!")

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#111827")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.offset_left = 22
    scroll.offset_top = 18
    scroll.offset_right = -22
    scroll.offset_bottom = -18
    add_child(scroll)
    var column := VBoxContainer.new()
    column.custom_minimum_size = Vector2(560, 0)
    column.add_theme_constant_override("separation", 10)
    scroll.add_child(column)
    var heading := Label.new()
    heading.text = "POKÉMON SHATTERED HOPE | CORE SANDBOX v0.1"
    heading.add_theme_font_size_override("font_size", 20)
    column.add_child(heading)
    var hint := Label.new()
    hint.text = "Prototype controls only. Battle rewards are simulated, not verified battle wins."
    column.add_child(hint)
    info = RichTextLabel.new()
    info.bbcode_enabled = true
    info.custom_minimum_size = Vector2(540, 178)
    column.add_child(info)
    _section(column, "Simulation & Evolution")
    _button(column, "Mark simulation WON (unlock Bond)", _unlock_bond)
    _button(column, "Trigger permanent Mega (requires 250 Bond)", _permanent_mega)
    _button(column, "Toggle temporary Mega (test only)", _temporary_mega)
    _section(column, "Bond Actions (manual testing)")
    for action in ["wild", "mega_wild", "trainer", "mega_trainer", "bonding", "faint"]:
        _button(column, "Apply: " + action.replace("_", " "), _apply_action.bind(action))
    _section(column, "Friendship & Persistence")
    _button(column, "Set friendship to 255", _max_friendship)
    _button(column, "Save Pokémon", _save)
    _button(column, "Load Pokémon", _load)
    _button(column, "Reset Pokémon", _reset)
    log_label = Label.new()
    column.add_child(log_label)

func _section(parent: VBoxContainer, title: String) -> void:
    var label := Label.new()
    label.text = title
    label.add_theme_font_size_override("font_size", 16)
    parent.add_child(label)

func _button(parent: VBoxContainer, title: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = title
    button.pressed.connect(callback)
    parent.add_child(button)

func _refresh(message: String) -> void:
    var species: Dictionary = db.get_species(mon.active_form(db))
    var details := "[b]%s[/b] | Level %d | Friendship %d/255\n" % [species.get("name", "Unknown"), mon.level, mon.friendship]
    details += "Bond: %.1f/250 | Unlocked: %s | Permanent Mega: %s\n" % [mon.bond_points, str(mon.bond_unlocked), str(mon.permanent_mega)]
    details += "Temporary Mega: %s | Nature: %s\n" % [str(mon.temporary_mega), mon.nature]
    details += "Stats: %s\n" % str(mon.stats(db))
    details += "EVs: %s" % str(mon.evs)
    info.text = details
    if log_label != null:
        log_label.text = message

func _unlock_bond() -> void:
    mon.bond_unlocked = true
    _refresh("Simulation success recorded: Bond unlocked.")

func _apply_action(action: String) -> void:
    var change := mon.gain_bond(action)
    _refresh("Applied %s: %.1f Bond change." % [action, change])

func _max_friendship() -> void:
    mon.friendship = 255
    _refresh("Friendship set to maximum.")

func _temporary_mega() -> void:
    if mon.permanent_mega:
        _refresh("Already permanently Mega-Evolved.")
        return
    mon.temporary_mega = not mon.temporary_mega
    _refresh("Temporary Mega toggled for stat inspection (not a battle engine).")

func _permanent_mega() -> void:
    if mon.evolve_permanently(db):
        _refresh("PERMANENT MEGA EVOLUTION COMPLETE!")
    else:
        _refresh("Not ready: complete simulation and reach 250 Bond.")

func _save() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        _refresh("Could not save.")
        return
    file.store_string(JSON.stringify(mon.to_dict(), "  "))
    file.close()
    _refresh("Saved to " + SAVE_PATH)

func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        _refresh("No save found yet.")
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if typeof(data) != TYPE_DICTIONARY:
        _refresh("Invalid save data.")
        return
    mon.from_dict(data)
    _refresh("Pokémon loaded. Temporary Mega reverts after loading.")

func _reset() -> void:
    mon = Pokemon.new()
    _refresh("Test Pokémon reset to defaults.")
