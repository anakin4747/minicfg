
vim.g.mapleader = ' '

-- options {{{ see :help options or :h 'number'
local options = {
    number = true,
    relativenumber = true,
    wrap = false,
    textwidth = 79,
    virtualedit = 'all',
    scrolloff = 9,
    list = true,
    shiftwidth = 4,
    tabstop = 4,
    smartindent = true,
    expandtab = true,
    hlsearch = false,
    incsearch = true,
    undofile = true,
    swapfile = false,
    backup = false,
    signcolumn = 'number',
    winborder = 'rounded',
    clipboard = 'unnamedplus',
    termguicolors = true,
    splitbelow = true,
    splitright = true,
    path = '**',
    dictionary = '/usr/share/dict/american-english,/usr/share/dict/french',
    foldmethod = 'indent',
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

local function man()
    vim.cmd('vert Man ' .. vim.fn.expand('<cword>'))
end

-- diagnostics {{{ see :h diagnostic
local function next_diagnostic(backwards)
    local count = backwards and -1 or 1
    vim.diagnostic.jump({ count = count, float = true })
end
-- }}}

-- keymaps {{{ see :h map or :h vim.keymap.set
local keymaps = {
    { 'n', 'gd', '<C-]>', 'goto definition' },
    { 'n', 'J', 'mzJ`z', 'Keeps cursor in place when using `J`' },
    { 'n', '<C-d>', '<C-d>zz', 'Center after <C-d>' },
    { 'n', '<C-u>', '<C-u>zz', 'Center after <C-u>' },
    { 'n', 'n', 'nzzzv', 'Center after next match' },
    { 'n', 'N', 'Nzzzv', 'Center after previous match' },
    { 't', '<esc><esc>', '<C-\\><C-n>', 'double escape to escape terminal mode' },
    { 'n', '[d', function() next_diagnostic(true) end, 'Go to previous error' },
    { 'n', ']d', function() next_diagnostic(false) end, 'Go to next error' },
    { 'n', '<leader>K', man, 'Open Man Page for word undercursor' },
}

for _, keymap in pairs(keymaps) do
    local modes, lhs, rhs, desc = unpack(keymap)
    vim.keymap.set(modes, lhs, rhs, { remap = false, desc = desc })
end
-- }}}

-- autocmds {{{ see :h autocmd
vim.api.nvim_create_autocmd('BufWritePre', {
    desc = 'clear trailing whitespace on write',
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
    end
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'highlight selection on yank',
    callback = function() vim.hl.on_yank() end
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'TermEnter' }, {
    desc = 'cd to terminal cwd on enter',
    pattern = 'term://*',
    callback = function()
        vim.fn.chdir(vim.fn.resolve(
            '/proc/' .. vim.b.terminal_job_pid .. '/cwd'
        ))
    end
})
-- }}}

-- lsps {{{ see :h lsp
local server_commands = {
    automake = { 'autotools-language-server' },
    awk = { 'awk-language-server' },
    sh = { 'bash-language-server', 'start' },
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
    'https://github.com/nvim-treesitter/nvim-treesitter.git',

    'https://github.com/github/copilot.vim.git',
    'https://github.com/anakin4747/ai.nvim.git',
    'https://github.com/olimorris/codecompanion.nvim.git',
})

require('codecompanion').setup()
-- }}}

-- colorscheme {{{
vim.cmd([[
    colorscheme gruvbox
    highlight! link Folded LineNr
]])

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })

require('nvim-treesitter').install('unstable')
-- }}}
