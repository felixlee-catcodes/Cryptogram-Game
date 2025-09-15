extends Node
class_name EncryptionService

@export var quote : String
const alphabet : Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var regEx = RegEx.new()

# This will be where various types of cipher algorithms are written; to be called by PuzzleManager
func _ready():
	regEx.compile("[A-Za-z]")
	caesar_encrypt(quote)
	
func caesar_encrypt(quote) -> String:
	var encrypted_quote : String = ""
	var shift_amt = randi_range(1, alphabet.size() - 1)
	var cipher : Dictionary = {}
	for letter in alphabet:
		var ct = apply_shift(letter, shift_amt)
		cipher[letter] = ct
	Log.prn("cipher dict: ", cipher)

	for char : String in quote:
		var match = regEx.search(char)
		if match:
			char = char.to_upper()
			var crypt_char = cipher[char]
			encrypted_quote += crypt_char
		elif not match: 
			encrypted_quote += char
			
	Log.pr("encrypted quote: ", encrypted_quote)
	return encrypted_quote

func apply_shift(letter, shift) -> String:
	var letter_idx = alphabet.find(letter)
	var shifted_idx : int = letter_idx + shift
	if shifted_idx > alphabet.size() - 1:
		shifted_idx = (letter_idx + shift) - (alphabet.size() - 1) - 1
	var shifted_letter : String = alphabet[shifted_idx]
	return shifted_letter
