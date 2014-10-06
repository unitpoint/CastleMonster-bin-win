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
		
		if(params.image.id == "blood-2"){
			@opacity = 0.5
		}
		var normOpacity = @opacity
		
		@resAnimFrameNum = math.random(0, @resAnim.totalFrames)
		@parent = @level.layers[LAYER.BLOOD]
		
		var updateHandle = @addUpdate(0.5, function(){
			if(!@isAwake){
				print "remove blood physics ${@__id}"
				@level.destroyEntityPhysics(this)
				@removeUpdate(updateHandle)
				updateHandle = null
			}
		})
		
		@opacity = 0
		@addAction(SequenceAction(
			TweenAction {
				name = "tween",
				duration = 0.2,
				opacity = normOpacity,
			},
			TweenAction {
				name = "tween",
				duration = math.random(3, 7),
				scale = 1.3,
				opacity = 0.8 * normOpacity,
				ease = Ease.QUAD_OUT,
			},
		))
		
		@timeoutHandle = @addTimeout(math.random(60, 120), function(){
			@timeoutHandle = null
			@replaceTweenAction {
				name = "tween",
				opacity = 0,
				duration = math.random(10, 20),
				doneCallback = function(){
					@level.deleteEntity(this)
				}
			}
		})
	},
	
	fadeOut = function(){
		if(@timeoutHandle){ @removeTimeout(@timeoutHandle); @timeoutHandle = null }
		@replaceTweenAction {
			name = "tween",
			opacity = 0,
			duration = 0.1,
			doneCallback = function(){
				@level.deleteEntity(this)
			}
		}
	},
	
	onPhysicsContact = function(){
	
	},
}
