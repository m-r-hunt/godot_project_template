extends Reference

class_name StateMachine


var states := {}
var target: Object = null
var current_state: State


class State:
	extends Reference


	var name: String
	var update: String
	var actions := {}
	var trigger := ""


	func _init(_name: String):
		name = _name
		update = _name + "_update"


	func add_action(action: String):
		actions[action] = name + "_" + action


func _init(_target: Object, _states: Array, actions: Dictionary = {}, triggers: Dictionary = {}):
	target = target
	for s in _states:
		states[s] = State.new(s)
	current_state = states[states[0]]

	for a in actions:
		add_action(a, actions[a])

	for s in triggers:
		set_transition_trigger(s, triggers[s])

	if OS.is_debug_build():
		check_state_machine()


func add_action(action: String, in_states: Array = []):
	if len(in_states) > 0:
		for s in in_states:
			states[s].add_action(action)
			assert(target.has_method(states[s].actions[action]))
	else:
		for s in states:
			states[s].add_action(action)
			assert(target.has_method(states[s].actions[action]))


func set_transition_trigger(state: String, function: String):
	assert(target.has_method(function))
	states[state].trigger = function


func check_state_machine():
	for s in states:
		assert(target.has_method(s + "_update"))


func update(delta: float):
	target.call(current_state.update, delta)


func do_action(action: String):
	assert(current_state.actions[action])
	target.call(current_state.actions[action])


func transition(state: String):
	current_state = states[state]
	if current_state.trigger != "":
		target.call(current_state.trigger)
