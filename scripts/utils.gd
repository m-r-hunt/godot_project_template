extends Object

class_name Utils


# "expect_connect" - wrapper around connect that silences warning by asserting success
# abbreviated for shortness on commonly used function
# requires explicitly passing signaller rather than implicitly passing as receiver
# as far as I know this is best solution as we cannot monkey patch Object or write a macro
static func e_connect(signaller, signal_name, object, method):
	assert(signaller.connect(signal_name, object, method) == OK)


# Allow "using" a variable to silence a warning
static func use(_arg):
	pass


static func resource_exists(path):
	var directory = Directory.new()
	return directory.file_exists(path)
