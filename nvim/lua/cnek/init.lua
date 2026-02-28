require("cnek.set")
require("cnek.remap")
require("cnek.lazy_init")

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('BufEnter', {
    group = ThePrimeagenGroup,
    callback = function()
        if vim.bo.filetype == "zig" then
            ColorMyPencils("tokyonight-night")
        else
            ColorMyPencils("rose-pine-moon")
        end
    end
})

autocmd('LspAttach', {
    group = ThePrimeagenGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.opt.paste = false -- Don't start in paste mode

vim.api.nvim_create_autocmd("InsertEnter", {
    group = ThePrimeagenGroup,
    pattern = "*",
    callback = function()
        if vim.opt.paste:get() then
            vim._backup_formatoptions = vim.opt.formatoptions:get()
            vim._backup_autoindent = vim.opt.autoindent:get()
            vim._backup_smartindent = vim.opt.smartindent:get()
            vim.opt.formatoptions:remove({ "r", "o" }) -- Don't auto-continue comments
            vim.opt.autoindent = false
            vim.opt.smartindent = false
        end
    end
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = ThePrimeagenGroup,
    pattern = "*",
    callback = function()
        if vim._backup_formatoptions then
            vim.opt.formatoptions = vim._backup_formatoptions
            vim._backup_formatoptions = nil
        end
        if vim._backup_autoindent ~= nil then
            vim.opt.autoindent = vim._backup_autoindent
            vim._backup_autoindent = nil
        end
        if vim._backup_smartindent ~= nil then
            vim.opt.smartindent = vim._backup_smartindent
            vim._backup_smartindent = nil
        end
    end
})

vim.opt.formatoptions:remove({ "r", "o" })
