return {
    11 = {
        'exact_day' = true,
        'phases' = {
            {
                'monster' = {'blue_bug'},
                'count' = 10,
            },
            {
                'monster' = {'twinkle'},
                'count' = 10,
            },
            {
                'monster' = {'serenivii'},
                'count' = 10,
            },
            {
                'monster' = {'strekoza_cherep'},
                'count' = 10,
            },
        },
    },
    10 = {
        'exact_day' = true,
        'phases' = {
            {
                // 'monster' = {'fishmen', 'firicrazy', 'zmeyacherepaha'},
                'monster' = {'serenivii', 'strekoza_cherep'},
                'count' = 50,
            },
        },
    },
    9 = {
        'exact_day' = true,
        'phases' = {
            {
                // 'monster' = {'fishmen', 'firicrazy', 'zmeyacherepaha'},
                'monster' = {'little_lemon', 'twinkle', 'pumpkin', 'white_wolf'},
                'count' = 40,
            },
        },
    },
	1 = {
		'phases' = {
            {
                'day' = 20,
                'monster' = {'little_lemon', 'twinkle', 'pumpkin', 'white_wolf', 'serenivii', 'strekoza_cherep'},
                'count' = 3,
            },
            {
                'day' = 15,
                'monster' = 'mountain_pangolin',
                'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {11, 12},
                'monster' = {'blue_bug'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 13,
                'monster' = {'blue_bug'},
                'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {7, 8},
                'monster' = {'fishmen', 'firicrazy'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 9,
                'monster' = {'fishmen', 'firicrazy'},
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {6, 7},
                'monster' = {'little_lemon', 'twinkle'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 8,
                'monster' = {'little_lemon', 'twinkle'},
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {5, 6},
                'monster' = {'wood_elf', 'serenivii'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 7,
                'monster' = {'wood_elf', 'serenivii'},
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {4, 5},
                'monster' = {'strekoza_cherep', 'lion_salamandra'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 6,
                'monster' = {'strekoza_cherep', 'lion_salamandra'},
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {3, 4},
                'monster' = {'pumpkin', 'white_wolf'},
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 5,
                'monster' = {'pumpkin', 'white_wolf'},
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {2, 3},
                'monster' = 'carnivorous_flower',
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {4, 10},
                'monster' = 'carnivorous_flower',
                'count' = 1,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 13,
                'monster' = 'carnivorous_flower',
                'count' = 2,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = {1, 2},
                'monster' = 'arbyz',
                'count' = 10,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
            {
                'day' = 3,
                'monster' = 'arbyz',
                'count' = 3,
				'next' = {
					'delay_sec' = 2.0,
				},
            },
        },
    },
}