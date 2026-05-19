local wiki_home = vim.env.VIMWIKI_HOME or '~/vimwiki'
local wiki_path = vim.fn.expand(wiki_home)

return {
  {
    'vimwiki/vimwiki',
    branch = 'dev',
    lazy = false,
    cmd = {
      'VimwikiIndex',
      'VimwikiTabIndex',
      'VimwikiUISelect',
      'VimwikiDiaryIndex',
      'VimwikiMakeDiaryNote',
      'VimwikiMakeYesterdayDiaryNote',
      'VimwikiMakeTomorrowDiaryNote',
      'Vimwiki2HTML',
      'VimwikiAll2HTML',
      'VimwikiBacklinks',
      'VimwikiGenerateLinks',
      'VimwikiRebuildTags',
      'VimwikiRenameLink',
      'VimwikiDeleteLink',
      'VimwikiTOC',
      'VimwikiTags',
    },
    ft = { 'vimwiki' },
    init = function()
      local path = wiki_path .. '/'

      vim.g.vimwiki_list = {
        {
          path = path,
          syntax = 'markdown',
          ext = 'md',
          index = 'index',
          diary_rel_path = 'diary/',
          diary_index = 'diary',
          diary_header = 'Diary',
          path_html = path .. '.site/',
          auto_tags = 1,
          auto_toc = 1,
          links_space_char = '-',
          nested_syntaxes = {
            bash = 'sh',
            c = 'c',
            cpp = 'cpp',
            javascript = 'javascript',
            json = 'json',
            lua = 'lua',
            python = 'python',
            rust = 'rust',
            sh = 'sh',
            toml = 'toml',
            typescript = 'typescript',
            vim = 'vim',
            yaml = 'yaml',
          },
        },
      }

      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_ext2syntax = vim.empty_dict()
      vim.g.vimwiki_auto_chdir = 0
      vim.g.vimwiki_create_link = 1
      vim.g.vimwiki_folding = 'expr'
      vim.g.vimwiki_hl_headers = 1
      vim.g.vimwiki_hl_cb_checked = 1
      vim.g.vimwiki_markdown_link_ext = 1
      vim.g.vimwiki_table_mappings = 1
      vim.g.vimwiki_key_mappings = {
        all_maps = 1,
        global = 0,
        mouse = 0,
      }
    end,
  },
}
