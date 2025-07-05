return {
    "nvim-treesitter/nvim-treesitter",
    config = function ()
        require'nvim-treesitter.configs'.setup {
            ensure_installed = { "c", "lua", "python", "zig" },
            highlight = {
                enable = true,
            }
        }
    end,
}
