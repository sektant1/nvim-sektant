-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>D', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Move to left window' })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = 'Move to right window' })

-- Resize splits with Ctrl+Arrow keys
vim.keymap.set('n', '<C-Up>', '<C-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<C-w>-', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', '<C-w><', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<C-w>>', { desc = 'Increase window width' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local uv = vim.uv or vim.loop

local cpp_flags = {
  '-std=c++20',
  '-O2',
  '-Wall',
  '-Wextra',
  '-Wpedantic',
  '-g',
}

local function compile_and_run_current_cpp_term()
  vim.cmd 'write'
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    return
  end

  local file_dir = vim.fn.fnamemodify(file, ':h')
  local root = vim.fn.fnamemodify(file_dir, ':h') -- parent of /src
  local out_dir = root .. '/bin/debug'
  local out = out_dir .. '/' .. vim.fn.fnamemodify(file, ':t:r')

  -- Ensure output directory exists
  vim.fn.mkdir(out_dir, 'p')

  local compile_cmd = table.concat(
    vim.tbl_flatten {
      'g++',
      cpp_flags,
      { vim.fn.shellescape(file), '-o', vim.fn.shellescape(out) },
    },
    ' '
  )

  local run_cmd = vim.fn.shellescape(out)

  local full = string.format('%s && %s', compile_cmd, run_cmd)

  vim.cmd 'botright split | resize 12'
  vim.cmd('term ' .. full)
end

vim.keymap.set('n', '<leader>cf', compile_and_run_current_cpp_term, { desc = 'Compile & run current C++ file' })

local function open_root_cmakelists()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start_dir = (bufname ~= '' and vim.fs.dirname(bufname)) or uv.cwd()

  local root = vim.fs.root(start_dir, { '.git' }) or start_dir

  local target = root .. '/CMakeLists.txt'

  if uv.fs_stat(target) then
    vim.cmd('edit ' .. vim.fn.fnameescape(target))
  else
    vim.notify('No root CMakeLists.txt found at: ' .. target, vim.log.levels.WARN)
  end
end

vim.keymap.set('n', '<leader>cm', open_root_cmakelists, {
  desc = 'Open project root CMakeLists.txt',
})

local map = vim.keymap.set

map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'which_key_ignore' })
map({ 'n', 'x' }, '<leader>D', '"+d', { desc = 'which_key_ignore' })
map({ 'v', 'x', 'n' }, '<C-y>', '"+y', { desc = 'which_key_ignore' })

-- vim.keymap.set('n', '<leader>q', ':bdelete<cr>', { desc = 'which_key_ignore' })
-- vim.keymap.set('n', '<leader>Q', '<Cmd>wqa<CR>', { desc = 'Quit all and write' })
vim.keymap.set('n', '<leader>w', '<Cmd>update<CR>', { desc = 'which_key_ignore' })
vim.keymap.set('n', '<leader>q', '<Cmd>quit<CR>', { desc = 'which_key_ignore' })
vim.keymap.set('n', '<leader>O', '<Cmd>restart<CR>', { desc = 'which_key_ignore' })
vim.keymap.set('n', '<leader>o', '<Cmd>source %<CR>', { desc = 'which_key_ignore' })

map({ 'n', 'v', 'x' }, '<leader>sv', '<Cmd>edit $MYVIMRC<CR>', { desc = 'init.lua' })
map({ 'n', 'v', 'x' }, '<leader>sz', '<Cmd>e ~/.bashrc<CR>', { desc = '.bashrc' })

-- Move lines/blocks
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move line down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move line up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move line down (insert)' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move line up (insert)' })
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move block down' })
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move block up' })

-- editing conveniences
map('n', 'o', "<cmd>:call append(line('.'), '')<CR>")
map('n', 'O', "<cmd>:call append(line('.')-1, '')<CR>")
map('n', 'Y', 'y$', { desc = 'Yank to end of line' })
map('n', 'D', 'd$', { desc = 'Delete to end of line' })
map('v', 'H', '^', { desc = 'Start of line' })
map('v', 'L', '$', { desc = 'End of line' })
map('x', '<leader>P', [["_dP]], { desc = 'Replace selection with buffer' })
map('v', 'p', '"_dP', opts)

map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

map({ 'n', 'v', 'x' }, ';', ':', { desc = 'Command mode' })
map({ 'n', 'v', 'x' }, ':', ';', { desc = 'Repeat last f/t' })
map({ 'n', 'v', 'x' }, '<C-s>', [[:s/\V]], { desc = 'Substitute in selection' })
-- map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "Run normal command" })

-- vim.keymap.set('n', '<leader>pi"', 'vi"p', { noremap = false })
-- vim.keymap.set('n', "<leader>pi'", "vi'p", { noremap = false })
-- vim.keymap.set('n', '<leader>pi(', 'vi(p', { noremap = false })
-- vim.keymap.set('n', '<leader>pi{', 'vi{p', { noremap = false })
-- vim.keymap.set('n', '<leader>pi[', 'vi[p', { noremap = false })
-- vim.keymap.set('n', '<leader>pib', 'vibp', { noremap = false })

-- tmux passthrough
vim.keymap.set('n', '<M-b>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-b' }
end)
vim.keymap.set('n', '<M-r>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-r' }
end)
vim.keymap.set('n', '<M-d>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-d' }
end)
vim.keymap.set('n', '<M-t>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-t' }
end)

-- -- tabs
-- map({ 'n' }, '<leader>n', '<Cmd>tabnew<CR>', { desc = 'Tab new' })
-- map({ 'n' }, '<leader>x', '<Cmd>tabclose<CR>', { desc = 'Tab close' })
-- map({ 'n' }, '<leader><S-Tab>', '<Cmd>tabprevious<CR>', { desc = 'which_key_ignore' })
-- map({ 'n' }, '<leader><Tab>', '<Cmd>tabnext<CR>', { desc = 'which_key_ignore' })
-- for i = 1, 4 do
--   map({ 'n' }, '<leader>' .. i, '<Cmd>tabnext ' .. i .. '<CR>', { desc = 'which_key_ignore' })
-- end

-- file managers / OS
-- map('n', '<leader>e', '<Cmd>Yazi<CR>', { desc = 'File Tree' })
map('n', '<C-f>', '<Cmd>Open .<CR>', { desc = 'Open in OS Finder' })
map('n', '<leader>a', ':edit #<CR>', { desc = 'which_key_ignore' })

-- LSP / diagnostics / quickfix
-- map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
map('n', '<C-q>', ':copen<CR>', { silent = true })
map('n', '<leader>d', function()
  vim.diagnostic.open_float()
end, { desc = 'Diagnostic float' })

-- ── Jest / Neotest (<leader>j) ────────────────────────────────────────────────
map('n', '<leader>jt', function()
  require('neotest').output_panel.open()
  require('neotest').run.run()
end, { desc = 'Run nearest test' })
map('n', '<leader>jf', function()
  require('neotest').output_panel.open()
  require('neotest').run.run(vim.fn.expand '%')
end, { desc = 'Run test file' })
map('n', '<leader>jl', function()
  require('neotest').output_panel.open()
  require('neotest').run.run_last()
end, { desc = 'Run last test' })
map('n', '<leader>jd', function()
  require('neotest').run.run { strategy = 'dap' }
end, { desc = 'Debug nearest test' })
map('n', '<leader>jx', function()
  require('neotest').run.stop()
end, { desc = 'Stop test run' })
map('n', '<leader>js', function()
  require('neotest').summary.toggle()
end, { desc = 'Toggle summary panel' })
map('n', '<leader>jo', function()
  require('neotest').output_panel.toggle()
end, { desc = 'Toggle output panel' })
map('n', ']j', function()
  require('neotest').jump.next { status = 'failed' }
end, { desc = 'Next failed test' })
map('n', '[j', function()
  require('neotest').jump.prev { status = 'failed' }
end, { desc = 'Prev failed test' })

-- ── Harpoon (<leader>m) ──────────────────────────────────────────────────────
local function harpoon_ui()
  local harpoon = require 'harpoon'
  harpoon.ui:toggle_quick_menu(harpoon:list())
end

map('n', '<leader>ma', function()
  require('harpoon'):list():add()
end, { desc = 'Add file' })
map('n', '<leader>mm', harpoon_ui, { desc = 'Menu' })
map('n', '<leader>mf', function()
  local harpoon = require 'harpoon'
  harpoon.extensions.telescope.telescope(harpoon:list())
end, { desc = 'Find in telescope' })
map('n', '<leader>1', function()
  require('harpoon'):list():select(1)
end, { desc = 'Harpoon file 1' })
map('n', '<leader>2', function()
  require('harpoon'):list():select(2)
end, { desc = 'Harpoon file 2' })
map('n', '<leader>3', function()
  require('harpoon'):list():select(3)
end, { desc = 'Harpoon file 3' })
map('n', '<leader>4', function()
  require('harpoon'):list():select(4)
end, { desc = 'Harpoon file 4' })

-- ── Terminal splits (<leader>t) ──────────────────────────────────────────────
local vterm_buf, vterm_win = nil, nil
map('n', '<leader>v', function()
  if vterm_win and vim.api.nvim_win_is_valid(vterm_win) then
    vim.api.nvim_win_close(vterm_win, false)
    vterm_win = nil
  else
    vim.cmd 'vsplit | vertical resize 50'
    if vterm_buf and vim.api.nvim_buf_is_valid(vterm_buf) then
      vim.api.nvim_win_set_buf(0, vterm_buf)
    else
      vim.cmd 'term'
      vterm_buf = vim.api.nvim_get_current_buf()
    end
    vterm_win = vim.api.nvim_get_current_win()
    vim.cmd 'startinsert'
  end
end, { desc = 'Toggle terminal vsplit' })

local hterm_buf, hterm_win = nil, nil
map('n', '<leader>h', function()
  if hterm_win and vim.api.nvim_win_is_valid(hterm_win) then
    vim.api.nvim_win_close(hterm_win, false)
    hterm_win = nil
  else
    vim.cmd 'split | resize 15'
    if hterm_buf and vim.api.nvim_buf_is_valid(hterm_buf) then
      vim.api.nvim_win_set_buf(0, hterm_buf)
    else
      vim.cmd 'term'
      hterm_buf = vim.api.nvim_get_current_buf()
    end
    hterm_win = vim.api.nvim_get_current_win()
    vim.cmd 'startinsert'
  end
end, { desc = 'Toggle terminal hsplit' })

-- ── HTTP / Kulala (<leader>h) ─────────────────────────────────────────────────
map('n', '<leader>Hh', function()
  require('kulala').run()
end, { desc = 'Run request' })
map('n', '<leader>Ha', function()
  require('kulala').run_all()
end, { desc = 'Run all requests' })
map('n', '<leader>Hn', function()
  require('kulala').jump_next()
end, { desc = 'Next request' })
map('n', '<leader>Hp', function()
  require('kulala').jump_prev()
end, { desc = 'Prev request' })
map('n', '<leader>Hc', function()
  require('kulala').copy()
end, { desc = 'Copy as curl' })
map('n', '<leader>Hi', function()
  require('kulala').inspect()
end, { desc = 'Inspect request' })
-- vim: ts=2 sts=2 sw=2 et
