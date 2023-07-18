extends Control

signal origin_changed

var _traits: Dictionary = {}
var _homelands: Array = []
var _backgrounds: Array = []
var _trades: Array = []
var _locations: Array = []

func _ready():
	_on_age_value_changed(%Age.value)

func set_age_limits(min_age: int, max_age: int):
	%Age.min_value = min_age
	%Age.max_value = max_age

func set_trait_options(traits: Array):
	_homelands.clear()
	_backgrounds.clear()
	_trades.clear()
	_locations.clear()
	%Homeland.clear()
	%Background.clear()
	%Trade.clear()
	%Location.clear()
	for option in traits:
		_traits[option.id] = option
		if option.category == "geographic":
			%Homeland.add_item(option.name)
			_homelands.append(option)
		elif option.category == "social":
			%Background.add_item(option.name)
			_backgrounds.append(option)
		elif option.category == "profession":
			%Trade.add_item(option.name)
			_trades.append(option)
		elif option.category == "spawn":
			%Location.add_item(option.name)
			_locations.append(option)
	%Homeland.selected = -1
	%Background.selected = -1
	%Trade.selected = -1
	%Location.selected = -1
	%LocationTitle.visible = false
	%LocationDescription.visible = false
	%BackgroundTitle.visible = false
	%BackgroundDescription.visible = false
	%TradeTitle.visible = false
	%TradeDescription.visible = false
	%HomelandTitle.visible = false
	%HomelandDescription.visible = false
	%HomelandGoodTraits.visible = false
	%HomelandBadTraits.visible = false
	%BackgroundGoodTraits.visible = false
	%BackgroundBadTraits.visible = false
	%TradeGoodTraits.visible = false
	%TradeBadTraits.visible = false

func is_origin_setup() -> bool:
	return %Homeland.selected != -1 && %Background.selected != -1 && %Trade.selected != -1 && %Location.selected != -1

func _on_age_value_changed(value: int):
	if value > 60:
		%AgeTitle.text = tr("AGE_ANCIENT")
		%AgeDescription.text = tr("AGE_ANCIENT_DESCRIPTION")
	elif value > 30:
		%AgeTitle.text = tr("AGE_OLD")
		%AgeDescription.text = tr("AGE_OLD_DESCRIPTION")
	else :
		%AgeTitle.text = tr("AGE_YOUNG")
		%AgeDescription.text = tr("AGE_YOUNG_DESCRIPTION")
	origin_changed.emit()

func _on_homeland_item_selected(index: int):
	origin_changed.emit()
	var homeland = _homelands[index]
	%HomelandTitle.text = homeland.name
	%HomelandDescription.text = homeland.description
	%HomelandTitle.visible = true
	%HomelandDescription.visible = true
	var provided_traits = homeland.provides.map(func (it): return _traits[it])
	var good_traits = provided_traits.filter(func (it): return it.valence == "Good")
	var bad_traits = provided_traits.filter(func (it): return it.valence == "Bad")
	%HomelandGoodTraits.text = "[ul]%s[/ul]" % "\n".join(good_traits.map(func (it): return it.name))
	%HomelandBadTraits.text = "[ul]%s[/ul]" % "\n".join(bad_traits.map(func (it): return it.name))
	%HomelandGoodTraits.visible = good_traits.size() > 0
	%HomelandBadTraits.visible = bad_traits.size() > 0

func _on_location_item_selected(index: int):
	origin_changed.emit()
	var location = _locations[index]
	%LocationTitle.text = location.name
	%LocationDescription.text = location.description
	%LocationTitle.visible = true
	%LocationDescription.visible = true

func _on_background_item_selected(index: int):
	origin_changed.emit()
	var background = _backgrounds[index]
	%BackgroundTitle.text = background.name
	%BackgroundDescription.text = background.description
	%BackgroundTitle.visible = true
	%BackgroundDescription.visible = true
	var provided_traits = background.provides.map(func (it): return _traits[it])
	var good_traits = provided_traits.filter(func (it): return it.valence == "Good")
	var bad_traits = provided_traits.filter(func (it): return it.valence == "Bad")
	%BackgroundGoodTraits.text = "[ul]%s[/ul]" % "\n".join(good_traits.map(func (it): return it.name))
	%BackgroundBadTraits.text = "[ul]%s[/ul]" % "\n".join(bad_traits.map(func (it): return it.name))
	%BackgroundGoodTraits.visible = good_traits.size() > 0
	%BackgroundBadTraits.visible = bad_traits.size() > 0

func _on_trade_item_selected(index: int):
	origin_changed.emit()
	var trade = _trades[index]
	%TradeTitle.text = trade.name
	%TradeDescription.text = trade.description
	%TradeTitle.visible = true
	%TradeDescription.visible = true
	var provided_traits = trade.provides.map(func (it): return _traits[it])
	var good_traits = provided_traits.filter(func (it): return it.valence == "Good")
	var bad_traits = provided_traits.filter(func (it): return it.valence == "Bad")
	%TradeGoodTraits.text = "[ul]%s[/ul]" % "\n".join(good_traits.map(func (it): return it.name))
	%TradeBadTraits.text = "[ul]%s[/ul]" % "\n".join(bad_traits.map(func (it): return it.name))
	%TradeGoodTraits.visible = good_traits.size() > 0
	%TradeBadTraits.visible = bad_traits.size() > 0

func get_age() -> int:
	return %Age.value

func get_selected_trait_ids():
	var homeland = _homelands[%Homeland.selected]
	var background = _backgrounds[%Background.selected]
	var trade = _trades[%Trade.selected]
	var location = _locations[%Location.selected]
	return [homeland.id, background.id, trade.id, location.id]
