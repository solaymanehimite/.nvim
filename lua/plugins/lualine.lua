return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        -- require('lualine').setup(
        --     {
        --         sections = {
        --             lualine_a = { 'mode' },
        --             lualine_b = { 'branch', 'diff', },
        --             lualine_c = { 'filename' },
        --             lualine_x = { 'filetype' },
        --             lualine_y = { 'diagnostics' },
        --             lualine_z = { 'location' }
        --         },
        --     }
        -- )
    end
}
