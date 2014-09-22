LevelHud = extends Actor {
	__object = {
		redArmorTime = 0,
		redHealthTime = 0,
		faceRow	= 0,
		faceState = 0,
		faceTime = 0,
		faceEndTime = 0,
		faceNextState = -1,
		faceNextTime = 0,
		faceNextDuration = 0,
		faceAlertTime = 0,	
	},
	
	__construct = function(level){
		super()
		@level = level
		@attrs {
			size = level.size,
			pos = vec2(0, 0),
			pivot = vec2(0, 0),
			priority = 10,
			parent = level,
		}
		
		@moveJoystick = Joystick().attrs {
			// priority = 0,
			parent = this,
			pivot = vec2(-0.25, 1.25),
			pos = vec2(0, @height),
		}
		
		var pad = 2
		@face = Sprite().attrs {
			resAnim = res.get("player-hud-face"),
			// priority = 0,
			parent = this,
			pivot = vec2(1, 1),
			pos = vec2(@width/2 - pad, @height - pad),
		}
		@faceBar = HealthProgressBar().attrs {
			parent = @face,
			pivot = vec2(0, 0),
			pos = vec2(0, @face.height + pad),
		}
		@face.height = @face.height + @faceBar.height + pad
		
		@armor = Sprite().attrs {
			resAnim = res.get("player-hud-armor"),
			// priority = 0,
			parent = this,
			pivot = vec2(0, 1),
			pos = vec2(@width/2 + pad, @height - pad),
		}
		@armorBar = HealthProgressBar().attrs {
			parent = @armor,
			pivot = vec2(0, 0),
			pos = vec2(0, @armor.height + pad),
		}
		@armor.height = @armor.height + @armorBar.height + pad
		
		/* @addUpdate(0.3, function(){
			@faceBar.progress = @faceBar.progress * 0.9
			@armorBar.progress = @armorBar.progress * 0.8
		}.bind(this)) */
	},
	
	setFaceState = function(state, duration){
		if(@faceState != state && @faceNextState != state){
			@faceNextState = state
			@faceNextTime = @level.time
			@faceNextDuration = duration
		}
	},
	
	onHappy = function(){
		@setFaceState(1, math.random(2, 5))
	},	
	
	onPain = function(){
		@setFaceState(2, math.random(1, 3))
	},	
	
	onAlert = function(){
		if(@level.time - @faceAlertTime > 3){
			@faceAlertTime = @level.time
			@setFaceState(randItem([3, 4]), math.random(1.5, 2.0))
		}
	},
	
	updateFaceFrame = function(){
		var faceHeight = @face.height
		@face.resAnimFrameNum = @faceState + @faceRow*5 // it changes size
		@face.height = faceHeight // restore height
	},
	
	update = function(ev){
		var time = @level.time
		
		if(@faceNextState >= 0 && @faceState != @faceNextState 
			&& (time - @faceNextTime > (@faceNextState != 0 ? 0.1 : 0.5) 
				|| time > @faceEndTime))
		{
			@faceState = @faceNextState
			@faceNextState = -1
			@faceEndTime = time + @faceNextDuration
			@updateFaceFrame()
		}else if(@faceNextState < 0 && time > @faceEndTime){
			if(math.random() <= 0.7){
				@setFaceState(randItem([3, 4]), math.random(0.7, 1.5))
			}else{
				@setFaceState(0, math.random(2, 5))
			}
		}
		/*
		var money = math.round(math.max(0, playerData.money - playerData.armorRecoverMoneyUsed))
		if(@moneyCached !== money){
			@moneyCached = money
			@moneyText.setText( @moneyCached )
		}
		var meat = math.round(math.max(0, playerData.meat - playerData.healthRecoverMeatUsed))
		if(@meatCached !== meat){
			@meatCached = meat
			@meatText.setText( @meatCached )
		}
		*/
		
		var playerHealth = playerData.health * playerData.effects.scale.playerHealth
		var playerArmor = playerData.armor * playerData.effects.scale.playerArmor
		
		var damaged = playerData.armorDamaged - playerData.armorRecovered + playerData.armor * (1 - playerData.effects.scale.playerArmor)
		var t = 1 - clamp(damaged / playerData.armor, 0, 1)
		@armorBar.progress = t
		// print "armorBar.progress: ${@armorBar.progress}"
		
		if(t >= 0.35){
			@redArmorTime = 0
			@armor.opacity = 1
		}else if(t > 0){
			if(@redArmorTime && time - @redArmorTime > 4){
				@armor.opacity = 1
			}else{
				@redArmorTime || @redArmorTime = time
				@armor.opacity = math.floor((time / 0.2) % 2) == 0 ? 1 : 0.5
			}
		}else{
			@redArmorTime = 0
			@armor.opacity = 0.5
		}
		
		var damaged = playerData.healthDamaged - playerData.healthRecovered + playerData.health * (1 - playerData.effects.scale.playerHealth)
		var t = 1 - clamp(damaged / playerData.health, 0, 1)
		@faceBar.progress = t
		// print "faceBar.progress: ${@faceBar.progress}"
		
		var oldFaceRow = @faceRow
		if(t >= 0.7){
			@faceRow = 0
		}else if(t >= 0.4){
			@faceRow = 1
		}else if(t >= 0.2){
			@faceRow = 2
		}else if(t > 0){
			@faceRow = 3
		}else{
			@faceRow = 4
		}
		if(oldFaceRow != @faceRow){
			@updateFaceFrame()
		}
		
		if(t >= 0.35){
			@redHealthTime = 0
			@face.opacity = 1
		}else if(t > 0){
			if(@redHealthTime && time - @redHealthTime > 4){
				@face.opacity = 1
			}else{
				@redHealthTime || @redHealthTime = time
				@face.opacity = math.floor((time / 0.2) % 2) == 0 ? 1 : 0.5
			}
		}else{
			@redHealthTime = 0
			@face.opacity = 0.5
		}
	},
}
