Bullet = extends Entity {
	__object = {
		owner = null,
		damagedList: [],
	},
	
	__construct = function(owner, params){
		super(owner.level)
		@owner = owner
		
		if(params.through && params.damageCount > 1){
			params = extend(params, {
				physics = {
					shapes = [
						{
							radiusScale = 1.0,
							ignoreBits = PHYS_CAT_BIT_PLAYER_FIRE | PHYS_CAT_BIT_PLAYER 
								| PHYS_CAT_BIT_WATER | PHYS_CAT_BIT_MONSTER_AREA | PHYS_CAT_BIT_MONSTER
								| PHYS_CAT_BIT_POWERUP | PHYS_CAT_BIT_BLOOD
						},
						{
							radiusScale: 1.1,
							sensor: true,
							ignoreBits: PHYS_CAT_BIT_ALL & ~(PHYS_CAT_BIT_MONSTER | PHYS_CAT_BIT_MONSTER_FIRE)
						}
					]
				}
			})	
		}
		
		params = extend({
			image = { 
				id = 'weapons/1',
				size = [ 2, 1 ],
				ms = 150,
				animation = [0, 1]
			},
			spawnOffs = 30,
			damage = 10, // + 50,
			physics = { 
				speed = 250, // 300,
				fixedRotation = false,
				// width = 30,
				// height = 20,
				radiusScale = 0.8,
				density = 0.1,
				linearDamping = 0,					
				restitution = 1.0,
				categoryBits = PHYS_CAT_BIT_PLAYER_FIRE,
				ignoreBits = PHYS_CAT_BIT_PLAYER_FIRE | PHYS_CAT_BIT_PLAYER 
					| PHYS_CAT_BIT_WATER | PHYS_CAT_BIT_POWERUP | PHYS_CAT_BIT_BLOOD
					| PHYS_CAT_BIT_MONSTER_SPAWN | PHYS_CAT_BIT_MONSTER_AREA 
					| PHYS_CAT_BIT_PLAYER_SPAWN,
			},
			lifeTimeSec = 2,
		}, params)
		
		// print "spawnBullet: ${params}"
		
		@initEntity(params)
		
		var isPlayerBullet = (params.physics.categoryBits & PHYS_CAT_BIT_PLAYER_FIRE) != 0
		@parent = @level.layers[isPlayerBullet ? LAYER.EFFECTS : LAYER.MONSTER_BULLETS]
		
		@playAnim(params.image.ms/1000, params.image.animation)
		
		@addTimeout(params.lifeTimeSec - 0.5, function(){
			@addTweenAction {
				opacity = 0,
				duration = 0.5,
				doneCallback = function(){
					@level.deleteEntity(this)
				}
			}
		})
	},
	
	onPhysicsContact = function(contact, i){
		var logStr = ""
		var otherName
		// var other = i ? contact.m_shape1 : contact.m_shape2;
		var otherCategoryBits = contact.getCategoryBits(1-i)
		if((otherCategoryBits & PHYS_CAT_BIT_PLAYER) != 0){
			if((@desc.physics.categoryBits & PHYS_CAT_BIT_MONSTER_FIRE) != 0){
				// print('monster fire is touched', @desc)
				contact.getEntity(1-i).onEnemyTouched(this) // other.m_body.actor.onEnemyTouched(this);
			}
		}else if((otherCategoryBits & PHYS_CAT_BIT_MONSTER) != 0){
			otherName = "enemy"
			
			var target = contact.getEntity(1-i) // other.m_body.actor;
			if(target.isEntVisible){
				// var curShape = contact.getShape(i) // !i ? contact.m_shape1 : contact.m_shape2
				var alreadyDamaged = false;
				for(var i = @damagedList.length-1; i >= 0; i--){
					var item = @damagedList[i]
					if(@time - item.time > 0.3){
						delete @damagedList[i] // .splice(i, 1);
						continue;
					}
					if(item.ent == target){
						alreadyDamaged = true
						// console.log('alreadyDamaged', target);
						break;
					}
				}
				if(!alreadyDamaged){
					if(@desc.damageCount > 1){
						@desc.damageCount--
						@damagedList[] = {time = @time, ent = target}
					}else{
						@level.deleteEntity(this)
					}
					if(!target.isEntDead && target.desc.health > 0){
						@level.createBlood(target, 3)
						
						target.damagedTime = target.time
						target.damaged += @desc.damage
						var damaged = target.damaged + target.desc.health * (1 - playerData.effects.scale.monsterHealth)
						logStr = logStr..target.damaged.." "..math.round(math.min(255, damaged * 255 / target.desc.health))
						// target.setFillStyle("rgb("+p+",0,0)");
						
						if(damaged >= target.desc.health){
							@level.onEnemyKilled(target)
							target.playDeathSound()
							target.die()
						}else{
							target.playPainSound()
						}
					}
				}
			}else{
				logStr = logStr.."invisible"
			}
		}else if((otherCategoryBits & PHYS_CAT_BIT_STATIC) != 0){
			// cm.sound.play({actor:"bullet", channel:"ric", sound:["temp/ric1", "temp/ric3"], lock_ms:10000, priority:0});
		}else{
			otherName = otherCategoryBits
		}
		otherName && print("[bullet contact] ", otherName, logStr)
	},
}
