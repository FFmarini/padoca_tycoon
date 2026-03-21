extends Node2D

@onready var customers_node = $Customers
@onready var spawn_point = $SpawnPoint
@onready var counter_point = $CounterPoint
@onready var queue_point_1 = $QueuePoint1
@onready var queue_point_2 = $QueuePoint2
@onready var exit_point = $ExitPoint

@onready var time_manager = get_node("/root/Main/TimeManager")
@onready var game_manager = get_node("/root/Main/GameManager")

var customer_scene = preload("res://scenes/Customer.tscn")
var queue_positions: Array[Marker2D] = []
var queue_customers: Array = []
var bakery_open := false

func _ready():
	print("customers_node =", customers_node)
	print("spawn_point =", spawn_point)
	print("counter_point =", counter_point)
	print("queue_point_1 =", queue_point_1)
	print("queue_point_2 =", queue_point_2)
	print("exit_point =", exit_point)
	print("customer_scene =", customer_scene)
	print("game_manager =", game_manager)
	print("time_manager =", time_manager)

	if not customers_node or not spawn_point or not counter_point or not queue_point_1 or not queue_point_2 or not exit_point or not game_manager or not time_manager:
		push_error("Algum nó obrigatório não foi encontrado.")
		return

	queue_positions = [counter_point, queue_point_1, queue_point_2]
	spawn_customer_loop()

func _process(_delta):
	bakery_open = time_manager.hour >= 6 and time_manager.hour < 18

func spawn_customer_loop():
	while true:
		await get_tree().create_timer(4.0).timeout
		try_spawn_customer()

func try_spawn_customer():
	if not bakery_open:
		print("Padaria fechada - cliente não entrou")
		return

	if queue_customers.size() >= queue_positions.size():
		print("Fila cheia")
		return

	var customer = customer_scene.instantiate()
	if not customer:
		push_error("Falha ao instanciar customer_scene.")
		return

	customers_node.add_child(customer)
	customer.global_position = spawn_point.global_position

	queue_customers.append(customer)
	update_queue_targets()
	handle_customer(customer)

func update_queue_targets():
	for i in range(queue_customers.size()):
		var customer = queue_customers[i]
		if is_instance_valid(customer):
			customer.set_target(queue_positions[i].global_position)

func handle_customer(customer):
	await wait_until_customer_reaches(customer, counter_point.global_position)

	while queue_customers.is_empty() or queue_customers[0] != customer:
		await get_tree().process_frame

	await get_tree().create_timer(2.0).timeout

	if game_manager.vender_pao(1):
		print("Cliente comprou pão")
	else:
		print("Cliente saiu sem comprar")

	if not queue_customers.is_empty() and queue_customers[0] == customer:
		queue_customers.remove_at(0)

	update_queue_targets()

	customer.set_target(exit_point.global_position)
	await wait_until_customer_reaches(customer, exit_point.global_position)

	if is_instance_valid(customer):
		customer.queue_free()

func wait_until_customer_reaches(customer, target: Vector2) -> void:
	while is_instance_valid(customer) and customer.global_position.distance_to(target) > 8:
		await get_tree().process_frame
