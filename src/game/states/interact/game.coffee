util = require "../../util"

class Game
    isoGroup =
    cursorPos =
    game = null

    preload: ->
        game = @game

        # Load resources
        game.load.image "tile", "assets/images/tile.png"
        game.load.image "cube", "assets/images/cube.png"

        # Advanced timing required to show fps
        game.time.advancedTiming = true

        # Enable Isometric plugin
        game.plugins.add new Phaser.Plugin.Isometric game

        # This is used to set a game canvas-based offset for the 0, 0, 0 isometric coordinate - by default
        # this point would be at screen coordinates 0, 0 (top left) which is usually undesirable.
        game.iso.anchor.set 0.5, 0.2

        # Expand world borders. Required for camera movement
        game.world.setBounds 0, 0, 2048, 2048

    create: ->
        # Give the stage a badass color
        game.stage.backgroundColor = 0xbada55

        # Create a group to hold all tiles
        isoGroup = game.add.group()

        # Spawn all our tiles
        @spawnTiles()

        # Create a 3D position for the cursor
        cursorPos = new Phaser.Plugin.Isometric.Point3()

    update: ->
        activePointer = game.input.activePointer

        # Fix cursor position in isometric world... or something
        # Works for now
        newPoint = Phaser.Point.add(activePointer.position, game.camera.position)
        newPoint.x -= game.width / 2
        newPoint.y -= game.height / 2

        # Update cursor position and shit
        game.iso.unproject newPoint, cursorPos

        # Loop through tiles and check their position with the cursor
        isoGroup.forEach (tile) ->
            #tile.isoX = cursorPos.x
            #tile.isoY = cursorPos.y
            inBounds = tile.isoBounds.containsXY cursorPos.x, cursorPos.y
            # TODO: origTint = tile.tint

            if not tile.selected and inBounds
                tile.selected = yes
                tile.tint = 0x86bfda

                # Slowly move the tile up a bit
                # It's not pretty but it works
                game.add.tween(tile).to
                    isoZ: 8,
                    100, Phaser.Easing.Quintic.Out, true

            else if tile.selected and not inBounds
                tile.selected = no
                tile.tint = 0xffffff

                # Slowly move the tile back down
                game.add.tween(tile).to
                    isoZ: 0,
                    200, Phaser.Easing.Quintic.Out, true

        # Move camera with mouse
        # Should we not put origDragPoint in game object?
        # Annotate
        if activePointer.isDown
            if game.origDragPoint
                game.camera.x += game.origDragPoint.x - activePointer.x
                game.camera.y += game.origDragPoint.y - activePointer.y

            game.origDragPoint = activePointer.position.clone()
        else
            game.origDragPoint = null

    render: ->
        # Render the fps in top left corner
        game.debug.text game.time.fps or "--", 2, 14, "#ffffff"

    # Create all of our tiles
    spawnTiles: ->
        for x in [0...256] by 38
            for y in [0...256] by 38
                tile = game.add.isoSprite x, y, 0, "tile", 0, isoGroup
                tile.anchor.set 0.5, 0

                tile.tint = util.randomHex()
        ###tile = game.add.isoSprite 256, 256, 0, "tile", 0, isoGroup
        tile.anchor.set 0.5, 0.2
        tile.tint = util.randomHex()###

# Export the entire class
module.exports = Game
