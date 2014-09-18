return {
    1 = {
        // 'invasion' = TEST_LEVEL_INVASION,
        'phases' = {
            {
                'invasion' = TEST_LEVEL_INVASION,
                'monster' = { 'wood_elf', 'little_lemon',
                    'serenivii' = { 'day' = 1 },
                    'lion_salamandra' = { 'day' = 1 },
                 },
                'count' = 7,
                'next' = {
                    'delay_sec' = 2.0,
                    // 'alive_monsters' = 3,
                },
            },
            {
                'invasion' = TEST_LEVEL_INVASION,
                'day' = 2,
                'monster' = 'white_wolf',
                'count' = 2,
                'next' = {
                    'delay_sec' = 1.0,
                    // 'alive_monsters' = 2,
                },
            },
            {
                'invasion' = TEST_LEVEL_INVASION,
                'day' = 2,
                'monster' = 'strekoza_cherep',
                'count' = 1,
                'next' = {
                    'delay_sec' = 1.0,
                    // 'alive_monsters' = 2,
                },
            },
            {
                'invasion' = TEST_LEVEL_INVASION,
                'day' = 2,
                'monster' = 'mountain_pangolin',
                'count' = 1,
                'next' = {
                    'delay_sec' = 1.0,
                    // 'alive_monsters' = 2,
                },
            },
        }
    },
}