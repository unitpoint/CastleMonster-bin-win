HealthProgressBar = extends Actor {
	__object = {
		_progress = -1,
	},
	
	__construct = function(bar, fill){
		bar || bar = "hud-bar-bg"
		fill || fill = "hud-bar-fill"
		
		bar is ResAnim || bar = res.get(bar)
		fill is ResAnim || fill = res.get(fill)
		
		@bg = Sprite().attrs {
			resAnim = bar,
			priority = 1,
			parent = this,
			pivot = vec2(0, 0),
			pos = vec2(0, 0),
		}
		@fill = Sprite().attrs {
			resAnim = fill,
			priority = 0,
			parent = this,
			pivot = vec2(0, 0),
			pos = vec2(0, 0),
		}
		@fill.scale = @bg.size / @fill.size
		@fillFullScaleX = @fill.scaleX
		@size = @bg.size
		@progress = 1
	},
	
	__get@progress = function(){
		return @_progress
	},
	
	__set@progress = function(t){
		if(!t){
			print "t: ${t}, playerData: ${playerData}"
			throw "attempt set progress to ${t}"
		}
		// t || throw "attempt progress set to ${t}"
		// print "[${@__name}] progress set to ${t}"
		t = clamp(t, 0, 1)
		t == @_progress && return;
		if(t >= 0.7){
			var color = Color(0, 0.78, 0)
		}else if(t >= 0.35){
			var color = Color(0.78, 0.78, 0)
		}else{
			var color = Color(0.78, 0, 0)
		}
		@_progress = t
		@fill.color = color
		@fill.scaleX = @fillFullScaleX * t
	},
}
