util = require "../util"

class Game
    isoGroup =
    cursors =
    cursorPos =
    player =
    game = null

    # Load images and sounds
    preload: ->
        game = @game

        game.load.image "tile", "assets/images/water.png"
        game.load.image "cube", "assets/images/cube.png"

        game.time.advancedTiming = true

        game.plugins.add new Phaser.Plugin.Isometric game

        #game.world.setBounds 0, 0, 2048, 2048
        game.physics.startSystem Phaser.Plugin.Isometric.ISOARCADE

        game.iso.anchor.setTo 0.5, 0 #0.2

        console.log "Hello, world!!!"

    create: ->
        game.stage.backgroundColor = 0xbada55

        isoGroup = game.add.group()

        game.physics.isoArcade.gravity.setTo 0, 0, -500

        cube = null

        # It works I guess..
        ###for x in [1024...0] by -140
            for y in [1024...0] by -140
                cube = game.add.isoSprite x, y, 0, "tile", 0, isoGroup
                cube.anchor.set 0.5, 0.2
                cube.tint = util.randomHex()

                game.physics.isoArcade.enable cube
                cube.body.collideWorldBounds = yes
                cube.body.bounce.set 1, 1, 0.2
                cube.body.drag.set 100, 100, 0###

        cube = game.add.isoSprite 128 * 2, 128 * 2, 0, "tile", 0, isoGroup
        cube.anchor.set 0.5, 0
        cube.tint = util.randomHex()

        #game.physics.isoArcade.enable cube
        #cube.body.collideWorldBounds = yes
        #cube.body.bounce.set 1, 1, 0.2
        #cube.body.drag.set 100, 100, 0

        player = game.add.isoSprite 128, 128, 0, "cube", 0
        player.tint = util.randomHex()
        player.anchor.set 0.5
        game.physics.isoArcade.enable player
        player.body.collideWorldBounds = yes

        cursorPos = new Phaser.Plugin.Isometric.Point3()
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

        #game.camera.follow player

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

        game.physics.isoArcade.collide isoGroup
        game.iso.topologicalSort isoGroup

        game.iso.unproject game.input.activePointer.position, cursorPos

        isoGroup.forEach (tile) ->
            #console.log "each"
            #tile.isoX = cursorPos.x
            #tile.isoY = cursorPos.y
            inBounds = tile.isoBounds.containsXY cursorPos.x, cursorPos.y
            origTint = tile.tint
            if not tile.selected and inBounds
                tile.selected = yes
                tile.tint = 0xffffff
                console.log "hover"
                game.add.tween(tile).to
                  isoZ: 4
                , 200, Phaser.Easing.Quadratic.InOut, true
            else if tile.selected and not inBounds
                tile.selected = no
                tile.tint = origTint
                game.add.tween(tile).to
                  isoZ: 0
                , 200, Phaser.Easing.Quadratic.InOut, true

    render: ->
        # game.debug.text "Click to toggle! Sorting enabled: #{sorted}", 2, 36, "#ffffff"
        game.debug.text game.time.fps || "--", 2, 14, "#ffffff"

module.exports = Game
