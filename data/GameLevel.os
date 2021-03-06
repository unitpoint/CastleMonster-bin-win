var enumVal = 0
LAYER = {
	UNDER_FLOOR 		= enumVal++, 
	FLOOR 				= enumVal++,
	MONSTER_SPAWN_AREA 	= enumVal++,
	PLAYER_SPAWN_AREA 	= enumVal++,
	FLOOR_DECALS 		= enumVal++,
	WALLS 				= enumVal++,
	PATH 				= enumVal++,
	BLOOD 				= enumVal++,
	POWERUPS 			= enumVal++,
	MONSTERS 			= enumVal++,
	PLAYER 				= enumVal++,
	MONSTER_BULLETS 	= enumVal++,
	EFFECTS 			= enumVal++,
	DISPLAY_EFFECTS		= enumVal++,
	PHYSICS_DEBUG 		= enumVal++,
	COUNT 				= enumVal				
}

ITEM_TYPE_WEAPON = 1
ITEM_TYPE_ARTEFACT = 2
ITEM_TYPE_RESOURCE = 3
ITEM_TYPE_OBJECT = 4
ITEM_TYPE_MONSTER = 5
ITEM_TYPE_ACHIEVEMENT = 6
ITEM_TYPE_ARMOR = 7
ITEM_TYPE_MEDAL = 8
			
GameLevel = extends BaseGameLevel {
	__object = {
		wave = {
			time = 0,
			num = 0,
			phase = 0,
			maxAliveMonsters = 0,
			completed = false,
			params = null,
			phaseParams = null,
			phaseMonsters = 0,
			phaseMonstersSpawned = 0
		},
		wavePhaseMonstersSpawned = 0,
		time = 0,
		findPathTime = 0,
		monsterFireTime = 0,
		paused = false,
		excludedSpawnAreas = [],
		monsterSide = 0,
		useMonstersBattle = false,
		usePathDebug = false,
		bloodUsedList = [],
		monsterIdleTime = 0,
		monsterIdleMinDist = 100,
		monsterIdleMaxDist = 200,
		checkWaveTime = 0,
		waveCompletedInProgress = false,
	},
	
	__construct = function(p_level, p_invasion, p_day){
		super()
		@size = stage.size
		
		@params = {
			// dayParams = dayParams,
			level = p_level,
			invasion = p_invasion,
			day = p_day,
		}
		
		@levelName = "level-"..@params.level
		@view = Sprite().attrs {
			// name = "view",
			priority = 0,
			resAnim = levelRes.get(@levelName),
			parent = this,
			pos = vec2(0, 0),
			pivot = vec2(0, 0),
			startContentOffs = vec2(0, 0),
		}
		// @debugDraw = DEBUG // @view must be already created
		
		@layers = []
		for(var i = 0; i < LAYER.COUNT; i++){
			@layers[] = Actor().attrs {
				priority = i,
				parent = @view,
			}
		}
		
		if(false){
			var test = Sprite().attrs {
				resAnim = res.get("breaks"),
				priority = 1000,
				parent = this,
				pivot = vec2(0.5, 0.5),
				pos = @size / 2,
				touchEnabled = false,
			}
			test.scale = @height / test.height
			
			test = Sprite().attrs {
				resAnim = res.get("scratch"),
				priority = 1000,
				parent = this,
				pivot = vec2(0, 0),
				pos = vec2(0, 0),
				touchEnabled = false,
			}
			test.scale = @height / test.height
		}
		
		@initLevelPhysics()
		
		@hud = LevelHud(this)
		
		@player = Player(this)
		
		// @player.playAnim(0.2, [0, 1])
		// @movePlayer(vec2(0.001, 0.001))
		
		@keyPressed = {}
		if(PLATFORM == "windows"){
			var moveJoystickActivated = false
			var keyboardEvent = function(ev){
				var pressed = ev.type == KeyboardEvent.DOWN
				if(ev.scancode == KeyboardEvent.SCANCODE_LEFT || ev.scancode == KeyboardEvent.SCANCODE_A){
					@keyPressed.left = pressed
				}
				if(ev.scancode == KeyboardEvent.SCANCODE_RIGHT || ev.scancode == KeyboardEvent.SCANCODE_D){
					@keyPressed.right = pressed
				}
				if(ev.scancode == KeyboardEvent.SCANCODE_UP || ev.scancode == KeyboardEvent.SCANCODE_W){
					@keyPressed.up = pressed
				}
				if(ev.scancode == KeyboardEvent.SCANCODE_DOWN || ev.scancode == KeyboardEvent.SCANCODE_S){
					@keyPressed.down = pressed
				}
				var dx, dy = 0, 0
				if(@keyPressed.left) dx--
				if(@keyPressed.right) dx++
				if(@keyPressed.up) dy--
				if(@keyPressed.down) dy++
				if(dx != 0 || dy != 0){
					var dir = vec2(dx, dy).normalizeTo(100)
					if(!moveJoystickActivated){
						moveJoystickActivated = true
						@hud.moveJoystick.dispatchEvent {
							type = TouchEvent.START,
							localPosition = @hud.moveJoystick.size/2 + dir
						}
					}else{
						@hud.moveJoystick.dispatchEvent {
							type = TouchEvent.MOVE,
							localPosition = @hud.moveJoystick.size/2 + dir
						}
					}
				}else if(moveJoystickActivated){
					moveJoystickActivated = false
					@hud.moveJoystick.dispatchEvent {
						type = TouchEvent.END,
						localPosition = @hud.moveJoystick.size/2
					}
				}
			}
			stage.addEventListener(KeyboardEvent.DOWN, keyboardEvent)
			stage.addEventListener(KeyboardEvent.UP, keyboardEvent)

			var aim = Sprite().attrs {
				resAnim = res.get("aim"),
				pivot = vec2(0.5, 0.5),
				pos = @size/2,
				parent = this
			}
			var fireUpdate = null
			var toFireJoystickLocalPos = function(){
				return @player ? @hud.fireJoystick.size/2 + (aim.pos 
									- @view.pos - @player.pos)/3 : @hud.fireJoystick.size/2
			}
			
			@addEventListener(TouchEvent.START, function(ev){
				if(ev.target != @hud.fireJoystick && ev.target != @hud.moveJoystick){
					@hud.fireJoystick.dispatchEvent {
						type = TouchEvent.START,
						localPosition = toFireJoystickLocalPos()
					}
					fireUpdate = @addUpdate(function(){
						@hud.fireJoystick.dispatchEvent { 
							type = TouchEvent.MOVE,
							localPosition = toFireJoystickLocalPos()
						}
					})
				}
			})
			
			@addEventListener(TouchEvent.MOVE, function(ev){
				aim.pos = ev.localPosition
			})
			
			@addEventListener(TouchEvent.END, function(ev){
				if(fireUpdate){
					@removeUpdate(fireUpdate); fireUpdate = null
					
					@hud.fireJoystick.dispatchEvent { 
						type = TouchEvent.END,
						localPosition = toFireJoystickLocalPos()
					}
				}
			})
		}
				
		@addUpdate(@update.bind(this))
		
		// @activateItem(playerData.defaultWeaponItem)
		// @activateItem(playerData.armorItem)
		
		@loadItems()
		
		var dayParams = @getDayParams(@params.level, @params.invasion, @params.day)
		// print "loaded dayParams: "..dayParams
		@applyDayParams(dayParams)
		@startWave(@params.day, 0)
	},
	
	getDayParams = function(level, invasion, day){
		return DayParams(level, invasion, day).day_params
	},
	
	getMonsterByName = function(nameId){
		nameId = 'ITEM_MONSTER_'..nameId.upper()
		var item = playerData.itemsByNameId[nameId]
		if(item && item.actorParams){
			// print('getMonsterByName '..nameId..' - found')
			return item.actorParams
		}
		print('getMonsterByName '..nameId..' - NOT FOUND')
	},

	getItemByName = function(nameId){
		nameId = 'ITEM_'..nameId.upper()
		var item = playerData.itemsByNameId[nameId]
		if(item && item.actorParams){
			// print('getItemByName '..nameId..' - found')
			return item.actorParams
		}
		print('getItemByName '..nameId..' - NOT FOUND')
	},
	
	loadItems = function(){
		// var startTimeSec = getTimeSec(); print "begin load items"
		playerData.originItems = json.decode(File.readContents("items.json"))
		// var loadedTimeSec = getTimeSec()
		
		var f = toNumber
		
		playerData.itemsById = {}
		playerData.itemsByNameId = {}
		playerData.itemsByTypeId = {}
		// playerData.usedItemsById = {}
		
		playerData.killedCountById = {}
		playerData.collectedCountById = {}
		playerData.usedCountById = {}
		
		// playerData.activeArmorItem = null
		// playerData.activeWeaponItem = null
		
		for(var type_id, originItems in playerData.originItems){
			for(var id, originItem in originItems){
				id = f(id)
				var item = {
					originItem = originItem,
					id = f( originItem['id'] ),
					typeId = f( originItem['type_id'] ),
					durationMS = f( originItem['action_time'] ) * 1000,
					nameId = originItem['name_id'],
					name = originItem['name'],
					desc = originItem['desc'],
					imageId = originItem['image'],
					data = originItem['data'] || {'sounds' = {}},
					count = f( originItem['count'] ),
					ingame = f( originItem['ingame'] ) * 1000
				}								
				playerData.itemsById[id] = item
				playerData.itemsByNameId[item.nameId] = item
				
				if(playerData.itemsByTypeId[item.typeId] === null){
					playerData.itemsByTypeId[item.typeId] = {}
				}
				playerData.itemsByTypeId[item.typeId][id] = item
				
				// loadImages.push({id:item.nameId, url:item.imageId})
				// cm.log('item', type_id, item['type_id'], cm.consts['ITEM_TYPE_MONSTER'], item['image_url'])
				
				var data = item.data
				/* for(var i, sounds in data['sounds']){
					cm.each(sounds, function(i, sound){
						loadSounds.push(sound)
					})
				} */
				
				if(type_id == ITEM_TYPE_MONSTER){
					item.actorParams = {
						itemId = item.id,
						nameId = item.nameId,
						image = {
							id =  item.imageId,
						},
						health = f( originItem['health'] ),
						fire = {
							weaponId = f( originItem['weapon_id'] ),
							damage = f( originItem['health'] ) / 10,
							density = f( originItem['density'] ) / 2,
							speed = f( originItem['speed'] ) * 1.5
							/*
							damage = f( originItem['weapon_damage'] ),
							density = f( originItem['weapon_density'] ),
							speed = f( originItem['weapon_speed'] ),
							*/
						},
						sounds = {
							pain = data['sounds']['pain'],
							death = data['sounds']['death'],
							idle = data['sounds']['idle']
						},
						physics = {
							maxSpeed = f( originItem['speed'] ),
							minSpeed = f( originItem['speed'] ) / 3,
							density = f( originItem['density'] ),
							forcePower = f( originItem['power'] ) * FORCE_SCALE,
							inversePower = f( originItem['power'] ) * FORCE_SCALE * 1.5,
							fly = f( originItem['fly'] ) != 0,
						}
					}
					if(data['physics']){
						var physics = item.actorParams.physics
						if(data['physics']['radiusScale']){
							physics.radiusScale = f( data['physics']['radiusScale'] )
						}
						if(data['physics']['aimOnDamage']){
							physics.aimOnDamage = data['physics']['aimOnDamage']
						}
						if(data['physics']['aimIntervalSec']){
							physics.aimIntervalSec = data['physics']['aimIntervalSec']
						}
						if(data['physics']['aimDurationSec']){
							physics.aimDurationSec = data['physics']['aimDurationSec']
						}
						if(data['physics']['pathWalkDurationSec']){
							physics.pathWalkDurationSec = data['physics']['pathWalkDurationSec']
						}
						if(data['physics']['inverseDurationSec']){
							physics.inverseDurationSec = data['physics']['inverseDurationSec']
						}
					}
					// cm.log('SETUP MONSTER', item)
				}else if(type_id == ITEM_TYPE_ARTEFACT){
					item.weapon_damage_p = f( originItem['weapon_damage_p'] )
					item.weapon_frequency_p = f( originItem['weapon_frequency_p'] )
					item.weapon_speed_p = f( originItem['weapon_speed_p'] )
					item.weapon_density_p = f( originItem['weapon_density_p'] )
					item.weapon_fire_type = originItem['weapon_fire_type']
					item.player_armor_p = f( originItem['player_armor_p'] )
					item.player_health_p = f( originItem['player_health_p'] )
					item.player_speed_p = f( originItem['player_speed_p'] )
					item.monster_health_p = f( originItem['monster_health_p'] )
					item.monster_speed_p = f( originItem['monster_speed_p'] )
					item.actorParams = {
						itemId = item.id,
						nameId = item.nameId,
						image = {
							id =  item.imageId,
						}
					}
				}else if(type_id == ITEM_TYPE_WEAPON){
					item.frequency = f(originItem['frequency'] || 2)
					item.actorParams = {
						itemId = item.id,
						nameId = item.nameId,
						image = {
							id =  item.imageId,
						},
						damage = math.max(1, f( originItem['damage'] )),
						damageCount = math.max(1, f( originItem['damage_count'] )),
						traceCount = math.max(1, f( originItem['trace_count'] )),
						through = f( originItem['through'] ),
						coverPercentage = clamp( f( originItem['cover_p'] ), 2, 100 ),
						sounds = {
							shot = data['sounds']['shot']
						},
						physics = {
							speed = math.max(10, f( originItem['speed'] )),
							density = math.max(0.1, f( originItem['density'] ))
						}
					}
					
					/* if(!playerData.activeWeaponItem || playerData.activeWeaponItem['ingame'] < item['ingame']){
						playerData.activeWeaponItem = item
					} */
				}else if(type_id == ITEM_TYPE_ARMOR){
					item.player_armor_p = f( originItem['player_armor_p'] )
					item.player_speed_p = f( originItem['player_speed_p'] )
					/* if(!playerData.activeArmorItem || playerData.activeArmorItem.ingame < item.ingame){
						playerData.activeArmorItem = item
					} */
					item.actorParams = {
						itemId = item.id,
						nameId = item.nameId,
						image = {
							id =  item.imageId,
						}
					}
				}
			}
		}
		// var endTimeSec = getTimeSec()
		// print('end load items', loadedTimeSec - startTimeSec, endTimeSec - loadedTimeSec, endTimeSec - startTimeSec) // , playerData.itemsByTypeId)
	},
	
	_tileAreas = null,
	getTileAreasByType = function(type){
		return @_tileAreas[type] || @{
			@_tileAreas && throw "there is no type: ${type}"
			@_tileAreas = {}
			var count = @tileAreaCount
			for(var i = 0; i < count; i++){
				var p = @getTileArea(i)
				;(@_tileAreas[p.type] || @_tileAreas[p.type] = [])[] = p
			}
			// print "loadTileAreas: ${@_tileAreas}"
			return @_tileAreas[type] || throw "there is no type: ${type}"
		}
	},
	
	findBestSpawnArea = function(pos){
		pos || pos = @player.pos
		// cm.log("[findBestSpawnArea] pos "+pos.x+" "+pos.y);
		var bestSpawnArea = null
		var bestDist, bestNum = 999999999, -1
		var list = @getTileAreasByType(PHYS_MONSTER_SPAWN)
		var count = #list
		var maxExcludedCount = math.ceil(math.min(count-1, math.max(2, @wave.day/5.0 + @params.invasion-1)))
		while(#@excludedSpawnAreas > maxExcludedCount){
			@excludedSpawnAreas.shift()
		}
		var excludedCount = #@excludedSpawnAreas
		for(var i = 0; i < count; i++){
			var area = list[i]
			
			var isExcludedArea = false;
			for(var j = 0; j < excludedCount; j++){
				if(area == @excludedSpawnAreas[j]){
					isExcludedArea = true
					break;
				}
			}
			if(isExcludedArea){
				continue
			}
			
			var points = [
						  area.pos + area.size/2,
						  /*
						  new cm.Point(area.x, area.y),
						  new cm.Point(area.x + area.width, area.y),
						  new cm.Point(area.x, area.y + area.height),
						  new cm.Point(area.x + area.width, area.y + area.height)
						  */
						  ];
			for(var j = 0; j < #points; j++){
				var p = points[j] - pos
				// cm.log("[findBestSpawnArea] pos: "+pos.x+" "+pos.y);
				var dist = p.x*p.x + p.y*p.y
				if(bestDist > dist){
					bestDist = dist
					bestNum = i
					bestSpawnArea = area
				}
				// cm.log("[findBestSpawnArea] i "+i+", p: "+p.x+" "+p.y+", dist "+dist+", best "+bestNum+", dist "+bestDist);
			}
		}
		// print("[findBestSpawnArea] areas "..#list..", best "..bestNum..", dist "..bestDist)
		@excludedSpawnAreas[] = bestSpawnArea
		return bestSpawnArea
	},
	
	startWave = function(day, phase, maxAliveMonsters){
		print "startWave: ${day}, ${phase}, ${maxAliveMonsters}"
		@wave.time = @time
		@wave.day = day
		@wave.phase = phase
		@wave.completed = false
		@wave.phaseParams = @wave.params.phases[ phase % @wave.params.phases.length ]
		@wave.maxAliveMonsters = math.round(maxAliveMonsters || @wave.phaseParams.maxAliveMonsters 
			|| @wave.params.maxAliveMonsters || 10)
		@wave.phaseMonsters = math.round(@wave.phaseParams.count || 1)
		@wave.phaseMonstersSpawned = 0
		
		@spawnWaveMonsters()
		
		if(phase == 0){
			playerData.startTimeSec = @time // getTimeSec()
			playerData.playTimeSec = 0
			playerData.killedCountById = {}
			playerData.collectedCountById = {}
			playerData.usedCountById = {}

			playerData.healthDamaged = math.max(0, playerData.healthDamaged - playerData.healthRecovered)
			playerData.healthRecovered = 0
			
			playerData.armorDamaged = math.max(0, playerData.armorDamaged - playerData.armorRecovered)
			playerData.armorRecovered = 0

			playerData.meat = math.max(0, math.round(playerData.meat - playerData.healthRecoverMeatUsed))
			playerData.healthRecoverMeatUsed = 0
			
			playerData.money = math.max(0, math.round(playerData.money - playerData.armorRecoverMoneyUsed))
			playerData.armorRecoverMoneyUsed = 0
			
			// cm.callbacks['dayStarted'](@params.level, @params.invasion, @wave.day)
		}
	},

	randAreaPos = function(area, edge){
		edge || edge = 0
		var x = math.random(area.pos.x - edge, area.pos.x + area.size.x + edge)
		var y = math.random(area.pos.y - edge, area.pos.y + area.size.y + edge)
		return vec2(x, y)
	},
	
	isEntityDead = function(ent){
		return !ent || ent.isEntDead
	},
	
	deleteEntity = function(ent){
		if(ent.isEntDead){ // throw "deleteEntity ${ent.classname}: ${ent.desc.image.id} - already dead"
			print "deleteEntity ${ent.classname}#${ent.__id}: ${ent.desc.image.id} - already dead"
			printBackTrace(1)
			print "was killed at time: ${ent.killedAtTime}, cur time: ${@time}"
			printBackTrace(ent.debugBackTrace)
			return
		}
		// ent.classname != "Bullet" && print("deleteEntity ${ent.classname}#${ent.__id}: ${ent.desc.image.id}")
		@destroyEntityPhysics(ent)
		ent.detach()
		ent.isEntDead = true
		ent.debugBackTrace = debugBackTrace(1)
		ent.killedAtTime = @time
		/* print("monsters _externalChildren: ")
		for(var m, i in @layers[LAYER.MONSTERS]._externalChildren){
			print "  [${m.classname}#${m.__id}] = ${i}"
		} */
	},
	
	dieEntity = function(ent){
		print "FAKE dieEntity"
		@deleteEntity(ent)
	},
	
	createBlood = function(ent, count, params, force){
		for(var i, item in @bloodUsedList){
			if(@time - item.time > 0.3){
				delete @bloodUsedList[i]
				continue
			}
			if(!force && item.ent == ent){
				return
			}
		}
		@bloodUsedList[] = {time = @time, ent = ent}
		
		var pos = ent.pos
		for(var i = 0; i < count; i++){
			Blood(this, extend({
				pos = pos,
			}, params))
		}
		var list = @layers[LAYER.BLOOD].childrenList
		var count, maxCount = #list, 200
		for(var i = count - maxCount - 1; i >= 0; i--){
			list[i].fadeOut()
		}
		/* while(#list > 10){
			// print "too many bloods: ${#list}, ${list[0]}"
			@deleteEntity(list[0])
		} */
	},
	
	spawnMonster = function(params, spawnArea){
		spawnArea || spawnArea = @findBestSpawnArea()
		@useMonstersBattle && @monsterSide = (@monsterSide + 1) % 2
		// print "spawnMonster: ${params}, pos: ${@randAreaPos(spawnArea, -10)}"
		// return;
		
		var m = Monster(this, extend({
			pos = @randAreaPos(spawnArea, -10),
			battleSide = @useMonstersBattle ? @monsterSide : false
		}, params))
		/*
		cm.log("[spawnMonster] xy: "+x+" "+y
				+", m-xy:"+m.x+" "+m.y
				+", "+spawnArea.x+" "+spawnArea.y+" "+spawnArea.width+" "+spawnArea.height);
		*/
		// @layers[LAYER.MONSTERS].addChild(m)
	},
	
	animRecover = function(imageId, p1, p2, p3, p4, callback){
		var solveCubic = function(t){
			var t2 = t * t
			var t3 = t * t2
			
			var x = (p1.x + t * (-p1.x * 3 + t * (3 * p1.x-
					p1.x*t)))+t*(3*p2.x+t*(-6*p2.x+
					p2.x*3*t))+t2*(p3.x*3-p3.x*3*t)+
					p4.x * t3
				
			var y = (p1.y+t*(-p1.y*3+t*(3*p1.y-
					p1.y*t)))+t*(3*p2.y+t*(-6*p2.y+
					p2.y*3*t))+t2*(p3.y*3-p3.y*3*t)+
					p4.y * t3
			
			return vec2(x, y)
		}
		
		var sprite = Sprite().attrs {
			resAnim = res.get(imageId),
			parent = @hud, // @layers[LEVEL.EFFECTS]
			pos = p1,
			pivot = vec2(0.5, 0.5),
		}
		
		var delayTime = math.random(0, 0.5)
		var pathDuration = math.random(1.5, 2)
		var level = this
		sprite.addTimeout(delayTime, function(){
			var pathStartTime = level.time
			var updateHandle = sprite.addUpdate(function(){
				var t = (level.time - pathStartTime) / pathDuration
				if(t >= 1){
					sprite.removeUpdate(updateHandle)
					t = 1
				}
				sprite.pos = solveCubic(t)
			})
		})
		sprite.addTimeout(delayTime + pathDuration - 0.4, function(){
			sprite.addTweenAction {
				duration = 0.4,
				opacity = 0,
				detachTarget = true,
				doneCallback = callback
			}
		})
	},
			
	recoverPlayer = function(callback){
		var self = this
		var meatPerHealth = @wave.params.meatPerHealth
		var moneyPerArmor = @wave.params.moneyPerArmor
		var healthToRecover = math.min(playerData.healthDamaged, playerData.meat / meatPerHealth)
		var armorToRecover = math.min(playerData.armorDamaged, playerData.money / moneyPerArmor)
		
		var animMeat = function(count, maxStepCount, dt){
			var stepCount = math.min(maxStepCount, count)
			var first = true
			for(var i = 0; i < stepCount; i++){						
				self.animRecover("meat", 
						vec2(0, 0), // self.hud.meatImage, 
						vec2(self.width*1.0, self.height*0.3),
						vec2(self.width*0.1, self.height*0.4),
						self.hud.face.pos,
						function(){
							if(first){
								self.player.onHappy()
								self.hud.onHappy()
								first = false
							}
							playerData.healthRecovered++;								
							playerData.healthRecoverMeatUsed += meatPerHealth
							if(--count <= 0 && callback){
								// cm.playerData.meat = cm.round(cm.playerData.meat);
								callback()
								callback = null
							}
							// checkFinished();
						}
					)
			}
			if(count - stepCount > 0){
				@addTimeout(dt, function(){ animMeat(count - stepCount, maxStepCount, dt, callback) })
			}
		}
		
		var animMoney = function(count, maxStepCount, dt, callback){
			var stepCount = math.min(maxStepCount, count)
			var first = true
			for(var i = 0; i < stepCount; i++){						
				self.animRecover("money", 
						vec2(self.width, 0), // self.hud.moneyImage, 
						vec2(self.width*0.0, self.height*1.0),
						vec2(self.width*0.9, self.height*-0.7),
						self.hud.armor.pos,
						function(){
							if(first){
								self.player.onHappy()
								self.hud.onHappy()
								first = false
							}
							playerData.armorRecovered++
							playerData.armorRecoverMoneyUsed += moneyPerArmor
							if(--count <= 0 && callback){
								// cm.playerData.money = cm.round(cm.playerData.money);
								callback()
								callback = null
							}
							// checkFinished();
						}
					);
			}
			if(count - stepCount > 0){
				@addTimeout(dt, function(){ animMoney(count - stepCount, maxStepCount, dt, callback) })
			}
		}
		
		var runAnim = function(func, count, callback){
			if(count > 0){
				var maxSteps = 20.0
				var dt = 0.300
				var maxTime = clamp(5 * count / 0.1, 1, 5)
				var steps = math.min(count, maxSteps)
				if(dt * steps > maxTime){
					dt = maxTime / steps
				}
				func(count, math.ceil(count / steps), dt, callback)
				// cm.log('runAnim', count, count / steps, dt, func)
			}else{
				callback()
			}
		};
		
		runAnim(animMoney, armorToRecover, function(){
			runAnim(animMeat, healthToRecover, function(){
				if(armorToRecover > 0 || healthToRecover > 0){
					self.player.onHappy()
					self.hud.onHappy()
				}
				callback()
			})
		})
	},
	
	onWaveCompleted = function(){
		@waveCompletedInProgress && return;
		@waveCompletedInProgress = true
		@addTimeout(1, function(){
			@recoverPlayer(function(){
				playerData.daysCompleted++
				/* var dayResult = {
					'level' = self.params.level, 
					'invasion' = self.params.invasion, 
					'day' = self.wave.day,
					'json_data' = $.JSON.encode(self.getDayResult())
				} */
				// TODO: save progress
					
				@params.day++
				var dayParams = @getDayParams(@params.level, @params.invasion, @params.day)
				print "new day: "..dayParams
				@applyDayParams(dayParams)
				@startWave(@params.day, 0)
				@waveCompletedInProgress = false
			})
		})
	},
	
	spawnWaveMonsters = function(){
		if(@wave.completed){
			return false
		}
		var count = math.min(@wave.phaseMonsters - @wave.phaseMonstersSpawned, 
				@wave.maxAliveMonsters - #@layers[LAYER.MONSTERS])
		// print "spawnWaveMonsters: ${count}"
		if(count > 0){				
			if(@wave.phaseMonsters >= 10 
				&& @wave.phaseMonsters - @wave.phaseMonstersSpawned - count <= 1)
			{
				count = @wave.phaseMonsters - @wave.phaseMonstersSpawned
			}
		
			var spawnArea = @findBestSpawnArea() // undefined, @prevSpawnArea)
			// @prevSpawnArea.push(spawnArea)
			
			// cm.log('[spawnWaveMonsters] clone @wave.phaseParams.monster')
			var monster
			var spawnRandMonster = @wave.phaseParams.monster[0] !== null
			count = math.min(5, count)
			/* debug */ // count *= 10 // count = 1
			for(var i = 0; i < count; i++){
				if(i == 0 || spawnRandMonster){
					if(spawnRandMonster){
						monster = randItem(@wave.phaseParams.monster).clone()
					}else{
						monster = @wave.phaseParams.monster.clone()
					}			
					
					monster.health *= @wave.params.monsterHealthScale || 1
					
					var speedScale = @wave.params.monsterSpeedScale || 1
					monster.physics.minSpeed = (monster.physics.minSpeed || 20) * speedScale
					monster.physics.maxSpeed = (monster.physics.maxSpeed || 100) * speedScale
					
					monster.fire.damage *= @wave.params.monsterFireDamageScale || 1
					monster.fire.speed *= @wave.params.monsterFireBulletSpeedScale || 1
					monster.fire.density *= @wave.params.monsterFireBulletDensityScale || 1
					
					if(@wave.params.monsterAimOnDamage){
						if((monster.physics.aimOnDamage = @wave.params.monsterAimOnDamage) === true){
							// delete monster.physics.inverseDurationSec
						}
					}
				}
				@spawnMonster(monster, spawnArea)
				@wavePhaseMonstersSpawned++
				// print("[wave spawn step] spawned "+@wavePhaseMonstersSpawned)
			}
			@wave.phaseMonstersSpawned += count

			print("[wave spawn] "..@wave.day.." "..@wave.phase
					..", need "..@wave.phaseMonsters
					..", cur spawned "..count
					..", all spawned "..@wave.phaseMonstersSpawned
					..", exist "..#@layers[LAYER.MONSTERS]
					..", max "..@wave.maxAliveMonsters
					)
			
			@wave.completed = @wave.phaseMonstersSpawned >= @wave.phaseMonsters
			return count 
		}
		return 0
	},
	
	applyDayParams = function(dayParams){
		// if(!dayParams) dayParams = {}

		var params
		params = @wave.params = {} // @waveParams[0]
		params.meatPerHealth = math.max(1, dayParams['meat_per_health'] || 1)
		params.moneyPerArmor = math.max(1, dayParams['money_per_armor'] || 1)
		params.maxAliveMonsters =  dayParams['max_alive_monsters']
		params.monsterFireMaxBullets =  dayParams['monster_fire_max_bullets']
		params.monsterFireMinDistance =  dayParams['monster_fire_min_distance']
		params.monsterFireIntervalSec =  dayParams['monster_fire_interval_sec']
		params.monsterFireFrequencyScale =  dayParams['monster_fire_frequency_scale']
		params.monsterFireDamageScale =  dayParams['monster_fire_damage_scale']
		params.monsterFireBulletSpeedScale =  dayParams['monster_fire_bullet_speed_scale']
		params.monsterFireBulletDensityScale =  dayParams['monster_fire_bullet_density_scale']
		params.monsterSpeedScale =  dayParams['monster_speed_scale']
		params.monsterHealthScale =  dayParams['monster_health_scale']
		params.monsterAimOnDamage = dayParams['monster_aim_on_damage']
		
		params.phases = []
		for(local i, dayPhase in dayParams['phases']){
			var phase = {}
			
			phase.count = dayPhase['count']
			phase.maxAliveMonsters = dayPhase['max_alive_monsters']
			
			if(dayPhase['next']){
				phase.next = {
					delaySec = dayPhase['next']['delay_sec'],
					aliveMonsters = dayPhase['next']['alive_monsters']
				}					
			}
			
			if(dayPhase['monster'] is String){
				phase.monster = [ @getMonsterByName(dayPhase['monster']) ]
			}else{
				phase.monster = []
				for(local i, name in dayPhase['monster']){
					phase.monster[] = @getMonsterByName(name)
				}
			}
			params.phases[] = phase
		}

		// print('day params ', params)
	},
	
	initLevelPhysics = function(name){
		var tiledMap = json.decode(File.readContents("level-${@params.level}.json"))
		// print "tiledMap: "..tiledMap
		
		tiledMap.physics = {}
		for(var i = 0; i < #tiledMap.tilesets; i++){
			var tileset = tiledMap.tilesets[i]
			if(tileset.name == "physics-tiles"){
				tiledMap.physics.tileset = tileset
				tiledMap.physics.firstGid = tileset.firstgid
				// cm.log("[firstPhysGid] "+tiledMap.physics.firstGid)
				break
			}
		}
		for(var i = 0; i < #tiledMap.layers; i++){
			var layer = tiledMap.layers[i]
			layer.name == "physics" || continue
			tiledMap.physics.layer = layer
			var width = layer.width
			var height = layer.height
			@setTileWorldSize(width, height)
			for(var x = 0; x < width; x++){
				for(var y = 0; y < height; y++){
					var gid = layer.map[x][y]
					if(gid){
						gid = gid - tiledMap.physics.firstGid
						/* switch(gid){
						case 0: // water
						case 1: // solid
						case 2: // player spawn
						case 3: // monster spawn
						} */ 
						@setTile(x, y, gid)
					}
				}
			}
			break
		}
		@createPhysicsWorld(@view.size)
	},
	
	checkWavePhase = function(){
		if(@time - @checkWaveTime > 1){
			@checkWaveTime = @time
			
			var wave = @wave.params
			var phase = @wave.phaseParams
			
			if(!@wave.completed){
				@spawnWaveMonsters()
				return
			}
			var curMonsters = #@layers[LAYER.MONSTERS]
			if(phase.next){
				if(phase.next.delaySec && @time - @wave.time < phase.next.delaySec){
					return
				}
				if(phase.next.aliveMonsters && curMonsters > phase.next.aliveMonsters){
					return
				}
			}
			if(@wave.phase >= wave.phases.length-1){
				/* 
				var p, m = @player
				print("[checkWavePhase] "+curMonsters
					+(curMonsters == 1 ? ", m: "+(m=@layers[@LAYER.MONSTERS].childrenList[0]).desc.image.id
						+ ", ["+(m.x + m.width / 2)+","+(m.y + m.height / 2)+"]"
						+ ", p: ["+(p.x + p.width / 2)+","+(p.y + p.height / 2)+"]"
						: ""));
				*/
				if(curMonsters == 0){
					@onWaveCompleted()
				}
			}else{
				@startWave(@wave.day, @wave.phase+1)
			}
		}
	},
	
	checkMonsterIdleSound = function(){
		if(@time - @monsterIdleTime >= 2){
			@monsterIdleTime = @time
			var bestDist, bestMonster = 99999999999
			var playerPos = @player.pos
			for(var i, monster in @layers[LAYER.MONSTERS]){
				if(monster.playIdleSound && !@isEntityDead(monster)){
					var dist = #(monster.pos - playerPos)
					if(dist >= @monsterIdleMinDist && dist <= @monsterIdleMaxDist && bestDist > dist){
						bestDist = dist
						bestMonster = monster
					}
				}
			}
			if(bestMonster){
				bestMonster.playIdleSound()
				@hud.onAlert()
			}
		}
	},
	
	updateCamera: function(ev){
		@player || return;
		
		var idealPos = @size / 2 - @player.pos
		var pos = @view.pos
		var move = (idealPos - pos) * 0.25 * ev.dt // (ev.dt * 2)
		// var moveLen = #move
		// var speed = #@player.linearVelocity
		
		pos += move
		// pos = idealPos
		// pos = cm.roundPoint(pos)
		
		var maxOffs = @width * 0.05 // math.round(@width * 0.05)
		if(idealPos.x - pos.x > maxOffs){
			pos.x = idealPos.x - maxOffs
		}else if(idealPos.x - pos.x < -maxOffs){
			pos.x = idealPos.x + maxOffs
		}
		if(idealPos.y - pos.y > maxOffs){
			pos.y = idealPos.y - maxOffs
		}else if(idealPos.y - pos.y < -maxOffs){
			pos.y = idealPos.y + maxOffs
		}
		
		if(@view.width <= @width){
			pos.x = (@width - @view.width) / 2
		}else
		if(pos.x > -@view.startContentOffs.x){
			pos.x = -@view.startContentOffs.x
		}else if(pos.x + @view.width < @width){
			pos.x = @width - @view.width
		}
		if(@view.height <= @height){
			pos.y = (@height - @view.height) / 2
		}else 
		if(pos.y > -@view.startContentOffs.y){
			pos.y = -@view.startContentOffs.y
		}else if(pos.y + @view.height < @height){
			pos.y = @height - @view.height
		}

		// pos.x = math.round(pos.x) // * @view.scaleX)
		// pos.y = math.round(pos.y) // * @view.scaleY)
		
		@view.pos = pos // vec2(math.round(pos.x), math.round(pos.y))
	},
	
	update = function(ev){
		@time = ev.time
		@updatePath(ev)
		if(!@findPathInProgress && @time - @findPathTime >= 0.1){
			var bestTime, bestMonster = 99999999999
			for(var i, monster in @layers[LAYER.MONSTERS].reverseIter()){
				if(bestTime > monster.pathNextTime && @time >= monster.pathNextTime){
					bestTime = monster.pathNextTime
					bestMonster = monster
				}
			}
			if(bestMonster){
				// print "update path of monster: ${bestMonster.desc.image.id} for ${bestMonster.classname}#${bestMonster.__id}"
				bestMonster.updatePath()
			}else{
				// print "monster not found to update path, count: ${#@layers[LAYER.MONSTERS]}"
			}
			@findPathTime = @time
		}
		
		@player.update(ev)
		for(var _, monster in @layers[LAYER.MONSTERS]){
			monster.update(ev)
		}
		/* for(var _, layer in @layers){
			for(var _, child in layer){
				"update" in child && child.update(ev)
			}
		} */

		// @updateActivatedItems()
		@checkWavePhase()
		@checkMonsterIdleSound()
		
		@updatePhysics(ev.dt)
		@updateCamera(ev)
		@hud.update(ev)
	},
	
	playSound = function(params){
		
	},
}
