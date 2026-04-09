-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      'mfussenegger/nvim-dap-python',

      -- Installs the debug adapters for you
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
    },
    keys = {
      -- Basic debugging keymaps, feel free to change to your liking!
      {
        '<leader>bc',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Start/Continue',
      },
      {
        '<leader>bi',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<leader>bO',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<leader>bo',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>bb',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>bB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      {
        '<leader>br',
        function()
          require('dapui').toggle()
        end,
        desc = 'Debug: See last session result.',
      },
      {
        '<leader>bpt',
        function()
          require('dap-python').test_method()
        end,
        desc = 'Debug Method',
        ft = 'python',
      },
      {
        '<leader>bpc',
        function()
          require('dap-python').test_class()
        end,
        desc = 'Debug Class',
        ft = 'python',
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local js_debug = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'

      for _, adapter in ipairs { 'pwa-node', 'pwa-chrome', 'node-terminal' } do
        dap.adapters[adapter] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = { js_debug, '${port}' },
          },
        }
      end

      local js_langs = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }

      for _, lang in ipairs(js_langs) do
        dap.configurations[lang] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Node file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to Node process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-chrome',
            request = 'launch',
            name = 'Launch Chrome (localhost:3000)',
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
          },
          -- Debug Jest: only runs tests in the current file
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Jest (current file)',
            runtimeExecutable = 'npx',
            runtimeArgs = {
              'jest',
              '--runInBand',
              '--testPathPattern',
              '${relativeFile}',
            },
            rootDir = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
          },
        }
      end
      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'delve',
          'codelldb',
          'python',
          'js-debug-adapter',
        },
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('dap-python').setup 'debugpy-adapter'
      -- Install golang specific config
      require('dap-go').setup {
        delve = {
          detached = vim.fn.has 'win32' == 0,
        },
      }

      -- ── C / C++ via codelldb ────────────────────────────────────────────
      local codelldb = vim.fn.stdpath 'data' .. '/mason/packages/codelldb/extension/adapter/codelldb'
      if vim.fn.executable(codelldb) == 1 then
        dap.adapters.codelldb = {
          type = 'server',
          port = '${port}',
          executable = { command = codelldb, args = { '--port', '${port}' } },
        }
      end

      -- Pick an executable with a file prompt (DAP program fields must be sync)
      local function pick_program()
        return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
      end

      local cpp_configs = {
        -- Standard launch — works for any C++ binary
        {
          name = 'C++: Launch',
          type = 'codelldb',
          request = 'launch',
          program = pick_program,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        -- OpenGL / graphics debug launch:
        --   • MESA_DEBUG=1          → mesa prints GL errors to stderr
        --   • LIBGL_DEBUG=verbose   → driver logs every API call
        --   • GL_DEBUG_OUTPUT env   → works alongside glDebugMessageCallback
        --   The binary should be compiled with -DCMAKE_BUILD_TYPE=Debug
        --   and create a GL debug context (GLFW_OPENGL_DEBUG_CONTEXT = GL_TRUE)
        {
          name = 'C++: Launch (OpenGL debug env)',
          type = 'codelldb',
          request = 'launch',
          program = pick_program,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          env = {
            MESA_DEBUG = '1',
            LIBGL_DEBUG = 'verbose',
            MESA_GL_VERSION_OVERRIDE = '4.6',
            -- Vulkan validation layer (harmless if Vulkan not used)
            VK_INSTANCE_LAYERS = 'VK_LAYER_KHRONOS_validation',
          },
        },
        -- Attach to an already-running process
        {
          name = 'C++: Attach to process',
          type = 'codelldb',
          request = 'attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
      dap.configurations.cpp = cpp_configs
      dap.configurations.c = cpp_configs
    end,
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'marilari88/neotest-jest',
      'm00qek/baleia.nvim',
    },
    config = function()
      -- Walk up from `file` returning the path of the first match found
      local function find_nearest(file, names)
        local path = vim.fn.fnamemodify(file, ':h')
        while path ~= '/' do
          for _, name in ipairs(names) do
            local candidate = path .. '/' .. name
            if vim.fn.filereadable(candidate) == 1 then
              return candidate
            end
          end
          path = vim.fn.fnamemodify(path, ':h')
        end
      end

      -- Detect package manager from the nearest lock file
      local function detect_pkg_manager(file)
        local path = vim.fn.fnamemodify(file, ':h')
        while path ~= '/' do
          if vim.fn.filereadable(path .. '/pnpm-lock.yaml') == 1 then
            return 'pnpm'
          end
          if vim.fn.filereadable(path .. '/yarn.lock') == 1 then
            return 'yarn'
          end
          if vim.fn.filereadable(path .. '/bun.lockb') == 1 then
            return 'bun'
          end
          if vim.fn.filereadable(path .. '/package-lock.json') == 1 then
            return 'npm'
          end
          path = vim.fn.fnamemodify(path, ':h')
        end
        return 'npm'
      end

      require('neotest').setup {
        adapters = {
          require 'neotest-jest' {
            jestCommand = function(path)
              local cmds = {
                npm = 'npx jest',
                yarn = 'yarn jest',
                pnpm = 'pnpm exec jest',
                bun = 'bun test',
              }
              local pm = detect_pkg_manager(path)
              return (cmds[pm] or 'npx jest') .. ' --passWithNoTests --colors'
            end,
            jestConfigFile = function(file)
              return find_nearest(file, {
                'jest.config.ts',
                'jest.config.js',
                'jest.config.mjs',
                'jest.config.cjs',
              })
            end,
            cwd = function(file)
              local pkg = find_nearest(file, { 'package.json' })
              if pkg then
                return vim.fn.fnamemodify(pkg, ':h')
              end
              return vim.fn.getcwd()
            end,
            env = { CI = false },
          },
        },
        summary = { enabled = true },
        output_panel = { enabled = true },
      }

      -- Fix: neotest-jest wraps --testNamePattern in single quotes that
      -- Jest 30 treats as literal regex characters, causing all tests to skip.
      local adapter = require('neotest-jest')
      local orig_build_spec = adapter.build_spec
      adapter.build_spec = function(args)
        local spec = orig_build_spec(args)
        if spec and spec.command then
          for i, v in ipairs(spec.command) do
            local pat = v:match '^--testNamePattern=(.+)$'
            if pat then
              pat = pat:gsub("^'", ''):gsub("'$", '')
              spec.command[i] = '--testNamePattern=' .. pat
              break
            end
          end
        end
        return spec
      end


      local baleia = require('baleia').setup {}
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'neotest-output-panel',
        callback = function(ev)
          baleia.automatically(ev.buf)
        end,
      })
    end,
  },

  -- Harpoon: mark files and jump between them instantly
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon'):setup()
    end,
  },

  -- HTTP client: send requests from .http files (replaces Postman/Insomnia)
  {
    'mistweaverco/kulala.nvim',
    ft = 'http',
    opts = {
      global_keymaps = false,
      ui = { display_mode = 'split' },
    },
  },

  {
    'linux-cultist/venv-selector.nvim',
    cmd = 'VenvSelect',
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        override_notify = false,
      },
    },
    --  Call config for Python files and load the cached venv automatically
    ft = 'python',
    keys = { { '<leader>bpv', '<cmd>:VenvSelect<cr>', desc = 'Select VirtualEnv', ft = 'python' } },
  },
}
