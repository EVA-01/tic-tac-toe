game = 
	getBoardValues: () ->
		return [
			[$("#game-box-00").data("content"),$("#game-box-10").data("content"),$("#game-box-20").data("content")]
			[$("#game-box-01").data("content"),$("#game-box-11").data("content"),$("#game-box-21").data("content")]
			[$("#game-box-02").data("content"),$("#game-box-12").data("content"),$("#game-box-22").data("content")]
		]
	clearBoard: () ->
		$("#game td").each () ->
			$(this).data("content", "").html("&nbsp;").addClass("empty")
			return
		return
	makeMove: (where, value, prefix = true) ->
		w = if prefix is true then "#game-box-#{where}" else where
		$(w).data("content", value).html(if value is "" then "&nbsp;" else value)
		$(w).addClass("empty") if value is ""
		$(w).removeClass("empty") if value isnt ""
		@nextRound()
		return
	ai: (protagonist, antagonist) ->
		lvl = if game[protagonist.toLowerCase()] is "Player One" then @player1Level else @player2Level
		move=TicTacToeAI.getOptimum(@getBoardValues(), protagonist, antagonist, lvl, true)
		@makeMove(move, protagonist) if move isnt false
		return
	human: (protagonist) ->
		$("#game").addClass("selecting")
		return
	player1: true
	player2: false
	player1Level: 9
	player2Level: 9
	turn: false
	bench: false
	x: false
	o: false
	getMark: (who) ->
		if @x is who then "X" else "O"
	isComputer: (p) ->
		if p is "Player One" then (not @player1) else (not @player2)
	displayMessage: (msg, top = true) ->
		where = if top is true then "#content-top" else "#content-bottom"
		if msg isnt ""
			if $("#{where} span").length isnt 0
				$("#{where} span").stop(true, true).fadeOut () ->
					$(where).html("<span style='display:none'>#{msg}</span>")
					$("#{where} span").fadeIn()
					return
			else
				$(where).html("<span style='display:none'>#{msg}</span>")
				$("#{where} span").fadeIn()
		else
			if $("#{where} span").length isnt 0
				$("#{where} span").stop(true, true).fadeOut () ->
					$(this).remove()
					return
		return
	nextRound: () ->
		status = TicTacToeAI.checkGame(@getBoardValues())
		switch status.status
			when "P"
				@select()
			when "D"
				@draw()
			when "X", "O"
				@winner(status)
		return
	draw: () ->
		$("#game").removeClass("selecting")
		@displayMessage("Draw")
		@displayMessage("<button>New game</button>", false)
		return
	winner: (status) ->
		$("#game").removeClass("selecting")
		who = this[status.status.toLowerCase()]
		for box in status.why
			$("#game-box-#{box}").addClass("won")
		@displayMessage(who+" Won")
		@displayMessage("<button>New game</button>", false)
	select: (s = true) ->
		[@turn, @bench] = [@bench, @turn] if s is true
		@displayMessage(@turn)
		if @isComputer(@turn)
			$("#game").removeClass("selecting")
			@ai(@getMark(@turn), @getMark(@bench))
		if not @isComputer(@turn)
			@human(@getMark(@turn))
		return
	init: () ->
		@player1Level = parseInt($("#one-range-container input").val())
		@player2Level = parseInt($("#two-range-container input").val())
		$("#player-slide").slideUp () ->
			$("#game-slide").slideDown () ->
				game.turn = ["Player One", "Player Two"].random()
				game.bench = if game.turn is "Player One" then "Player Two" else "Player One"
				game.x = game.turn
				game.o = game.bench
				game.select(false)
				return
			return
		return
	startOver: () ->
		@displayMessage("")
		@displayMessage("", false)
		@clearBoard()
		$("#game td.won").removeClass("won")
		$("#game-slide").slideUp () ->
			$("#player-slide").slideDown()
			return
		return
$(document).ready ()->
	$("#player-slide li").click () ->
		id=$(this).attr('id')
		switch id
			when "one-computer"
				game.player1=false
				$("#one-range-container").slideDown()
			when "one-human"
				game.player1=true
				$("#one-range-container").slideUp()
			when "two-computer"
				game.player2=false
				$("#two-range-container").slideDown()
			when "two-human"
				game.player2=true
				$("#two-range-container").slideUp()
		$(this).parents("ul").find(".active").removeClass("active")
		$(this).addClass("active")
		return
	$("#player-slide button").click () ->
		game.init()
		return
	$(document).on("click", "#content-bottom button",  () ->
		game.startOver()
		return
	)
	$(document).on("click", "#game.selecting .empty", () ->
		game.makeMove("#"+$(this).attr("id"), game.getMark(game.turn), false)
		return
	)
	return