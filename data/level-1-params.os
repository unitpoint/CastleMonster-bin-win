return {
	1 = {
		'phases' = {
            {
                'day' = 30,
                'monster' = 'firicrazy',
                'count' = 5,
            },
			{
				// 'level' = 2,
				// 'invasion' = 3,
				// 'day' = {1, 10},
				// 'max_alive_monsters' = 2,
				'monster' = { 'wood_elf', 'little_lemon',
                    'serenivii' = { 'day' = 10 },
                    'lion_salamandra' = { 'day' = 25 },
                 },
				'count' = 5,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 1,
				},
			},
            {
                'day' = {9, 9},
                'monster' = 'firicrazy',
                'count' = 1,
            },
            {
                'day' = {19, 19},
                'monster' = 'fishmen',
                'count' = 1,
            },
            {
                'day' = {24, 24},
                'monster' = 'strekoza_cherep',
                'count' = 1,
            },
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 4, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'wood_elf', 'serenivii', 'little_lemon' },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 20, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'serenivii', 'lion_salamandra' },
				'count' = 5,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
		},
	},
    4 = {
        'exact_day' = true,
        'phases' = {
			{
				'monster' = { 'serenivii' },
				'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
        },
    },
    20 = {
        'exact_day' = true,
        'phases' = {
			{
				'monster' = { 'lion_salamandra' },
				'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
			{
				'monster' = { 'serenivii' },
				'count' = 5,
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
				'monster' = { 'lion_salamandra', 'serenivii' },
				'count' = 30,
			},
        },
    },
}