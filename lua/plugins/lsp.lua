return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",

        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local lspconfig_defaults = require("lspconfig").util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            "force",
            lspconfig_defaults.capabilities,
            require("cmp_nvim_lsp").default_capabilities()
        )

        -- sources
        local cmp = require("cmp")
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            sources = {
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
                { name = "nvim_lua" },
                { name = "luasnip" },
            },
            mapping = cmp.mapping.preset.insert({
                ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                ["<C-d>"] = cmp.mapping.scroll_docs(4),
                -- Jump to the next snippet placeholder
                ["<C-f>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")
                    if luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                -- Jump to the previous snippet placeholder
                ["<C-b>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = { "menu", "abbr", "kind" },
                format = function(entry, item)
                    local menu_icon = {
                        nvim_lsp = "<>",
                        luasnip = " #",
                        buffer = "[]",
                        path = ":/",
                        nvim_lua = "@",
                    }

                    item.menu = menu_icon[entry.source.name]
                    return item
                end,
            },
        })

        -- autoformat method
        local buffer_autoformat = function(bufnr)
            local group = "lsp_autoformat"
            vim.api.nvim_create_augroup(group, { clear = false })
            vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                group = group,
                desc = "LSP format on save",
                callback = function()
                    -- note: do not enable async formatting
                    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                end,
            })
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
                vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
                vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
                vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
                vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
                vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
                vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
                vim.keymap.set("n", "<C-R>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
                vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
                vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

                -- format on save
                local id = vim.tbl_get(event, "data", "client_id")
                local client = id and vim.lsp.get_client_by_id(id)
                if client == nil then
                    return
                end

                -- make sure there is at least one client with formatting capabilities
                if client.supports_method("textDocument/formatting") then
                    buffer_autoformat(event.buf)
                end
            end,
        })

        require("mason").setup({})
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "pylsp" },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
            },
        })

        -- fix Undefined global: 'vim'
        require("lspconfig").lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                },
            },
        })

        vim.diagnostic.config({
            virtual_text = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "E",
                    [vim.diagnostic.severity.WARN] = "W",
                    [vim.diagnostic.severity.HINT] = "H",
                    [vim.diagnostic.severity.INFO] = "I",
                },
            },
        })
    end,
}
