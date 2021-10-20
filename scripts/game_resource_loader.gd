extends Node

var directories = [ # Doing this to make it more future proof
	"res://resources"
]

var loaded_json = {
	"cast": {
	},
	"classes": {
		
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# [TODO] next steps. change how characters and classes are loaded to utilise json.
	# Example using this function.
	# var test1 = character('kris');
	# print(loaded_json.cast, loaded_json.classes)
	pass

func character(name):
	if !loaded_json.cast.has(name):
		var base = {}
		var cast = load_file('cast', name);
		if cast.class:
			base = klass(cast.class).duplicate(true)
		merge_dict(base, cast)
		loaded_json.cast[name] = base
	return loaded_json.cast[name]

func klass(name): # Using klass, as can't use class or get_class
	if !loaded_json.classes.has(name):
		loaded_json.classes[name] = load_file('classes', name)
	return loaded_json.classes[name]
	
func load_file(type, file_name):
	var file = File.new()
	for i in range(directories.size()-1, -1, -1):
		var directory = directories[i]
		var path = str(directories[0], '/', type, '/', file_name, '.json')
		if file.file_exists(path):
			file.open(path, File.READ)
			var content = file.get_as_text()
			file.close()
			# TODO: error checking
			return JSON.parse(content).result
		else:
			print("failed to find ", path)
	return {}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

static func merge_dict(dest, source):
	for key in source:                     # go via all keys in source
		if dest.has(key):                  # we found matching key in dest
			var dest_value = dest[key]     # get value 
			var source_value = source[key] # get value in the source dict           
			if typeof(dest_value) == TYPE_DICTIONARY:       
				if typeof(source_value) == TYPE_DICTIONARY: 
					merge_dict(dest_value, source_value)  
				else:
					dest[key] = source_value # override the dest value
			else:
				dest[key] = source_value     # add to dictionary 
		else:
			dest[key] = source[key]          # just add value to the dest
