-- persistence.lua
-- Place this file in ~/.config/nvim/lua/plugins/persistence.lua

-- This configuration is designed to work with Kickstart Neovim and lazy.nvim
return {
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- Load the plugin before reading a buffer
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/'), -- Directory to store sessions
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals' },
      pre_save = nil, -- Function to run before saving session
      save_empty = false, -- Don't save if no buffers are loaded
    },
    keys = {
      -- Keybindings for persistence operations
      {
        '<leader>rs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore session for current directory',
      },
      {
        '<leader>rl',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore last session',
      },
      {
        '<leader>ss',
        function()
          require('persistence').stop()
        end,
        desc = "Don't save current session",
      },
    },
    config = function(_, opts)
      require('persistence').setup(opts)

      -- Auto-save session when exiting Neovim
      local group = vim.api.nvim_create_augroup('PersistenceAugroup', { clear = true })
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
          -- Only save session if Neovim wasn't started with arguments
          if vim.fn.argc() == 0 then
            require('persistence').save()
          end
        end,
      })

      -- Create commands for session management
      vim.api.nvim_create_user_command('SessionSave', function()
        require('persistence').save()
        vim.notify('Session saved', vim.log.levels.INFO)
      end, {})

      vim.api.nvim_create_user_command('SessionLoad', function()
        require('persistence').load()
      end, {})

      vim.api.nvim_create_user_command('SessionLoadLast', function()
        require('persistence').load { last = true }
      end, {})

      -- Uncomment this block if you want automatic session loading on startup
      -- vim.api.nvim_create_autocmd("VimEnter", {
      --   callback = function()
      --     -- Auto load session if Neovim is started without arguments
      --     if vim.fn.argc() == 0 then
      --       vim.defer_fn(function()
      --         require("persistence").load()
      --       end, 10) -- Small delay to ensure everything else is loaded
      --     end
      --   end,
      -- })
    end,
  },

  -- Optional: Add integration with telescope if you're using it
  {
    'nvim-telescope/telescope.nvim',
    optional = true, -- This ensures it only loads if telescope is already installed
    keys = {
      -- Add this keymap only if telescope is available
      { '<leader>ps', '<cmd>Telescope find_files cwd=~/.local/state/nvim/sessions/<CR>', desc = 'Find sessions' },
    },
  },
}
