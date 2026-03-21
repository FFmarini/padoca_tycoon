extends Node

var hour := 4
var minute := 0

var speed := 60  # quanto tempo real = 1 minuto do jogo (ajustável)

signal time_changed
signal day_started
signal bakery_opened

func _ready():
	run_clock()

func run_clock():
	while true:
		await get_tree().create_timer(1.0).timeout
		
		minute += 1
		
		if minute >= 60:
			minute = 0
			hour += 1
			
			if hour >= 24:
				hour = 0
				emit_signal("day_started")
		
		emit_signal("time_changed", hour, minute)
		
		# Evento importante
		if hour == 6 and minute == 0:
			emit_signal("bakery_opened")
