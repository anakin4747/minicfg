
vim.g.mapleader = ' '
vim.g.loaded_netrwPlugin = 1

-- options {{{ see :help options or :h 'number'
local options = {
    backup = false,
    clipboard = 'unnamedplus',
    cmdheight = 0,
    dictionary = '/usr/share/dict/american-english,/usr/share/dict/french',
    expandtab = true,
    foldmethod = 'indent',
    hlsearch = false,
    incsearch = true,
    laststatus = 0,
    list = true,
    number = true,
    path = '**',
    relativenumber = true,
    ruler = false,
    scrollback = 1000000,
    scrolloff = 9,
    shiftwidth = 4,
    showcmd = false,
    showmode = false,
    showtabline = 0,
    signcolumn = 'number',
    smartindent = true,
    splitbelow = true,
    splitright = true,
    swapfile = false,
    tabstop = 4,
    termguicolors = true,
    textwidth = 79,
    undofile = true,
    virtualedit = 'all',
    winborder = 'rounded',
    wrap = false,
}

for option, value in pairs(options) do
    vim.o[option] = value
end
-- }}}

local function man()
    vim.cmd('vert Man ' .. vim.fn.expand('<cword>'))
end

local function oldfiles()
    local qflist = {}
    for _, filename in ipairs(vim.v.oldfiles) do
        table.insert(qflist, { filename = filename })
    end
    vim.fn.setqflist(qflist, 'r')
    vim.cmd('copen')
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

    { { 'n', 'i', 'x', 'v', 't' }, '<C-h>', vim.fn['next_bufs#PrevTermBuf'],    'Previous terminal buffer' },
    { { 'n', 'i', 'x', 'v', 't' }, '<C-l>', vim.fn['next_bufs#NextTermBuf'],    'Next terminal buffer' },
    { { 'n', 'v' },                '<S-h>', vim.fn['next_bufs#PrevNonTermBuf'], 'Previous non-terminal buffer' },
    { { 'n', 'v' },                '<S-l>', vim.fn['next_bufs#NextNonTermBuf'], 'Next non-terminal buffer' },

    { 't', '<S-h><S-h><S-h>', vim.fn['next_bufs#PrevNonTermBuf'], 'Previous non-terminal buffer' },
    { 't', '<S-l><S-l><S-l>', vim.fn['next_bufs#NextNonTermBuf'], 'Next non-terminal buffer' },

    { { 'n', 't', }, '<C-b>s', '<C-\\><C-n>:split +terminal<cr>i',      'Open a terminal below' },
    { { 'n', 't', }, '<C-b>v', '<C-\\><C-n>:vert split +terminal<cr>i', 'Open a terminal on the right' },

    { 'n', '<leader>of', oldfiles, 'Open a quickfix list of :oldfiles' },

    { 't', '<C-w>', '<C-\\><C-n><C-w>', 'Escape <C-w> in terminal mode' },
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
        vim.cmd([[ %s/\s\+$//e ]])
        vim.fn.winrestview(view)
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'highlight selection on yank',
    callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'TermEnter', 'TermLeave' }, {
    desc = 'cd to terminal cwd on enter',
    pattern = 'term://*',
    callback = function()
        local cwd = vim.fn.resolve('/proc/' .. vim.b.terminal_job_pid .. '/cwd')
        if vim.fn.isdirectory(cwd) == 1 then
            vim.fn.chdir(cwd)
        end
    end,
})

vim.api.nvim_create_autocmd('BufLeave', {
    desc = 'restore scrolloff when leaving a terminal buffer',
    pattern = 'term://*',
    callback = function() vim.o.scrolloff = options.scrolloff end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'try to start treesitter for supported filetypes',
    callback = function() pcall(vim.treesitter.start) end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'set keywordprg for vim files',
    pattern = 'vim',
    command = [[ setlocal keywordprg=:vert\ help ]],
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'set tab to 1 to enable folding by indent',
    pattern = 'man',
    command = [[ setlocal sw=1 ts=1 ]],
})

vim.api.nvim_create_autocmd('BufEnter', {
    desc = 'unfold folds on buffer enter',
    command = [[ silent! normal zR ]],
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
    make = { 'make-language-server' },
    nix = { 'nil' },
    python = { 'pyright-langserver', '--stdio' },
    rust = { 'rust-analyzer' },
    systemd = { 'systemd-language-server' },
    tex = { 'texlab' },
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

    'https://github.com/anakin4747/resize.vim.git',
    'https://github.com/anakin4747/next_bufs.vim.git',

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
    highlight markdownError NONE
]])

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })

require('nvim-treesitter').install('unstable')
-- }}}
