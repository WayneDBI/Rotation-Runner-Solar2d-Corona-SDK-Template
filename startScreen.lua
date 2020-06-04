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
-- startScreen.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26th March 2014
-- Version 6.0
-- Requires Corona 2014.2189 - Tested on
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )

local scene = storyboard.newScene()

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

local image

-- level select button function
function levelSelect()
	storyboard.gotoScene( "mainGameInterface", "fade", 400  )
	return true
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	function Touch(event)
		if(event.phase == "began" and gameOverBool == false) then
	
		elseif(event.phase == "ended") then
			levelSelect()
		end
	end
	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	image = display.newImageRect( imagePath.."startScreen.png",1024,768 )
	image.x = _w/2
	image.y = _h/2
	screenGroup:insert( image )
	image:addEventListener( "touch", Touch )
	
	----------------------------------------------------------------------------------------------------
	-- Setup the Highlight bar
	----------------------------------------------------------------------------------------------------
	highlight = display.newImageRect( imagePath.."highlight.png",480,64 )
	highlight.x = _w+200
	highlight.y = _h/2
	highlight.alpha = 1.0
	highlight.rotation = -55
	screenGroup:insert( highlight )
		
	transition.to(highlight, {alpha=0.0,xScale=4.0, yScale=4.0, x=0, time=1800})				-- Swipe the Highlight across the screen	

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.removeScene( "main" )
	storyboard.purgeScene( "mainGameInterface" )
	storyboard.removeScene( "mainGameInterface" )
	storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
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

return scene