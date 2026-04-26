extends Node

var ally_color: Color = Color("#19f8ff")
var ally_color_dark: Color = Color("#0C8E94")

var enemy_color: Color = Color("#d14b4b")
var enemy_color_dark: Color = Color("#7a1f1f")

var wave_multiplier := 1.

var hp_mult := 1. #
var dmg_mult := 1. #
var dash_cd_mult := 1. #

var life_steal := 0. #

var invincible_duration_offset := 0.
var flat_damage_reduction := 0. #
var switch_cooldown_mult := 1. #

var enemy_speed_mult := 1. #
var enemy_dmg_mult := 1. #
