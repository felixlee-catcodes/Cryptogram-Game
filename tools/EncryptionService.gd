extends Node
class_name EncryptionService

@export var quote : String
const alphabet : Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var regEx = RegEx.new()

# This will be where various types of cipher algorithms are written; to be called by PuzzleManager
func _ready():
	regEx.compile("[A-Za-z]")

#region Basic Caesar Cipher:
func basic_caesar_encrypt(text) -> String:
	var encrypted_quote : String = ""
	var shift_amt = randi_range(1, alphabet.size() - 1)
	var cipher : Dictionary = {}
	for letter in alphabet:
		var ct = apply_shift(letter, shift_amt)
		cipher[letter] = ct

	for _char : String in text:
		var match = regEx.search(_char)
		if match:
			_char = _char.to_upper()
			var crypt_char = cipher[_char]
			encrypted_quote += crypt_char
		elif not match: 
			encrypted_quote += _char

	return encrypted_quote
#endregion
#region Pop Random:
func pop_random_encrypt(_quote) -> Dictionary:
	var encrypted_text : String = ""
	var cipher : Dictionary = {}
	var unique_chars = count_unique(_quote)
	var pool = alphabet.duplicate(true)
	
	# BUILDING THE CIPHER:
	for _char in unique_chars:
		var choice = _char
		while choice == _char:
			choice = pool.pop_at(randi_range(0, pool.size() - 1))
		cipher[_char] = choice

	#ENCRYPTING THE INPUT TEXT:	
	for _char : String in _quote:
		#Log.pr("char? ", _char)
		var match = regEx.search(_char)
		if match:
			#Log.pr("match!")
			_char = _char.to_upper()
			var crypt_char = cipher[_char]
			encrypted_text += crypt_char
		elif not match: 
			encrypted_text += _char
	return {"cipher": cipher, "encrypted_text":encrypted_text, "unique_chars": unique_chars}
#endregion
#region HELPER FUNCTIONS:
func count_unique(text) -> Array:
	var unique_chars : Array = []
	for _char in text:
		var match = regEx.search(_char)
		if match and not _char.to_upper() in unique_chars:
			unique_chars.append(_char.to_upper())
	return unique_chars


func apply_shift(letter, shift) -> String:
	var letter_idx = alphabet.find(letter)
	var shifted_idx : int = letter_idx + shift
	if shifted_idx > alphabet.size() - 1:
		shifted_idx = (letter_idx + shift) - (alphabet.size() - 1) - 1
	var shifted_letter : String = alphabet[shifted_idx]
	return shifted_letter
#endregion
