# Pokémon Shattered Hope — Core Sandbox v0.1

A minimal **Godot 4.x / GDScript** prototype for testing Pokémon instance data, stat calculations, EV limits, friendship, and the draft Bond Resonance mechanic.

## Windows quick start
1. Download the **Godot 4 standard Windows editor** from https://godotengine.org/download/windows/ (no .NET edition required).
2. Extract this project ZIP into a folder, e.g. `C:\PokemonDev\ShatteredHope_Core_v0_1`.
3. Open Godot → **Import** → choose `project.godot` in that folder.
4. Open the project, press **F6** while `scenes/main.tscn` is open, or **F5** to run the whole project.
5. Click **Mark simulation WON**, then test bonding actions. Use **Set friendship to 255** to test the bonus rates.
6. Reach 250 points → **Trigger permanent Mega**, then save and load.

## Implemented
- Species database in `data/species.json`: Ralts, Gardevoir, Mega Gardevoir.
- Individual Pokémon with level, nature, IVs, EVs, friendship, temporary/permanent form flags.
- Gen III+ style stat calculations for non-Shedinja Pokémon and four example natures. More natures and mechanics follow later.
- EV validation (normal 510 total and 252 per-stat); custom per-instance caps can be configured for special Pokémon such as the lore's Mewtwo.
- Separate post-simulation Bond Resonance (0–250): wild +0.5/+1, Mega wild +1/+2, trainer +1/+2, Mega trainer +2/+6 (normal/max friendship); bonding +5; fainting −3.
- Permanent Mega Gardevoir switching base stats; temporary Mega inspection toggle; JSON save/load (`user://sandbox_save.json`).

## NOT implemented yet
**No real battle engine**, no Mega Stones, no bracelet checks, no stone-consuming instability, no actual simulation boss, no animations, no overworld. Buttons simulate events in order to test the progression rules. `bond_unlocked` is manually enabled by the simulation-success button.

## Important design notes
- The currently drafted **machine trial unlocks Bond**; max friendship is **not** required to enter the machine. Max friendship only improves some rewards.
- Actions are **mutually exclusive**, e.g. a Mega trainer win gives the Mega trainer reward only, not both trainer rewards.
- Individual test Pokémon can be expanded later without rewriting the database format.
- Species and character names are fan-project placeholders; avoid redistributing copyrighted assets without permission.

## Next steps
1. Confirm project launches and save/reload works.
2. Add Pokémon party model and move database.
3. Add turn-based battle engine.
4. Replace manual buttons with battle event callbacks.
5. Implement actual simulation-machine encounter and temporary/permanent Mega conditions.

## Source references
Godot documentation: https://docs.godotengine.org/en/stable/
