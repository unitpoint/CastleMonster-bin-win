Blood = extends Entity {
	__construct = function(level, params){
		super(level)
		
		params = extend({
			// center = pos,
			image = { 
				id = "blood-monster", 
				size = [4, 4]
				// animation = [ randItem(activeFrames) ]
			},
			// shape = false,
			angle = 360 * math.random(),
			targetDir = vec2(randSign(), randSign()).normalize(),
			spawnOffs = math.random(5, 20),
			physics = {
				radiusScale = 1.0,
				speed = 5 + randSign()*5,
				density = 1.0,
				linearDamping = math.random(0.925, 0.975), // 1 - (0.05 + randSign()*0.025),
				categoryBits = PHYS_CAT_BIT_BLOOD,
				ignoreBits = PHYS_CAT_BIT_ALL & ~(PHYS_CAT_BIT_STATIC | PHYS_CAT_BIT_WATER)
			},
		}, params)
		
		// print "spawn blood: ${params}"
		@initEntity(params)
		
		@resAnimFrameNum = math.random(0, @resAnim.totalFrames)
		@parent = @level.layers[LAYER.BLOOD]
		
		@addTweenAction {
			name = "tween",
			duration = math.random(3, 7),
			scale = 1.3,
			opacity = 0.8,
			ease = Ease.QUAD_OUT,
		}
		
		@addTimeout(math.random(8, 15), function(){
			@replaceTweenAction {
				name = "tween",
				opacity = 0,
				duration = math.random(5, 10),
				doneCallback = function(){
					@level.deleteEntity(this)
				}.bind(this)
			}
		}.bind(this))
	},
	
	onPhysicsContact = function(){
	
	},
}
