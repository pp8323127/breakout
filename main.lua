- RESET LEVEL

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





-- WIN/LOSE ARGUMENT
function restart()
	if gameEvent == "win" and currentLevel == 1 then
		currentLevel = currentLevel + 1
		--currentLevel2()	--next Level
		levelNum.text = tosrting(currentLevel)
	elseif gameEvent == "win" and currentLevel == 2 then	
		alertScreen("  Game Over", "  Congratulations!")
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




function dragPaddle(event)
	
	if isSimulator then
		if event.phase == "began" then
			moveX = event.x - paddle.x -- 事件位置-板子位置
		elseif event.phase == "moved" then
			paddle.x = event.x - moveX
		end

		if((paddle.x - paddle.width * 0.5) < 0) then
			paddle.x = paddle.width * 0.5
		elseif((paddle.x + paddle.width * 0.5) > display.contentWidth) then
			paddle.x = display.contentWidth - paddle.width*0.5
		end

	
	end
end






function alertScreen(title, message)
	gameListeners("remove")
	
	alertBox = display.newImage("alertBox.png")
	alertBox.x = 240; alertBox.y = 160
	transition.from(alertBox, {time = 500, xScale = 0.5, yScale = 0.5, transition = easing.outExpo})

	conditionDisplay = display.newText(title, 0, 0, "Arial", 38)
	conditionDisplay:setTextColor(255, 255, 255, 255)
	conditionDisplay.xScale = 0.5
	conditionDisplay.yScale = 0.5
	--conditionDisplay:setReferencePoint(display.CenterReferencePoint)
	conditionDisplay.anchorX, conditionDisplay.anchorX = 0.5, 0.5
	conditionDisplay.x = display.contentCenterX
	conditionDisplay.y = display.contentCenterY - 15

	messageText = display.newText(message, 0, 0, "Arial", 38)
	messageText:setTextColor(255, 255, 255, 255)
	messageText.xScale = 0.5
	messageText.yScale = 0.5
	--messageText:setReferencePoint(display.CenterReferencePoint)
	conditionDisplay.anchorX, conditionDisplay.anchorX = 0.5, 0.5
	conditionDisplay.x = display.contentCenterX
	conditionDisplay.y = display.contentCenterY 


	alertDisplayGroup = display.newGroup()
	alertDisplayGroup:insert(alertBox)
	alertDisplayGroup:insert(conditionDisplay)
	alertDisplayGroup:insert(messageText)

	
	--alertBox:addEventListener("tap", restart)
end





function addGameScreen()
	background = display.newImage("background1.jpg",0,0,true) --true→把圖片填滿畫面
	--background:scale (4,4)
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
	
	levelText = display.newText("Level:", 360, 10, "Arial", 14)
	levelText:setTextColor(255, 255, 255, 255)
	
	levelNum = display.newText("0", 400, 10, "Arial", 14)
	levelNum:setTextColor(255, 255, 255, 255)



	-- Build Level Bricks 
	
	gameLevel1() 
	
	-- -- Start Listener 
	
	background:addEventListener("tap", startGame)

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
			paddle.x = display.contentWidth - paddle * 0.5
		end

	end
end






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
