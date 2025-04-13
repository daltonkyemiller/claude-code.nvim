local cmds = require("claude-code.commands")
local config = require("claude-code.config"):get()
local state = require("claude-code.state")
local terminal = require("claude-code.terminal")
local buffers = require("claude-code.buffers")

local M = {}

local function buf_lacks_content(bufnr)
  local first_char = vim.api.nvim_buf_get_text(bufnr, 0, 0, 0, 1, {})[1] or ""
  return first_char == "" or first_char == "\n" or first_char == nil
end

local function submit_input()
  local input_text = buffers.get_input_buffer_text()
  
  terminal.send_input(input_text)
  terminal.send_enter()

  -- Clear input buffer
  buffers.clear_input_buffer()
end

local function send_escape()
  terminal.send_escape()
end

local function create_mapping(mode, key, callback, bufnr)
  if not key then return end

  vim.keymap.set(mode, key, callback, { buffer = bufnr, silent = true })
end

local function setup_mode_mappings(mode, keymap_item, callback, bufnr)
  create_mapping(mode, keymap_item[mode], callback, bufnr)
end

local function setup_both_mode_mappings(keymap_item, callback, bufnr)
  setup_mode_mappings("n", keymap_item, callback, bufnr)
  setup_mode_mappings("i", keymap_item, callback, bufnr)
end

---@param current_normal_mappings vim.api.keyset.get_keymap[]
---@param current_insert_mappings vim.api.keyset.get_keymap[]
local function update_movement_mappings(current_normal_mappings, current_insert_mappings)
  local keymaps = config.keymaps
  local arrow_keys = {
    { name = "arrow_up", sequence = "\x1b[A" },
    { name = "arrow_down", sequence = "\x1b[B" },
    { name = "arrow_left", sequence = "\x1b[D" },
    { name = "arrow_right", sequence = "\x1b[C" },
  }

  if buf_lacks_content(state.input_bufnr) then
    -- Set arrow keys in both normal and insert modes
    for _, key in ipairs(arrow_keys) do
      local keymap = keymaps[key.name]
      local sequence = key.sequence

      -- Set for normal mode
      if keymap and keymap.n ~= "none" then
        setup_mode_mappings(
          "n",
          keymap,
          function() terminal.send_sequence(sequence) end,
          state.input_bufnr
        )
      end

      -- Set for insert mode
      if keymap and keymap.i ~= "none" then
        setup_mode_mappings(
          "i",
          keymap,
          function() terminal.send_sequence(sequence) end,
          state.input_bufnr
        )
      end
    end
  else
    -- Remove all arrow key mappings when buffer has content
    for _, key in ipairs(arrow_keys) do
      local keymap = keymaps[key.name]

      -- Restore or remove normal mode mapping
      if keymap and keymap.n ~= "none" then
        local old_mapping = vim.iter(current_normal_mappings):find(function(mapping) return mapping.lhs == keymap.n end)
        if old_mapping then
          if not old_mapping.rhs and not old_mapping.callback then return end

          vim.keymap.set("n", keymap.n, old_mapping.rhs or old_mapping.callback, {
            buffer = state.input_bufnr,
            noremap = old_mapping.noremap == 1,
            silent = old_mapping.silent == 1,
            expr = old_mapping.expr == 1,
            nowait = old_mapping.nowait == 1,
            callback = old_mapping.callback,
            desc = old_mapping.desc,
            script = old_mapping.script == 1,
          })
        else
          pcall(vim.keymap.del, "n", keymap.n, { buffer = state.input_bufnr })
        end
      end

      -- Restore or remove insert mode mapping
      if keymap and keymap.i ~= "none" then
        local old_mapping = vim.iter(current_insert_mappings):find(function(mapping) return mapping.lhs == keymap.i end)
        if old_mapping then
          if not old_mapping.rhs and not old_mapping.callback then return end

          vim.keymap.set("i", keymap.i, old_mapping.rhs or old_mapping.callback, {
            buffer = state.input_bufnr,
            noremap = old_mapping.noremap == 1,
            silent = old_mapping.silent == 1,
            expr = old_mapping.expr == 1,
            nowait = old_mapping.nowait == 1,
            callback = old_mapping.callback,
            desc = old_mapping.desc,
            script = old_mapping.script == 1,
          })
        else
          pcall(vim.keymap.del, "i", keymap.i, { buffer = state.input_bufnr })
        end
      end
    end
  end
end

M.setup_input_bufr_mappings = function()
  local keymaps = config.keymaps
  local bufnr = state.input_bufnr

  -- Set keymap to submit input
  setup_both_mode_mappings(keymaps.submit, submit_input, bufnr)

  -- Set keymap to send escape
  setup_both_mode_mappings(keymaps.escape, send_escape, bufnr)

  -- Set keymap to switch window
  setup_both_mode_mappings(
    keymaps.switch_window,
    function() vim.api.nvim_set_current_win(state.claude_winnr) end,
    bufnr
  )

  -- Set keymap to close
  setup_both_mode_mappings(keymaps.close, cmds.hide, bufnr)

  local current_normal_mappings = vim.api.nvim_buf_get_keymap(bufnr, "n")
  local current_insert_mappings = vim.api.nvim_buf_get_keymap(bufnr, "i")

  -- Set up autocmd to update mappings when buffer content changes
  local autocmds = require("claude-code.autocmds")
  autocmds.setup_input_buffer_text_changed(
    bufnr,
    current_normal_mappings,
    current_insert_mappings,
    update_movement_mappings
  )

  -- Initial setup of mappings
  update_movement_mappings(current_normal_mappings, current_insert_mappings)
end

M.setup_claude_bufr_mappings = function()
  local keymaps = config.keymaps
  local bufnr = state.claude_bufnr

  -- Set keymap to switch window
  setup_both_mode_mappings(keymaps.switch_window, function() vim.api.nvim_set_current_win(state.input_winnr) end, bufnr)

  -- Set keymap to close
  setup_both_mode_mappings(keymaps.close, cmds.close, bufnr)
end

return M