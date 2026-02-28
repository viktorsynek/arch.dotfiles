vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>zm", vim.cmd.ZenMode)

vim.keymap.set('n', '<leader>bc', function()
    local line = vim.api.nvim_get_current_line()
    local new_line

    if line:match('true') then
        new_line = line:gsub('true', 'false')
    elseif line:match('false') then
        new_line = line:gsub('false', 'true')
    end

    if new_line then
        vim.api.nvim_set_current_line(new_line)
    end
end)

vim.keymap.set('n', '<leader>y', '"+Y', { desc = 'Paste from clipboard with proper indenting' })
vim.keymap.set('v', '<leader>y', '"+Y', { desc = 'Paste from clipboard with proper indenting' })

vim.keymap.set('n', '<leader>p', '"+P', { desc = 'Paste from clipboard with proper indenting' })
vim.keymap.set('v', '<leader>p', '"+P', { desc = 'Paste from clipboard with proper indenting' })

