extends CanvasLayer

@onready var gm = get_node("/root/Main/GameManager")
@onready var time_manager = get_node("/root/Main/TimeManager")
@onready var oven = get_tree().get_first_node_in_group("oven")

var upgrade_cost := 50

func _ready():
	if gm:
		gm.ui_updated.connect(update_ui)

	update_ui()
	update_status_label()

func _process(_delta):
	if time_manager:
		update_time_display()
		update_status_label()

func update_ui():
	if not gm:
		return

	$MoneyLabel.text = "💰 " + str(gm.dinheiro) + "\n🍞 " + str(gm.paes_prontos)
	$UpgradeButton.text = "Upgrade Forno ($" + str(upgrade_cost) + ")"

func update_time_display():
	var h = str(time_manager.hour).pad_zeros(2)
	var m = str(time_manager.minute).pad_zeros(2)
	$TimeLabel.text = "🕒 " + h + ":" + m

func update_status_label():
	if not time_manager:
		return

	if time_manager.hour >= 6 and time_manager.hour < 18:
		$StatusLabel.text = "🟢 Padaria Aberta"
	else:
		$StatusLabel.text = "🔴 Padaria Fechada"

func _on_upgrade_button_pressed():
	if not gm:
		return

	if gm.dinheiro >= upgrade_cost:
		gm.dinheiro -= upgrade_cost
		upgrade_cost *= 2
		gm.quantidade_por_lote += 5
		gm.emit_signal("ui_updated")
