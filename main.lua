-- Hide Status Bar  

display.setStatusBar( display.HiddenStatusBar )
--display.setStatusBar( display.DarkStatusBar )
-- Physice Engine//重力

local physices = require "physics"
physics.start()
physics.setGravity(0,0)

--Accelerometer //水平儀 加速器

system.setAccelerometerInterval( 100 )  --精準度，"100"每秒取100次

--Menu Screen

local menuScreenGroup --display.newGroup()
local mmScreen
local playBtn

--Game Screen

local backround
local paddle
local brick
local ball

--level/score Text

local scoreText
local scoreNum
local levelText
local levelNum

-- alertDisplayGroup

local alertDisplayGroup --display.newGroup()
local alertBox
local alertScreen
local conditionDisplay
local messageText

-- Variables

local _W = display.contentWidth / 2  --一開始的預設位置 (_W,_H)  /2→取中間值
local _H = display.contentHeight / 2  --一開始的預設位置
local bricks = display.newGroup()
local brickWidth = 35  --磚塊的大小
local brickHeight = 15  --磚塊的大小
local row
local column
local score = 0  --起始分數
local scoreIncrease = 100  --分數增額
local currentLevel --開始層級
local vx = 3   --根據一開始設定的WH位置去定義一開始的飛行位置
local vy = -3
local gameEvent = ""

local isSimulateor = "simulator" == system.getInfo("enviroment")

--Main Function

function main()  --畫面一開始進入主選單
	mainMenu()
end

function mainMenu()
	menuScreenGroup = display.newGroup()

	mmScreen = display.newImage("background2.jpg",0,0,true) --true→把圖片填滿畫面
	mmScreen:scale (1.3,1.3)
	mmScreen.x = display.contentCenterX --直接取得畫面中心點
	mmScreen.y = display.contentCenterY --直接取得畫面中心點
	
	playBtn = display.newImage("startBtn.png")
	playBtn.anchorX,playBtn.anchorY = 0.5,0.5
	playBtn.x = _W; playBtn.y = _H + 50
	--playBtn:scale (3,3) --放大比例
	playBtn.name = "playbutton"

	helpBtn = display.newImage("helpBtn.png")
	helpBtn.anchorX, helpBtn.anchorY = 0.5,0.5
	helpBtn.x = _W; helpBtn.y = _H + 110
	--helpBtn:scale (3,3) --放大比例
	helpBtn.name = "helpButton"

	
	menuScreenGroup:insert(mmScreen)
	menuScreenGroup:insert(playBtn)
	menuScreenGroup:insert(helpBtn)
	
	--Button Listeners
	
	playBtn:addEventListener("tap", loadGame)	
	helpBtn:addEventListener("tap", helpGame)

end


function loadGame(event)
	if event.target.name == "playbutton" then
	
		--Start Game
		
		transition.to(menuScreenGroup,{time = 300, alpha=0, onComplete = addGameScreen})
		
		playBtn:removeEventListener("tap",loadGame)
	end
end	


function helpGame(event)
	if event.target.name == "helpButton" then
		transition.to(menuScreenGroup,{time = 300, alpha=0, onComplete = helpGameScreen})
		
		helpBtn:removeEventListener("tap",helpGame)
	end
end


function backtoMenu(event)
	if event.target.name == "backButton" then
		transition.to(menuScreenGroup,{time = 300, alpha=0, onComplete = mainMenu})
		
		backBtn:removeEventListener("tap",backtoMenu)
	end
end


function addGameScreen()
	background = display.newImage("background3.jpg",0,0,true) --true→把圖片填滿畫面
	background:scale (1.3,1.3)
	background.x = display.contentCenterX --直接取得畫面中心點
	background.y = display.contentCenterY --直接取得畫面中心點

	paddle = display.newImage("paddle.png")
	paddle.x = 230; paddle.y = 300
	paddle.name = "paddle"

	ball = display.newImage("ball.png")
	ball.x = 230; ball.y = 288
	ball.name = "ball"

	
	--Text
	scoreText = display.newText("Score:", 50, 10, "Arial", 14)
	scoreText:setTextColor(255, 255, 255, 255)
	
	scoreNum = display.newText("0", 90, 10, "Arial", 14)
	scoreNum:setTextColor(255, 255, 255, 255)
	
	levelText = display.newText("Level:", 210, 10, "Arial", 14)
	levelText:setTextColor(255, 255, 255, 255)
	
	levelNum = display.newText("0", 240, 10, "Arial", 14)
	levelNum:setTextColor(255, 255, 255, 255)



	-- Build Level Bricks 
	
	gameLevel1() 
	
	-- -- Start Listener 
	
	background:addEventListener("tap", startGame)

end


function touchMove(event)
	-- 	while event.x > 160 and event.phase == "began" do 
	-- 		--paddle.x = paddle.x + 1
	-- --邊界，讓板子不要移過頭
	-- if((paddle.x - paddle.width * 0.5) < 0) then
	-- 	paddle.x = paddle.width * 0.5
	-- 	break
	-- elseif((paddle.x + paddle.width * 0.5) > display.contentWidth) then
	-- 	paddle.x = display.contentWidth - paddle.width * 0.5
	-- 	break
	-- end
	-- 		paddle.x = paddle.x + 1 
	-- 	end



	if event.phase == "began" then	--當點下去螢幕，是began phase
		if event.x > 160 then	--判斷點下去的位置，是畫面左右哪一半邊（因全寬為320width，160則剛好是左右分界點)
			paddle.x = paddle.x + 10	--大於160就是往右
		else
			paddle.x = paddle.x - 10
		end
	end


	--邊界，讓板子不要移過頭
	if((paddle.x - paddle.width * 0.5) < 0) then
		paddle.x = paddle.width * 0.5
	elseif((paddle.x + paddle.width * 0.5) > display.contentWidth) then
		paddle.x = display.contentWidth - paddle.width * 0.5
	end

end


function dragPaddle(event)
	if isSimulator then

		if event.phase == "began" then
			moveX = event.x - paddle.x
		elseif event.phase == "moved" then
			paddle.x = event.x - moveX
		end

		--邊界，讓板子不要移過頭
		if((paddle.x - paddle.width * 0.5) < 0) then
			paddle.x = paddle.width * 0.5
		elseif((paddle.x + paddle.width * 0.5) > display.contentWidth) then
			paddle.x = display.contentWidth - paddle.width * 0.5
		end

	end
end


function movePaddle(event) 
	-- Accelerometer Movement
	
	--must be yGravity since it's landscape
	paddle.x = display.contentCenterX - (display.contentCenterX * (event.yGravity * 3))	--yGravity陀螺儀的Y軸
	
	-- Wall Borders 
	-- Left Border
	if((paddle.x - paddle.width * 0.5) < 0) then
		paddle.x = paddle.width * 0.5
	-- Right Border
	elseif((paddle.x + paddle.width * 0.5) > display.contentWidth) then
		paddle.x = display.contentWidth - paddle.width * 0.5
	end
end


function helpGameScreen()
	background = display.newImage("background3.jpg",0,0,true) --true→把圖片填滿畫面
	background:scale (1.3,1.3)
	background.x = display.contentCenterX --直接取得畫面中心點
	background.y = display.contentCenterY --直接取得畫面中心點

	local text1 = display.newText("HELP for BreakOUT GAME",150 ,150, Arial,12)
	text1:setTextColor(Black)

	backBtn = display.newImage("backBtn.png")
	backBtn.anchorX, backBtn.anchorY = 0.5,0.5
	backBtn.x = _W; backBtn.y = _H + 100
	--backBtn:scale (3,3) --放大比例

	backBtn.name = "backButton"

	backBtn:addEventListener("tap", backtoMenu)
end


function bounce()
	vy = -3	
	-- Paddle Collision, check the which side of the paddle the ball hits, left, right 
	
	if((ball.x + ball.width * 0.5) < paddle.x) then
		vx = -vx
	elseif((ball.x + ball.width * 0.5) >= paddle.x) then
		vx = vx
	end
end


--BRICK REMOVAL

function removeBrick(event)
	
	-- Check the which side of the brick the ball hits, left, right  
  
    if event.other.name == "brick" and ball.x + ball.width * 0.5 < event.other.x + event.other.width * 0.5 then
        vx = -vx
    elseif event.other.name == "brick" and ball.x + ball.width * 0.5 >= event.other.x + event.other.width * 0.5 then
        vx = -vx
    end
    
	-- Bounce, Remove
	if event.other.name == "brick" then
		vy = vy * -1
		event.other:removeSelf()
		event.other = nil
		bricks.numChildren = bricks.numChildren - 1

		-- Score
		score = score + 1
		scoreNum.text = score * scoreIncrease
		
		--scoreNum:setReferencePoint(display.CenterLeftReferencePoint)
		scoreNum.anchorX, scoreNum.anchorY = 0.5, 0.5
		scoreNum.x = 90
	end
	
	-- Check if all bricks are destroyed
	
	if bricks.numChildren < 0 then
		alertScreen("YOU WIN!", "Continue")
		gameEvent = "win"
	end
end


function updateBall()
	-- Ball Movement 

	ball.x = ball.x + vx
	ball.y = ball.y + vy
	
	-- Wall Collision 
	
	if ball.x < 0 or ball.x + ball.width > display.contentWidth then  
		vx = -vx
	end--Left
	
	if ball.y < 0  then 
		vy = -vy
	end--Up
	
	if ball.y + ball.height > paddle.y + paddle.height then 
		alertScreen("YOU LOSE!", "Play Again") gameEvent = "lose" 
	end--down/lose
end


function startGame()
	-- Physics
	physics.addBody(paddle, "static", {density = 1, friction = 0, bounce = 0})
	physics.addBody(ball, "dynamic", {density = 1, friction = 0, bounce = 0})
	
	background:removeEventListener("tap", startGame)
	gameListeners("add")
end


function gameLevel1()
	currentLevel = 1

	bricks:toFront()	--顯示在最上層

	local numOfRows = 4
	local numOfColumns = 4
	local brickPlacement = {x = (_W) - (brickWidth * numOfColumns ) / 2  + 20, y = 50}

	for row = 0, numOfRows - 1 do
		for column = 0, numOfColumns - 1 do
			--Creat a Brick
			local brick = display.newImage("brick.png")
			brick.name = "brick"
			brick.x = brickPlacement.x + (column * brickWidth)
			brick.y = brickPlacement.y + (row * brickHeight)
			physics.addBody(brick, "static", {density = 1, friction = 0, bounce = 0})
			--bricks.insert(bricks, brick)
			bricks:insert(brick)
		end
	end

end


function gameListeners(event)
	if event == "add" then
		--Runtime:addEventListener("accelerometer", movePaddle)
		Runtime:addEventListener("enterFrame", updateBall)
		paddle:addEventListener("collision", bounce)
		ball:addEventListener("collision", removeBrick)
		-- Used to drag the paddle on the simulator
		--paddle:addEventListener("touch", dragPaddle)
		background:addEventListener("touch", touchMove)
		
	elseif event == "remove" then
		--Runtime:removeEventListener("accelerometer", movePaddle)
		Runtime:removeEventListener("enterFrame", updateBall)
		paddle:removeEventListener("collision", bounce)
		ball:removeEventListener("collision", removeBrick)
		-- Used to drag the paddle on the simulator
		--paddle:removeEaddventListener("touch", dragPaddle)
		background:removeEventListener("touch", touchMove)
	end
end


-- RESET LEVEL

function changeLevel1()

	-- Clear Level Bricks 
	
	bricks:removeSelf()
	
	bricks.numChildren = 0
	bricks = display.newGroup()

	-- Remove Alert 
	
	alertBox:removeEventListener("tap", restart)
	alertDisplayGroup:removeSelf()
	alertDisplayGroup = nil
	
	-- Reset Ball and Paddle position 
	
	ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5)
	ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) - 2
	
	paddle.x =	display.contentWidth * 0.5
	
	-- Redraw Bricks 
	
	gameLevel1()	
	
	-- Start
	
	background:addEventListener("tap", startGame)
end


function changeLevel2()

	-- Clear Level Bricks 
	
	bricks:removeSelf()
	
	bricks.numChildren = 0
	bricks = display.newGroup()

	-- Remove Alert 
	
	alertBox:removeEventListener("tap", restart)
	alertDisplayGroup:removeSelf()
	alertDisplayGroup = nil
	
	-- Reset Ball and Paddle position 
	
	ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5)
	ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) - 2
	
	paddle.x =	display.contentWidth * 0.5
	
	-- Redraw Bricks 
	
	gameLevel2()	
	
	-- Start
	
	background:addEventListener("tap", startGame)
end


function alertScreen(title, message)
	gameListeners("remove")
	
	alertBox = display.newImage("alertBox.png")
	alertBox.x = 160; alertBox.y = 240
	transition.from(alertBox, {time = 500, xScale = 0.5, yScale = 0.5, transition = easing.outExpo})

	conditionDisplay = display.newText(title, 0, 0, "Arial", 38)
	conditionDisplay:setTextColor(255, 255, 255, 255)
	conditionDisplay.xScale = 0.5
	conditionDisplay.yScale = 0.5
	--conditionDisplay:setReferencePoint(display.CenterReferencePoint)
	conditionDisplay.anchorX, conditionDisplay.anchorX = 0.5, 0.5
	conditionDisplay.x = display.contentCenterX
	conditionDisplay.y = display.contentCenterY - 15

	messageText = display.newText(message, 0, 0, "Arial", 25)
	messageText:setTextColor(255, 255, 255, 255)
	messageText.xScale = 0.5
	messageText.yScale = 0.5
	--messageText:setReferencePoint(display.CenterReferencePoint)
	messageText.anchorX, conditionDisplay.anchorX = 0.5, 0.5
	messageText.x = display.contentCenterX
	messageText.y = display.contentCenterY + 15


	alertDisplayGroup = display.newGroup()
	alertDisplayGroup:insert(alertBox)
	alertDisplayGroup:insert(conditionDisplay)
	alertDisplayGroup:insert(messageText)

	
	alertBox:addEventListener("tap", restart)
end


-- WIN/LOSE ARGUMENT
function restart()
	if gameEvent == "win" and currentLevel == 1 then
		currentLevel = currentLevel + 1
		--currentLevel2()	--next Level
		levelNum.text = tosrting(currentLevel)
	elseif gameEvent == "win" and currentLevel == 2 then	
		alertScreen("  Game Finish", "  Congratulations!")
		gameEvent = "completed"
	elseif gameEvent == "lose" and currentLevel == 1 then
		score = 0
		scoreNum.text = "0"
		changeLevel1()	--same level
	elseif gameEvent == "lose" and currentLevel == 2 then
		score = 0
		scoreNum.text = "0"
		changeLevel2()	--same level
	elseif gameEvent == "completed" then
		alertBox:removeEventListener("tap", restart)
	end
end



main()
