return {
  'sektant1/clanger.nvim',
  ft = { 'cpp', 'c', 'cxx', 'hpp', 'h' },
  cmd = {
    'CreateClass',
    'CreateStruct',
    'CreateEnum',
    'CreateInterface',
    'CppSwitch',
    'SwitchHeaderSource',
    'GenerateImpl',
    'CppAddGuard',
    'CppProjectInfo',
    'CppNewFile',
    'CppRenameSymbol',
  },
  opts = {
    picker = 'auto',
    author = 'Gabe',
    default_namespace = 'ENG',
  },
}
