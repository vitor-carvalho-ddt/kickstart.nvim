-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    -- 1) Basic autopairs setup
    require('nvim-autopairs').setup {
      fast_wrap = {
        map = '<C-e>', -- The key to trigger "Fast Wrap" CTRL+e
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        offset = 0, -- Offset from pattern match
        end_key = '$', -- Key to end "Fast Wrap" selection
        keys = 'asdfghjkl;', -- Keys in the popup for selecting an insert position
        check_comma = true,
        highlight = 'PmenuSel',
        highlight_grey = 'LineNr',
      },
    }

    -- 2) Automatically add "(" after completing a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'

    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
