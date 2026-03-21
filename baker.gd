extends CharacterBody2D

enum State {
	IDLE,
	INDO_ESTOQUE,
	INDO_MASSEIRA,
	BATENDO_MASSA,
	INDO_MESA,
	MODELANDO,
	CRESCENDO,
	INDO_FORNO,
	ASSANDO,
	INDO_BALCAO
}

@export var speed := 80.0

@onready var gm = get_node("/root/Main/GameManager")
@onready var tm = get_node("/root/Main/TimeManager")
@onready var stock_point = $"../StockPoint"
@onready var mixer_point = $"../MixerPoint"
@onready var table_point = $"../TablePoint"
@onready var grow_point = $"../GrowPoint"
@onready var oven_point = $"../OvenPoint"
@onready var sell_point = $"../SellPoint"

var state = State.IDLE
var target_position: Vector2
var trabalhando := false

func _ready():
	target_position = global_position

func _physics_process(_delta):
	move_to_target()

func _process(_delta):
	if deve_produzir() and not trabalhando:
		iniciar_processo()

func deve_produzir() -> bool:
	# Produz antes da abertura ou quando tiver pouco pão
	if gm == null or tm == null:
		return false

	if trabalhando:
		return false

	if not gm.tem_ingredientes():
		return false

	if tm.hour >= 4 and tm.hour < 6:
		return true

	if tm.hour >= 6 and tm.hour < 18 and gm.paes_prontos < 10:
		return true

	return false

func iniciar_processo():
	trabalhando = true
	gm.padeiro_ocupado = true
	await processo_completo()
	trabalhando = false
	gm.padeiro_ocupado = false

func processo_completo():
	state = State.INDO_ESTOQUE
	await ir_ate(stock_point.global_position)

	if not gm.tem_ingredientes():
		state = State.IDLE
		return

	gm.consumir_ingredientes()

	state = State.INDO_MASSEIRA
	await ir_ate(mixer_point.global_position)

	state = State.BATENDO_MASSA
	await esperar(3.0)

	state = State.INDO_MESA
	await ir_ate(table_point.global_position)

	state = State.MODELANDO
	await esperar(2.0)

	state = State.CRESCENDO
	await ir_ate(grow_point.global_position)
	await esperar(4.0)

	state = State.INDO_FORNO
	await ir_ate(oven_point.global_position)

	state = State.ASSANDO
	await esperar(5.0)

	state = State.INDO_BALCAO
	await ir_ate(sell_point.global_position)

	gm.adicionar_paes(gm.quantidade_por_lote)

	state = State.IDLE

func ir_ate(pos: Vector2) -> void:
	target_position = pos
	while global_position.distance_to(target_position) > 4.0:
		await get_tree().process_frame

func esperar(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout

func move_to_target():
	var dir = target_position - global_position
	if dir.length() > 4.0:
		velocity = dir.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func get_status_text() -> String:
	match state:
		State.IDLE:
			return "Parado"
		State.INDO_ESTOQUE:
			return "Pegando ingredientes"
		State.INDO_MASSEIRA:
			return "Levando à masseira"
		State.BATENDO_MASSA:
			return "Batendo massa"
		State.INDO_MESA:
			return "Levando à mesa"
		State.MODELANDO:
			return "Modelando pães"
		State.CRESCENDO:
			return "Deixando crescer"
		State.INDO_FORNO:
			return "Levando ao forno"
		State.ASSANDO:
			return "Assando"
		State.INDO_BALCAO:
			return "Colocando à venda"
	return "Parado"
