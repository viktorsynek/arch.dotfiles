return {
    "numToStr/Comment.nvim",
    opts = {},
    keys = {
        {
            "<leader>c",
            function()
                require("Comment.api").toggle.linewise.current()
            end,
            mode = "n",
            desc = "Comment line",
        },
        {
            "<leader>c",
            "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
            mode = "x",
        }

    },
}

