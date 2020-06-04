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
-- main.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26th March 2014
-- Version 6.0
-- Requires Corona 2014.2189 - Tested on
------------------------------------------------------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard 		= require "storyboard"
local physics 			= require( "physics" )

--New for Version 6
local loadsave 			= require("loadsave") -- Require our external Load/Save module
local myGlobalData 		= require( "globalData" )

_G.sprite = require "sprite"							-- Add SPRITE API for Graphics 1.0

_G._w 					= display.contentWidth  		-- Get the devices Width
_G._h 					= display.contentHeight 		-- Get the devices Height
_G.gameScore			= 0								-- The Users score
--_G.highScore			= 0								-- Saved HighScore value
_G.sfxVolume			= 0.7							-- Default SFX Volume
_G.musicVolume			= 0.7							-- Default Music Volume
_G.imagePath			= "assets/images/"
_G.audioPath			= "assets/audio/"
_G.level				= 1								-- Global Level Select, Clean, Load, etc...
_G.doDebugPhysics		= true


_G.saveDataTable		= {}							-- Define the Save/Load base Table to hold our data
-- Load in the saved data to our game table
-- check the files exists before !
if loadsave.fileExists("dba_rotRun_template_data.json", system.DocumentsDirectory) then
	saveDataTable = loadsave.loadTable("dba_rotRun_template_data.json")
else
	saveDataTable.highScore 			= 0
	-- Save the NEW json file, for referencing later..
	loadsave.saveTable(saveDataTable, "dba_rotRun_template_data.json")
end

--Now load in the Data
saveDataTable = loadsave.loadTable("dba_rotRun_template_data.json")

myGlobalData.highScore = saveDataTable.highScore		-- Saved HighScore value






-- Enable debug by setting to [true] to see FPS and Memory usage.
local doDebug 			= false


-- Debug Data
if (doDebug) then
	local fps = require("fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = display.contentWidth/2,  270;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


--Set the Music Volume
audio.setVolume( musicVolume, 	{ channel=1 } ) -- set the volume on channel 1
audio.setVolume( sfxVolume, 	{ channel=2 } ) -- set the volume on channel 2
audio.setVolume( sfxVolume, 	{ channel=3 } ) -- set the volume on channel 3
audio.setVolume( sfxVolume, 	{ channel=4 } ) -- set the volume on channel 4

--Pre load some audio
audioMyMusic  = audio.loadSound( audioPath.."myMusic.mp3" )
audioMySFX1  = audio.loadSound( audioPath.."mySFX1.mp3" )
audioMySFX2  = audio.loadSound( audioPath.."mySFX2.mp3" )
audioMySFX3  = audio.loadSound( audioPath.."mySFX3.mp3" )

function startGame()
	image:removeSelf()
	image=nil
	storyboard.gotoScene( "startScreen")	--This is our start screen
end



------------------------------------------------------------------------------------------------------------------------------------
-- Preload SpriteSheets
------------------------------------------------------------------------------------------------------------------------------------
sheetInfo = require("spriteSheet")
imageSheet = graphics.newImageSheet( imagePath.."spriteSheet.png", sheetInfo:getSheet() )

image = display.newImageRect( "Default.png",_w,_h )
image.x = display.contentWidth/2
image.y = display.contentHeight/2

--Start Game after a short delay.
timer.performWithDelay(10, startGame ) -- Change the DELAY time (in milliseconds).
