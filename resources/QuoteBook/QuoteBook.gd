extends Resource
class_name QuoteBook

const SAVE_PATH : String = "user://save/QuoteBook.tres"

@export var quotes : Array[QuoteEntry] = []
@export var prev_tags : Array[String] = []

func save() -> void:
	Log.pr("save quote")
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("save"):
		dir.make_dir("save")
		
	var err = ResourceSaver.save(self, SAVE_PATH)
	if err != OK:
		push_error("Failed to save stats: %s" % err)
	else:
		Log.pr("QuoteBook saved")


func load_book():
	#Log.pr("Load quote book")
	var loaded = ResourceLoader.load(SAVE_PATH) as QuoteBook
	if loaded:
		#Log.pr("existing book found and loaded")
		return loaded
	else: 
		var new_book = QuoteBook.new()
		new_book.save()
		#Log.pr("no existing book found; new book created")
		return new_book


func add_quote(text: String, author: String, solve_time: String, hints_used: int, tags : Array) -> void:
	Log.pr("quotes size(before): ", quotes.size())
	Log.prn("tags: ", tags)
	var new_entry = QuoteEntry.new()
	Log.prn("new entry: ", new_entry)
	new_entry.author = author
	new_entry.text = text
	new_entry.date_added = "%d-%02d-%02d" % [
		Time.get_datetime_dict_from_system()["year"],
		Time.get_datetime_dict_from_system()["month"], 
		Time.get_datetime_dict_from_system()["day"]
	]
	new_entry.solve_time = solve_time
	new_entry.hints_used = hints_used
	
	if not tags.is_empty():
		new_entry.tags = tags
		for tag in tags:
			if not tag in prev_tags:
				prev_tags.append(tag)
	
	quotes.append(new_entry)
	save()
	Log.pr("quotes size(after): ", quotes.size())


func remove_entry(entry: QuoteEntry):
	quotes.erase(entry)
	save()


func update_tags(entry: QuoteEntry, tags: Array) -> void:
	if quotes.has(entry):
		entry.tags = tags
		save()


func find_by_author(author: String) -> Array[QuoteEntry]:
	return quotes.filter(func(a): a.author == author)
