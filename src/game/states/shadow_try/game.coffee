util = require "../util"

class Game
    isoGroup =
    shadowGroup =
    cursors =
    player =
    playerShadow =
    game = null

    # Load images and sounds
    preload: ->
        game = @game

        game.load.image "tile", "assets/images/water.png"
        game.load.image "cube", "assets/images/cube.png"
        game.load.image "cubeShadow", "assets/images/cubeShadow.png"

        game.time.advancedTiming = true

        game.plugins.add new Phaser.Plugin.Isometric game

        game.world.setBounds 0, 0, 2048, 2048
        game.physics.startSystem Phaser.Plugin.Isometric.ISOARCADE

        game.iso.anchor.setTo 0.5, 0 #0.2

        console.log "Hello, world!!!"

    create: ->
        game.stage.backgroundColor = 0xbada55

        isoGroup = game.add.group()
        shadowGroup = game.add.group()

        game.physics.isoArcade.gravity.setTo 0, 0, -500

        cube = null

        # It works I guess..
        for x in [1024...0] by -140
            for y in [1024...0] by -140
                cube = game.add.isoSprite x, y, 0, "cube", 0, isoGroup
                cube.anchor.set 0.5

                game.physics.isoArcade.enable cube
                cube.body.collideWorldBounds = yes
                cube.body.bounce.set 1, 1, 0.2
                cube.body.drag.set 100, 100, 0

        player = game.add.isoSprite 128, 128, 0, "cube", 0, isoGroup
        player.tint = util.randomHex()
        player.anchor.set 0.5
        game.physics.isoArcade.enable player
        player.body.collideWorldBounds = yes

        playerShadow = game.add.isoSprite 128, 128, 20, "cubeShadow", 0, shadowGroup
        playerShadow.tint = "#ffffff"
        playerShadow.anchor.set 0.5, 0.5
        #game.physics.isoArcade.enable playerShadow
        #playerShadow.body.collideWorldBounds = yes

        cursors = game.input.keyboard.createCursorKeys()
        game.input.keyboard.addKeyCapture [
            Phaser.Keyboard.LEFT
            Phaser.Keyboard.RIGHT
            Phaser.Keyboard.UP
            Phaser.Keyboard.DOWN
            Phaser.Keyboard.SPACEBAR
        ]

        space = game.input.keyboard.addKey Phaser.Keyboard.SPACEBAR
        space.onDown.add ->
            player.body.velocity.z = 300
            console.log "jump"

        game.camera.follow player

    update: ->
        speed = 200

        if cursors.up.isDown
            player.body.velocity.y = -speed
        else if cursors.down.isDown
            player.body.velocity.y = speed
        else
            player.body.velocity.y = 0

        if cursors.left.isDown
            player.body.velocity.x = -speed
        else if cursors.right.isDown
            player.body.velocity.x = speed
        else
            player.body.velocity.x = 0

        #playerShadow.position.y = player.position.y
        #playerShadow.isoZ = 100
        #playerShadow.isDirty = yes
        #console.log playerShadow.position

        game.physics.isoArcade.collide isoGroup
        game.iso.topologicalSort isoGroup

        playerShadow.isoX = player.isoX
        playerShadow.isoY = player.isoY
        playerShadow.isoZ = 0
        #game.iso.topologicalSort shadowGroup
        # player.tint = util.randomHex()

    render: ->
        # game.debug.text "Click to toggle! Sorting enabled: #{sorted}", 2, 36, "#ffffff"
        game.debug.text game.time.fps || "--", 2, 14, "#ffffff"

module.exports = Game
