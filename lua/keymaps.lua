vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)
vim.keymap.set("n", "<leader><leader>", ":source<CR>")

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<tab>", ":tabnext<CR>")
vim.keymap.set("n", "<S-tab>", ":tabprev<CR>")

vim.keymap.set("n", "<C-c>", "<Esc>")
