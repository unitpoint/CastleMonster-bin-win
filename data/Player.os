Player = extends Entity {
	__object = {
		originSpeed = 120,
		playerSpeedScale = null,
		isShooting = false,
		enemyKilledTime = 0,
		enemyKilledFastCount = 0,
		enemyKilledSoundTimer = null,
	},

	__construct = function(level){
		super(level)
		@attrs {
			resAnim = res.get("players/1"),
			parent = level.layers[LAYER.PLAYER],
			pos = level.randAreaPos(randItem(level.getTileAreasByType(PHYS_PLAYER_SPAWN))),
			pivot = vec2(0.5, 0.5),
		}
		var params = {
			image = {
				id = "player",
				imageId = playerData.armorItem.nameId,
				size = [ 20, 1 ],
				ms = 200,
			},
			sounds = {
				// pain: [ "player-pain-1", "player-pain-2", "player-pain-3", "player-pain-4", "player-pain-5", "player-pain-6", "player-pain-7", "player-pain-8" ],
				pain: [ "player2-pain-1", "player2-pain-2", "player2-pain-3", "player2-pain-4", "player2-pain-5", "player2-pain-6", "player2-pain-7", "player2-pain-8" ],
				death: [ "player-death-1", "player-death-2" ]
			},		
			physics = {
				// radiusScale = 0.8,
				// density = 1.0,
				restitution = 0.2,
				// friction = 1.0,
				linearDamping = 0.92,
				stopLinearDamping = 0.95,
				// angularDamping = 1.0,
				categoryBits = PHYS_CAT_BIT_PLAYER,
				ignoreBits = PHYS_CAT_BIT_PLAYER_FIRE | PHYS_CAT_BIT_BLOOD 
					| PHYS_CAT_BIT_MONSTER_SPAWN | PHYS_CAT_BIT_MONSTER_AREA 
					| PHYS_CAT_BIT_PLAYER_SPAWN,
				
				minSpeed = 0,
				maxSpeed = @originSpeed,
				forcePower = 1000 * PLAYER_FORCE_SCALE * 3.0/3,
				
				shapes = [ {						
					radiusScale = 0.8
					// widthScale = 0.6,
					// heightScale = 0.9
				}, {
					radiusScale = 2.5,
					sensor = true,
					density = 0,
					categoryBits = PHYS_CAT_BIT_PLAYER_SENSOR,
					ignoreBits = PHYS_CAT_BIT_ALL & ~PHYS_CAT_BIT_POWERUP
				} /*, {
					radiusScale = 8,
					sensor = true,
					density = 0,
					ignoreBits = PHYS_CAT_BIT_ALL & ~PHYS_CAT_BIT_MONSTER
				}*/ ]
			}
		}
		@desc = params
		@physics = params.physics
		
		level.initEntityPhysics(this)
		
		@nextWeapon()
		
		@setMaxSpeed(@originSpeed)
	},
	
	setMaxSpeed = function(value){
		value || throw "setMaxSpeed with null"
		var keys = {
			120 = {
				linearDamping = 0.96,
				forcePower = 1000 * PLAYER_FORCE_SCALE * 2.0/2,
			},
			300 = {
				linearDamping = 0.92,
				forcePower = 1000 * PLAYER_FORCE_SCALE * 3.0/3,
			}
		}
		var selectedKeys = []
		for(var speed, params in keys){
			if(speed <= value && (selectedKeys[0] === null || selectedKeys[0].speed < speed)){
				selectedKeys[0] = {
					speed = speed, 
					linearDamping = params.linearDamping,
					forcePower = params.forcePower,
				}
			}
			if(speed >= value && (selectedKeys[1] === null || selectedKeys[1].speed > speed)){
				selectedKeys[1] = {
					speed = speed, 
					linearDamping = params.linearDamping,
					forcePower = params.forcePower,
				}
			}
		}
		var result = {}
		if(selectedKeys[0] !== null && selectedKeys[1] !== null){
			var a, b = selectedKeys[0], selectedKeys[1]
			if(a.speed == b.speed){
				result = a
			}else{
				var t = (value - a.speed) * 1.0 / (b.speed - a.speed)
				for(var i in a){
					result[i] = a[i] + (b[i] - a[i]) * t
				}
			}
		}else if(selectedKeys[0] !== null){
			result = selectedKeys[0]
		}else{
			result = selectedKeys[1]
		}
		result.speed = value
		print('set player max speed', value, selectedKeys, result, t)
		
		@physics.linearDamping = result.linearDamping
		@physics.maxSpeed = result.speed
		@physics.forcePower = result.forcePower
		
		@linearDamping = @physics.linearDamping
		@stopDampingUpdated = false
	},
	
	update = function(ev){
		if(@level.hud.moveJoystick.active){
			var dir = (@level.hud.moveJoystick.dir * 2).normalizeToMax(1)
		}else{
			var dx, dy = 0, 0
			if(@level.keyPressed.left) dx--
			if(@level.keyPressed.right) dx++
			if(@level.keyPressed.up) dy--
			if(@level.keyPressed.down) dy++
			if(dx != 0 || dy != 0){
				var dir = vec2(dx, dy).normalize()
			}
		}
		if(dir.x != 0 || dir.y != 0){
			if(@stopDampingUpdated){
				@linearDamping = @physics.linearDamping
				@angularDamping = @physics.angularDamping
				@stopDampingUpdated = false
			}
			
			if(@playerSpeedScale === null || @playerSpeedScale != playerData.effects.scale.playerSpeed){
				@playerSpeedScale = playerData.effects.scale.playerSpeed
				@setMaxSpeed(@originSpeed * @playerSpeedScale)
				print('player max speed changed', @physics.maxSpeed)
			}
			
			@applyForce(dir * @physics.forcePower, {maxSpeed = @physics.maxSpeed * #dir})
		}else{
			if(!@stopDampingUpdated){
				@linearDamping = @physics.stopLinearDamping || 0.96
				@angularDamping = @physics.stopAngularDamping || 0.96
				@stopDampingUpdated = true
			}
		}
		// cm.applyActorForce(this, cm.keysToDir().multiply(this.desc.physics.forcePower), undefined, true);
		// cm.log("[player move] force "+this.desc.physics.forcePower+" "+dir.x+" "+dir.y);
		if(#@linearVelocity > 5){				
			@playFootstepSound()
		}
		
		@updateSprite()
	},
	
	onEnemyKilled = function(enemy){
		if(@level.time - @enemyKilledTime <= 2){
			@enemyKilledFastCount++
		}else{
			@enemyKilledFastCount = 1
		}
		@enemyKilledTime = @level.time
		
		@removeTimeout(@enemyKilledSoundTimer)
		@enemyKilledSoundTimer = null
		
		if(@enemyKilledFastCount >= 2){
			enemy.bonusScale = clamp(@enemyKilledFastCount/2, 1, 5)
			var sound = []
			if(@enemyKilledFastCount <= 3){
				sound[] = "amazing"
				sound[] = "awesome"
				sound[] = "impressive"
			}
			switch(@enemyKilledFastCount){
			case 3:
				sound[] = "05kills"
				break
			case 4:
				sound[] = "10kills"
				break
			case 5:
				sound[] = "15kills"
				break
			case 6:
				sound[] = "20kills"
				break
			case 7:
				sound[] = "25kills"
				break
			case 8:
				sound[] = "30kills"
				break
			default:
				sound[] = "30kills"
				sound[] = "25kills"
				sound[] = "20kills"
				break
			}
			@enemyKilledSoundTimer = addTimeout(0.5, function(){
				@level.playSound {
					actor = "player", channel = "talk", volume = 100,
					sound = sound,
					lock_sec = 1
				}
			})
		}else if(math.rand() <= 0.1){
			@enemyKilledSoundTimer = addTimeout(math.random(0.5, 1), function(){
				@level.playSound {
					actor = "player", channel = "talk", volume = 100,
					sound = ["headshot", "airshot"],
					lock_sec = math.random(1, 10)
				}
			})
		}
	},
	
	onPhysicsContact = function(contact, i){
		if(@level.player != this){
			return
		}
		var otherCategoryBits = contact.getCategoryBits(1-i)
		if((otherCategoryBits & PHYS_CAT_BIT_MONSTER) != 0){
			var enemy = contact.getEntity(1-i)
			@onEnemyTouched(enemy)
		}else if((otherCategoryBits & PHYS_CAT_BIT_POWERUP) != 0){
			powerup = contact.getEntity(1-i)
			name = powerup.desc.image.id
			switch(name){
			case "money":
				@onMoneyTouched(powerup)
				break;
				
			case "meat":
				@onMeatTouched(powerup)
				break;
			}
		}
	},
	
	onEnemyTouched = function(enemy){
		@level.createBlood(this, 4, {
			image = {
				id = "blood-player"
			}
		})
		if(@level.time - playerData.damagedTime > 1){
			if(playerData.meat > 0 && enemy.desc.health > 0){						
				var meatCount = math.random(1, math.ceil(enemy.desc.health / 100))
				playerData.meat = math.floor(math.max(0, playerData.meat - meatCount))
			}
			
			// enemy.desc.damage || throw "damage (${enemy.desc.damage}) is not set of "..enemy.desc.nameId
			var damage = math.max((enemy.desc.damage || 0), (enemy.desc.health || 0) / 5)
			damage = math.min(playerData.health * 0.4, damage)
			
			var playerHealth = playerData.health * playerData.effects.scale.playerHealth
			var playerArmor = playerData.armor * playerData.effects.scale.playerArmor
			
			var armorDamage = clamp(playerArmor - playerData.armorDamaged, 0, damage) * 0.9
			playerData.armorDamaged += armorDamage
			playerData.healthDamaged += damage - armorDamage
			
			playerData.damagedTime = @level.time
			
			if(!playerData.healthDamaged){
				print "damage: ${damage}, armorDamage: ${armorDamage}, enemy.desc: ${enemy.desc}"
				throw "!playerData.healthDamaged"
			}
			// print("Player.onEnemyTouched, damage: ${damage}, armorDamage: ${armorDamage}, playerData.armorDamaged: ${playerData.armorDamaged}, playerData.healthDamaged: ${playerData.healthDamaged}")
			
			if(playerData.healthDamaged > playerHealth){
				@playDeathSound()
				
				@level.createBlood(this, 10, {
					image = {
						id = "blood-player"
					}
				}, true)				
				var die = Sprite().attrs {
					resAnim = @resAnim,
					pos = @pos,
					pivot = vec2(0.5, 0.5),
					parent = @level.layers[LAYER.POWERUPS],
					resAnimFrameNum = 17,
				}
				die.addTweenAction {
					duration = 1.4,
					pos = @pos + @linearVelocity * 1.4,
					ease = Ease.QUAD_OUT,
				}
				var dieUpdateHandle = die.addUpdate(0.5, function(ev){
					if(die.resAnimFrameNum == 19){
						die.removeUpdate(dieUpdateHandle)
						die.addTimeout(10, function(){
							die.addTweenAction {
								duration = 5,
								opacity = 0,
								detachTarget = true,
							}
						})
						return
					}
					die.resAnimFrameNum++ 
				})
				
				@level.deleteEntity(this)
				@level.player = null
			}
		}
	},
	
	playFootstepSound = function(){
	
	},
	
	playPainSound = function(){
		// cm.log("playPainSound", this.desc.sounds.pain);
		@level.playSound {
			actor = @desc.image.id, 
			channel = 'pain', 
			volume = 100, 
			sound = @desc.sounds.pain
		}
		
		@level.hud.onPain(); // playerFace.sprite.setAnimationImageIndex( [2] );
	},
	
	playDeathSound = function(){
	
	},
	
	nextWeapon = function(){
		print "FAKE nextWeapon"
	},
}
