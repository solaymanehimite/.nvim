return {
    'Mofiqul/vscode.nvim',
    name = "vscode",
    priority = 1000,
    config = function()
        require("vscode").setup({
            transparent = true
        })
    end

}
