extends Label

func showmachin(newturn, newday = 1):
	text = str(newturn) + " " + str(newday)

func pauseit():
	get_node("../TurnController").pause_turns()

func resumeit():
	get_node("../TurnController").resume_turns()
