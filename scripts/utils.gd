# Define the function that generates a random string
static func generate_random_string(length : int, char_set = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):
	# Initialize an empty string to store the random characters
	var random_string = ""
	# Generate random characters and add them to the string
	for i in range(length):
		# Generate a random index between 0 and the length of the character set
		var index = int(randf_range(0, char_set.length()))
		# Convert the character at the random index to a string and add it to the random string
		random_string += char_set[index]
	# Return the generated random string
	return random_string

static func generate_random_player_name():
	var prefix = generate_random_string(5, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	var suffix = generate_random_string(3, "0123456789")
	return prefix + "_" + suffix

static func generate_random_player_color():
	var r = randf_range(0.4, 1.0)
	var g = randf_range(0.4, 1.0)
	var b = randf_range(0.4, 1.0)
	return Color(r, g, b)
