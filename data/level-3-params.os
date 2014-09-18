return {
	1 = {
		'phases' = {
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 10, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'lion_salamandra', 'serenivii', 'pumpkin', 'wood_elf', 'little_lemon' },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
			{
                'day' = 2,
				'monster' = { 'lion_salamandra', },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
			{
                'day' = {1, 9},
				'monster' = { 'mountain_pangolin', 'firicrazy' },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
			{
                'day' = {10, 19},
				'monster' = { 'mountain_pangolin', 'firicrazy' },
				'count' = 5,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
			{
                'day' = 20,
				'monster' = { 'mountain_pangolin', 'firicrazy' },
				'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				// 'day' = {1, 10},
				// 'max_alive_monsters' = 2,
				'monster' = { 'pumpkin', },
				'count' = 2,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
			{
                'day' = 5,
				'monster' = { 'little_lemon', },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
			{
				'monster' = { 'serenivii', },
				'count' = 2,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
            {
				'day' = 10, // {4, 6},
				'monster' = { 'zmeyacherepaha' },
				'count' = 1,
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 20, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'fishmen' },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 29, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'carnivorous_flower' },
				'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
			{
				// 'level' = 2,
				// 'invasion' = 3,
				'day' = 25, // {4, 6},
				// 'max_alive_monsters' = 2,
				'monster' = { 'lion_salamandra', 'serenivii', 'pumpkin', 'wood_elf', 'little_lemon', 'fishmen', 'zmeyacherepaha', 'mountain_pangolin' },
				'count' = 20,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 2,
				},
			},
		},
	},
    10 = {
        'exact_day' = true,
        'phases' = {
			{
				'monster' = { 'zmeyacherepaha' },
				'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 1,
				},
			},
			{
				'monster' = { 'pumpkin' },
				'count' = 10,
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
				'monster' = { 'fishmen' },
				'count' = 4,
				'next' = {
					'delay_sec' = 2.0,
					// 'alive_monsters' = 1,
				},
			},
			{
				'monster' = { 'lion_salamandra', 'serenivii', 'pumpkin' },
				'count' = 20,
				'next' = {
					'delay_sec' = 2.0,
					'alive_monsters' = 2,
				},
			},
        },
    },
}