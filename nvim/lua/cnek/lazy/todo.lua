return {
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
        event = "BufReadPost",
        config = function()
            require("todo-comments").setup({
                signs = false,
                highlight = {
                    keyword = "wide_bg",  -- Try wide_bg instead of wide
                    after = "fg",
                    priority = 200,
                    comments_only = false,
                },
                colors = {
                    error = "#DC2626",
                    warning = "#FBBF24",
                    info = "#2563EB",
                    hint = "#10B981",
                    default = "#7C3AED",
                },
                keywords = {
                    TODO = { icon = " ", color = "info" },
                    HACK = { icon = " ", color = "warning" },
                    WARN = { icon = " ", color = "error", alt = { "WARNING" } },
                    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                },
            })

            vim.defer_fn(function()
                vim.api.nvim_set_hl(0, "TodoBgTODO", { fg = "#ffffff", bg = "#5ad6b1", bold = true })
                vim.api.nvim_set_hl(0, "TodoBgWARN", { fg = "#ffffff", bg = "#eba234", bold = true })
                vim.api.nvim_set_hl(0, "TodoBgFIX", { fg = "#ffffff", bg = "#f03e68", bold = true })
                vim.api.nvim_set_hl(0, "TodoBgNOTE", { fg = "#ffffff", bg = "#5aa4d6", bold = true })
            end, 100)
        end
    }
}
