-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim_create_autocmd

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
      use_libuv_file_watcher = true,
    },
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          if #vim.api.nvim_list_wins() == 1 then
            local bufname = vim.api.nvim_buf_get_name(0)
            if string.find(bufname, 'neo%-tree') then
              vim.cmd 'quit'
            end
          end
        end,
      },
    },
  },
}
