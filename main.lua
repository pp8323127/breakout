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
