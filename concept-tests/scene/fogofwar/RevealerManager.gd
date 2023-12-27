extends RefCounted
class_name RevealerManager

static var instance: RevealerManager = null

static func Instance() -> RevealerManager:
	if !instance:
		instance = RevealerManager.new()
	return instance

var _to_reveal: Array[RevealerBehavior] = []

func register_for_reveal(revealer: RevealerBehavior) -> void:
	_to_reveal.push_back(revealer)

func unregister(revealer: RevealerBehavior) -> void:
	_to_reveal.erase(revealer)

func get_revealers() -> Array[RevealerBehavior]:
	return _to_reveal
