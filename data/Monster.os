Monster = extends Entity {
	__object = {
		aimTime = 0,
		aimType = true,
		aimInverse = false,
		stopped = false,
		startContinualTime = 0,
		endContinualTime = 1,
		checkContinualTime = 0,
		bonusScale = 1,
		
		startPos = vec2(0, 0),
		
		path = false,
		pathIndex = 0,
		pathFailed = 0,
		pathValid = 0,
		pathTime = 0,
		pathNextTime = 0,
		target = null,
	},
	
	__construct = function(level, params){
		super(level)
		
		params = extend({
			pos = { x = level.view.width * math.random(0.2, 0.8), y = level.view.height * math.random(0.2, 0.8) },
			image = {
				size = [ 20, 1 ],
				ms = 200
			},
			sounds = {
				pain = [ "unknown" ], // "temp/paind", "temp/painb", "temp/giant1", "temp/giant2", "temp/giant3", "temp/giant4" ],
				death = [ "unknown" ], // "temp/deathe", "temp/deathb", "temp/deathd" ],
				idle = [ "unknown" ]
			},
			health = 10,
			fire = {
				day = 1,
				weapon = 5,
				frequency = 1000.0 / 500.0,
				speed = 100,
				damage = 10,
				density = 0.5
			},
			physics = {
				radiusScale = 1,
				density = 1.0,
				minSpeed = 20,
				maxSpeed = 100,
				linearDamping = 0,
				// friction = 0.5,
				restitution = 0.2,
				forcePower = 1000,
				inversePower = 2000,
				stopPercent = 10,
				stopDurationSec = [1.0, 3.0],
				aimOnDamage = "inverse",
				aimIntervalSec = 3.0,
				aimDurationSec = [2.0, 4.0],
				pathWalkDurationSec = [20.0, 30.0],
				inverseDurationSec = [2.0, 4.0],
				categoryBits = PHYS_CAT_BIT_MONSTER,
				ignoreBits = PHYS_CAT_BIT_POWERUP | PHYS_CAT_BIT_BLOOD
					| PHYS_CAT_BIT_MONSTER_SPAWN | PHYS_CAT_BIT_MONSTER_AREA 
					| PHYS_CAT_BIT_PLAYER_SPAWN,
			}
		}, params)
		
		// print "spawnMonster: ${params}"
		
		@initEntity(params)
		
		@parent = @level.layers[LAYER.MONSTERS]
	},
	
	getAimIntervalSec = function(){
		return randTime(@desc.physics.aimIntervalSec)
	},
	
	getAimDurationSec = function(){
		return randTime(@desc.physics.aimDurationSec)
	},
	
	getPathWalkDurationSec = function(){
		if(@desc.physics.pathWalkDurationSec){
			return randTime(@desc.physics.pathWalkDurationSec)
		}
		return randTime(@desc.physics.aimDurationSec)
	},
	
	getInverseDurationSec = function(){
		if(@desc.physics.inverseDurationSec){
			return randTime(@desc.physics.inverseDurationSec)
		}
		return math.min(2, randTime(@desc.physics.aimDurationSec))
	},
	
	getStopDurationSec = function(){
		if(@desc.physics.stopDurationSec){
			return randTime(@desc.physics.stopDurationSec)
		}
		return math.min(2, randTime(@desc.physics.aimDurationSec))
	},
	
	updatePath = function(){
		var level = @level
		@pathTime = level.time
		
		if(!level.useMonstersBattle){
			@target = level.player || return;
		}else{
			if(level.isEntityDead(@target)){
				@target = null
				var bestDist = 99999999999
				for(var i, monster in level.layers[LAYER.MONSTERS]){
					if(monster !== this && monster.desc.battleSide != @desc.battleSide){
						var dist = #(@pos - monster.pos)
						if(bestDist > dist){
							bestDist = dist
							@target = monster
						}
					}
				}
				if(!@target){
					@path = false
					@pathNextTime = level.time + math.random(0.1, 0.2)
					return // false
				}
			}
		}
		
		var checkPath = !@path || level.time >= @pathNextTime
		if(checkPath){
			var dist = 99999999
			if(@isEntVisible){
				dist = #(@pos - @target.pos)
				// cm.log("[dist] "+dist+" "+@desc.image.id)
			}
			if(dist < 200 && level.traceEntities(this, @target, @desc.physics.fly)){
				@path = false
				@pathNextTime = level.time + math.random(0.1, 0.2)
				return // false
			}
			@pathNextTime = level.time + math.random(0.1, 0.2)
			
			var x1, y1 = level.entityPosToTile(@pos)
			var x2, y2 = level.entityPosToTile(@target.pos)
			// print "p1: ${p1} ${@pos}, p2: ${p2} ${@target.pos}"
			
			if(@path && @pathValid <= 10){
				@pathValid++
				var node = @path[@path.length-1]
				if(math.abs(node.x - x2) <= 1 && math.abs(node.y - y2) <= 1){
					// print("[path] cur path is still valid for ${@classname}#${@__id}")
					return
				}
			}
			
			@pathFailed++
			@pathValid = 0
			
			var self = this
			// print "start finding path for ${@classname}#${@__id}"
			level.findPath(x1, y1, x2, y2, @desc.physics.fly, true, function(path){
				// print "path found for ${self.classname}#${self.__id}: ${path}"
				if(!path || level.isEntityDead(self)){
					return
				}
				self.path = path
				self.pathFailed = 0
				self.pathValid = 1
				self.pathIndex = 0
				// self.pathTime = self.time
				
				if(true){
					for(var i, monster in level.layers[LAYER.MONSTERS]){
						if(monster !== self && !monster.path // && !monster.aimInverse && !monster.stopped
							&& monster.desc.physics.fly == self.desc.physics.fly
							&& (!level.useMonstersBattle || monster.desc.battleSide == self.desc.battleSide))
						{
							var dist = #(self.pos - monster.pos)
							if(dist < 100 && level.traceEntities(self, monster, self.desc.physics.fly)){
								monster.path = self.path
								monster.pathFailed = 0
								monster.pathIndex = self.pathIndex
								monster.pathNextTime = level.time + math.random(0.1, 0.2)
								monster.target = self.target
								// print("[path cloned on new path] "..monster.desc.image.id)
							}
						}
					}
				}
				
				if(level.usePathDebug){
					level.layers[LAYER.PATH].removeChildren()
					for(var i = 0; i < self.path.length; i++){
						var node = self.path[i]
						var pos = level.tileToEntityPos(node.x, node.y)
						Sprite().attrs {
							resAnim = res.get("dot"),
							parent = level.layers[LAYER.PATH],
							pos = pos,
							pivot = vec2(0.5, 0.5),
						}
					}
				}
			})
		}			
		// return !!@path
	},
	
	pathMoveStep = 0,
	pathMoveMonster = function(){
		if(!@path /*|| !@physicsBody*/){
			return false
		}
		
		var level = @level

		var from = @pos
		var x, y = level.entityPosToTile(from)
		
		var newIndex, node			
		for(var i = @path.length-1; i >= @pathIndex; i--){
			node = @path[i]
			if(math.abs(node.x - x) <= 1 && math.abs(node.y - y) <= 1){
				newIndex = i+1
				break
			}
		}
		if(newIndex !== null){
			if(newIndex >= @path.length){
				@path = false
				// print("[path] finished")
				return false
			}
			@pathIndex = newIndex
			node = @path[ @pathIndex ]
			// print("[path] new node "..@pathIndex..", pos "..node.x.." "..node.y)
		}else{
			node = @path[ @pathIndex ]
		}
		
		var to = level.tileToEntityPos(node.x, node.y)
		// print("[path] node "..@pathIndex..", to pos "..to.x.." "..to.y..", from "..from.x.." "..from.y)
		
		@pathMoveStep = 1 // (@pathMoveStep + 1) % 10
		if(@pathMoveStep == 0){
			var maxSpeed = @desc.physics.maxSpeed
			maxSpeed = maxSpeed * playerData.effects.scale.monsterSpeed
			var curSpeed = #@linearVelocity
			maxSpeed = math.min(maxSpeed, math.max(maxSpeed * 0.1, curSpeed * 1.1))
			var speed = vec2(to.x - from.x, to.y - from.y).normalizeTo(maxSpeed)
			@linearVelocity = speed
			// cm.log("[path move] set speed: "+cm.round(speed.x, 1)+" "+cm.round(speed.y, 1))
		}else{
			var forcePower = @desc.physics.forcePower
			@aimForce = vec2(to.x - from.x, to.y - from.y).normalizeTo(forcePower * 0.9)
			@applyForce(@aimForce, {speedScale = playerData.effects.scale.monsterSpeed})
			// print("[path move] apply force: "..math.round(@aimForce.x, 1).." "..math.round(@aimForce.y, 1))
		}
		return true
	},
	
	moveMonster = function(aim){
		if(@level.paused){
			return
		}
		@nextMoveTime = @level.time + 0.050
		@aimInverse = false
		@stopped = false
		var isContinualPhase = @level.time < @endContinualTime
		// print("[moveMonster] "..@level.time.." "..aim.." "..@aimType.." "..isContinualPhase)
		if(aim === null){
			aim = @aimType
			if(isContinualPhase && aim && @level.time >= @checkContinualTime){
				var curPos = @pos
				var moveDist = #(@startPos - curPos)
				@startPos = curPos
				if(moveDist < 20){
					switch(aim){
					case "inverse":
						// cm.log("[monster move] dist "+cm.round(moveDist)+", inverse => true")
						isContinualPhase = false
						aim = true
						break
					case "stop":
					case false:
						break
					// case true:
					default:
						// cm.log("[monster move] dist "+cm.round(moveDist)+", true => inverse")
						isContinualPhase = false
						aim = @isEntVisible 
								// && @level.traceEntities(this, @level.player, @desc.physics.fly) 
								? "inverse" : true
						break
					}
				}else{						
					@checkContinualTime += 2
				}
			}else if(!isContinualPhase){
				if(@aimType === true){
					@spawnBullet()
					aim = /*@path ? true :*/ "inverse"
				}else{
					aim = @level.time - @aimTime >= @getAimIntervalSec()
				}
				// cm.log("[aim] "+aim)
			}
		}
		var target = @target // ? @target : @level.player
		if(@level.useMonstersBattle){
			if(@level.isEntityDead(target)){
				aim = false
			}
		}else{
			if(!target){
				target = @level.player
			}
			/* if(!target || @level.isEntityDead(target)){
				aim = false
			} */
		}
		if(aim === "stop") aim = false
		var aimChanged = aim !== @aimType
		if(!aim){
			@aimType = aim
			if(aimChanged || !isContinualPhase){
				@startContinualTime = @level.time
				@endContinualTime = @level.time + 1 // @getAimDurationSec()
				@checkContinualTime = @endContinualTime
				@aimForce = vec2( randSign(), randSign() * 0.5 ).normalize()
				@aimForce = @aimForce * @desc.physics.forcePower
			}
			@applyForce(@aimForce, {speedScale = playerData.effects.scale.monsterSpeed})
			// print("[apply free aim] "..aim.." "..@level.time.." "..@desc.image.id)
			return
		}
		/* if(aim == "stop" || (aim === true 
				&& @isEntVisible
				&& @desc.physics.stopPercent !== undefined
				&& math.random(0.001, 0.1) <= @desc.physics.stopPercent))
		{
			@aimType = "stop"
			@stopped = true
			if(aimChanged || !isContinualPhase){
				// @aimTime = @level.time
				@startContinualTime = @level.time
				@endContinualTime = @level.time + @getStopDurationMS()
				@checkContinualTime = @endContinualTime
				@nextMoveTime = @endContinualTime
			}
			return
		} */
		if(aim === "inverse"){
			@aimType = "inverse"
			@aimInverse = true
			if(aimChanged || !isContinualPhase){
				// @aimTime = @level.time
				@startPos = @pos
				@startContinualTime = @level.time
				@endContinualTime = @level.time + @getInverseDurationSec()
				@checkContinualTime = @level.time + 2
			}
		}else{
			@aimType = true
			if(aimChanged || !isContinualPhase){
				@aimTime = @level.time
				@startPos = @pos
				@startContinualTime = @level.time
				@endContinualTime = @level.time + @getAimDurationSec()
				@checkContinualTime = @level.time + 2
			}
		}
		// cm.log("[pathMoveMonster] "+(@nextMoveTime - @level.time))
		if(!@aimInverse && @pathMoveMonster()){
			// @aimType = aim
			if(aimChanged || !isContinualPhase){
				@endContinualTime = @level.time + @getPathWalkDurationSec()
			}
			return
		}
		// var playerPos = target.physicsBody.GetCenterPosition()
		var playerPos = target.pos // physicsBody ? target.physicsBody.GetCenterPosition() : cm.physics.viewToPhysVec(cm.getActorCenter(target))
		var monsterPos = @pos // physicsBody.GetCenterPosition()
		var force = (playerPos - monsterPos).normalize()
		if(@aimInverse){ // || cm.key.isPressed(cm.key.SPACE)){
			force = -force
		}
		if(@aimInverse && @desc.physics.inversePower){
			var forcePower = @desc.physics.inversePower
		}else{
			var forcePower = @desc.physics.forcePower
		}
		@aimForce = force * forcePower
		@applyForce(@aimForce, {speedScale = playerData.effects.scale.monsterSpeed})
		// print("[apply aim] "..aim.." "..@desc.image.id.." "..@level.time.." "..(@level.time < @endContinualTime))
	},
	
	isEntVisible = false,
	nextMoveTime = 0,
	update = function(ev){
		if(@pathFailed >= 10){
			print("[kill #${@__id} "..@desc.image.id.." is in stick")
			@deleteOnFailed = true
			@level.deleteEntity(this)
			return
		}

		if(@level.time >= @nextMoveTime){
			@moveMonster() // @desc.physics.aimMoveOnly || @desc.physics.aim ? true : @aimType)				
		}
	
		@updateSprite()
		
		var x = @x + @level.view.x
		var y = @y + @level.view.y
		var edge = 5
		@isEntVisible = x + @width >= edge 
				&& x < @level.width - edge
				&& y + @height >= edge 
				&& y < @level.height - edge
				
		if(@stopped){
			if(!@stopDampingUpdated){
				@linearDamping = @desc.physics.stopLinearDamping || 0.98
				@angularDamping = @desc.physics.stopAngularDamping || 0.98
				@stopDampingUpdated = true
			}
			// var speed = cm.physics.physVecToView( @physicsBody.GetLinearVelocity() )
			// force = speed.normalize().multiply( -@desc.physics.forcePower )
			// cm.applyActorForce(this, force)
		}else{
			if(@stopDampingUpdated){
				@linearDamping = @desc.physics.linearDamping || PHYS_DEF_LINEAR_DAMPING
				@angularDamping = @desc.physics.angularDamping || PHYS_DEF_ANGULAR_DAMPING
				@stopDampingUpdated = false
			}
		} 
	},
	
	onPhysicsContact = function(contact, i){
		// var other = i ? contact.m_shape1 : contact.m_shape2;
		
		/* if(other.m_body.actor && other.m_body.actor.desc && other.m_body.actor.desc.image)
		cm.log('[monster contact]', 
			other.m_body.actor && other.m_body.actor.desc && other.m_body.actor.desc.image && other.m_body.actor.desc.image.id, 
			other.m_body.actor); */
			
		var otherCategoryBits = contact.getCategoryBits(1-i)
		if((otherCategoryBits & PHYS_CAT_BIT_PLAYER_FIRE) != 0){
			if(@desc.physics.aimOnDamage 
					/* && (@desc.physics.aimOnDamage == "inverse" 
							|| @time - @aimTime > @desc.physics.aimOnDamageSec * 1000)*/)
			{
				if(@desc.physics.aimOnDamage === true){
					@pathNextTime = @time - 10
				}
				@moveMonster(@desc.physics.aimOnDamage)
				print("[aim on damage] "..@desc.image.id..", "..@desc.physics.aimOnDamage)
			}
		}else if((otherCategoryBits & PHYS_CAT_BIT_PLAYER) != 0){
			if(!contact.getIsSensor(1-i)){ //@desc.physics.inverseDurationSec !== undefined)
				var other = contact.getEntity(1-i)
				other.playPainSound()
				
				@playIdleSound()
				@moveMonster("inverse")
				// print("[touch player] time: ${math.round(@level.time, 3)}, #${@__id} "..@desc.image.id..", dist: ${math.round(#(@pos - other.pos), 2)}")
			}
		}else if((otherCategoryBits & PHYS_CAT_BIT_MONSTER) != 0){
			var other = contact.getEntity(1-i)

			// other.physicsBody.ApplyForce( @aimForce, other.physicsBody.GetCenterPosition() );
			// cm.applyActorForce(other, {x:@aimForce.x*2, y:@aimForce.y*2});
			if(@level.useMonstersBattle && @desc.battleSide != other.desc.battleSide){
				other.moveMonster("inverse");
				if(/*@aim === true &&*/ other.time - other.damagedTime > 0.3){
					other.damagedTime = other.time
					other.damaged += 10
					if(other.damaged >= other.desc.health){
						@level.dieEntity(other)
					}else if(!other.path && other.target != this){
						other.target = this
						other.path = false
						other.pathNextTime = other.time - 10
					}
				}
				@moveMonster("inverse")
				if(/*other.aim === true &&*/ @time - @damagedTime > 0.3){
					@damagedTime = @time
					@damaged += 10
					if(@damaged >= @desc.health){
						@level.dieEntity(this)
					}else if(!@path && @target !== other){
						@target = other
						@path = false
						@pathNextTime = other.time - 10
					}
				}
				return true
			}else  if(!@aimInverse){
				var selfPathUsed = @aimType === true /*!@aimInverse && !@stopped*/ && @path
				var otherPathUsed = other.aimType === true /*!other.aimInverse && !other.stopped*/ && other.path
				
				var level = @level
				var target = @target || level.player
				if(selfPathUsed && otherPathUsed){
					var remain = @path.length - @pathIndex
					var remainOther = other.path.length - other.pathIndex
					var actor = remain < remainOther && level.traceEntities(other, target, other.desc.physics.fly) ? this : other
					if(true){
						actor.moveMonster("inverse")
						actor.applyForce(actor.aimForce*3, {noClipForce = true})
						// print("[push monster] "..actor.desc.image.id)
					}						
					return true
					// cm.applyActorForce(actor, {x:actor.aimForce.x*2, y:actor.aimForce.y*2});
				}else if(selfPathUsed || otherPathUsed){
					/* var actor = otherPathUsed ? this : other;
					if(level.traceEntities(actor, level.player, actor.desc.physics.fly)){
						actor.moveMonster("inverse");
						cm.applyActorForce(actor, {x:actor.aimForce.x*2, y:actor.aimForce.y*2});
						cm.log("[push monster2] "+actor.desc.image.id);
						// return true;
					}else{
						// cm.applyActorForce(this, {x:@aimForce.x*10, y:@aimForce.y*10}, true);
					}
					return true; */
				}
			}
		}else if((otherCategoryBits & (PHYS_CAT_BIT_STATIC | PHYS_CAT_BIT_WATER)) != 0){
			if(@level.time > (@endContinualTime + @startContinualTime)/2 && /*@isMonsterVisible &&*/ @aimInverse){
				// @endContinualTime = 0;
				// @path = false;
				// cm.log("[break inverse] "+@desc.image.id+", wall is touched");
				// @moveMonster(cm.randItem([false, "stop"]));
			}
		}
	},
	
	spawnBullet = function(){
		var level = @level
		var waveParams = level.wave.params

		var bulletsLayer = level.layers[LAYER.MONSTER_BULLETS]
		if(#bulletsLayer >= waveParams.monsterFireMaxBullets){
			print("[monster fire] skipped, max bullets reached "..#bulletsLayer)
			return
		}
		var fireIntervalSec = level.time - level.monsterFireTime
		if(fireIntervalSec < waveParams.monsterFireIntervalSec){
			// print("[monster fire] skipped, time is blocked "..math.round(fireIntervalSec, 2).." "..waveParams.monsterFireIntervalSec)
			return
		}
		
		var target = @target || level.player
		var monsterPos = @pos
		var targetDir =	target.pos - monsterPos
		var dist = #targetDir
		if(dist < waveParams.monsterFireMinDistance){
			// print("[monster fire] skipped due to dist "..math.round(dist).." < "..waveParams.monsterFireMinDistance)
			return
		}
		
		level.monsterFireTime = level.time
		// @dirIndex = cm.dirToIndex( aim.targetDir )
		var weaponItem = playerData.itemsById[@desc.fire.weaponId]
		if(!weaponItem || weaponItem.typeId != ITEM_TYPE_WEAPON){
			return
		}
		
		var scale = playerData.effects.scale
		Bullet(this, extend(weaponItem.actorParams, { // cm.weapons[@desc.fire.weapon_id], {
			pos = monsterPos,
			targetDir = targetDir * (1.0 / dist),
			damage = @desc.fire.damage * scale.monsterHealth,
			physics = {
				density = @desc.fire.density,
				speed = @desc.fire.speed * scale.monsterSpeed,
				categoryBits = PHYS_CAT_BIT_MONSTER_FIRE,
				ignoreBits = 0
					// | PHYS_CAT_BIT_PLAYER_FIRE 
					| PHYS_CAT_BIT_MONSTER_FIRE
					| PHYS_CAT_BIT_MONSTER 
					| PHYS_CAT_BIT_WATER
					| PHYS_CAT_BIT_BLOOD
					// | PHYS_CAT_BIT_POWERUP
					| PHYS_CAT_BIT_MONSTER_SPAWN | PHYS_CAT_BIT_MONSTER_AREA 
					| PHYS_CAT_BIT_PLAYER_SPAWN,
			},
			lifeTimeSec = 3.5,
		}))
	},
}
