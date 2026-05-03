-- ============================================================================
-- Master keymap file. ALL keybinds (core + plugins) live here.
-- Plugin specs in lua/custom/plugins and lua/kickstart/plugins should NOT
-- contain `keys = {}` or `vim.keymap.set` — add them below instead.
-- Plugins are still lazy-loaded via `event`, `cmd`, or `ft`. Plugin functions
-- are wrapped in callbacks so the plugin only loads when the key is pressed.
-- ============================================================================

local map = vim.keymap.set
local uv = vim.uv or vim.loop

-- ── Core editor ─────────────────────────────────────────────────────────────
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<C-D>', vim.diagnostic.setloclist, { desc = 'Open diagnostic Quickfix list' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window resize
map('n', '<C-Up>', '<C-w>+', { desc = 'Increase window height' })
map('n', '<C-Down>', '<C-w>-', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<C-w><', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<C-w>>', { desc = 'Increase window width' })

-- Yank / delete to system
map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'which_key_ignore' })
map({ 'n', 'x' }, '<leader>D', '"+d', { desc = 'which_key_ignore' })
map({ 'v', 'x', 'n' }, '<C-y>', '"+y', { desc = 'which_key_ignore' })

-- File save / quit / source
map('n', '<leader>w', '<Cmd>update<CR>', { desc = 'which_key_ignore' })
map('n', '<leader>q', '<Cmd>quit<CR>', { desc = 'which_key_ignore' })
map('n', '<leader>O', '<Cmd>restart<CR>', { desc = 'which_key_ignore' })
map('n', '<leader>o', '<Cmd>source %<CR>', { desc = 'which_key_ignore' })
map({ 'n', 'v', 'x' }, '<leader>sv', '<Cmd>edit $MYVIMRC<CR>', { desc = 'init.lua' })
map({ 'n', 'v', 'x' }, '<leader>sz', '<Cmd>e ~/.bashrc<CR>', { desc = '.bashrc' })

-- Move lines/blocks
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move line down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move line up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move line down (insert)' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move line up (insert)' })
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move block down' })
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move block up' })

-- Editing conveniences
map('n', 'o', "<cmd>:call append(line('.'), '')<CR>")
map('n', 'O', "<cmd>:call append(line('.')-1, '')<CR>")
map('n', 'Y', 'y$', { desc = 'Yank to end of line' })
map('n', 'D', 'd$', { desc = 'Delete to end of line' })
map('v', 'H', '^', { desc = 'Start of line' })
map('v', 'L', '$', { desc = 'End of line' })
map('x', '<leader>P', [["_dP]], { desc = 'Replace selection with buffer' })

map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

map({ 'n', 'v', 'x' }, ';', ':', { desc = 'Command mode' })
map({ 'n', 'v', 'x' }, ':', ';', { desc = 'Repeat last f/t' })
map({ 'n', 'v', 'x' }, '<C-s>', [[:s/\V]], { desc = 'Substitute in selection' })

-- tmux passthrough
map('n', '<M-b>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-b' }
end)
map('n', '<M-r>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-r' }
end)
map('n', '<M-d>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-d' }
end)
map('n', '<M-t>', function()
  vim.fn.system { 'tmux', 'send-keys', 'M-t' }
end)

-- File managers / OS
map('n', '<leader>e', '<Cmd>Yazi<CR>', { desc = 'Yazi (file dir)' })
map('n', '<leader>E', '<Cmd>Yazi cwd<CR>', { desc = 'Yazi (cwd)' })
-- map('n', '<leader>cw', '<Cmd>Yazi toggle<CR>', { desc = 'Yazi (resume)' })
map('n', '\\', '<Cmd>Yazi<CR>', { desc = 'Yazi' })
map('n', '<C-f>', '<Cmd>Open .<CR>', { desc = 'Open in OS Finder' })
map('n', '<leader>a', ':edit #<CR>', { desc = 'Alternate file' })

-- Diagnostics / quickfix
map('n', '<C-q>', ':copen<CR>', { silent = true })
map('n', '<leader>d', function()
  vim.diagnostic.open_float()
end, { desc = 'Diagnostic float' })

-- Markdown preview
-- map('n', '<leader>mp', '<CMD>PeekOpen<CR>', { desc = 'Toggle Markdown Preview' })

-- ── C++ compile & run / CMakeLists open ─────────────────────────────────────
local cpp_flags = { '-std=c++20', '-O2', '-Wall', '-Wextra', '-Wpedantic', '-g' }

local function compile_and_run_current_cpp_term()
  vim.cmd 'write'
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    return
  end
  local file_dir = vim.fn.fnamemodify(file, ':h')
  local root = vim.fn.fnamemodify(file_dir, ':h')
  local out_dir = root .. '/bin/debug'
  local out = out_dir .. '/' .. vim.fn.fnamemodify(file, ':t:r')
  vim.fn.mkdir(out_dir, 'p')
  local compile_cmd = table.concat(vim.tbl_flatten { 'g++', cpp_flags, { vim.fn.shellescape(file), '-o', vim.fn.shellescape(out) } }, ' ')
  local run_cmd = vim.fn.shellescape(out)
  vim.cmd 'botright split | resize 12'
  vim.cmd('term ' .. string.format('%s && %s', compile_cmd, run_cmd))
end

map('n', '<F8>', compile_and_run_current_cpp_term, { desc = 'Compile & run current C++ file' })

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

map('n', '<F2>', open_root_cmakelists, { desc = 'Open project root CMakeLists.txt' })

-- ── Yank highlight autocmd ──────────────────────────────────────────────────
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ============================================================================
-- Plugin keymaps
-- ============================================================================

-- ── vim-tmux-navigator (C-h/j/k/l) ──────────────────────────────────────────
map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Navigate left' })
map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Navigate down' })
map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Navigate up' })
map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Navigate right' })

-- ── Telescope (<leader>s*) ──────────────────────────────────────────────────
local function tb()
  return require 'telescope.builtin'
end
map('n', '<leader>sh', function()
  tb().help_tags()
end, { desc = 'Search Help' })
map('n', '<leader>sk', function()
  tb().keymaps()
end, { desc = 'Search Keymaps' })
map('n', '<leader><leader>', function()
  tb().find_files()
end, { desc = 'Search Files' })
map('n', '<leader>st', function()
  tb().builtin()
end, { desc = 'Search Select Telescope' })
map('n', '<leader>sw', function()
  tb().grep_string()
end, { desc = 'Search current Word' })
map('n', '<leader>sg', function()
  tb().live_grep()
end, { desc = 'Search by Grep' })
map('n', '<leader>sd', function()
  tb().diagnostics()
end, { desc = 'Search Diagnostics' })
map('n', '<leader>sr', function()
  tb().resume()
end, { desc = 'Search Resume' })
map('n', '<leader>sT', function()
  tb().colorscheme()
end, { desc = 'Search Theme' })
map('n', '<leader>s.', function()
  tb().oldfiles()
end, { desc = 'Search Recent Files' })
map('n', '<leader>sb', function()
  tb().buffers()
end, { desc = 'Search Buffers' })
map('n', '<leader>sp', function()
  require('telescope').extensions.projects.projects {}
end, { desc = 'Search Projects' })
map('n', '<leader>ss', function()
  tb().current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
end, { desc = 'Grep in current buffer' })
map('n', '<leader>s/', function()
  tb().live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = 'Search in Open Files' })
map('n', '<leader>sn', function()
  tb().find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Search Neovim files' })

-- ── Harpoon (<leader>m, <leader>1-4) ────────────────────────────────────────
map('n', '<leader>ma', function()
  require('harpoon'):list():add()
end, { desc = 'Add file' })
map('n', '<leader>mm', function()
  local h = require 'harpoon'
  h.ui:toggle_quick_menu(h:list())
end, { desc = 'Menu' })
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

-- ── terminal splits ─────────────────────────────

local function term_split(direction, size)
  local cwd = vim.fn.getcwd()
  if direction == 'vertical' then
    vim.cmd('vsplit | vertical resize ' .. size)
  else
    vim.cmd('botright split | resize ' .. size)
  end
  vim.cmd 'enew'
  vim.fn.jobstart(vim.o.shell, { term = true, cwd = cwd })
  vim.cmd 'startinsert'
end

map('n', '<leader>|', function()
  term_split('vertical', 50)
end, { desc = 'Vertical terminal (50, cwd)' })
map('n', '<leader>-', function()
  term_split('horizontal', 15)
end, { desc = 'Horizontal terminal (15, cwd)' })

-- ── Neotest / Jest (<leader>j) ──────────────────────────────────────────────
local function nt()
  return require 'neotest'
end
map('n', '<leader>jt', function()
  nt().output_panel.open()
  nt().run.run()
end, { desc = 'Run nearest test' })
map('n', '<leader>jf', function()
  nt().output_panel.open()
  nt().run.run(vim.fn.expand '%')
end, { desc = 'Run test file' })
map('n', '<leader>jl', function()
  nt().output_panel.open()
  nt().run.run_last()
end, { desc = 'Run last test' })
map('n', '<leader>jd', function()
  nt().run.run { strategy = 'dap' }
end, { desc = 'Debug nearest test' })
map('n', '<leader>jx', function()
  nt().run.stop()
end, { desc = 'Stop test run' })
map('n', '<leader>js', function()
  nt().summary.toggle()
end, { desc = 'Toggle summary panel' })
map('n', '<leader>jo', function()
  nt().output_panel.toggle()
end, { desc = 'Toggle output panel' })
map('n', ']j', function()
  nt().jump.next { status = 'failed' }
end, { desc = 'Next failed test' })
map('n', '[j', function()
  nt().jump.prev { status = 'failed' }
end, { desc = 'Prev failed test' })

-- -- ── Kulala HTTP (<leader>H) ─────────────────────────────────────────────────
-- map('n', '<leader>Hh', function()
--   require('kulala').run()
-- end, { desc = 'Run request' })
-- map('n', '<leader>Ha', function()
--   require('kulala').run_all()
-- end, { desc = 'Run all requests' })
-- map('n', '<leader>Hn', function()
--   require('kulala').jump_next()
-- end, { desc = 'Next request' })
-- map('n', '<leader>Hp', function()
--   require('kulala').jump_prev()
-- end, { desc = 'Prev request' })
-- map('n', '<leader>Hc', function()
--   require('kulala').copy()
-- end, { desc = 'Copy as curl' })
-- map('n', '<leader>Hi', function()
--   require('kulala').inspect()
-- end, { desc = 'Inspect request' })

-- ── Git: fugitive + lazygit (<leader>g) ─────────────────────────────────────
map('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status' })
map('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = 'Git blame' })
map('n', '<leader>gd', '<cmd>Gvdiffsplit<cr>', { desc = 'Git diff split' })
map('n', '<leader>gl', '<cmd>Git log --oneline<cr>', { desc = 'Git log' })
map('n', '<leader>gp', '<cmd>Git push<cr>', { desc = 'Git push' })
map('n', '<leader>gP', '<cmd>Git pull<cr>', { desc = 'Git pull' })
map('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })

-- ── Gitsigns hunk navigation ────────────────────────────────────────────────
map('n', ']c', function()
  if vim.wo.diff then
    return ']c'
  end
  vim.schedule(function()
    require('gitsigns').nav_hunk 'next'
  end)
  return '<Ignore>'
end, { expr = true, desc = 'Jump to next git change' })

map('n', '[c', function()
  if vim.wo.diff then
    return '[c'
  end
  vim.schedule(function()
    require('gitsigns').nav_hunk 'prev'
  end)
  return '<Ignore>'
end, { expr = true, desc = 'Jump to previous git change' })

-- ── Conform format ──────────────────────────────────────────────────────────
map('', '<leader>fm', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

-- ── Executioner (<F3>-<F7>, <leader>ep) ─────────────────────────────────────
map('n', '<F5>', function()
  require('executioner').run_scripts()
end, { desc = 'Executioner: run script' })
map('n', '<F6>', function()
  require('executioner').rerun()
end, { desc = 'Executioner: rerun last script' })
map('n', '<F7>', function()
  require('executioner').configure()
end, { desc = 'Executioner: configure project' })
map('n', '<F4>', function()
  require('executioner').build()
end, { desc = 'Executioner: build target' })
map('n', '<F3>', function()
  require('executioner').build_last()
end, { desc = 'Executioner: rerun last build' })
map('n', '<F9>', function()
  require('executioner').create_project()
end, { desc = 'Executioner: create project' })

-- ── ram.nvim (<leader>n / <leader>N) ────────────────────────────────────────
map('n', '<leader>n', function()
  require('ram').global()
end, { desc = 'Ram: global' })
map('n', '<leader>N', function()
  require('ram').project()
end, { desc = 'Ram: project' })

-- ── Tailwind values (<Leader>cv) ────────────────────────────────────────────
-- map('n', '<Leader>cv', '<CMD>TWValues<CR>', { desc = 'Tailwind CSS values' })

-- ── dial.nvim ───────────────────────────────────────────────────────────────
local function dial(direction, mode_name)
  return function()
    require('dial.map').manipulate(direction, mode_name)
  end
end
map('n', '<C-a>', dial('increment', 'normal'))
map('n', '<C-x>', dial('decrement', 'normal'))
map('n', 'g<C-a>', dial('increment', 'gnormal'))
map('n', 'g<C-x>', dial('decrement', 'gnormal'))
map('x', '<C-a>', dial('increment', 'visual'))
map('x', '<C-x>', dial('decrement', 'visual'))
map('x', 'g<C-a>', dial('increment', 'gvisual'))
map('x', 'g<C-x>', dial('decrement', 'gvisual'))
map('n', '<D-a>', dial('increment', 'normal'))
map('n', '<D-x>', dial('decrement', 'normal'))
map('n', 'g<D-a>', dial('increment', 'gnormal'))
map('n', 'g<D-x>', dial('decrement', 'gnormal'))
map('x', '<D-a>', dial('increment', 'visual'))
map('x', '<D-x>', dial('decrement', 'visual'))
map('x', 'g<D-a>', dial('increment', 'gvisual'))
map('x', 'g<D-x>', dial('decrement', 'gvisual'))

-- ── Multicursor ─────────────────────────────────────────────────────────────
-- local function mc()
--   return require 'multicursor-nvim'
-- end
-- map({ 'n', 'x' }, '<up>', function()
--   mc().lineAddCursor(-1)
-- end)
-- map({ 'n', 'x' }, '<down>', function()
--   mc().lineAddCursor(1)
-- end)
-- map({ 'n', 'x' }, '<leader><up>', function()
--   mc().lineSkipCursor(-1)
-- end)
-- map({ 'n', 'x' }, '<leader><down>', function()
--   mc().lineSkipCursor(1)
-- end)
-- map({ 'n', 'x' }, '<M-n>', function()
--   mc().matchAddCursor(1)
-- end)
-- map({ 'n', 'x' }, '<M-p>', function()
--   mc().matchSkipCursor(1)
-- end)
-- map('n', '<c-leftmouse>', function()
--   mc().handleMouse()
-- end)
-- map('n', '<c-leftdrag>', function()
--   mc().handleMouseDrag()
-- end)
-- map('n', '<c-leftrelease>', function()
--   mc().handleMouseRelease()
-- end)
-- map({ 'n', 'x' }, '<c-q>', function()
--   mc().toggleCursor()
-- end)

-- ── Flash (s/S/r/R) ─────────────────────────────────────────────────────────
map({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash' })
map({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })
map('o', 'r', function()
  require('flash').remote()
end, { desc = 'Remote Flash' })
map({ 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })

-- ── Aerial symbol outline ───────────────────────────────────────────────────
map('n', '<leader>so', '<cmd>AerialToggle!<cr>', { desc = 'Symbol Outline' })
map('n', '<leader>sO', '<cmd>AerialNavToggle<cr>', { desc = 'Symbol Outline (nav)' })
map('n', '<leader>ssy', '<cmd>Telescope aerial<cr>', { desc = 'Symbols (telescope)' })
map('n', ']]', '<cmd>AerialNext<cr>', { desc = 'Next symbol' })
map('n', '[[', '<cmd>AerialPrev<cr>', { desc = 'Prev symbol' })

-- ── grug-far (find/replace project) ─────────────────────────────────────────
map('n', '<leader>sR', '<cmd>GrugFar<cr>', { desc = 'Find/Replace (project)' })
map('x', '<leader>sR', function()
  require('grug-far').with_visual_selection { prefills = { paths = vim.fn.expand '%' } }
end, { desc = 'Find/Replace (selection)' })

-- ── Claude Code (<leader>C) ─────────────────────────────────────────────────
map('n', '<leader>C', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })

-- ── Hatch (<leader>i*) — file template hatcher ──────────────────────────────
map('n', '<leader>ih', '<cmd>Hatch<cr>', { desc = 'Hatch: apply template' })
map('n', '<leader>iH', '<cmd>HatchForce<cr>', { desc = 'Hatch: force apply' })
map('n', '<leader>iC', '<cmd>HatchCloneTemplates<cr>', { desc = 'Hatch: clone templates' })

-- ── DAP debug (<leader>b) ───────────────────────────────────────────────────
local function dap()
  return require 'dap'
end
map('n', '<leader>dc', function()
  dap().continue()
end, { desc = 'Debug: Start/Continue' })
map('n', '<leader>di', function()
  dap().step_into()
end, { desc = 'Debug: Step Into' })
map('n', '<leader>dO', function()
  dap().step_over()
end, { desc = 'Debug: Step Over' })
map('n', '<leader>do', function()
  dap().step_out()
end, { desc = 'Debug: Step Out' })
map('n', '<leader>db', function()
  dap().toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })
map('n', '<leader>dB', function()
  dap().set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Breakpoint' })
map('n', '<leader>dr', function()
  require('dapui').toggle()
end, { desc = 'Debug: See last session result.' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(ev)
    map('n', '<leader>dpt', function()
      require('dap-python').test_method()
    end, { buffer = ev.buf, desc = 'Debug Method' })
    map('n', '<leader>dpc', function()
      require('dap-python').test_class()
    end, { buffer = ev.buf, desc = 'Debug Class' })
    map('n', '<leader>dpv', '<cmd>:VenvSelect<cr>', { buffer = ev.buf, desc = 'Select VirtualEnv' })
  end,
})

-- ── CMake / tasks.nvim (<leader>c, <leader>p) ───────────────────────────────
-- tasks.lua exposes _G.NvimTasks with closures (last_exe, build_and_run, ...).
-- Plugin loads on VeryLazy so _G.NvimTasks is populated before any keypress.
local function tk(fn)
  return function()
    return _G.NvimTasks and _G.NvimTasks[fn] and _G.NvimTasks[fn]()
  end
end
local function tk_task(cmdline)
  return function()
    if _G.NvimTasks and _G.NvimTasks.task then
      _G.NvimTasks.task(cmdline)()
    end
  end
end

-- map('n', '<leader>cc', tk_task 'Task start cmake configure', { desc = 'CMake: configure' })
-- map('n', '<leader>cb', tk_task 'Task start cmake build_all', { desc = 'CMake: build all' })
-- map('n', '<leader>cB', tk_task 'Task set_module_param cmake build_type', { desc = 'CMake: set build type' })
-- map('n', '<leader>ce', tk 'pick_exe', { desc = 'CMake: pick & run executable' })
-- map('n', '<leader>cr', tk 'build_and_run', { desc = 'CMake: build all + run last exe' })
-- map('n', '<leader>ct', tk_task 'Task start cmake ctest', { desc = 'CMake: ctest' })
-- map('n', '<leader>cT', tk_task 'Task start cmake test', { desc = 'CMake: build tests + ctest' })
-- map('n', '<leader>cs', tk_task 'Task set_module_param cmake target', { desc = 'CMake: select target' })
-- map('n', '<leader>ck', tk_task 'Task set_module_param cmake build_kit', { desc = 'CMake: select kit' })
-- map('n', '<leader>cC', tk 'ccmake_tui', { desc = 'CMake: ccmake TUI' })
-- map('n', '<C-c>', tk_task 'Task cancel', { desc = 'Task: cancel' })
-- map('n', '<leader>vm', tk 'profile_valgrind', { desc = 'Valgrind: valgrind memcheck' })
-- map('n', '<leader>vc', tk 'profile_callgrind', { desc = 'Valgrind: callgrind CPU' })
-- map('n', '<leader>vp', tk 'profile_perf', { desc = 'Valgrind: perf record + report' })
-- map('n', '<leader>vr', tk 'profile_renderdoc', { desc = 'Valgrind: RenderDoc frame capture' })
-- map('n', '<leader>vR', tk 'profile_renderdoc_gui', { desc = 'Valgrind: open RenderDoc GUI' })
-- map('n', '<leader>vh', tk 'profile_heaptrack', { desc = 'Valgrind: heaptrack' })

-- ── LSP (LspAttach buffer-local) ────────────────────────────────────────────
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local lmap = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
    end
    lmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    lmap('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    lmap('gra', function()
      require('actions-preview').code_actions()
    end, '[C]ode [A]ction', { 'n', 'x' })
    lmap('grr', function()
      tb().lsp_references()
    end, '[G]oto [R]eferences')
    lmap('gri', function()
      tb().lsp_implementations()
    end, '[G]oto [I]mplementation')
    lmap('grd', function()
      tb().lsp_definitions()
    end, '[G]oto [D]efinition')
    lmap('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    lmap('grt', function()
      tb().lsp_type_definitions()
    end, '[G]oto [T]ype Definition')
    lmap('grs', function()
      tb().lsp_document_symbols()
    end, '[S]ymbols (document)')
    lmap('grS', function()
      tb().lsp_dynamic_workspace_symbols()
    end, '[S]ymbols (workspace)')
  end,
})

-- ── LSP / diagnostics globals (<leader>l, <leader>t) ────────────────────────
-- Ouroboros: source<->header switch (works without LSP, faster than clangd cmd)
map('n', '<leader>ls', '<cmd>Ouroboros<cr>', { desc = 'Switch Source/Header' })

-- Inlay hints (global toggle — affects all buffers)
map('n', '<leader>th', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = '[T]oggle Inlay [H]ints' })

map('n', '<leader>tl', function()
  vim.diagnostic.config { virtual_lines = not vim.diagnostic.config().virtual_lines }
end, { desc = '[T]oggle Diagnostic Virtual [L]ines' })
map('n', '<leader>tv', function()
  local cfg = vim.diagnostic.config()
  vim.diagnostic.config { virtual_text = not cfg.virtual_text }
end, { desc = '[T]oggle Diagnostic Virtual [T]ext' })

-- vim: ts=2 sts=2 sw=2 et
