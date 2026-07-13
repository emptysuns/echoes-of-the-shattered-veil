class_name EffectDefinitionResource
extends ContentDefinition
## A safe, finite gameplay effect primitive.

enum EffectType { DAMAGE, HEAL, APPLY_STATUS, MODIFY_ENERGY, MOVE, SUMMON, REVEAL_LORE }

@export var effect_type: EffectType = EffectType.DAMAGE
@export var magnitude: int = 1
@export var duration_turns: int = 0
@export var target_id: StringName
@export var chance: float = 1.0

func validate() -> PackedStringArray:
    var errors := super.validate()
    if chance < 0.0 or chance > 1.0: errors.append("chance must be between zero and one")
    if effect_type in [EffectType.APPLY_STATUS, EffectType.SUMMON, EffectType.REVEAL_LORE] and String(target_id).is_empty():
        errors.append("target_id is required for this effect type")
    return errors
