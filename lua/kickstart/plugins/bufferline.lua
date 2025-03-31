-- A snazzy 💅 buffer line (with tabpage integration) for Neovim built using lua.
-- https://github.com/akinsho/bufferline.nvim

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
      always_show_bufferline = true,
      offsets = {
        {
          filetype = "neo-tree",
          text="Neo Tree",
          separator= true,
          text_align = "left",
        }
      },
    }
  }
  end,
}
