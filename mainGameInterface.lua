------------------------------------------------------------------------------------------------------------------------------------
-- Rotation Runner Template
------------------------------------------------------------------------------------------------------------------------------------
-- Developed by Deep Blue Apps.com [http//:www.deepbueapps.com]
------------------------------------------------------------------------------------------------------------------------------------
-- Abstract: Jump onto the platforms as they rotate around the screen, see how long
-- You can keep going. Jump onto the platforms or Double Jump to try and stay alive.
-- The longer you keep going the higher your score. Each of the platforms are dynamically resized
-- as they arc around the game area, you never know what size platforms your going to get.
------------------------------------------------------------------------------------------------------------------------------------
--
-- mainGameInterface.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26th March 2014
-- Version 6.0
-- Requires Corona 2014.2189 - Tested on
------------------------------------------------------------------------------------------------------------------------------------

-- Collect relevant external libraries
local storyboard 	= require( "storyboard" )

--New for Version 6
local loadsave 			= require("loadsave") -- Require our external Load/Save module
local myGlobalData 		= require( "globalData" )
local tempHighScore = 0
tempHighScore = myGlobalData.highScore --set the Current Highscore to a temp Variable


local scene 		= storyboard.newScene()

local gameOverBool				= false
local debugON           		= false
local heroOnPlatform			= false
local heroJumpStatus			= 0		-- 0 = on Ground, 1 = in-air, 2 = double jump

local platformsArray			= {}
local testBlock 				= nil
local centreRotation 			= nil

local rotationSpeed			= 0.3
local rotationSpeedIncrement	= 0.01
local secondsPassed			= 0

local gameTime				= 0
local gameScore				= 0

local platformsMinWidth		= 200	-- Smaller blocks HARDER !!
local platformsMaxWidth		= 800
local platformsMinY			= 530
local platformsMaxY			= 650

local jumpUpForce				= -50	-- Higher Negative number to jump higher
local jumpDownForce				= 70	-- Higher number to fall down quicker
local doubleJumpUpForce			= -60	-- Higher negative number to jump higher on the double jump
local doubleJumpDownForce		= 70	-- Higher number to push the player down quicker

_W 		= display.contentWidth/2
_H 		= display.contentHeight/2
_MH  	= display.contentHeight

-- Initiate the Game Groups
local game 				= display.newGroup();
local platformGroup		= display.newGroup();
local gameOverGroup		= display.newGroup();

game.x = 0

local solidPlatforms 				= false			-- set to true to use SOLID flat colour platforms, otherwise use False - then assign an image for the platforms..
local platformImage				= "wall"		-- Set to [Wall] or [Grass] or Add your own image
local platformImageType			= "jpg"			-- set the file extension type for the platform image used
local platformImageWidth			= 800
local platformImageHeight			= 800
local gameTimerInfo				= 0
local viewTimer					= nil

local incrementedNum = 0;
local markTime = system.getTimer();


-----------------------------------------------------------------
-- Setup the Physics World
-----------------------------------------------------------------
physics.start()
physics.setScale( 90 )
physics.setGravity( 0, 0 )
physics.setPositionIterations(200)

-- un-comment to see the Physics world over the top of the Sprites
--physics.setDrawMode( "hybrid" )

----------------------------------------------------------------------------------------------------
-- Extra cleanup routines
----------------------------------------------------------------------------------------------------
local coronaMetaTable = getmetatable(display.getCurrentStage())
	isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroups ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
		if objectOrGroup.numChildren then
			-- we have a group, so first clean that out
			while objectOrGroup.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				cleanGroups ( objectOrGroup[objectOrGroup.numChildren])
			end
		end
			objectOrGroup:removeSelf()
    return
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
		
		audio.setVolume( musicVolume )
		
		-----------------------------------------------------------------
		-- Setup our Physics collision data.
		-- This data was generated using the FREE DBA  Collision Editor:
		-- http://http://www.deepblueapps.com/dba-collision-editor-2/
		-----------------------------------------------------------------
		heroFilterData = { categoryBits = 1, maskBits = 6 }
		wallsFilterData = { categoryBits = 2, maskBits = 1 }
		blocksFilterData = { categoryBits = 4, maskBits = 1 }
		--changerFilterData = { categoryBits = 8, maskBits = 4 }

		-----------------------------------------------------------------
		-- Setup the various animation sequences
		-----------------------------------------------------------------
		animationSequenceData = {
		  { name = "heroFail",  frames={ 1 }, time=250, loopCount=1 },
		  { name = "heroRun", frames={ 5,6,7 }, time=300 },
		  { name = "heroJump", frames={ 2,3,4 }, time=450, loopCount=1 },
		  { name = "scoreSprite", frames={ 8 }, time=250, loopCount=1 },
		  { name = "highScoreSprite", frames={ 9 }, time=250, loopCount=1 }
		}

		-----------------------------------------------------------------
		-- Setup the Background Sky sprite
		-----------------------------------------------------------------
		bgImageSprite = display.newImageRect(imagePath.."bg_circular_001.png",1024,768)
		bgImageSprite.x = _W
		bgImageSprite.y = _H
		game:insert( bgImageSprite )
		bgImageSprite:addEventListener( "touch", Touch)
		
		-----------------------------------------------------------------
		-- Setup the Player
		-----------------------------------------------------------------
		playerCharacter = display.newSprite( imageSheet, animationSequenceData )
		playerCharacter.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		playerCharacter.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		playerCharacter.x = _W
		playerCharacter.y = 400
		playerCharacter.myName = "hero"

		local heroMaterial = { density=10.0, friction=0.5, bounce=0.0, filter=heroFilterData  }
		physics.addBody( playerCharacter, "dynamic", heroMaterial )
		
		playerCharacter.isFixedRotation = true 	-- we don't want our hero to be abe to ROTATE or change angle
		playerCharacter.isBullet = true
		
		playerCharacter:setSequence( "heroRun" )
		playerCharacter:play()
		game:insert( playerCharacter )
		
		---------------------------------------------------------------------------
		-- Add the World Boundries (We'll use these to check for a Game Over)
		---------------------------------------------------------------------------
		function addWall( x, y, angle,  width, height, wallType )
		
			--local wallCollisionFilter = { categoryBits = 2, maskBits = 3 } 
			local wallMaterial = { density=300.0, friction=0.5, bounce=0.3, filter=wallsFilterData }

			worldWall = display.newRect( 0, 0, width, height )
			--worldWall:setReferencePoint(display.TopLeftReferencePoint)
			worldWall.anchorX = 0.0		-- Graphics 2.0 Anchoring method
			worldWall.anchorY = 0.0		-- Graphics 2.0 Anchoring method
			worldWall.x = x
			worldWall.y = y
			worldWall.rotation = angle
			worldWall.myName = "wall"
			worldWall.alpha = 0.0
			physics.addBody( worldWall, "static", wallMaterial )
			game:insert( worldWall )
		end
	
		addWall(0,0,0,20,display.contentHeight,"Die")						--Left
		addWall(display.contentWidth-20,0,0,20,display.contentHeight,"Die")	--Right
		addWall(0,0,0,display.contentWidth,20,"Die")  						--Top
		addWall(0,display.contentHeight-2,0,display.contentWidth,20,"Die")	--Bottom

		
		-----------------------------------------------------------------
		-- This object will act as our trigger to change the SIZE of the  platforms!
		-----------------------------------------------------------------
		local changerMaterial = { density=300.0, friction=0.5, bounce=0.3 }
		blockChanger = display.newRect( 0, 0, 40,40 )
		blockChanger.x = -600
		blockChanger.y = 100
		blockChanger.myName = "changer"
		blockChanger.alpha = 0.0
		physics.addBody( blockChanger, "dynamic", changerMaterial )
		blockChanger.isFixedRotation = false
		game:insert( blockChanger )


		-----------------------------------------------------------------
		-- Create the central rotation object - we'll use the rotation
		-- of this object as the theta rotation marker for the platforms.
		-----------------------------------------------------------------
		centreRotation = display.newRect(0, 0, 100,100)
		centreRotation:setFillColor(1,1,1)
		centreRotation.alpha = 0.0
		centreRotation.x = display.contentWidth/2
		centreRotation.y = display.contentHeight/2
		game:insert( centreRotation )

		-----------------------------------------------------------------
		-- Generate our 8 platforms. We'll spawn them into a table to manage
		-----------------------------------------------------------------
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=800, height=580, startX=0, startY=100, offsetAngle=80, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=800, height=400, startX=772, startY=119, offsetAngle=35, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=845, height=500, startX=866, startY=293, offsetAngle=-10, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=845, height=300, startX=866, startY=293, offsetAngle=305, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=845, height=600, startX=866, startY=293, offsetAngle=260, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=800, height=290, startX=772, startY=119, offsetAngle=215, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=845, height=500, startX=866, startY=293, offsetAngle=170, offsetRandom=600})
		local spawns = createPlatform({objTable=platformsArray, group=platformGroup, width=845, height=500, startX=866, startY=293, offsetAngle=125, offsetRandom=600})
		game:insert( platformGroup )


		-----------------------------------------------------------------
		-- Score and HighScore
		-----------------------------------------------------------------
		localScore = display.newSprite( imageSheet, animationSequenceData )
		localScore.x = 79
		localScore.y = 42		
		localScore:setSequence( "scoreSprite" )
		localScore:play()
		game:insert( localScore )

		myScoreText = display.newText(gameScore,0,0, "HelveticaNeue-CondensedBlack", 38)
		--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		myScoreText:setFillColor(1,1,1)
		myScoreText.x = 165
		myScoreText.y = 40
		myScoreText.alpha = 1
		game:insert(myScoreText)

		localHighScore = display.newSprite( imageSheet, animationSequenceData )
		localHighScore.anchorX = 0.5		-- Graphics 2.0 Anchoring method
		localHighScore.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		localHighScore.x = 782
		localHighScore.y = 42		
		localHighScore:setSequence( "highScoreSprite" )
		localHighScore:play()
		game:insert( localHighScore )
		
		myHighScoreText = display.newText(tempHighScore,0,0, "HelveticaNeue-CondensedBlack", 38)
		--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myHighScoreText:setFillColor(1,1,1)
		myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		myHighScoreText.x = 867
		myHighScoreText.y = 40
		myHighScoreText.alpha = 1
		game:insert(myHighScoreText)

		-----------------------------------------------------------------
		-- GameOver Group
		-----------------------------------------------------------------
		gameOverSprite = display.newImageRect(imagePath.."obj_gameover1.png",714,270)
		gameOverSprite.x = _w/2
		gameOverSprite.y = _h*2
		gameOverSprite.xScale = 0.5
		gameOverSprite.yScale = 0.5
		
		gameOverGroup:insert( gameOverSprite )
		game:insert(gameOverGroup)

		screenGroup:insert( game )
		
		-----------------------------------------------------------------
		-- Speed increaser function, gets called every 1 second.
		-----------------------------------------------------------------
		local function speedIncreaser()
			if (gameOverBool==false) then
				secondsPassed = secondsPassed + 1
				rotationSpeed = rotationSpeed + rotationSpeedIncrement
			
				--Update Score
				myScoreText.text = secondsPassed
				gameScore = secondsPassed
				--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
				myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
				myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
				myScoreText.x = 165; myScoreText.y = 40
			
				--Update HighScore
				if (secondsPassed > tempHighScore) then
					tempHighScore = secondsPassed
					myHighScoreText.text = tempHighScore
					--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint)
					myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
					myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
					myHighScoreText.x = 867; myHighScoreText.y = 40
				end
			else
				rotationSpeed = 0
			end
		end
		
		--Update BG Score effect timer
		local function bgTimeEffectUpdate()
			if (gameOverBool==false) then
			
			incrementedNum = system.getTimer() - markTime;
        
				bgTimerText.text = incrementedNum/100
				--bgTimerText:setReferencePoint(display.CenterLeftReferencePoint)
				bgTimerText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
				bgTimerText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
				bgTimerText.x = (display.contentWidth/2)-200
				bgTimerText.y = display.contentHeight/2
			end
		end
		
		-----------------------------------------------------------------
		-- BG timer effect
		-----------------------------------------------------------------
		--bgTimerText = display.newText(gameTimerInfo,0,0, "HelveticaNeue-CondensedBlack", 100)
		--bgTimerText:setReferencePoint(display.CenterLeftReferencePoint)
		--bgTimerText:setTextColor(255,255,255)
		--bgTimerText.x = (display.contentWidth/2)-200
		--bgTimerText.y = display.contentHeight/2
		--bgTimerText.alpha = 0.4
		--game:insert(bgTimerText)

		-----------------------------------------------------------------
		-- This timer triggers the Scores update and the speed of the blocks rotating..
		-----------------------------------------------------------------
		heroJumpStatus = 0
		rotateTheBlocksTimer = timer.performWithDelay(1000,speedIncreaser,0)
		
		--rotateTheInfoTimer = timer.performWithDelay(1,bgTimeEffectUpdate,-1)

		-----------------------------------------------------------------
		-- Start the BG Music - Looping
		-----------------------------------------------------------------
		--Reserve Channels 1, 2, 3 for Specific audio
		audio.reserveChannels( 4 )
		
		audio.stop(1)
		audio.play(audioMyMusic, {channel=1,loops = -1})


end

----------------------------------------------------------------------------------------------------
-- Touch Jump
----------------------------------------------------------------------------------------------------
function Touch(event)
	if(event.phase == "began" and gameOverBool == false) then

		print("TOUCH +++")
		
		--Play Jump Audio
		audio.play(audioMySFX1, {channel=2})
		
		-----------------------------------------------------------------
		-- If JUMP status is on 0 - then goto the SINGLE JUMP routine.
		-----------------------------------------------------------------
		if (heroJumpStatus == 0) then
			playerCharacter:setSequence( "heroJump" )
			playerCharacter:play()
			
			heroJumpStatus = 1
			heroOnPlatform = false

			-- Apply an Impulse to make our hero Jump
			-- After 0.3 seconds = push him back down again and reset the animation state
			playerCharacter:applyLinearImpulse(0, jumpUpForce, playerCharacter.x, playerCharacter.y)
			timer.performWithDelay(300,function() playerCharacter:applyLinearImpulse(0, jumpDownForce, playerCharacter.x, playerCharacter.y); playerCharacter:setSequence( "heroRun" ); playerCharacter:play(); end)
				
		-----------------------------------------------------------------
		-- If JUMP status is on 1 - then goto the DOUBLE JUMP routine.
		-----------------------------------------------------------------
		elseif(heroJumpStatus == 1) then
			playerCharacter:setSequence( "heroJump" )
			playerCharacter:play()
			heroJumpStatus = 2
			heroOnPlatform = false
			
			-- Apply a second Impulse to make our hero Double Jump (NOTE: The extra impulse values - change these to suit your needs)
			-- After 0.3 seconds = push him back down again and reset the animation state
			playerCharacter:applyLinearImpulse(0, doubleJumpUpForce, playerCharacter.x, playerCharacter.y)
			timer.performWithDelay(300,function() playerCharacter:applyLinearImpulse(0, doubleJumpDownForce, playerCharacter.x, playerCharacter.y); playerCharacter:setSequence( "heroRun" ); playerCharacter:play();  end)

		else

		end
		
		
	elseif(event.phase == "ended") then

  	end
end


-----------------------------------------------------------------
-- Function to spawn our Platforms
-----------------------------------------------------------------
function createPlatform(params)
    
    --Prepare a holder for our Platforms
    local object = nil
    
    --Determine if we are using SOLID platforms or an image?
    if (solidPlatforms == true) then
    	object = display.newRect(0, 0, params.width, params.height)
		object:setFillColor(0,0,0)		-- Set the Colour (Red, Green, Blue)
    else
    	object = display.newImageRect(imagePath..platformImage.."."..platformImageType,platformImageWidth,platformImageHeight) -- use your OWN images or test between [grass.jpg] and [wall.jpg]
    end
    	
	object.alpha = 1
	object.x = params.startX
	object.y = params.startY
	object.angleOffset = params.offsetAngle
	object.randomOffset = params.offsetRandom
		
	local platformMaterial = { density=500.0, friction=0.0, bounce=0.0, filter=blocksFilterData }
	physics.addBody( object, "static", platformMaterial )
	object.isBullet = true
	
	object.group = params.group or nil
	object.group:insert(object)		--Insert our Spawned sprite into the correct group

    object.objTable = params.objTable				--Set the objects table to a table passed in by parameters
    object.index = #object.objTable + 1				--Automatically set the table index to be inserted into the next available table index
	
	object.myRef = "platform_" .. object.index	--Give the object a custom name
	object.myName = "platform"
	object.myState = "alive"
	object.replace = false

    object.objTable[object.index] = object			--Insert the object into the table at the specified index
    
    return object
end



function gameOverFunctionEnd()
	-- Clean up
	Runtime:removeEventListener ( "enterFrame", rotateBlocks )
	Runtime:removeEventListener ( "collision", onGlobalCollision )
	bgImageSprite:removeEventListener ( "touch", Touch)
	cleanGroups(game)
	
	storyboard.gotoScene( "startScreen")	--restart game
end 




local function gameOverFunctionStart()
	--Play Jump Audio
	audio.play(audioMySFX2, {channel=3})

	gameOverBool = true
	timer.cancel(rotateTheBlocksTimer)
	transition.to(playerCharacter, {x = _w/2, y = ((_h/2)-150), rotation=360, xScale=3.1, yScale=3.1,alpha=0.0, time = 2000} )

	gameOverSprite.y = _h/2
	gameOverSprite.xScale = 1
	gameOverSprite.yScale = 1
	transition.to(gameOverSprite, {rotation=360, time = 1800} ) 

	--NEW VERSION 6.0 - Save HighScore
	--Save new HIGHSCORE if the current score is greater than previous.
	print("SCORE: "..gameScore)
	print("HIGH SCORE: "..myGlobalData.highScore)
	
	if (gameScore > myGlobalData.highScore) then
		print("----SAVING NEW HIGHSCORE----")
		myGlobalData.highScore = gameScore
		saveDataTable.highScore = myGlobalData.highScore
		-- Save the json file.
		loadsave.saveTable(saveDataTable, "dba_rotRun_template_data.json")
	end


	
	timer.performWithDelay(2800,gameOverFunctionEnd)

end 




-----------------------------------------------------------------
-- Our collision routines - checking whats hit what...
-----------------------------------------------------------------
function onGlobalCollision( event )

		--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision began" )

		if ( event.phase == "began" and gameOverBool==false) then
	
			-- Platforms hit the CHANGER object
			if (event.object1.myName == "changer" and event.object2.myName == "platform") then
				print (event.object2.index)
				event.object2.replace = true
			end
			
			-- hero hit the platforms
			if (event.object1.myName == "hero" and event.object2.myName == "platform") then
				heroOnPlatform = true
				heroJumpStatus = 0
				
				--Play Jump Audio
				audio.stop(4)
				audio.play(audioMySFX3, {channel=4})
			
			end
			
			-- hero hit the walls = DIE!
			if (event.object1.myName == "hero" and event.object2.myName == "wall") then
				gameOverBool=true
				timer.performWithDelay(50,gameOverFunctionStart)
			end
		
		
		elseif ( event.phase == "ended"  and gameOverBool==false) then
	
			--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision ENDED" )
			
			if (event.object1.myName == "changer" and event.object2.myName == "platform" and event.object2.myState == "alive") then
				
				-- We change the state of the physics shape, so this block of code is not called again...
				event.object2.myState = "readyToChange"
				
				-- Capture the platforms OLD/Current Angle
				local oldOffset = event.object2.angleOffset
								
				-- Define the platforms physics attributes
				local platformMaterial = { density=500.0, friction=0.5, bounce=0.0, filter=blocksFilterData }
				
				local function removeOldBody()
				    if ( event.object2 ) then
						physics.removeBody(event.object2)
					end
				end
				
				-- Remove the OLD physics body
				timer.performWithDelay(5,removeOldBody)
				
				-- adjust the target platforms WIDTH and POSITION
				
				--Instant size/position change - may cause stutter?
				--timer.performWithDelay(50,function() event.object2.height=(math.random(platformsMinWidth,platformsMaxWidth)); event.object2.randomOffset=(math.random(platformsMinY,platformsMaxY)); end)
				
				--Quick transition of new Size/Position - smooths out the stutter
				timer.performWithDelay(50,function() transition.to(event.object2, {height=(math.random(platformsMinWidth,platformsMaxWidth)),randomOffset=(math.random(platformsMinY,platformsMaxY)), time = 300} ); end)


				-- Attach a NEW physics body
				timer.performWithDelay(400,function() physics.addBody( event.object2, "static", platformMaterial ); end)
			end

			if (event.object1.myName == "hero" and event.object2.myName == "platform") then

			end


		end
end



---------------------------------------------------------------------------------
-- Rotate the platforms, and control the rotation speeds.
-- This routine is updated and checked every game Tick
---------------------------------------------------------------------------------
function rotateBlocks()

	if ( gameOverBool==false) then

		-- update the centre rotation object - all the other platforms follow this object for angle and speed.
		centreRotation.rotation = centreRotation.rotation + rotationSpeed	-- The variable [rotationSpeed] gets incremented every second.
		if (centreRotation.rotation == 360 ) then
			centreRotation.rotation = 0
		end
	
		-- Rotate the platforms in the array. Using Cos & Sin to achieve an ELLIPTICAL rotation.
		for i = 1, #platformsArray do -- Iterate through the platforms Table
			local randomDistance	= platformsArray[i].randomOffset
			local theta = (math.pi * (centreRotation.rotation+(platformsArray[i].angleOffset))) / 180
			platformsArray[i].x = centreRotation.x + (randomDistance+700)*(math.cos(theta))
			platformsArray[i].y = centreRotation.y + (randomDistance+100)*(math.sin(theta))
			platformsArray[i].rotation = centreRotation.rotation + platformsArray[i].angleOffset
		end
		
		-- Force our hero DOWN, if no jump buttons pressed
		if (heroJumpStatus == 0) then
			playerCharacter:applyLinearImpulse(0, 10, playerCharacter.x, playerCharacter.y)
		end
		
		-- Constrain our hero to the CENTRE X position of the screen - no matter what!
		playerCharacter.x = _W

		-- Behind the scenes theres an object triggering the Platforms to update their shape n size.
		-- We need this object to maintain it's position.
		blockChanger.x = -600
		blockChanger.y = 100
		blockChanger.isFixedRotation = false

	end
	
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	-- remove previous scene's view
	storyboard.purgeScene( "main" )
	storyboard.removeScene( "startScreen" )

end
		
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
--	print( "((destroying scene 1's view))" )
end


---------------------------------------------------------------------------------
-- END OF SCENE IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------
Runtime:addEventListener ( "enterFrame", rotateBlocks )
Runtime:addEventListener ( "collision", onGlobalCollision )

return scene