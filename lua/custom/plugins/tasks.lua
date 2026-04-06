return {
  'Shatur/neovim-tasks',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
    'm00qek/baleia.nvim',
  },
  event = 'VeryLazy',
  config = function()
    local Path = require 'plenary.path'
    local jobs = vim.loop.available_parallelism and vim.loop.available_parallelism() or 4

    -- ── Setup ────────────────────────────────────────────────────────────
    require('tasks').setup {
      default_params = {
        cmake = {
          cmd = 'cmake',
          build_type = 'Debug',
          build_kit = 'clang-ninja',
          cmake_kits_file = tostring(Path:new(vim.fn.stdpath 'config', 'cmake-kits.json')),
          dap_name = 'codelldb',
          build_dir = tostring(Path:new('{cwd}', 'build')),
          cmake_args = { '-DCMAKE_COLOR_DIAGNOSTICS=ON', '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON' },
          build_args = { '--', '-j' .. jobs },
          ctest_args = { '--color=yes', '--output-on-failure' },
          restart_clangd_after_configure = true,
          ignore_presets = false,
        },
      },
      save_before_run = true,
      params_file = 'neovim.json',
      quickfix = { pos = 'botright', height = 12, only_on_error = false },
    }

    -- ── Baleia: colorize ANSI codes in the quickfix (cmake/ctest output) ─
    local baleia = require('baleia').setup {}
    vim.api.nvim_create_autocmd('BufWinEnter', {
      pattern = 'quickfix',
      callback = function(ev)
        if vim.bo[ev.buf].buftype == 'quickfix' then
          baleia.automatically(ev.buf)
        end
      end,
    })
    -- also catch the FileType event which fires more reliably for qf
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'qf',
      callback = function(ev)
        baleia.automatically(ev.buf)
      end,
    })

    -- ── Extra cmake tasks ────────────────────────────────────────────────
    do
      local cmake_mod = require 'tasks.module.cmake'
      local function build_target(name)
        return function(cfg, prev)
          return cmake_mod.tasks.build(vim.tbl_deep_extend('force', {}, cfg, { target = name }), prev)
        end
      end
      cmake_mod.tasks.build_tests = build_target 'tests'
      cmake_mod.tasks.test = { build_target 'tests', cmake_mod.tasks.ctest }
    end

    -- ── Helpers ──────────────────────────────────────────────────────────

    -- Walk upward from cwd to find the cmake project root, then cd there.
    -- Works for any project structure: single CMakeLists.txt, nested,
    -- monorepos, etc.
    local function cmake_root()
      local start = vim.loop.cwd()
      if not (vim.fs and vim.fs.find) then
        return start
      end
      local found = vim.fs.find('CMakeLists.txt', { path = start, upward = true })[1]
      local root = found and vim.fs.dirname(found) or start
      if root ~= vim.loop.cwd() then
        vim.cmd('cd ' .. vim.fn.fnameescape(root))
      end
      return root
    end

    local function task(cmdline)
      return function()
        cmake_root()
        vim.cmd(cmdline)
      end
    end

    -- ── Executable picker ────────────────────────────────────────────────
    local last_exe = nil

    local function run_exe(path)
      last_exe = path
      vim.cmd('botright split | terminal ' .. vim.fn.fnameescape(path))
    end

    local function find_executables(root)
      return vim.fn.systemlist(
        'find '
          .. vim.fn.shellescape(root)
          .. ' -maxdepth 8 -type f -executable'
          .. ' ! -path "*/.git/*"'
          .. ' ! -path "*/CMakeFiles/*"'
          .. ' ! -path "*/_deps/*"'
          .. ' ! -name "*.so*"'
          .. ' ! -name "*.dylib"'
          .. ' ! -name "*.a"'
          .. ' ! -name "cmake_*"'
          .. ' 2>/dev/null'
      )
    end

    local function pick_exe()
      local root = cmake_root()
      local bins = find_executables(root)
      if #bins == 0 then
        vim.notify('No executables found under ' .. root, vim.log.levels.WARN)
        return
      end
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local state = require 'telescope.actions.state'

      pickers
        .new({}, {
          prompt_title = 'Run Executable  [<CR> run · <C-d> debug]',
          finder = finders.new_table {
            results = bins,
            entry_maker = function(path)
              local rel = path:sub(#root + 2)
              return { value = path, display = rel, ordinal = rel }
            end,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local sel = state.get_selected_entry()
              if sel then
                run_exe(sel.value)
              end
            end)
            map('i', '<C-d>', function()
              actions.close(prompt_bufnr)
              local sel = state.get_selected_entry()
              if sel then
                last_exe = sel.value
                require('dap').run {
                  type = 'codelldb',
                  request = 'launch',
                  program = sel.value,
                  cwd = root,
                }
              end
            end)
            return true
          end,
        })
        :find()
    end

    -- Build all, then re-run the last picked executable (no picker).
    local function build_and_run()
      local root = cmake_root()
      if not last_exe then
        vim.notify('No executable selected — use <leader>ce first', vim.log.levels.WARN)
        return
      end
      vim.cmd 'Task start cmake build_all'
      vim.api.nvim_create_autocmd('QuickFixCmdPost', {
        once = true,
        callback = function()
          local has_err = vim.iter(vim.fn.getqflist()):any(function(e)
            return e.type == 'E'
          end)
          if has_err then
            vim.notify('Build failed — not running ' .. vim.fn.fnamemodify(last_exe, ':t'), vim.log.levels.ERROR)
          else
            run_exe(last_exe)
          end
        end,
      })
    end

    -- ── Keymaps ──────────────────────────────────────────────────────────
    -- Configure / build
    vim.keymap.set('n', '<leader>cc', task 'Task start cmake configure', { desc = 'CMake: configure' })
    vim.keymap.set('n', '<leader>cb', task 'Task start cmake build_all', { desc = 'CMake: build all' })
    vim.keymap.set('n', '<leader>cB', task 'Task set_module_param cmake build_type', { desc = 'CMake: set build type' })

    -- Run / debug
    vim.keymap.set('n', '<leader>ce', pick_exe, { desc = 'CMake: pick & run executable' })
    vim.keymap.set('n', '<leader>cr', build_and_run, { desc = 'CMake: build all + run last exe' })

    -- Tests
    vim.keymap.set('n', '<leader>ct', task 'Task start cmake ctest', { desc = 'CMake: ctest' })
    vim.keymap.set('n', '<leader>cT', task 'Task start cmake test', { desc = 'CMake: build tests + ctest' })

    -- Params
    vim.keymap.set('n', '<leader>cs', task 'Task set_module_param cmake target', { desc = 'CMake: select target' })
    vim.keymap.set('n', '<leader>ck', task 'Task set_module_param cmake build_kit', { desc = 'CMake: select kit' })

    -- ccmake TUI
    vim.keymap.set('n', '<leader>cC', function()
      cmake_root()
      local build_dir = tostring(require('tasks.cmake_utils.cmake_utils').getBuildDir())
      vim.cmd('botright split | terminal ccmake ' .. vim.fn.fnameescape(build_dir))
    end, { desc = 'CMake: ccmake TUI' })

    vim.keymap.set('n', '<C-c>', task 'Task cancel', { desc = 'Task: cancel' })

    -- ── Profiling / analysis ──────────────────────────────────────────────
    -- All tools operate on `last_exe` (set by <leader>ce picker).

    local function need_exe(tool)
      if last_exe then
        return true
      end
      vim.notify(tool .. ': pick an executable first with <leader>ce', vim.log.levels.WARN)
      return false
    end

    -- valgrind memcheck — memory leaks, invalid reads/writes
    vim.keymap.set('n', '<leader>pm', function()
      if not need_exe 'valgrind' then return end
      vim.cmd(
        'botright split | terminal valgrind'
          .. ' --leak-check=full'
          .. ' --track-origins=yes'
          .. ' --show-leak-kinds=all'
          .. ' --error-exitcode=1'
          .. ' ' .. vim.fn.fnameescape(last_exe)
      )
    end, { desc = 'Profile: valgrind memcheck' })

    -- valgrind callgrind — CPU call-graph profiling, open with kcachegrind
    vim.keymap.set('n', '<leader>pc', function()
      if not need_exe 'callgrind' then return end
      local out = '/tmp/callgrind.' .. os.time() .. '.out'
      vim.cmd(
        'botright split | terminal valgrind'
          .. ' --tool=callgrind'
          .. ' --callgrind-out-file=' .. out
          .. ' ' .. vim.fn.fnameescape(last_exe)
          .. ' ; echo ""'
          .. ' ; echo "Done. Open with: kcachegrind ' .. out .. '"'
      )
    end, { desc = 'Profile: callgrind CPU (open with kcachegrind)' })

    -- perf — Linux kernel profiler, near-zero overhead
    vim.keymap.set('n', '<leader>pp', function()
      if not need_exe 'perf' then return end
      vim.cmd(
        'botright split | terminal perf record -g -o /tmp/perf.data'
          .. ' ' .. vim.fn.fnameescape(last_exe)
          .. ' && perf report -i /tmp/perf.data'
      )
    end, { desc = 'Profile: perf record + report' })

    -- RenderDoc — frame capture for OpenGL/Vulkan, opens in qrenderdoc GUI
    vim.keymap.set('n', '<leader>pr', function()
      if not need_exe 'renderdoccmd' then return end
      local cap = '/tmp/renderdoc_' .. os.time()
      vim.cmd(
        'botright split | terminal renderdoccmd capture'
          .. ' --wait-for-exit'
          .. ' --capture-file ' .. cap
          .. ' ' .. vim.fn.fnameescape(last_exe)
          .. ' ; echo ""'
          .. ' ; echo "Capture saved to ' .. cap .. '.rdc — open with: qrenderdoc ' .. cap .. '.rdc"'
      )
    end, { desc = 'Profile: RenderDoc frame capture' })

    -- Open RenderDoc GUI (to replay a .rdc file manually)
    vim.keymap.set('n', '<leader>pR', function()
      vim.cmd 'botright split | terminal qrenderdoc'
    end, { desc = 'Profile: open RenderDoc GUI' })

    -- heaptrack — heap memory profiler with GUI (lighter than valgrind)
    vim.keymap.set('n', '<leader>ph', function()
      if not need_exe 'heaptrack' then return end
      local out = '/tmp/heaptrack_' .. os.time()
      vim.cmd(
        'botright split | terminal heaptrack'
          .. ' -o ' .. out
          .. ' ' .. vim.fn.fnameescape(last_exe)
          .. ' ; echo ""'
          .. ' ; echo "Done. Open with: heaptrack_gui ' .. out .. '.zst"'
      )
    end, { desc = 'Profile: heaptrack (heap profiler)' })
  end,
}
