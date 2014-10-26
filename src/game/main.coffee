window.onload = ->
    Phaser = require "phaser"
    PhaserIsometric = require "phaser-plugin-isometric"

    game = new Phaser.Game 800, 600, Phaser.AUTO, "phaser-game"



    # Game States
    #game.state.add "game", require "./states/game"
    game.state.add "game", require "./states/interact/game"

    game.state.start "game"
