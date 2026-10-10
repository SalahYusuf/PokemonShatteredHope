extends RefCounted

const STATS := ["hp", "atk", "def", "spa", "spd", "spe"]
const NATURE_EFFECTS := {"MODEST": {"up": "spa", "down": "atk"}, "ADAMANT": {"up": "atk", "down": "spa"}, "TIMID": {"up": "spe", "down": "atk"}, "JOLLY": {"up": "spe", "down": "spa"}}

var species_id := "GARDEVOIR"
var level := 45
var nature := "MODEST"
var friendship := 180
var ivs := {"hp": 31, "atk": 31, "def": 31, "spa": 31, "spd": 31, "spe": 31}
var evs := {"hp": 0, "atk": 0, "def": 0, "spa": 252, "spd": 4, "spe": 252}
var ev_total_limit := 510
var ev_stat_limit := 252
var bond_points := 0.0
var bond_unlocked := false
var permanent_mega := false
var temporary_mega := false

func set_evs(new_evs: Dictionary) -> bool:
    var total := 0
    for stat in STATS:
        var amount := int(new_evs.get(stat, 0))
        if amount < 0 or amount > ev_stat_limit:
            return false
        total += amount
    if total > ev_total_limit:
        return false
    for stat in STATS:
        evs[stat] = int(new_evs.get(stat, 0))
    return true

func active_form(db: RefCounted) -> String:
    if permanent_mega or temporary_mega:
        var form_id: String = db.get_species(species_id).get("mega_form", "")
        if not form_id.is_empty():
            return form_id
    return species_id

func stats(db: RefCounted) -> Dictionary:
    var base: Dictionary = db.get_species(active_form(db)).get("base_stats", {})
    var result := {}
    for stat in STATS:
        var b := int(base.get(stat, 1))
        var iv := int(ivs.get(stat, 0))
        var ev := int(evs.get(stat, 0))
        var core := int(floor((2 * b + iv + floor(ev / 4.0)) * level / 100.0))
        if stat == "hp":
            result[stat] = core + level + 10
        else:
            var modifier := 1.0
            if NATURE_EFFECTS.has(nature):
                if NATURE_EFFECTS[nature]["up"] == stat:
                    modifier = 1.1
                if NATURE_EFFECTS[nature]["down"] == stat:
                    modifier = 0.9
            result[stat] = int(floor((core + 5) * modifier))
    return result

func gain_bond(action: String) -> float:
    if not bond_unlocked or permanent_mega:
        return 0.0
    var at_max := friendship >= 255
    var reward := 0.0
    match action:
        "wild": reward = 1.0 if at_max else 0.5
        "mega_wild": reward = 2.0 if at_max else 1.0
        "trainer": reward = 2.0 if at_max else 1.0
        "mega_trainer": reward = 6.0 if at_max else 2.0
        "bonding": reward = 5.0
        "faint": reward = -3.0
        _: return 0.0
    var before := bond_points
    bond_points = clampf(bond_points + reward, 0.0, 250.0)
    return bond_points - before

func can_permanent_mega() -> bool:
    return bond_unlocked and bond_points >= 250.0 and not permanent_mega

func evolve_permanently(db: RefCounted) -> bool:
    if not can_permanent_mega() or db.get_species(species_id).get("mega_form", "") == "":
        return false
    permanent_mega = true
    temporary_mega = false
    return true

func to_dict() -> Dictionary:
    return {"species_id": species_id, "level": level, "nature": nature, "friendship": friendship, "ivs": ivs.duplicate(true), "evs": evs.duplicate(true), "ev_total_limit": ev_total_limit, "ev_stat_limit": ev_stat_limit, "bond_points": bond_points, "bond_unlocked": bond_unlocked, "permanent_mega": permanent_mega, "temporary_mega": temporary_mega}

func from_dict(data: Dictionary) -> void:
    species_id = str(data.get("species_id", species_id))
    level = clampi(int(data.get("level", level)), 1, 100)
    nature = str(data.get("nature", nature))
    friendship = clampi(int(data.get("friendship", friendship)), 0, 255)
    ivs = data.get("ivs", ivs).duplicate(true)
    ev_total_limit = maxi(0, int(data.get("ev_total_limit", 510)))
    ev_stat_limit = maxi(0, int(data.get("ev_stat_limit", 252)))
    var loaded_evs: Dictionary = data.get("evs", evs)
    if not set_evs(loaded_evs):
        push_warning("Save had invalid EVs; retaining defaults")
    bond_points = clampf(float(data.get("bond_points", 0.0)), 0.0, 250.0)
    bond_unlocked = bool(data.get("bond_unlocked", false))
    permanent_mega = bool(data.get("permanent_mega", false))
    temporary_mega = false  # Battle-only state must never survive saving
