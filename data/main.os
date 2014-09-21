print "--"
print "[start] ${DateTime.now()}"

GAME_SIZE = vec2(960, 540)

var displaySize = stage.size
var scale = displaySize / GAME_SIZE
// scale = math.max(scale.x, scale.y)
scale = math.min(scale.x, scale.y)
stage.size = displaySize / scale
stage.scale = scale

// dump(_G)

function getTimeSec(){
	return DateTime.now().comtime
}

function clamp(a, min, max){
	return a < min ? min : a > max ? max : a
}

function randItem(items){
	if(arrayOf(items)){
		return items[math.random(#items)]
	}
	if(items.prototype === Object){
		var keys = items.keys
		return items[keys[math.random(#keys)]]
	}
	return items
}

function randSign(){
	return math.random()*2-1
}

function randTime(time, scale){
	if(time[0]){
		return math.random(time[0], time[1]) * (scale || 1)
	}
	return time * (1 + randSign()*0.1) * (scale || 1)
}

function TileArea.valueOf(){
	return {type = @type, pos = @pos, size = @size}.valueOf()
}

function extend(a, b, clone_result){
	if(b === null){
		return a.deepClone()
	}
	if(!!objectOf(b) != !!objectOf(a)){
		return b.deepClone()
	}
	if(clone_result !== false){
		a = a.deepClone()
	}
	for(var key, item in b){
		if(objectOf(item)){
			var val
			if((val = a[key]) && objectOf(val)){
				a[key] = extend(val, item, false)
			}else{
				a[key] = item.deepClone()
			}
		}else{
			a[key] = item
		}
	}
	return a
}

playerData = {
	__get = function(name){
		throw "property \"${name}\" not found in \"${@__name || @classname}\""
	},

	money = 0,
	meat = 0,
	enemyKilled = 0,
	
	health = 100,
	armor = 100,
	
	healthDamaged = 0,
	armorDamaged = 0,
	// damaged = 0,
	damagedTime = 0,
	
	healthRecovered = 0,
	armorRecovered = 0,

	healthRecoverMeatUsed = 0,
	armorRecoverMoneyUsed = 0,
	
	armorItem = null,
	defaultWeaponItem = null,
	
	// items = {},
	originItems = {},
	itemsById = {},
	itemsByNameId = {},
	itemsByTypeId = {},
	
	killedCountById = {},
	collectedCountById = {},
	usedCountById = {},
	
	startTimeSec = 0,
	playTimeSec = 0,
	daysCompleted = 0,
	
	activeItems = {},
	activeArtefacts = {},
	activeArmors = {},
	activeWeapons = {},
	
	effects = {
		scale = {
			weaponDamage = 1.0,
			weaponFrequency = 1.0,
			weaponSpeed = 1.0,
			weaponDensity = 1.0,
			playerArmor = 1.0,
			playerHealth = 1.0,
			playerSpeed = 2.0, // 1.0,
			monsterHealth = 1.0,
			monsterSpeed = 1.0
		},
		weaponFireType = 0
	}
}

TEST_LEVEL_INVASION = 3
INVASION_COUNT = 30
DAY_COUNT = 30

FORCE_SCALE = 20 // TO_PHYS_SCALE * 200
PLAYER_FORCE_SCALE = 10 // TO_PHYS_SCALE * 100

GameLevel(5, 1, 3).attachTo(stage)

