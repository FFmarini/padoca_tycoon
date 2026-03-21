extends Node

signal ui_updated

var dinheiro: int = 100
var paes_prontos: int = 0

var farinha: int = 20
var agua: int = 20
var sal: int = 20
var fermento: int = 20

var produzindo := false
var etapa := "Parado"
var quantidade_por_lote := 10
var padeiro_ocupado := false

@onready var time_manager = $"../TimeManager"

func _process(_delta):
	producao_automatica()

func tem_ingredientes() -> bool:
	return farinha >= 1 and agua >= 1 and sal >= 1 and fermento >= 1

func consumir_ingredientes():
	farinha -= 1
	agua -= 1
	sal -= 1
	fermento -= 1

func iniciar_producao():
	if produzindo:
		return

	if not tem_ingredientes():
		print("Sem ingredientes")
		return

	produzindo = true

	consumir_ingredientes()
	etapa = "Preparando"
	emit_signal("ui_updated")
	await get_tree().create_timer(5.0).timeout
func adicionar_paes(qtd: int):
	paes_prontos += qtd
	emit_signal("ui_updated")
	emit_signal("ui_updated")
	await get_tree().create_timer(6.0).timeout

	etapa = "Assando"
	emit_signal("ui_updated")
	await get_tree().create_timer(5.0).timeout

	paes_prontos += quantidade_por_lote
	print("Pães prontos:", paes_prontos)

	etapa = "Parado"
	produzindo = false
	emit_signal("ui_updated")

func producao_automatica():
	if time_manager.hour >= 4 and time_manager.hour < 6:
		if not produzindo and tem_ingredientes():
			iniciar_producao()

func vender_pao(qtd := 1) -> bool:
	if paes_prontos >= qtd:
		paes_prontos -= qtd
		dinheiro += qtd * 5
		emit_signal("ui_updated")
		return true
	return false
