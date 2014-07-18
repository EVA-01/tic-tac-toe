Array::count = (e) ->
	c=0
	for a in this
		if a is e
			c++
	c
Array::max = () ->
	@reduce (p, v)->
		if p > v then p else v
Array::random = () ->
	return this[Math.floor(Math.random() * this.length)]

TicTacToeAI =
	sets: [
		["00","01","02"]
		["10","11","12"]
		["20","21","22"]
		["00","10","20"]
		["01","11","21"]
		["02","12","22"]
		["00","11","22"]
		["02","11","20"]
	]
	handleXY: (coordinates) ->
		if coordinates.constructor is String
			coordinates
		else if coordinates.constructor is Array
			coordinates[0..1].join("")
	getBox: (board, coordinate) ->
		board[coordinate[1]][coordinate[0]]
	getBoxes: (board, coordinates...) ->
		if coordinates.length is 1
			@getBox(board, coordinates[0])
		else
			for m in coordinates
				@getBox(board, m)
	getSetMembership: (coordinates) ->
		j = @handleXY(coordinates)
		for k in @sets
			if j in k
				k
			else
	rankBox: (board, coordinates, protagonist, antagonist) ->
		###
		if @getBox(board, coordinates) in [protagonist, antagonist]
			for set in @getSetMembership(coordinates)
				-1
		else
			a = for set in @getSetMembership(coordinates)
				k = @getBoxes(board, set[0], set[1], set[2])
				if antagonist in k
					0
				else
					c=k.count(protagonist)
					12.5 * c ** 2 + 12.5 * c + 25
		###
		for set in @getSetMembership(coordinates)
			k = @getBoxes(board, set[0], set[1], set[2])
			100*(2**(1-k.count("")))*(antagonist not in k)*(@getBox(board, coordinates) is "")-(@getBox(board, coordinates) isnt "")
	getEmptyCoordinates: (board) ->
		for x in ["00", "01", "02", "10", "11", "12", "20", "21", "22"]
			if @getBox(board, x) is ""
				x
			else
	getOptimumPlacement: (board, protagonist, antagonist) ->
		j = @getEmptyCoordinates(board)
		results = for c in j
			r = @rankBox(board, c, protagonist, antagonist)
			if r.max isnt -1
				{
					c: c
					max: r.max()
					count: r.count(r.max()),
					r: r
				}
			else
		results.sort (a,b) ->
			if a.max > b.max
				return -1
			if a.max < b.max
				return 1
			if a.max = b.max
				return 0
		best = for n in [0...(results.length)]
			if results[0].max is results[n].max
				results[n]
			else
		best.sort (a,b) ->
			if a.count > b.count
				return -1
			if a.count < b.count
				return 1
			if a.count = b.count
				return 0
		theverybest = for n in [0...(best.length)]
			if best[0].count is best[n].count
				best[n]
			else
		theverybest
	getOptimum: (board, protagonist, antagonist, lvl = 10, some = false) ->
		if some is false or lvl is 10
			bestP = @getOptimumPlacement(board, protagonist, antagonist).random()
			bestA = @getOptimumPlacement(board, antagonist, protagonist).random()
		else
			bestP = @getSomePlacement(board, protagonist, antagonist, lvl).random()
			bestA = @getSomePlacement(board, antagonist, protagonist, lvl).random()
		if bestP.max is 100 or (bestA.max isnt 100 and bestP.max isnt -1)
			return bestP.c
		else if bestA.max is 100
			return bestA.c
		else if bestP.max is -1
			return false
	getSomePlacement: (board, protagonist, antagonist, lvl) ->
		j = @getEmptyCoordinates(board)
		results = for c in j
			r = @rankBox(board, c, protagonist, antagonist)
			if r.max isnt -1
				{
					c: c
					max: r.max()
					count: r.count(r.max()),
					r: r
				}
			else
		results.sort (a,b) ->
			if a.max > b.max
				return -1
			if a.max < b.max
				return 1
			if a.max = b.max
				return 0
		results[0..(9-lvl)]
	isFutile: (board, protagonist, antagonist) ->
		@getOptimumPlacement(board, protagonist, antagonist).random().max is 0 and @getOptimumPlacement(board, antagonist, protagonist).random().max is 0
	checkGame: (board) ->
		status=false
		why = false
		for set in @sets
			if "XXX" is @getBoxes(board, set[0], set[1], set[2]).join("")
				status = "X"
				why = set
			else if "OOO" is @getBoxes(board, set[0], set[1], set[2]).join("")
				status = "O"
				why = set
		if status is false
			if @getEmptyCoordinates(board).length is 0 or @isFutile(board, "X", "O") is true
				status = "D"
			else
				status = "P"
		return {status: status, why: why}