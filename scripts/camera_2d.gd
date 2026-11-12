extends Camera2D

var period:float = 0.3
var magnitude = 100.0
func camera_shake(magnitude):
	
	var elapsed_time:float = 0.0
	while elapsed_time < period:
		offset = Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
		)
		
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
	offset = Vector2.ZERO
