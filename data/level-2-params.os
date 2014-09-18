return {
    1 = {
        'exact_day' = true,
        'phases' = {
			{
				'monster' = { 'pumpkin' },
				'count' = 5,
			},
        },
    },
	2 = {
		'phases' = {
			{
				'monster' = { 'pumpkin' },
				'count' = 5,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
            /* {
                'monster' = 'firicrazy',
                'count' = 2,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 1,
				},
            }, */
			{
				// 'level' = 2,
				// 'invasion' = 3,
				// 'day' = {1, 10},
				// 'max_alive_monsters' = 2,
				'monster' = { 'little_lemon', 'firicrazy',
                    'pumpkin' = { 'day' = 5 },
                    'serenivii' = { 'day' = 10 },
                    'lion_salamandra' = { 'day' = 15 },
                    'wood_elf' = { 'day' = 25 },
                 },
				'count' = 4,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
            {
				'day' = 30, // {4, 6},
				'monster' = { 'mountain_pangolin' },
				'count' = 3,
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 20, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'pumpkin', 'wood_elf' },
				'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 25, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'firicrazy' },
				'count' = 5,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
		},
	},
    10 = {
        'exact_day' = true,
        'phases' = {
			{
				'monster' = { 'pumpkin' },
				'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
			{
				'monster' = { 'firicrazy' },
				'count' = 2,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
        },
    },
    29 = {
        'exact_day' = true,
        'phases' = {
            {
				'monster' = { 'mountain_pangolin' },
				'count' = 3,
			},
            {
				'monster' = { 'firicrazy', 'lion_salamandra', 'serenivii', 'pumpkin', 'wood_elf', 'little_lemon' },
				'count' = 30,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
        },
    },
}