io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest")
api = require("api") --I STILL WANT IT AS A GLOBAL !
local utf8 = require("utf8")

function love.mousepressed(x,y,button,istouch)
	local x,y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_mpress(x,y,button,istouch)
end

function love.mousemoved(x,y,dx,dy,istouch)
	local x, y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_mmove(x,y,dx,dy,istouch)
end

function love.mousereleased(x,y,button,istouch)
  local x, y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_mrelease(x,y,button,istouch)
end

function love.wheelmoved(x,y)
  _auto_mmove(x,y,0,0,false,true) --Mouse button 0 is the wheel
end

function love.touchpressed(id,x,y,dx,dy,pressure)
  local x, y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_tpress(id,x,y,pressure)
end

function love.touchmoved(id,x,y,dx,dy,pressure)
  local x, y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_tmove(id,x,y,pressure)
end

function love.touchreleased(id,x,y,dx,dy,pressure)
  local x, y = _ScreenToLiko(x,y) if x < 0 or x > 192 or y < 0 or y > 128 then return end
  _auto_trelease(id,x,y,pressure)
end

function love.keypressed(key,scancode,isrepeat)
  _auto_kpress(key,scancode,isrepeat)
end

function love.keyreleased(key,scancode)
  _auto_krelease(key,scancode)
end

function love.textinput(text)
  local text_escaped = text:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
  if #text == 1 and _FontChars:find(text_escaped) then
    _auto_tinput(text)
  end
end

--Internal Callbacks--
function love.load()
  --love.keyboard.setTextInput(true)
  if not love.filesystem.exists("/data/") then love.filesystem.createDirectory("/data/") end
  if not love.filesystem.exists("/data/demos/") then
    love.filesystem.createDirectory("/data/demos/")
    for k, demo in ipairs(love.filesystem.getDirectoryItems("/demos/")) do
      api.fs.write("/demos/"..demo,love.filesystem.read("/demos/"..demo))
    end
  end
  api.loadDefaultCursors()
  _ScreenCanvas = love.graphics.newCanvas(192,128)
  _ScreenCanvas:setFilter("nearest")
  love.graphics.clear(0,0,0,255)
  love.graphics.setCanvas(_ScreenCanvas)
  love.graphics.clear(0,0,0,255)
  love.graphics.translate(_ScreenTX,_ScreenTY)
  
  love.resize(love.graphics.getDimensions())
  
  love.graphics.setLineStyle("rough")
  love.graphics.setLineJoin("miter")
  
  love.graphics.setFont(_Font)
  
  api.clear() --Clear the canvas for the first time
  api.stroke(1)
  
  require("autorun")
  --require("debugrun")
  --require("editor")
  _auto_init()
end

function love.resize(w,h)
  _ScreenWidth, _ScreenHeight = w, h
  local TSX, TSY = w/192, h/128 --TestScaleX, TestScaleY
  if TSX < TSY then
    _ScreenScaleX, _ScreenScaleY, _ScreenScale = w/192, w/192, w/192
    _ScreenX, _ScreenY = 0, (_ScreenHeight-128*_ScreenScaleY)/2
  else
    _ScreenScaleX, _ScreenScaleY, _ScreenScale = h/128, h/128, h/128
    _ScreenX, _ScreenY = (_ScreenWidth-192*_ScreenScaleX)/2, 0
  end
  api.clearCursorsCache()
  _ShouldDraw = true
end

function love.update(dt)
  local mx, my = _ScreenToLiko(love.mouse.getPosition())
  love.window.setTitle(_ScreenTitle.." FPS: "..love.timer.getFPS().." ShouldDraw: "..(_ForceDraw and "FORCE" or (_ShouldDraw and "Yes" or "No")).." MX, MY: "..mx..","..my)
  _auto_update(dt)
end

function love.visible(v)
  _ForceDraw = not v
  _ShouldDraw = v
end

function love.focus(f)
  _ForceDraw = not f
  _ShouldDraw = f
end

function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() and (_ShouldDraw or _ForceDraw) then
			love.graphics.setCanvas()
			love.graphics.origin()
			love.graphics.setColor(255,255,255)
			love.graphics.draw(_ScreenCanvas, _ScreenX,_ScreenY, 0, _ScreenScaleX,_ScreenScaleY)
			--love.graphics.api.points(1,1,_ScreenWidth,_ScreenHeight)
			love.graphics.present()
			love.graphics.setCanvas(_ScreenCanvas)
			love.graphics.translate(_ScreenTX,_ScreenTY)
			_ShouldDraw = false
		end
 
		if love.timer then love.timer.sleep(0.001) end
	end
 
end