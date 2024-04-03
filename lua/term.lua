local M = {}

M.floating_terminal_buf = nil
M.floating_terminal_win = nil
M.toggle_terminal_key = "<leader>t"

--- Function to open or toggle the floating terminal window.
function Toggle_floating_terminal()
  -- Check if the floating terminal window exists
  if M.floating_terminal_win and vim.api.nvim_win_is_valid(M.floating_terminal_win) then
    -- If the window exists, close it
    vim.api.nvim_win_close(M.floating_terminal_win, true)
    M.floating_terminal_buf = nil
    M.floating_terminal_win = nil
  else
    -- Calculate width and height as positive integers
    local width = math.floor(vim.api.nvim_get_option('columns') * 0.8)
    local height = math.floor(vim.api.nvim_get_option('lines') * 0.8)

    if width < 1 then
      width = 1
    end
    if height < 1 then
      height = 1
    end

    -- Create the buffer if not already existing
    if not M.floating_terminal_buf or not vim.api.nvim_buf_is_valid(M.floating_terminal_buf) then
      M.floating_terminal_buf = vim.api.nvim_create_buf(true, false) -- Set "listed" to true
    end

    -- Open the window with the existing buffer
    M.floating_terminal_win = vim.api.nvim_open_win(M.floating_terminal_buf, true, {
      style = "minimal",
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.api.nvim_get_option("lines") - height) / 2),
      col = math.floor((vim.api.nvim_get_option("columns") - width) / 2),
      focusable = true,
      border = "double",
      title = "Terminal",
    })

    local cmd = "zsh"
    -- Redirect the Zsh shell to the existing buffer
    vim.fn.termopen(cmd, {
      cwd = vim.fn.getcwd(),
      on_exit = function()
        Toggle_floating_terminal()
      end,
    })

    -- Enter terminal mode after opening the terminal
    vim.api.nvim_buf_set_keymap(M.floating_terminal_buf, 't', '<C-\\><C-n>', '<C-\\><C-n><cmd>stopinsert<CR>',
      { noremap = true })
    vim.api.nvim_buf_set_keymap(M.floating_terminal_buf, 't', M.toggle_terminal_key,
      '<cmd>lua Toggle_floating_terminal()<CR>',
      { noremap = true })

    -- Enter insert mode after opening the terminal
    vim.cmd('startinsert')
  end
end

M.Toggle_floating_terminal = Toggle_floating_terminal

function M.setup(options)
  -- Customize terminal key
  if options and options.toggle_terminal_key then
    M.toggle_terminal_key = options.toggle_terminal_key
  end

  -- Set keymap
  vim.keymap.set("n", M.toggle_terminal_key, function()
    M.Toggle_floating_terminal()
  end, { noremap = true, silent = true })
end

return M
