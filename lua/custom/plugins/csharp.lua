local function target_path(target)
  if type(target) == 'string' then
    return target
  end

  if type(target) == 'table' then
    return target.target or target.path or target.name or target[1]
  end
end

local function is_unity_solution(path)
  if not path or not path:match '%.slnx?$' then
    return false
  end

  local dir = vim.fs.dirname(path)
  return vim.uv.fs_stat(dir .. '/ProjectSettings/ProjectVersion.txt') ~= nil
    or (vim.uv.fs_stat(dir .. '/Assets') ~= nil and vim.uv.fs_stat(dir .. '/Packages/manifest.json') ~= nil)
end

local function prefer_unity_solution(targets)
  for _, target in ipairs(targets) do
    if is_unity_solution(target_path(target)) then
      return target
    end
  end
end

return {
  {
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'csx', 'razor', 'cshtml' },
    dependencies = { 'mason-org/mason.nvim' },
    init = function()
      vim.filetype.add {
        extension = {
          cs = 'cs',
          csx = 'cs',
          razor = 'razor',
          cshtml = 'cshtml',
        },
      }
    end,
    opts = {
      broad_search = true,
      choose_target = prefer_unity_solution,
      filewatching = 'roslyn',
      lock_target = false,
      silent = false,
    },
    config = function(_, opts)
      vim.lsp.config('roslyn', {
        settings = {
          ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'fullSolution',
            dotnet_compiler_diagnostics_scope = 'fullSolution',
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ['csharp|completion'] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ['csharp|formatting'] = {
            dotnet_organize_imports_on_format = true,
          },
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      })

      require('roslyn').setup(opts)

      vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('Custom_csharp_codelens', { clear = true }),
        pattern = { '*.cs', '*.csx' },
        callback = function(args)
          local clients = vim.lsp.get_clients { bufnr = args.buf, name = 'roslyn' }
          if #clients > 0 then
            vim.lsp.codelens.refresh { bufnr = args.buf }
          end
        end,
      })

      vim.api.nvim_create_user_command('UnityRegenerateProjectFiles', function()
        local file = vim.api.nvim_buf_get_name(0)
        local start = file ~= '' and vim.fs.dirname(file) or vim.uv.cwd()
        local root = vim.fs.root(start, { 'ProjectSettings', 'Assets', 'Packages' })
        if not root then
          vim.notify('Not inside a Unity project', vim.log.levels.WARN)
          return
        end

        vim.notify('Regenerate Unity project files from Unity: Edit > Preferences > External Tools > Regenerate project files', vim.log.levels.INFO)
      end, { desc = 'Show Unity project file regeneration hint' })
    end,
  },
}
