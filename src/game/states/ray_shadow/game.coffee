class Game
    light =
    bitmap =
    lightBitmap =
    rayBitmap =
    rayBitmapImage =
    walls =
    fpsText =
    game = null

    # Load images and sounds
    preload: ->
        game = @game

        game.load.image "block", "assets/images/block.png"
        game.load.image "light", "assets/images/light.png"

        console.log "Hello, world!!!"

    # Create things
    create: ->
        # Set stage background color
        game.stage.backgroundColor = 0x4488cc

        # Add the light
        light = game.add.sprite game.width / 2, game.height / 2, "light"
        light.anchor.setTo 0.5, 0.5

        # Create a bitmap texture for drawing light cones
        bitmap = game.add.bitmapData game.width, game.height
        bitmap.context.fillStyle   = "rgb(255, 255, 255)"
        bitmap.context.strokeStyle = "rgb(255, 255, 255)"
        lightBitmap = game.add.image 0, 0, bitmap

        lightBitmap.blendMode = Phaser.blendModes.MULTIPLY

        rayBitmap = game.add.bitmapData game.width, game.height
        rayBitmapImage = game.add.image 0, 0, rayBitmap
        rayBitmapImage.visible = false

        # Toggle rays on click
        game.input.onTap.add @toggleRays, this

        # Build some walls that will block line of sight
        NUM_WALLS = 4
        walls = game.add.group()

        for i in [0...NUM_WALLS]
            x = i * game.width / NUM_WALLS + 50
            y = game.rnd.integerInRange 50, game.height - 200
            game.add.image(x, y, "block", 0, walls).scale.setTo 3


        # Simulate click in center when game starts running ???
        game.input.activePointer.x = game.width / 2
        game.input.activePointer.y = game.height / 2

        # Show FPS
        game.time.advancedTiming = true
        # Ugly code :(
        fpsText = game.add.text(
            20, 20, "0 fps",
            font: "16px Arial"
            fill: "#ffffff"
        )

    # Called every frame
    update: ->
        # Update FPS counter
        if game.time.fps isnt 0
            fpsText.setText game.time.fps + " fps"

        light.x = game.input.activePointer.x
        light.y = game.input.activePointer.y

        bitmap.context.fillStyle = "rgb(100, 100, 100)"
        bitmap.context.fillRect 0, 0, game.width, game.height

        stageCorners = [
            new Phaser.Point 0, 0
            new Phaser.Point game.width, 0
            new Phaser.Point game.width, game.height
            new Phaser.Point 0, game.height
        ]

        # Ray casting!
        points = []
        ray = null
        intersect = null

        walls.forEach ((wall) ->
            corners = [
                new Phaser.Point wall.x + 0.1, wall.y + 0.1
                new Phaser.Point wall.x - 0.1, wall.y - 0.1
                new Phaser.Point wall.x - 0.1 + wall.width, wall.y + 0.1
                new Phaser.Point wall.x + 0.1 + wall.width, wall.y - 0.1
                new Phaser.Point wall.x - 0.1 + wall.width, wall.y - 0.1 + wall.height
                new Phaser.Point wall.x + 0.1 + wall.width, wall.y + 0.1 + wall.height
                new Phaser.Point wall.x + 0.1, wall.y - 0.1 + wall.height
                new Phaser.Point wall.x - 0.1, wall.y + 0.1 + wall.height
            ]

            for i in [0...corners.length]
                c = corners[i]

                # Don't to math, kids.
                slope = (c.y - light.y) / (c.x - light.x)
                b = light.y - slope * light.x

                end = null

                if c.x == light.x
                    if c.y <= light.y
                        end = new Phaser.Point light.x, 0
                    else
                        end = new Phaser.Point light.x, game.height

                else if c.y == light.y
                    if c.x <= light.x
                        end = new Phaser.Point 0, light.y
                    else
                        end = new Phaser.Point game.width, light.y

                else
                    left = new Phaser.Point 0, b
                    right = new Phaser.Point game.width, slope * game.width + b
                    top = new Phaser.Point -b / slope, 0
                    bottom = new Phaser.Point (game.height - b) / slope, game.height

                    if c.y <= light.y and c.x >= light.x
                        if top.x >= 0 and top.x <= game.width
                            end = top
                        else
                            end = right

                    else if c.y <= light.y and c.x <= light.x
                        if top.x >= 0 and top.x <= game.width
                            end = top
                        else
                            end = left

                    else if c.y >= light.y and c.x >= light.x
                        if bottom.x >= 0 and bottom.x <= game.width
                            end = bottom
                        else
                            end = right

                    else if c.y >= light.y and c.x <= light.x
                        if bottom.x >= 0 and bottom.x <= game.width
                            end = bottom
                        else
                            end = left

                ray = new Phaser.Line light.x, light.y, end.x, end.y

                intersect = @getWallIntersection ray

                if intersect
                    points.push intersect
                else
                    points.push ray.end
        ), this

        for i in [0...stageCorners.length]
            ray = new Phaser.Line light.x, light.y, stageCorners[i].x, stageCorners[i].y
            intersect = @getWallIntersection ray

            if not intersect
                points.push stageCorners[i]

        center =
            x: light.x
            y: light.y

        points = points.sort (a, b) ->
            if a.x - center.x >= 0 and b.x - center.x < 0
                return 1

            if a.x - center.x < 0 and b.x - center.x >= 0
                return -1

            if a.x - center.x == 0 and b.x - center.x == 0
                if a.y - center.y >= 0 or b.y - center.y >= 0
                    return 1

                return -1

            det = (a.x - center.x) * (b.y - center.y) - (b.x - center.x) * (a.y - center.y)

            if det < 0
                return 1
            if det > 0
                return -1

            d1 = (a.x - center.x) * (a.x - center.x) + (a.y - center.y) * (a.y - center.y)
            d2 = (b.x - center.x) * (b.x - center.x) + (b.y - center.y) * (b.y - center.y)

            return 1

        bitmap.context.beginPath()
        bitmap.context.fillStyle = "rgb(255, 255, 255)"
        bitmap.context.moveTo points[0].x, points[0].y

        for j in [0...points.length]
            bitmap.context.lineTo points[j].x, points[j].y

        bitmap.context.closePath()
        bitmap.context.fill()

        rayBitmap.context.clearRect 0, 0, game.width, game.height
        rayBitmap.context.beginPath()
        rayBitmap.context.fillStyle = "rgb(255, 255, 255)"
        rayBitmap.context.strokeStyle = "rgb(255, 255, 255)"
        rayBitmap.context.moveTo points[0].x, points[0].y

        for k in [0...points.length]
            rayBitmap.context.moveTo light.x, light.y
            rayBitmap.context.lineTo points[k].x, points[k].y
            rayBitmap.context.fillRect points[k].x - 2, points[k].y - 2, 4, 4

        rayBitmap.context.stroke()

        bitmap.dirty = true
        rayBitmap.dirty = true

    toggleRays: ->
        rayBitmapImage.visible = not rayBitmapImage.visible

    # Given a ray, this function iterates through all of the walls and
    # returns the closest wall intersection from the start of the ray
    # or null if the ray does not intersect any walls.
    getWallIntersection: (ray) ->
        distanceToWall = Number.POSITIVE_INFINITY
        closestIntersection = null

        walls.forEach ((wall) ->
            # Create array of lines representing the four edges of each wall
            lines = [
                new Phaser.Line wall.x, wall.y, wall.x + wall.width, wall.y
                new Phaser.Line wall.x, wall.y, wall.x, wall.y + wall.height
                new Phaser.Line wall.x + wall.width, wall.y, wall.x + wall.width, wall.y + wall.height
                new Phaser.Line wall.x, wall.y + wall.height, wall.x + wall.width, wall.y + wall.height
            ]

            for i in [0...lines.length]
                intersect = Phaser.Line.intersects ray, lines[i]
                if intersect
                    distance = game.math.distance ray.start.x, ray.start.y, intersect.x, intersect.y

                    if distance < distanceToWall
                        distanceToWall = distance
                        closestIntersection = intersect
        ), this

        return closestIntersection

module.exports = Game
