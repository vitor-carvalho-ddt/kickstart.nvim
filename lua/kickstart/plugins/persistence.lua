-- https://github.com/folke/persistence.nvim

-- File: ~/.config/nvim/lua/plugins/persistence.lua

return {
  'folke/persistence.nvim',
  lazy = false, -- Ensure plugin loads on startup

  -- Define keymaps
  keys = {
    {
      '<leader>rs',
      function()
        require('persistence').load()
      end,
      desc = 'Restore Session for Current Directory',
    },
    {
      '<leader>rl',
      function()
        require('persistence').load { last = true }
      end,
      desc = 'Restore Last Session',
    },
    {
      '<leader>rt',
      function()
        require('persistence').select()
      end,
      desc = 'Select Session to Restore',
    },
    {
      '<leader>rd',
      function()
        require('persistence').stop()
      end,
      desc = "Don't Save Current Session",
    },
    {
      '<leader>rw',
      function()
        require('persistence').save()
      end,
      desc = 'Manually Save Session',
    },
  },

  -- Configure plugin
  config = function()
    -- Configure sessionoptions - NeoTree prevention
    vim.opt.sessionoptions:remove 'options' -- Don't save options and mappings
    vim.opt.sessionoptions:remove 'folds' -- Don't save folds (can cause issues)
    vim.opt.sessionoptions:remove 'terminal' -- Don't save terminal buffers

    -- Save only the essential things
    vim.opt.sessionoptions = 'buffers,curdir,tabpages,winsize,globals'

    -- Add this to disable the saving of specific filetypes/buftypes
    -- With this, NeoTree and other special buffers won't be saved
    local excluded_filetypes = {
      'neotree',
      'neo-tree',
      'NvimTree',
      'Trouble',
      'help',
      -- 'qf', -- quickfix
      'prompt',
    }

    local excluded_buftypes = {
      'nofile',
      'terminal',
      'prompt',
      -- 'quickfix',
      'help',
    }

    -- Function to check if a buffer should be excluded
    local function should_exclude_buffer(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()

      -- Check if filetype should be excluded
      local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
      for _, excluded_ft in ipairs(excluded_filetypes) do
        if ft == excluded_ft then
          return true
        end
      end

      -- Check if buftype should be excluded
      local bt = vim.api.nvim_buf_get_option(bufnr, 'buftype')
      for _, excluded_bt in ipairs(excluded_buftypes) do
        if bt == excluded_bt then
          return true
        end
      end

      return false
    end

    -- Custom save function that excludes NeoTree and other special buffers
    local persistence = require 'persistence'
    local originalSave = persistence.save

    persistence.save = function(opts)
      -- Close NeoTree and other special windows before saving
      pcall(vim.cmd, 'silent! Neotree close')

      -- Close any floating windows
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then
          pcall(vim.api.nvim_win_close, win, false)
        end
      end

      -- Remove any buffers that should be excluded
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if should_exclude_buffer(bufnr) then
          -- Try to unload the buffer
          pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end
      end

      -- Add a small delay to ensure all operations complete
      vim.cmd 'sleep 50m'

      -- Call the original save function
      return originalSave(opts)
    end

    -- Setup the plugin
    persistence.setup {
      dir = vim.fn.stdpath 'state' .. '/sessions/', -- directory where session files are saved
      options = nil, -- use the configured sessionoptions above instead of overriding

      -- Set to 0 to always save sessions regardless of buffer count
      need = 0,

      -- Use git branch for session saving if in a git repo
      branch = true,
    }

    -- Ensure autocommands for saving sessions frequently
    vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusLost', 'CursorHold' }, {
      pattern = '*',
      callback = function()
        -- Only trigger auto-save for regular file buffers
        if vim.bo.buftype == '' and vim.fn.expand '%' ~= '' and not should_exclude_buffer() then
          pcall(persistence.save)
        end
      end,
      group = vim.api.nvim_create_augroup('PersistenceAutoSave', { clear = true }),
    })

    -- Force a save before exiting
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        persistence.save()
      end,
      group = vim.api.nvim_create_augroup('PersistenceExitSave', { clear = true }),
    })

    -- Post-load cleanup to fix focus issues and prevent NeoTree from reopening
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistenceLoadPost',
      callback = function()
        -- Clean up any NeoTree buffers that might have been restored
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          local ft = pcall(function()
            return vim.api.nvim_buf_get_option(bufnr, 'filetype')
          end) and vim.api.nvim_buf_get_option(bufnr, 'filetype') or ''

          if ft == 'neo-tree' or ft == 'neotree' or ft == 'NvimTree' then
            pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
          end
        end

        -- Focus a real buffer
        vim.defer_fn(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' and not should_exclude_buffer(buf) then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                pcall(vim.api.nvim_win_set_buf, win, buf)
                pcall(vim.api.nvim_set_current_win, win)
                return
              end
              break
            end
          end
        end, 100)
      end,
      group = vim.api.nvim_create_augroup('PersistenceLoadHooks', { clear = true }),
    })

    -- Create a debug command to inspect session state (optional)
    vim.api.nvim_create_user_command('PersistenceDebug', function()
      print('Persistence active:', persistence.active)
      print('Current session:', vim.v.this_session)
      print('Persistence dir:', persistence.config.dir)
      print('Persistence need:', persistence.config.need)
      print('Current directory:', vim.fn.getcwd())

      print('\nSession options:', vim.inspect(vim.opt.sessionoptions:get()))

      print '\nBuffers:'
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(bufnr)
        local ft = pcall(function()
          return vim.api.nvim_buf_get_option(bufnr, 'filetype')
        end) and vim.api.nvim_buf_get_option(bufnr, 'filetype') or 'unknown'
        local bt = pcall(function()
          return vim.api.nvim_buf_get_option(bufnr, 'buftype')
        end) and vim.api.nvim_buf_get_option(bufnr, 'buftype') or 'normal'
        local excluded = should_exclude_buffer(bufnr)

        print(string.format('Buffer %d: %s (ft: %s, bt: %s) - %s', bufnr, name, ft, bt, excluded and 'EXCLUDED' or 'included'))
      end
    end, {})
  end,
}
