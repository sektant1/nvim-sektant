local M = {}

local uv = vim.uv or vim.loop

M.root_markers = {
  'pyproject.toml',
  'uv.lock',
  'pytest.ini',
  'tox.ini',
  'noxfile.py',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  '.venv',
  '.git',
}

local function exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

function M.root(start)
  start = start or vim.api.nvim_buf_get_name(0)
  if start == '' then
    start = uv.cwd()
  end

  local dir = exists(start) and vim.fs.dirname(start) or start
  return vim.fs.root(dir, M.root_markers) or dir or uv.cwd()
end

function M.has_uv(root)
  root = root or M.root()
  return vim.fn.executable 'uv' == 1 and (exists(root .. '/uv.lock') or exists(root .. '/pyproject.toml'))
end

function M.python_path(root)
  root = root or M.root()

  local candidates = {}
  if vim.env.VIRTUAL_ENV then
    table.insert(candidates, vim.env.VIRTUAL_ENV .. '/bin/python')
  end
  if vim.env.CONDA_PREFIX then
    table.insert(candidates, vim.env.CONDA_PREFIX .. '/bin/python')
  end
  table.insert(candidates, root .. '/.venv/bin/python')

  for _, candidate in ipairs(candidates) do
    if executable(candidate) then
      return candidate
    end
  end

  if executable 'python3' then
    return 'python3'
  end
  return 'python'
end

function M.pyright_settings(root)
  local python = M.python_path(root)
  local settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'basic',
        useLibraryCodeForTypes = true,
      },
    },
  }

  if python:match '/%.venv/bin/python$' then
    settings.python.venvPath = root
    settings.python.venv = '.venv'
  elseif python:match '/bin/python$' then
    settings.python.pythonPath = python
  end

  return settings
end

local function shell_join(argv)
  return table.concat(
    vim.tbl_map(function(arg)
      return vim.fn.shellescape(arg)
    end, argv),
    ' '
  )
end

function M.command(argv)
  return shell_join(argv)
end

function M.project_command(root, args)
  root = root or M.root()
  if M.has_uv(root) then
    return shell_join(vim.list_extend({ 'uv', 'run', 'python' }, args))
  end
  return shell_join(vim.list_extend({ M.python_path(root) }, args))
end

function M.test_command(root, args)
  root = root or M.root()
  args = args or {}
  if M.has_uv(root) then
    return shell_join(vim.list_extend({ 'uv', 'run', 'pytest' }, args))
  end
  return shell_join(vim.list_extend({ M.python_path(root), '-m', 'pytest' }, args))
end

function M.open_term(cmd, opts)
  opts = opts or {}
  local cwd = opts.cwd or M.root()
  vim.cmd(opts.vertical and 'botright vsplit' or 'botright split')
  if opts.size then
    vim.cmd((opts.vertical and 'vertical resize ' or 'resize ') .. opts.size)
  end
  vim.cmd 'enew'
  vim.fn.termopen(cmd, { cwd = cwd })
  vim.cmd 'startinsert'
end

local function prompt_input(title, default, on_submit)
  default = default or ''

  local ok, Input = pcall(require, 'nui.input')
  if not ok then
    vim.ui.input({ prompt = title .. ': ', default = default }, function(value)
      if value ~= nil then
        on_submit(value)
      end
    end)
    return
  end

  local input
  input = Input({
    position = '50%',
    size = { width = 60 },
    border = {
      style = 'single',
      text = { top = ' ' .. title .. ' ', top_align = 'left' },
    },
  }, {
    prompt = '> ',
    default_value = default,
    on_submit = function(value)
      on_submit(value or '')
    end,
  })

  input:mount()
  input:map({ 'n', 'i' }, '<Esc>', function()
    input:unmount()
  end, { noremap = true })
end

local function run_file_command(args, pythonpath)
  vim.cmd 'write'
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    return
  end

  local root = M.root(file)
  local cmd = M.project_command(root, { file })
  if args and args ~= '' then
    cmd = cmd .. ' ' .. args
  end
  if pythonpath and pythonpath ~= '' then
    cmd = 'PYTHONPATH=' .. vim.fn.shellescape(pythonpath) .. ' ' .. cmd
  end
  M.open_term(cmd, { cwd = root, size = 15 })
end

function M.run_file()
  prompt_input('Python args', '', function(args)
    run_file_command(args)
  end)
end

function M.run_file_with_args_pythonpath()
  local root = M.root()
  prompt_input('Python args', '', function(args)
    prompt_input('PYTHONPATH', root, function(pythonpath)
      run_file_command(args, pythonpath)
    end)
  end)
end

function M.run_selection()
  vim.cmd 'write'
  local root = M.root()
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local tmp = vim.fn.tempname() .. '.py'
  vim.fn.writefile(lines, tmp)
  M.open_term(M.project_command(root, { tmp }), { cwd = root, size = 15 })
end

function M.create_venv()
  local root = M.root()
  local cmd = M.has_uv(root) and shell_join { 'uv', 'venv', '.venv' } or shell_join { M.python_path(root), '-m', 'venv', '.venv' }
  M.open_term(cmd, { cwd = root, size = 12 })
end

function M.sync_dependencies()
  local root = M.root()
  local cmd
  if M.has_uv(root) then
    cmd = shell_join { 'uv', 'sync' }
  elseif exists(root .. '/requirements.txt') then
    cmd = shell_join { M.python_path(root), '-m', 'pip', 'install', '-r', 'requirements.txt' }
  else
    vim.notify('No uv project or requirements.txt found', vim.log.levels.WARN)
    return
  end
  M.open_term(cmd, { cwd = root, size = 12 })
end

function M.add_dependency()
  local package = vim.fn.input 'Package to add: '
  if package == '' then
    return
  end

  local root = M.root()
  local cmd = M.has_uv(root) and shell_join { 'uv', 'add', package } or shell_join { M.python_path(root), '-m', 'pip', 'install', package }
  M.open_term(cmd, { cwd = root, size = 12 })
end

function M.remove_dependency()
  local package = vim.fn.input 'Package to remove: '
  if package == '' then
    return
  end

  local root = M.root()
  local cmd = M.has_uv(root) and shell_join { 'uv', 'remove', package } or shell_join { M.python_path(root), '-m', 'pip', 'uninstall', '-y', package }
  M.open_term(cmd, { cwd = root, size = 12 })
end

function M.install_current_project()
  local root = M.root()
  M.open_term(M.project_command(root, { '-m', 'pip', 'install', '-e', '.[dev]' }), { cwd = root, size = 12 })
end

function M.test_nearest()
  require('neotest').output_panel.open()
  require('neotest').run.run()
end

function M.test_file()
  require('neotest').output_panel.open()
  require('neotest').run.run(vim.fn.expand '%')
end

function M.test_last()
  require('neotest').output_panel.open()
  require('neotest').run.run_last()
end

function M.debug_nearest_test()
  require('neotest').run.run { strategy = 'dap' }
end

function M.test_under_cursor()
  local ok, neotest = pcall(require, 'neotest')
  if ok then
    neotest.output_panel.open()
    neotest.run.run()
    return
  end

  local root = M.root()
  local file = vim.api.nvim_buf_get_name(0)
  local line = vim.fn.line '.'
  M.open_term(M.test_command(root, { file .. '::' .. line }), { cwd = root, size = 15 })
end

return M
