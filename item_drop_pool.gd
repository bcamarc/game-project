extends RefCounted
class_name ItemDropPool

const MONSTER_DROP_CHANCE := 0.1

static func monster_items() -> Array:
	return [
		{"name": "Rusty Dagger", "icon": preload("res://RPG Icons/Icon1.png"), "type": "weapon", "damage": 4},
		{"name": "Iron Sabre", "icon": preload("res://RPG Icons/Icon2.png"), "type": "weapon", "damage": 6},
		{"name": "Blue Steel Blade", "icon": preload("res://RPG Icons/Icon3.png"), "type": "weapon", "damage": 8},
		{"name": "Silver Knife", "icon": preload("res://RPG Icons/Icon4.png"), "type": "weapon", "damage": 7},
		{"name": "Golden Cutlass", "icon": preload("res://RPG Icons/Icon5.png"), "type": "weapon", "damage": 10},
		{"name": "Curved Sword", "icon": preload("res://RPG Icons/Icon6.png"), "type": "weapon", "damage": 11},
		{"name": "Bronze Wand", "icon": preload("res://RPG Icons/Icon7.png"), "type": "weapon", "damage": 5, "magic": 5},
		{"name": "Heavy Short Sword", "icon": preload("res://RPG Icons/Icon8.png"), "type": "weapon", "damage": 12},
		{"name": "Crystal Blade", "icon": preload("res://RPG Icons/Icon9.png"), "type": "weapon", "damage": 13, "magic": 3},
		{"name": "Throwing Spear", "icon": preload("res://RPG Icons/Icon10.png"), "type": "weapon", "damage": 9},
		{"name": "Blue Warhammer", "icon": preload("res://RPG Icons/Icon21.png"), "type": "weapon", "damage": 12},
		{"name": "Spiked Mace", "icon": preload("res://RPG Icons/Icon22.png"), "type": "weapon", "damage": 14},
		{"name": "Iron Hammer", "icon": preload("res://RPG Icons/Icon23.png"), "type": "weapon", "damage": 11},
		{"name": "Chain Flail", "icon": preload("res://RPG Icons/Icon24.png"), "type": "weapon", "damage": 15},
		{"name": "Stone Club", "icon": preload("res://RPG Icons/Icon25.png"), "type": "weapon", "damage": 8},
		{"name": "Round Mace", "icon": preload("res://RPG Icons/Icon26.png"), "type": "weapon", "damage": 10},
		{"name": "Battle Mallet", "icon": preload("res://RPG Icons/Icon27.png"), "type": "weapon", "damage": 13},
		{"name": "Crystal Hammer", "icon": preload("res://RPG Icons/Icon28.png"), "type": "weapon", "damage": 16, "magic": 3},
		{"name": "Steel Maul", "icon": preload("res://RPG Icons/Icon29.png"), "type": "weapon", "damage": 15},
		{"name": "Golden Scepter", "icon": preload("res://RPG Icons/Icon30.png"), "type": "weapon", "damage": 9, "magic": 8},
		{"name": "Twin Axe", "icon": preload("res://RPG Icons/Icon43.png"), "type": "weapon", "damage": 12},
		{"name": "Hooked Axe", "icon": preload("res://RPG Icons/Icon44.png"), "type": "weapon", "damage": 11},
		{"name": "Hatchet", "icon": preload("res://RPG Icons/Icon45.png"), "type": "weapon", "damage": 9},
		{"name": "Crescent Axe", "icon": preload("res://RPG Icons/Icon46.png"), "type": "weapon", "damage": 14},
		{"name": "Runed Axe", "icon": preload("res://RPG Icons/Icon47.png"), "type": "weapon", "damage": 15, "magic": 2},
		{"name": "Double Axe", "icon": preload("res://RPG Icons/Icon48.png"), "type": "weapon", "damage": 16},
		{"name": "Gem Axe", "icon": preload("res://RPG Icons/Icon49.png"), "type": "weapon", "damage": 17, "magic": 4},
		{"name": "Golden Axe", "icon": preload("res://RPG Icons/Icon50.png"), "type": "weapon", "damage": 18},
		{"name": "Sickle", "icon": preload("res://RPG Icons/Icon51.png"), "type": "weapon", "damage": 10},
		{"name": "Moon Axe", "icon": preload("res://RPG Icons/Icon52.png"), "type": "weapon", "damage": 15, "magic": 3},
		{"name": "Iron Spear", "icon": preload("res://RPG Icons/Icon58.png"), "type": "weapon", "damage": 10},
		{"name": "Pick Spear", "icon": preload("res://RPG Icons/Icon59.png"), "type": "weapon", "damage": 12},
		{"name": "Long Spear", "icon": preload("res://RPG Icons/Icon60.png"), "type": "weapon", "damage": 11},
		{"name": "Hook Spear", "icon": preload("res://RPG Icons/Icon61.png"), "type": "weapon", "damage": 13},
		{"name": "Blue Lance", "icon": preload("res://RPG Icons/Icon62.png"), "type": "weapon", "damage": 14},
		{"name": "Trident", "icon": preload("res://RPG Icons/Icon63.png"), "type": "weapon", "damage": 15},
		{"name": "Dark Trident", "icon": preload("res://RPG Icons/Icon64.png"), "type": "weapon", "damage": 16},
		{"name": "Bronze Halberd", "icon": preload("res://RPG Icons/Icon65.png"), "type": "weapon", "damage": 13},
		{"name": "Golden Lance", "icon": preload("res://RPG Icons/Icon66.png"), "type": "weapon", "damage": 17},
		{"name": "Branch Spear", "icon": preload("res://RPG Icons/Icon67.png"), "type": "weapon", "damage": 12},
		{"name": "Short Bow", "icon": preload("res://RPG Icons/Icon101.png"), "type": "weapon", "damage": 7},
		{"name": "Hunter Bow", "icon": preload("res://RPG Icons/Icon102.png"), "type": "weapon", "damage": 8},
		{"name": "Vine Bow", "icon": preload("res://RPG Icons/Icon103.png"), "type": "weapon", "damage": 9, "speed": 2},
		{"name": "Simple Bow", "icon": preload("res://RPG Icons/Icon104.png"), "type": "weapon", "damage": 7},
		{"name": "Recurve Bow", "icon": preload("res://RPG Icons/Icon105.png"), "type": "weapon", "damage": 10},
		{"name": "Wooden Bow", "icon": preload("res://RPG Icons/Icon106.png"), "type": "weapon", "damage": 8},
		{"name": "Gold-Tipped Bow", "icon": preload("res://RPG Icons/Icon107.png"), "type": "weapon", "damage": 11},
		{"name": "Black Bow", "icon": preload("res://RPG Icons/Icon108.png"), "type": "weapon", "damage": 12},
		{"name": "Forest Bow", "icon": preload("res://RPG Icons/Icon109.png"), "type": "weapon", "damage": 11, "speed": 3},
		{"name": "Blue Bow", "icon": preload("res://RPG Icons/Icon110.png"), "type": "weapon", "damage": 12, "magic": 2},
		{"name": "Round Wood Shield", "icon": preload("res://RPG Icons/Icon141.png"), "type": "chestplate", "defense": 3},
		{"name": "Iron Round Shield", "icon": preload("res://RPG Icons/Icon142.png"), "type": "chestplate", "defense": 5},
		{"name": "Buckler", "icon": preload("res://RPG Icons/Icon143.png"), "type": "chestplate", "defense": 4},
		{"name": "Tower Shield", "icon": preload("res://RPG Icons/Icon144.png"), "type": "chestplate", "defense": 7},
		{"name": "Knight Shield", "icon": preload("res://RPG Icons/Icon145.png"), "type": "chestplate", "defense": 8},
		{"name": "Bronze Shield", "icon": preload("res://RPG Icons/Icon146.png"), "type": "chestplate", "defense": 6},
		{"name": "Cross Shield", "icon": preload("res://RPG Icons/Icon147.png"), "type": "chestplate", "defense": 7},
		{"name": "Skull Shield", "icon": preload("res://RPG Icons/Icon148.png"), "type": "chestplate", "defense": 9},
		{"name": "Green Shield", "icon": preload("res://RPG Icons/Icon149.png"), "type": "chestplate", "defense": 5},
		{"name": "Tear Shield", "icon": preload("res://RPG Icons/Icon150.png"), "type": "chestplate", "defense": 6},
		{"name": "Red Hood", "icon": preload("res://RPG Icons/Icon161.png"), "type": "helmet", "defense": 2},
		{"name": "Leather Cap", "icon": preload("res://RPG Icons/Icon162.png"), "type": "helmet", "defense": 3},
		{"name": "Brown Helmet", "icon": preload("res://RPG Icons/Icon163.png"), "type": "helmet", "defense": 4},
		{"name": "Horned Cap", "icon": preload("res://RPG Icons/Icon164.png"), "type": "helmet", "defense": 4},
		{"name": "Leather Helm", "icon": preload("res://RPG Icons/Icon165.png"), "type": "helmet", "defense": 5},
		{"name": "Viking Helm", "icon": preload("res://RPG Icons/Icon166.png"), "type": "helmet", "defense": 6},
		{"name": "Red Feather Helm", "icon": preload("res://RPG Icons/Icon167.png"), "type": "helmet", "defense": 5},
		{"name": "Iron Helm", "icon": preload("res://RPG Icons/Icon168.png"), "type": "helmet", "defense": 7},
		{"name": "Green Helm", "icon": preload("res://RPG Icons/Icon169.png"), "type": "helmet", "defense": 6, "magic": 2},
		{"name": "Steel Helm", "icon": preload("res://RPG Icons/Icon170.png"), "type": "helmet", "defense": 8},
		{"name": "Red Tunic", "icon": preload("res://RPG Icons/Icon181.png"), "type": "chestplate", "defense": 3},
		{"name": "Leather Armor", "icon": preload("res://RPG Icons/Icon182.png"), "type": "chestplate", "defense": 4},
		{"name": "Padded Armor", "icon": preload("res://RPG Icons/Icon183.png"), "type": "chestplate", "defense": 5},
		{"name": "Bronze Armor", "icon": preload("res://RPG Icons/Icon184.png"), "type": "chestplate", "defense": 6},
		{"name": "Strapped Armor", "icon": preload("res://RPG Icons/Icon185.png"), "type": "chestplate", "defense": 7},
		{"name": "Studded Armor", "icon": preload("res://RPG Icons/Icon186.png"), "type": "chestplate", "defense": 8},
		{"name": "Dragon Armor", "icon": preload("res://RPG Icons/Icon187.png"), "type": "chestplate", "defense": 10},
		{"name": "Iron Armor", "icon": preload("res://RPG Icons/Icon188.png"), "type": "chestplate", "defense": 9},
		{"name": "Green Plate", "icon": preload("res://RPG Icons/Icon189.png"), "type": "chestplate", "defense": 8, "magic": 2},
		{"name": "Steel Plate", "icon": preload("res://RPG Icons/Icon190.png"), "type": "chestplate", "defense": 11},
		{"name": "Red Boots", "icon": preload("res://RPG Icons/Icon221.png"), "type": "boots", "speed": 4},
		{"name": "Cloth Sandals", "icon": preload("res://RPG Icons/Icon222.png"), "type": "boots", "speed": 3},
		{"name": "Leather Boots", "icon": preload("res://RPG Icons/Icon223.png"), "type": "boots", "speed": 5},
		{"name": "Brown Boots", "icon": preload("res://RPG Icons/Icon224.png"), "type": "boots", "speed": 6},
		{"name": "Padded Boots", "icon": preload("res://RPG Icons/Icon225.png"), "type": "boots", "speed": 7},
		{"name": "Strapped Boots", "icon": preload("res://RPG Icons/Icon226.png"), "type": "boots", "speed": 8},
		{"name": "Tall Boots", "icon": preload("res://RPG Icons/Icon227.png"), "type": "boots", "speed": 9},
		{"name": "Laced Boots", "icon": preload("res://RPG Icons/Icon228.png"), "type": "boots", "speed": 10},
		{"name": "Gold Boots", "icon": preload("res://RPG Icons/Icon229.png"), "type": "boots", "speed": 12},
		{"name": "Iron Boots", "icon": preload("res://RPG Icons/Icon230.png"), "type": "boots", "speed": 6, "defense": 4}
	]

static func roll_monster_item(drop_chance := MONSTER_DROP_CHANCE) -> Dictionary:
	if randf() > drop_chance:
		return {}

	return weighted_random_item(monster_items())

static func weighted_random_item(items: Array) -> Dictionary:
	if items.is_empty():
		return {}

	var total_weight := 0.0
	for item in items:
		total_weight += _drop_weight(item)

	var roll := randf() * total_weight
	for item in items:
		roll -= _drop_weight(item)
		if roll <= 0.0:
			return item

	return items.back()

static func _drop_weight(item: Dictionary) -> float:
	var power := 0
	power += int(item.get("damage", 0))
	power += int(item.get("defense", 0))
	power += int(item.get("speed", 0))
	power += int(item.get("magic", 0)) * 2

	var weight = maxf(1.0, 30.0 - float(power))
	var item_name := str(item.get("name", "")).to_lower()
	if item_name.contains("gold") or item_name.contains("crystal") or item_name.contains("dragon") or item_name.contains("dark"):
		weight *= 0.35

	return weight
