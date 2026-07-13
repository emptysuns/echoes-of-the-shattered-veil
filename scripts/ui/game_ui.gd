class_name GameUI
extends CanvasLayer
## Bilingual pixel UI and semantic input surface.

signal start_run_requested
signal direction_requested(direction: Vector2i)
signal wait_requested
signal npc_requested(dialogue_id: StringName)
signal dialogue_advance_requested
signal dialogue_choice_requested(index: int)
signal overlay_closed
signal language_toggle_requested

var theme := Theme.new()
var hud: Panel
var health_label: Label
var energy_label: Label
var floor_label: Label
var essence_label: Label
var quest_label: Label
var message_label: RichTextLabel
var minimap: MiniMapView
var hub: Panel
var hub_meta: Label
var hub_npc_buttons: Array[Button] = []
var hub_npc_keys := [&"npc.maelin.name", &"npc.ilyra.name", &"npc.vey.name", &"npc.oryn.name", &"npc.moth.name"]
var hub_start_button: Button
var overlay_close_button: Button
var dialogue_panel: Panel
var dialogue_speaker: Label
var dialogue_text: RichTextLabel
var dialogue_choices: VBoxContainer
var overlay: Panel
var overlay_title: Label
var overlay_body: RichTextLabel
var banner: Panel
var banner_label: Label
var touch_root: Control
var messages: Array[String] = []

func _ready() -> void:
    _build_theme()
    _build_hud()
    _build_hub()
    _build_dialogue()
    _build_overlay()
    _build_banner()
    _build_touch_controls()
    hide_hud()

func _build_theme() -> void:
    var font := load("res://assets/fonts/ark-pixel-12px.ttf") as FontFile
    if font != null:
        font = font.duplicate() as FontFile
        font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
        font.generate_mipmaps = false
        theme.default_font = font
    theme.default_font_size = 10
    theme.set_color("font_color", "Label", Color("d8d2c4"))
    theme.set_color("default_color", "RichTextLabel", Color("d8d2c4"))
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("090812e8")
    panel_style.border_color = Color("4b6f8f")
    panel_style.set_border_width_all(1)
    panel_style.content_margin_left = 7; panel_style.content_margin_right = 7
    panel_style.content_margin_top = 5; panel_style.content_margin_bottom = 5
    theme.set_stylebox("panel", "Panel", panel_style)
    var button_style := StyleBoxFlat.new()
    button_style.bg_color = Color("17152b")
    button_style.border_color = Color("4b6f8f")
    button_style.set_border_width_all(1)
    button_style.corner_radius_top_left = 0; button_style.corner_radius_top_right = 0
    button_style.corner_radius_bottom_left = 0; button_style.corner_radius_bottom_right = 0
    theme.set_stylebox("normal", "Button", button_style)
    var hover := button_style.duplicate() as StyleBoxFlat; hover.bg_color = Color("27234a"); hover.border_color = Color("d59a42")
    theme.set_stylebox("hover", "Button", hover); theme.set_stylebox("pressed", "Button", hover)

func _full_control() -> Control:
    var control := Control.new()
    control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    control.theme = theme
    return control

func _build_hud() -> void:
    var root := _full_control(); add_child(root)
    hud = Panel.new(); hud.position = Vector2(4, 4); hud.size = Vector2(472, 30); hud.theme = theme; root.add_child(hud)
    health_label = _label(Vector2(8, 6), Vector2(88, 18)); hud.add_child(health_label)
    energy_label = _label(Vector2(96, 6), Vector2(78, 18)); hud.add_child(energy_label)
    floor_label = _label(Vector2(178, 6), Vector2(65, 18)); hud.add_child(floor_label)
    essence_label = _label(Vector2(247, 6), Vector2(100, 18)); hud.add_child(essence_label)
    quest_label = _label(Vector2(4, 36), Vector2(330, 18)); root.add_child(quest_label)
    message_label = RichTextLabel.new(); message_label.position = Vector2(4, 218); message_label.size = Vector2(365, 48); message_label.fit_content = false; message_label.bbcode_enabled = true; message_label.theme = theme; root.add_child(message_label)
    minimap = MiniMapView.new(); minimap.position = Vector2(425, 36); minimap.size = Vector2(50, 34); minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE; root.add_child(minimap)

func _build_hub() -> void:
    var root := _full_control(); add_child(root)
    hub = Panel.new(); hub.position = Vector2(20, 14); hub.size = Vector2(440, 242); hub.theme = theme; root.add_child(hub)
    var title := _label(Vector2(15, 12), Vector2(410, 28)); title.text = "破碎帷幕的回响\nEchoes of the Shattered Veil"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; hub.add_child(title)
    var subtitle := _label(Vector2(20, 47), Vector2(400, 20)); subtitle.text = "Echo Sanctum · 回响圣所"; subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; subtitle.modulate = Color("83b6b3"); hub.add_child(subtitle)
    var npcs := [["npc.maelin.name", "base.dialogue.hub.maelin"], ["npc.ilyra.name", "base.dialogue.hub.ilyra"], ["npc.vey.name", "base.dialogue.hub.vey"], ["npc.oryn.name", "base.dialogue.hub.oryn"], ["npc.moth.name", "base.dialogue.hub.moth"]]
    for index in range(npcs.size()):
        var data: Array = npcs[index]
        var button := _button(Vector2(20 + (index % 2) * 202, 76 + (index / 2) * 31), Vector2(192, 25), ContentRegistry.text(StringName(data[0])))
        var dialogue_id := StringName(data[1]); button.pressed.connect(func() -> void: npc_requested.emit(dialogue_id)); hub.add_child(button); hub_npc_buttons.append(button)
    hub_meta = _label(Vector2(20, 171), Vector2(400, 18)); hub.add_child(hub_meta)
    hub_start_button = _button(Vector2(20, 199), Vector2(255, 29), ContentRegistry.text(&"ui.start_run")); hub_start_button.pressed.connect(func() -> void: start_run_requested.emit()); hub.add_child(hub_start_button)
    var lang := _button(Vector2(285, 199), Vector2(127, 29), "中文 / EN"); lang.pressed.connect(func() -> void: language_toggle_requested.emit()); hub.add_child(lang)

func _build_dialogue() -> void:
    var root := _full_control(); add_child(root)
    dialogue_panel = Panel.new(); dialogue_panel.position = Vector2(14, 140); dialogue_panel.size = Vector2(452, 124); dialogue_panel.theme = theme; dialogue_panel.hide(); root.add_child(dialogue_panel)
    dialogue_speaker = _label(Vector2(9, 7), Vector2(130, 17)); dialogue_speaker.modulate = Color("d59a42"); dialogue_panel.add_child(dialogue_speaker)
    dialogue_text = RichTextLabel.new(); dialogue_text.position = Vector2(9, 25); dialogue_text.size = Vector2(434, 34); dialogue_text.bbcode_enabled = true; dialogue_text.theme = theme; dialogue_panel.add_child(dialogue_text)
    dialogue_choices = VBoxContainer.new(); dialogue_choices.position = Vector2(9, 60); dialogue_choices.size = Vector2(434, 58); dialogue_choices.add_theme_constant_override("separation", 2); dialogue_panel.add_child(dialogue_choices)

func _build_overlay() -> void:
    var root := _full_control(); add_child(root)
    overlay = Panel.new(); overlay.position = Vector2(38, 32); overlay.size = Vector2(404, 204); overlay.theme = theme; overlay.hide(); root.add_child(overlay)
    overlay_title = _label(Vector2(10, 8), Vector2(300, 20)); overlay_title.modulate = Color("d59a42"); overlay.add_child(overlay_title)
    overlay_body = RichTextLabel.new(); overlay_body.position = Vector2(10, 32); overlay_body.size = Vector2(384, 130); overlay_body.bbcode_enabled = true; overlay_body.scroll_active = true; overlay_body.theme = theme; overlay.add_child(overlay_body)
    overlay_close_button = _button(Vector2(284, 166), Vector2(110, 27), ContentRegistry.text(&"ui.close")); overlay_close_button.pressed.connect(close_overlay); overlay.add_child(overlay_close_button)

func _build_banner() -> void:
    var root := _full_control(); add_child(root)
    banner = Panel.new(); banner.position = Vector2(55, 82); banner.size = Vector2(370, 106); banner.theme = theme; banner.hide(); root.add_child(banner)
    banner_label = _label(Vector2(10, 12), Vector2(350, 80)); banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; banner.add_child(banner_label)

func _build_touch_controls() -> void:
    touch_root = Control.new(); touch_root.position = Vector2(4, 118); touch_root.size = Vector2(110, 96); touch_root.theme = theme; add_child(touch_root)
    var directions := [[Vector2i(-1,-1),Vector2(0,0),"↖"],[Vector2i(0,-1),Vector2(30,0),"↑"],[Vector2i(1,-1),Vector2(60,0),"↗"],[Vector2i(-1,0),Vector2(0,30),"←"],[Vector2i(1,0),Vector2(60,30),"→"],[Vector2i(-1,1),Vector2(0,60),"↙"],[Vector2i(0,1),Vector2(30,60),"↓"],[Vector2i(1,1),Vector2(60,60),"↘"]]
    for raw: Array in directions:
        var direction: Vector2i = raw[0]; var button := _button(raw[1], Vector2(28,28), String(raw[2])); button.pressed.connect(func() -> void: direction_requested.emit(direction)); touch_root.add_child(button)
    var wait_button := _button(Vector2(30,30),Vector2(28,28),"·"); wait_button.pressed.connect(func() -> void: wait_requested.emit()); touch_root.add_child(wait_button)
    touch_root.visible = DisplayServer.is_touchscreen_available()

func show_hub() -> void:
    hub.show(); hide_hud(); dialogue_panel.hide(); overlay.hide(); banner.hide()
    hub_meta.text = "%s: %d  ·  Deaths: %d" % [ContentRegistry.text(&"ui.essence"), MetaProgressionSystem.echo_essence, MetaProgressionSystem.death_count]

func show_hud() -> void:
    hub.hide(); hud.show(); quest_label.show(); message_label.show(); minimap.show(); banner.hide()

func hide_hud() -> void:
    hud.hide(); quest_label.hide(); message_label.hide(); minimap.hide()

func update_hud(player: Actor, floor_index: int) -> void:
    if player == null: return
    health_label.text = "%s %d/%d" % [ContentRegistry.text(&"ui.health"), player.health.current, player.health.maximum]
    energy_label.text = "%s %d" % [ContentRegistry.text(&"ui.energy"), player.timeline.energy]
    floor_label.text = "%s %d" % [ContentRegistry.text(&"ui.floor"), floor_index]
    essence_label.text = "%s %d" % [ContentRegistry.text(&"ui.essence"), MetaProgressionSystem.echo_essence]
    var step := QuestSystem.current_step(&"base.quest.act1.a_name_returned")
    quest_label.text = "%s: %s" % [ContentRegistry.text(&"ui.quest"), ContentRegistry.text(StringName("quest.a_name_returned.%s" % step))]

func show_dialogue(view: Dictionary) -> void:
    dialogue_panel.show()
    dialogue_speaker.text = ContentRegistry.text(StringName("%s.name" % String(view.speaker).replace("base.npc.", "npc.")))
    dialogue_text.text = String(view.text)
    for child in dialogue_choices.get_children(): child.queue_free()
    var choices: Array = view.get("choices", [])
    if choices.is_empty():
        var next := _button(Vector2.ZERO, Vector2(430, 25), ContentRegistry.text(&"ui.continue")); next.pressed.connect(func() -> void: dialogue_advance_requested.emit()); dialogue_choices.add_child(next)
    else:
        for index in range(choices.size()):
            var choice: Dictionary = choices[index]
            var button := _button(Vector2.ZERO, Vector2(430, 18), String(choice.text)); button.pressed.connect(func() -> void: dialogue_choice_requested.emit(index)); dialogue_choices.add_child(button)

func hide_dialogue() -> void:
    dialogue_panel.hide()

func show_inventory() -> void:
    overlay_title.text = ContentRegistry.text(&"ui.inventory")
    var lines := PackedStringArray()
    for item_id: String in InventorySystem.items:
        var definition := ContentRegistry.get_definition(StringName(item_id)) as ItemDefinitionResource
        if definition != null: lines.append("%s × %d" % [ContentRegistry.text(definition.display_name_key), InventorySystem.items[item_id]])
    lines.append("\n[1] %s" % ContentRegistry.text(&"base.item.consumable.echo_tonic.name"))
    _show_overlay_text("\n".join(lines))

func show_codex() -> void:
    overlay_title.text = ContentRegistry.text(&"ui.codex")
    var lines := PackedStringArray()
    for lore in LoreSystem.entries(): lines.append("[color=#d59a42]%s[/color]\n%s\n" % [ContentRegistry.text(lore.display_name_key), ContentRegistry.text(lore.body_key)])
    if lines.is_empty(): lines.append("—")
    _show_overlay_text("\n".join(lines))

func show_messages() -> void:
    overlay_title.text = ContentRegistry.text(&"ui.messages")
    _show_overlay_text("\n".join(messages))

func _show_overlay_text(text: String) -> void:
    overlay_body.text = text; overlay.show(); UIManager.open_overlay(&"journal")

func close_overlay() -> void:
    overlay.hide(); UIManager.close_overlay(&"journal"); overlay_closed.emit()

func append_message(text: String) -> void:
    messages.append(text)
    if messages.size() > 80: messages.pop_front()
    message_label.text = "\n".join(messages.slice(maxi(0, messages.size() - 3)))

func show_banner(text: String) -> void:
    banner_label.text = text; banner.show()

func refresh_locale() -> void:
    for index in range(hub_npc_buttons.size()): hub_npc_buttons[index].text = ContentRegistry.text(hub_npc_keys[index])
    hub_start_button.text = ContentRegistry.text(&"ui.start_run")
    overlay_close_button.text = ContentRegistry.text(&"ui.close")
    show_hub()

func _label(position_value: Vector2, size_value: Vector2) -> Label:
    var label := Label.new(); label.position = position_value; label.size = size_value; label.theme = theme; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; return label

func _button(position_value: Vector2, size_value: Vector2, text_value: String) -> Button:
    var button := Button.new(); button.position = position_value; button.custom_minimum_size = size_value; button.size = size_value; button.text = text_value; button.theme = theme; button.focus_mode = Control.FOCUS_ALL; return button
