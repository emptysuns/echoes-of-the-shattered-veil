# Data Templates

All IDs are namespaced, display text uses localization keys, and content never embeds executable expressions. The concrete script paths below are part of the v0.1.0 Resource API.

## Entity example

```ini
[gd_resource type="Resource" script_class="EntityDefinitionResource" load_steps=3 format=3]

[ext_resource path="res://scripts/core/resources/entity_definition_resource.gd" type="Script" id="1"]
[ext_resource path="res://resources/entities/stats/ash_hound_stats.tres" type="Resource" id="2"]

[resource]
script = ExtResource("1")
content_id = "base.enemy.ash_hound"
display_name_key = "entity.ash_hound.name"
tags = PackedStringArray("enemy", "beast", "act1")
stats = ExtResource("2")
ai_profile = "chase"
texture_path = "res://assets/sprites/actors/ash_hound.png"
```

## Item and affix example

```ini
[gd_resource type="Resource" script_class="ItemDefinitionResource" load_steps=2 format=3]

[ext_resource path="res://scripts/core/resources/item_definition_resource.gd" type="Script" id="1"]

[resource]
script = ExtResource("1")
content_id = "base.item.weapon.ashglass_sabre"
display_name_key = "item.ashglass_sabre.name"
item_type = 1
max_stack = 1
power = 4
affix_slots = 2
tags = PackedStringArray("weapon", "blade", "act1")
```

## Branching dialogue JSON example

```json
{
  "schema_version": 1,
  "dialogue_id": "base.dialogue.hub.maelin_a_bell_remembers",
  "start_node": "opening",
  "nodes": {
    "opening": {"type": "line", "speaker": "base.npc.maelin", "text_key": "dialogue.maelin.opening", "next": "first_choice"},
    "first_choice": {
      "type": "choice",
      "choices": [
        {"text_key": "dialogue.maelin.choice_crack", "next": "crack", "commands": [{"type": "set_flag", "target": "base.flag.maelin_noticed_crack", "value": true}]},
        {"text_key": "dialogue.maelin.choice_leave", "next": "end"}
      ]
    },
    "crack": {"type": "line", "speaker": "base.npc.maelin", "text_key": "dialogue.maelin.crack_reply", "next": "end"},
    "end": {"type": "end"}
  }
}
```

## StoryBeat example

```ini
[gd_resource type="Resource" script_class="StoryEventResource" load_steps=2 format=3]

[ext_resource path="res://scripts/core/resources/story_event_resource.gd" type="Script" id="1"]

[resource]
script = ExtResource("1")
content_id = "base.story.act1.nave_missing_names"
act = 1
required = true
room_tag = "story_nave"
minimum_floor = 1
maximum_floor = 3
cooldown_floors = 2
fallback_room_id = "base.room.story.ash_clinic"
```

## Ending example

```ini
[gd_resource type="Resource" script_class="EndingResource" load_steps=2 format=3]

[ext_resource path="res://scripts/core/resources/ending_resource.gd" type="Script" id="1"]

[resource]
script = ExtResource("1")
content_id = "base.ending.chorus"
display_name_key = "ending.chorus.name"
priority = 100
minimum_lore_ratio = 0.85
required_flags = PackedStringArray("base.flag.caedmon_chose_after_restoration", "base.flag.ilyra_memory_not_forged", "base.flag.aster_echo_not_overwritten")
required_survivors = PackedStringArray("base.npc.maelin", "base.npc.ilyra", "base.npc.vey", "base.npc.oryn", "base.npc.moth")
```
