
-- options {{{ see :help options or :h 'number'
local options = {
    number = true,              -- Show line number
    relativenumber = true,      -- Show line numbers relative to current line
    wrap = false,               -- Don't wrap long lines
    textwidth = 79,             -- Go to new line after 80 characters
    virtualedit = "all",        -- Ability to move anywhere
    scrolloff = 9,              -- Keep a 9 space gap between cursor and window border
    list = true,                -- Show all whitespace
    shiftwidth = 4,             -- Specifies indent width
    tabstop = 4,                -- Specifies how many spaces in a tab
    smartindent = true,         -- Automatic indenting
    expandtab = true,           -- Always expand tabs to spaces
    hlsearch = false,           -- After searching remove highlight
    incsearch = true,           -- Show incremental matches while searching
    undofile = true,            -- Make undo history persist exiting vim
    swapfile = false,           -- Don't use swapfiles
    backup = false,             -- Don't save .bak backups
    signcolumn = "number",      -- Place errors over number columns to avoid jitter
    winborder = "rounded",      -- Set rounded floating window borders
    clipboard = "unnamedplus",  -- Use system clipboard for EVERYTHING
    termguicolors = true,       -- Enables 24-bit RGB color
    splitbelow = true,          -- Open new horizontal windows below
    splitright = true,          -- Open new vertical windows to the right
    background = "dark",
    path = '**',                -- Make gf recursive

    -- Add english and french dictionary for spelling
    -- you will need to install these with your package manager
    dictionary = "/usr/share/dict/american-english,/usr/share/dict/french",

    -- Maybe only use once you know the folding keybindings
    foldmethod = "indent",      -- Fold based on indents

    -- Clean ui
    -- only recommed this for more experienced users
    cmdheight = 0,
    showcmd = false,
    ruler = false,
    showmode = false,
    showtabline = 0,
    laststatus = 0,
}

for option, value in pairs(options) do
    vim.o[option] = value
end
-- }}}

-- diagnostics {{{ see :h diagnostic

-- This will display diagnostics after each line
-- vim.diagnostic.config({ virtual_text = true })
-- or
-- This will display diagnostics in the line below
-- vim.diagnostic.config({ virtual_lines = true })

local function next_diagnostic(backwards)
    local count = backwards and -1 or 1
    vim.diagnostic.jump({ count = count, float = true })
end
-- }}}

-- keymaps {{{ see :h map or :h vim.keymap.set
local keymaps = {
    { 'n', 'gd', '<C-]>', 'goto definition' },
    { 't', '<esc><esc>', '<C-\\><C-n>', 'double escape to escape terminal mode' },
    { 'n', '[d', function() next_diagnostic(true) end, 'Go to previous error' },
    { 'n', ']d', function() next_diagnostic(false) end, 'Go to next error' },
}

for _, keymap in pairs(keymaps) do
    local modes, lhs, rhs, desc = unpack(keymap)
    vim.keymap.set(modes, lhs, rhs, { remap = false, desc = desc })
end
-- }}}

-- autocmds {{{ see :h autocmd
vim.api.nvim_create_autocmd('BufWritePre', {
    desc = "clear trailing whitespace on write",
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
    end
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "highlight selection on yank",
    callback = function() vim.hl.on_yank() end
})
-- }}}

-- lsps {{{ see :h lsp
local server_commands = {
    automake = { 'autotools-language-server' },
    awk = { 'awk-language-server' },
    bash = { 'bash-language-server', 'start' },
    bitbake = { 'language-server-bitbake', '--stdio' },
    c = { 'clangd' },
    cmake = { 'cmake-language-server' },
    cpp = { 'clangd' },
    dockerfile = { 'docker-language-server', 'start', '--stdio' },
    dot = { 'dot-language-server', '--stdio' },
    dts = { 'devicetree-language-server', '--stdio' },
    go = { 'gopls' },
    javascript = { 'typescript-language-server', '--stdio' },
    kconfig = { 'kconfig-language-server' },
    lua = { 'lua-language-server' },
    make = { 'autotools-language-server' },
    nix = { 'nil' },
    python = { 'pyright-langserver', '--stdio' },
    rust = { 'rust-analyzer' },
    systemd = { 'systemd-language-server' },
    typescript = { 'typescript-language-server', '--stdio' },
    typst = { 'tinymist' },
    yaml = { 'yaml-language-server', '--stdio' },
}

for filetype, command in pairs(server_commands) do
    vim.lsp.config(filetype, {
        root_markers = { '.git' },
        filetypes = { filetype },
        cmd = command,
    })
    vim.lsp.enable(filetype)
end
-- }}}

-- plugins {{{ see :h vim.pack
vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim.git',
    'https://github.com/tpope/vim-fugitive.git',
    'https://github.com/ellisonleao/gruvbox.nvim.git',
    'https://github.com/anakin4747/ai.nvim',
    'https://github.com/olimorris/codecompanion.nvim.git',
})

require("codecompanion").setup()
-- }}}

-- colorscheme {{{
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
-- }}}
