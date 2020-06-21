extends Node

var player = preload("res://Scenes/Game/Player/Player.tscn")
var nplayer = preload("res://Scenes/NetworkedGame/Player/NPlayer.tscn")
var bot = preload("res://Scenes/Game/Player/Bot/Bot.tscn")
var bomb = preload("res://Scenes/Game/Bomb/Bomb.tscn")
var explosion = preload("res://Scenes/Game/Bomb/Explosion/Explosion.tscn")
var fireline = preload("res://Scenes/Game/Effects/FireLine.tscn")
var baguette = preload("res://Scenes/Game/Baguette/Baguette.tscn")
var explosion_hitbox = preload("res://Scenes/Game/Bomb/Explosion/ExplosionHitBox.tscn")
var item = preload("res://Scenes/Game/Items/Item.tscn")
var gravestone = preload("res://Scenes/Game/Effects/GraveStone.tscn")

# effects
var effect_pop = preload("res://Scenes/Game/Effects/PopEffect.tscn")
var effect_impact = preload("res://Scenes/Game/Effects/Impact.tscn")

# networked game
var ngame = preload("res://Scenes/NetworkedGame/NGame.tscn")

# menu
var conf_item_entry = preload("res://Scenes/MainMenu/ConfigurationMenu/ItemEntry.tscn")

# game summary
var player_summary = preload("res://Scenes/Game/GUI/GameSummary/PlayerStatistics.tscn")
var player_stat = preload("res://Scenes/Game/GUI/GameSummary/Stat.tscn")
