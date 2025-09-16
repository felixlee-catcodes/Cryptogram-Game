extends HTTPRequest

var URL : String = "https://zenquotes.io/api/quotes"
const CACHE_PATH : String = "user://quote_cache.json"
const MIN_CACHE_SIZE : int = 7

var cached_quotes : Array = []

func _ready():
	self.use_threads = true
	self.request(URL)

#region Cache Handling
func _load_cache() -> void:
	pass


func _save_cache() -> void:
	pass
#endregion

#region Quote retrieval
func get_random_quote() -> Dictionary:
	pass

func mark_quote_solved(quote: Dictionary):
	pass
#endregion

#region Fetch from API
func fetch_and_add_quotes() -> void:
	pass
#endregion
#func _on_request_completed(result, response_code, headers, body: PackedByteArray):
	#Log.pr(response_code, " --> response code")
	#if response_code == 200:
		#Log.pr("successful response")
		#var data = body.get_string_from_utf8()
		#Log.prn("result body: ", data)
	#else:
		#Log.pr(response_code, " --> response code")
		#Log.pr("request error")
