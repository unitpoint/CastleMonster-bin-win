DayParamsException = extends Exception {
}

local function isset(v){
	return v !== null
}

local function empty(v){
	return v === null || v === 0 || v === "" || v === false
}

DayParams = extends Object {
	__object = {
		level = null,
		invasion = null,
		day = null,

		level_def_params = null,
		level_params = null,

		key_day = null,

		start_level = null,
		start_invasion = null,
		start_day = null,

		day_params = null,
	},

    __construct = function(level, invasion, day, user){
        if(level < 1){
            level = 0
            invasion = clamp(invasion + TEST_LEVEL_INVASION-1, 1, INVASION_COUNT)
            day = clamp(day, 1, DAY_COUNT)
        }elseif(invasion < 1 || invasion > INVASION_COUNT || day < 1 || day > DAY_COUNT){
            throw DayParamsException("Params (level, invasion, day) is invalid")
        }

        @level = level
        @invasion = invasion
        @day = day

        filename = "level-params.os"
        if(!File.exists(filename)){
            throw DayParamsException("Def level params file (level, invasion, day) is not found")
        }
        @level_def_params = require(filename)
        if(!objectOf(@level_def_params)){
            throw DayParamsException("Def level params (level, invasion, day) is invalid")
        }

		filename = "level-${level}-params.os"
        // debug
        /* if(level == 1){
            filename = "level-test-params.os"
        } */

        @level_params = File.exists(filename) ? require(filename) : {}
        if(!objectOf(@level_params)){
            throw DayParamsException("Level params (level, invasion, day) is invalid")
        }
        level = math.max(1, level) // test level is 0
        def_start_level = 1

        def_day_params = def_key_day = null
        for(@key_day = day; @key_day >= 1; @key_day--){
            if(isset(@level_params[@key_day])
                    && (empty(@level_params[@key_day]['exact_day']) || @key_day == day))
            {
                @day_params = @level_params[@key_day]
                def_start_level = level
                break
            }
            if(!def_day_params && isset(@level_def_params[@key_day])
                    && (empty(@level_def_params[@key_day]['exact_day']) || @key_day == day))
            {
                def_day_params = @level_def_params[@key_day]
                def_key_day = @key_day
                break
            }
        }
        if(!@day_params && def_day_params){
            @day_params = def_day_params
            @key_day = def_key_day
        }
        if(!@day_params || !objectOf(@day_params) || !objectOf(@day_params['phases'])){
            // CVarDumper::dump(@day_params, 10, 1) exit
            throw DayParamsException("Day params (level, invasion, day) is invalid")
        }

        @start_level = @getParam('level', def_start_level)
        @start_invasion = @getParam('invasion', 1)
        @start_day = @getParam('day', @key_day)

        @scaleParam('monster_speed_scale', 1.15, 1.03, 1.07)
        @scaleParam('monster_health_scale', 1.1, 1.05, 1.1)

        @scaleParam('meat_per_health', 1.1, 1.05, 1.1)
        @scaleParam('money_per_armor', 1.1, 1.05, 1.1)

		@countParam('monster_fire_max_bullets', 20, 1.1, 1.05, 1.05)
		@scaleParam('monster_fire_min_distance', 0.95, 0.95, 0.95)
		@copyParam('monster_fire_interval_sec')
		@scaleParam('monster_fire_frequency_scale', 1.1, 1.05, 1.05)
		@scaleParam('monster_fire_damage_scale', 1.1, 1.05, 1.05)
        @copyParam('monster_fire_bullet_speed_scale')
		@scaleParam('monster_fire_bullet_density_scale', 1.1, 1.05, 1.05)

		@copyParam('monster_aim_on_damage')

		var max_alive_monsters = 30
        @countParam('max_alive_monsters', max_alive_monsters)

        @day_params['monster_fire_min_distance'] = math.max(70, math.round(@day_params['monster_fire_min_distance']))

        @day_params['monster_all_count'] = 0

        // move phases at the end for debug purposes
        var phases = @day_params['phases']
        delete @day_params['phases']
        @day_params['phases'] = phases

        var save_params = [@start_level, @start_invasion, @start_day]
        for(var index, phase in @day_params['phases']){
            @start_level, @start_invasion, @start_day = save_params.unpack()

			var cont = false
            for(var _, name in ['level', 'invasion', 'day']){
                if(isset(phase[name])){
                    if(objectOf(phase[name])){
                        if(@name < phase[name][0] || @name > phase[name][1]){
                            delete @day_params['phases'][index]
                            cont = true
							break
                        }
                        @["start_name"] = phase[name][0]
                    }elseif(@name < phase[name]){
                        delete @day_params['phases'][index]
						cont = true
						break
                    }else{
                        @["start_name"] = phase[name]
                    }
                    delete phase[name]
                }
            }
			cont && continue
            // CVarDumper::dump(array(@day, @start_day, @getCount(10, 100)), 10, 1)
            if(isset(phase['monster'])){
                phase['monster'] = @filterItems(phase['monster'])
            }

            /* if(isset(phase['item'])){
                phase['item'] = @filterItems(phase['item'])
            } */

            if(!isset(phase['monster']) && !isset(phase['item'])){
                delete @day_params['phases'][index]
                continue
            }

            if(isset(phase['max_alive_monsters'])){
                phase['max_alive_monsters'] = @getCount(phase['max_alive_monsters'], max_alive_monsters)
            }
            if(isset(phase['next']['alive_monsters'])){
                phase['next']['alive_monsters'] = @getCount(phase['next']['alive_monsters'], max_alive_monsters)
            }
            phase['count'] = @getCount(phase['count'], max_alive_monsters)
            if(phase['count'] < 1){
                delete @day_params['phases'][index]
                continue
            }
            @day_params['monster_all_count'] += phase['count']

        }
        @day_params['phases'] = @day_params['phases'].values

        if(user && user.levels < 2){
            @day_params['monster_fire_max_bullets'] = 0
        }

        var count = #@day_params['phases']
        if(count >= 1){
            if(@level > 0 && user){
                probability = 0.7

				/*
                user_max_level = Yii::app()->db->createCommand()
                        ->select('max(level) as level')
                        ->from('{{invasion}}')
                        ->where('user_id=:user_id', array(':user_id' => user->id))
                        ->queryScalar()
                user_max_level = math.min(MAX_PROBABILITY_LEVEL, user_max_level)
                if(@level < user_max_level && user_max_level > 0){
                    probability *= math.min(1, 1.5 * (float)@level / user_max_level)
                }

                user_level_invasion = Yii::app()->db->createCommand()
                        ->select('invasion, day_completed')
                        ->from('{{invasion}}')
                        ->where('user_id=:user_id AND level=:level', array(':user_id' => user->id, ':level' => @level))
                        ->queryRow()
                if(user_level_invasion){
                    if(@invasion < user_level_invasion['invasion'] && user_level_invasion['invasion'] > 0){
                        probability *= math.min(1, 1.5 * (float)@invasion / user_level_invasion['invasion'])
                    }
                    if(@day < user_level_invasion['day_completed'] && user_level_invasion['day_completed'] > 0){
                        probability *= math.min(1, 1.5 * (float)@day / user_level_invasion['day_completed'])
                    }
                }
				*/

                r = math.random()
                // Yii::trace("Rand item prob probability, ".(r > probability ? 'false' : 'true')." (r), level @level @invasion @day, pick level user_max_level"
                //         . (user_level_invasion ? " {user_level_invasion['invasion']} {user_level_invasion['day_completed']}" : ''))
                if(r > probability){
                    return
                }
            }
			/*
            item = Item::getRandItemForUser(user)
            if(item){
                i = floor(count/2)
                if(!isset(@day_params['phases'][i]['item'])){
                    @day_params['phases'][i]['item'] = preg_replace("#^item_#", '', strtolower(item->name))
                }
            }
			*/
        }
    },

    filterItems = function(items){
        if(objectOf(items)){
            for(var item_name, filter in items){
                if(objectOf(filter)){
                    delete items[item_name]
					var cont = false
                    for(var _, name in ['level', 'invasion', 'day']){
                        if(isset(filter[name])){
                            if(objectOf(filter[name])){
                                if(@name < filter[name][0] || @name > filter[name][1]){
                                    cont = true
									break
                                }
                            }elseif(@name < filter[name]){
								cont = true
								break
                            }
                        }
                    }
					cont && continue
                    items[] = item_name
                }
            }
        }
        return items
    },

    copyParam = function(name, def_value){
        @day_params[name] = @getParam(name, def_value)
    },

    scaleParam = function(name, b, invasion_power, level_power){
		invasion_power || invasion_power = 1.5
		level_power || level_power = 1.5
        var save_params = [@start_level, @start_invasion, @start_day]
        @day_params[name] = @getParam(name, null, true) * @getScale(b, invasion_power, level_power)
        @start_level, @start_invasion, @start_day = save_params.unpack()
    },

    countParam = function(name, max, b, invasion_power, level_power){
		b || b = 3.0
		invasion_power || invasion_power = 1.5
		level_power || level_power = 1.5
        var save_params = [@start_level, @start_invasion, @start_day]
        @day_params[name] = @getCount(@getParam(name, null, true), max, b, invasion_power, level_power)
        @start_level, @start_invasion, @start_day = save_params.unpack()
    },

    getParam = function(name, def_value, update_start_params){
        if(isset(@day_params[name])){
            return @day_params[name]
        }
        if(isset(@level_params[name])){
            if(update_start_params){
                @start_day = 1
                @start_invasion = 1
            }
            return @level_params[name]
        }
        if(isset(@level_def_params[name])){
            if(update_start_params){
                @start_day = 1
                @start_invasion = 1
                @start_level = 1
            }
            return @level_def_params[name]
        }
        return def_value
    },

    getCount = function(count, max, b, invasion_power, level_power){
		b || b = 2.0
		invasion_power || invasion_power = 1.4
		level_power || level_power = 1.4
        var min_delta = math.max(0, @day - @start_day)
                        + math.max(0, @invasion - @start_invasion)
                        + math.max(0, @level - @start_level)
        return math.round(math.min(max, math.max(count + min_delta, count * @getScale(b, invasion_power, level_power))))
    },

    getScale = function(b, invasion_power, level_power){
        a = 1.0
		invasion_power || invasion_power = 1.5
		level_power || level_power = 1.5
        level_power = math.pow(level_power, math.max(0, @level - @start_level))
        invasion_power = math.pow(invasion_power, math.max(0, @invasion - @start_invasion))
        var day_value = @getInterpolated({1 = a, [DAY_COUNT] = b}, @day)
		// print "day_value: "..day_value
        if(@start_day <= @day){
            var start_day_value = @getInterpolated({1 = a, [DAY_COUNT] = b}, @start_day)
			// print "start_day_value: "..start_day_value
            // day_value /= start_day_value
			day_value = day_value / start_day_value
        }
        return day_value * invasion_power * level_power
    },

    getInterpolated = function(keys, need_key){
        var selected_keys = {}
        for(var key, value in keys){
            if(key <= need_key && (!isset(selected_keys[0]) || selected_keys[0]['key'] < key)){
                selected_keys[0] = {
                    'key' = key,
                    'value' = value,
                }
            }
            if(key >= need_key && (!isset(selected_keys[1]) || selected_keys[1]['key'] > key)){
                selected_keys[1] = {
                    'key' = key,
                    'value' = value,
                }
            }
        }
		// print "selected_keys: "..selected_keys
        if(isset(selected_keys[0]) && isset(selected_keys[1])){
            var a, b = selected_keys.unpack()
            if(a['key'] == b['key']){
                return a['value']
            }
            var t = (need_key - a['key']) / (b['key'] - a['key'])
            return a['value'] + (b['value'] - a['value']) * t
        }
        if(isset(selected_keys[0])){
            return selected_keys[0]['value']
        }
        return selected_keys[1]['value']
    }
}