#should be triggered in case if "mother" event is refused
#offers a bank loan
extends DecisionSimple

var bank_name := ['Rotsher', 'KGB', 'Java']
var loan_amount: int
var loan_percent: float
var loan_month_term: int

func _init():
	#on accept
	#Money amount instantly added to the city budget
	accept_effects = {
		"on_gauges": {
			#"BUDGET": added further in code
			},
	}
	
	#on decline
	#no effect
	refuse_or_expire_effects = {
		"on_gauges": {
		#empty
		},
	}

func on_triggered(scene_tree: SceneTree) -> void:
	.on_triggered(scene_tree)
	# ex: Loan offer in Rothser Bank
	title = (
		'Loan offer in '
		+ WeightChoice.choose_random_from_array(bank_name)
		+ ' Bank'
	)
	loan_amount = WeightChoice.randi_range(200, 1000)
	loan_percent = stepify(rand_range(0.01, 0.05), 0.01) #will round our foat number until 0.01 precision
	loan_month_term = WeightChoice.randi_range(12, 24) # 12-24 month
	accept_effects['on_gauges']['BUDGET'] = loan_amount
	# ex: Loan amount: 1000$ Loan term: 14 month Loan percentage: 5% 
	description = (
		'Loan amount: ' + str(loan_amount) + 'K $ \n' + 
		'Loan term: ' + str(loan_month_term) + ' month \n' + 
		'Interest rates: ' + str(loan_percent * 100) + '%'
	)

func on_accepted(scene_tree: SceneTree) -> void:
	.on_accepted(scene_tree)# we add loan amount to the city budget one time
	
	var month_passed := 0
	var monthly_debt_amount: int
	var monthly_effect = {
		'on_gauges': {
			'BUDGET' : 0
		}
	}
	#each month the city budget will loose a certain amount of money 
	#corresponding to it's monthly bank debt
	while month_passed != loan_month_term:
		yield(turn_controller, "turn_changed")
		month_passed += 1
		monthly_debt_amount = int(round((loan_amount + round(loan_amount * loan_percent)) / loan_month_term))
		loan_amount -= monthly_debt_amount
		monthly_effect['on_gauges']['BUDGET'] = monthly_debt_amount
		gauge_controller.apply_to_gauges(monthly_effect.on_gauges)
