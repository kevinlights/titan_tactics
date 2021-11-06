extends CharacterStats
class_name CharacterStatsJson

var initial_stats: Dictionary;
func _init(name):
	initial_stats = GameResourceLoader.character(name)
	populate_from_inital_stats()

func populate_from_inital_stats():
	if initial_stats.has('base'):
		if initial_stats.base.has('hp'):
			set_hp(initial_stats.base.hp);
		else:
			push_error("Character missing hp")
			
		if initial_stats.base.has('atk'):
			atk = initial_stats.base.atk;
		else:
			push_error("Character missing atk")
			
		if initial_stats.base.has('def'):
			def = initial_stats.base.def;
		else:
			push_error("Character missing def")
			
		if initial_stats.base.has('atk_range'):
			atk_range = initial_stats.base.atk_range;
		else:
			push_error("Character missing atk_range")
			
		if initial_stats.base.has('mov_range'):
			mov_range = initial_stats.base.mov_range;
		else:
			push_error("Character missing mov_range")
			
	if initial_stats.has('level'):
		set_level(initial_stats.level)
		
	if initial_stats.has('name'):
		set_hp(initial_stats.name);
	else:
		push_error("Character missing name")

func level_up():
	push_error("Not implemented yet")
func set_level(lvl):
	push_error("Not implemented yet")

func to_save_data():
	push_error("Not implemented yet")
func from_save_data():
	push_error("Not implemented yet")
