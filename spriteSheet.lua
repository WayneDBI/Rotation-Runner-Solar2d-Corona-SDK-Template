--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:5a36b96450f6509d32bc43d9fcda4434$
--
-- local sheetInfo = require("myExportedImageSheet") -- lua file that Texture packer published
--
-- local myImageSheet = graphics.newImageSheet( "ImageSheet.png", sheetInfo:getSheet() ) -- ImageSheet.png is the image Texture packer published
--
-- local myImage1 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name1"))
-- local myImage2 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name2"))
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- obj_fall001
            x=168,
            y=4,
            width=66,
            height=68,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_jump001
            x=168,
            y=76,
            width=62,
            height=70,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_jump002
            x=68,
            y=178,
            width=60,
            height=66,

            sourceX = 8,
            sourceY = 2,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_jump003
            x=68,
            y=112,
            width=62,
            height=62,

            sourceX = 6,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_run001
            x=4,
            y=76,
            width=60,
            height=66,

            sourceX = 9,
            sourceY = 2,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_run002
            x=4,
            y=150,
            width=60,
            height=72,

            sourceX = 9,
            sourceY = 0,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_run003
            x=106,
            y=40,
            width=58,
            height=68,

            sourceX = 11,
            sourceY = 4,
            sourceWidth = 72,
            sourceHeight = 72
        },
        {
            -- obj_score
            x=4,
            y=40,
            width=98,
            height=32,

            sourceX = 61,
            sourceY = 0,
            sourceWidth = 160,
            sourceHeight = 32
        },
        {
            -- obj_topscore
            x=4,
            y=4,
            width=160,
            height=32,

        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["obj_fall001"] = 1,
    ["obj_jump001"] = 2,
    ["obj_jump002"] = 3,
    ["obj_jump003"] = 4,
    ["obj_run001"] = 5,
    ["obj_run002"] = 6,
    ["obj_run003"] = 7,
    ["obj_score"] = 8,
    ["obj_topscore"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
