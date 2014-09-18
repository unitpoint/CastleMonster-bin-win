
/**
 * CastleMonsters OS2D game
 * Copyright (c} 2015 Evgeniy Golovin <evgeniy.golovin@unitpoint.ru>
 */

return {
	// 'level' = 5,
    'meat_per_health' = 3,
    'money_per_armor' = 2,
    'max_alive_monsters' = 7, // 20,
    'monster_fire_max_bullets' = 5,
    'monster_fire_min_distance' = 100,
    'monster_fire_interval_sec' = 1.0,
    'monster_fire_frequency_scale' = 1.0,
    'monster_fire_damage_scale' = 1.0,
    'monster_fire_bullet_speed_scale' = 1.0,
    'monster_fire_bullet_density_scale' = 1.0,
    'monster_speed_scale' = 1.0,
    'monster_health_scale' = 1.0,
    'monster_aim_on_damage' = 'inverse',
	1 = {
		'phases' = {
			{
				// 'level' = 2,
				// 'invasion' = 3,
				// 'day' = 4,
				// 'max_alive_monsters' = 2,
				'monster' = { 'wood_elf', 'little_lemon' },
				'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 1,
				},
			},
        },
    },
}