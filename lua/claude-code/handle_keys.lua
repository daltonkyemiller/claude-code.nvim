local buffers = require("claude-code.buffers")
local commands = require("claude-code.commands")
local config = require("claude-code.config")
local files = require("claude-code.files")
local state = require("claude-code.state")
local terminal = require("claude-code.terminal")

local function buf_lacks_content(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return true end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return #lines == 0 or (#lines == 1 and lines[1] == "")
end

local function submit_input()
  local input_text = buffers.get_input_buffer_text()

  terminal.send_input(input_text)
  terminal.send_enter()

  -- Clear input buffer
  buffers.clear_input_buffer()
end

local function send_escape() terminal.send_escape() end

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
      if keymap and keymap.n ~= false then
        setup_mode_mappings("n", keymap, function() terminal.send_sequence(sequence) end, state.input_bufnr)
      end

      -- Set for insert mode
      if keymap and keymap.i ~= false then
        setup_mode_mappings("i", keymap, function() terminal.send_sequence(sequence) end, state.input_bufnr)
      end
    end
  else
    -- Remove all arrow key mappings when buffer has content
    for _, key in ipairs(arrow_keys) do
      local keymap = keymaps[key.name]

      -- Restore or remove normal mode mapping
      if keymap and keymap.n ~= false then
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
      if keymap and keymap.i ~= false then
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

function add_files_to_ctx()
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local col = pos[2]

  files.pick(function(paths)
    vim.api.nvim_set_current_win(state.input_winnr)
    local text = vim.iter(paths):map(function(path) return "@" .. path end):join(" ")
    vim.api.nvim_buf_set_text(0, row, col, row, col, { text })
    -- set the cursor to the end of the inserted text
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
    return nil
  end)
end

local M = {}

M.setup_input_bufr_mappings = function()
  local keymaps = config.keymaps
  local bufnr = state.input_bufnr

  if bufnr == nil then
    vim.notify("Claude Code: No input buffer found.", vim.log.levels.WARN)
    return
  end

  setup_both_mode_mappings(keymaps.submit, submit_input, bufnr)

  setup_both_mode_mappings(keymaps.escape, send_escape, bufnr)

  setup_both_mode_mappings(keymaps.shift_tab, function() terminal.send_sequence("\x1b[Z") end, bufnr)

  -- Set keymap to switch window
  setup_both_mode_mappings(
    keymaps.switch_window,
    function() vim.api.nvim_set_current_win(state.claude_winnr) end,
    bufnr
  )

  setup_both_mode_mappings(keymaps.pick_file, add_files_to_ctx, bufnr)

  -- Set keymap to close
  setup_both_mode_mappings(keymaps.close, commands.hide, bufnr)

  local current_normal_mappings = vim.api.nvim_buf_get_keymap(bufnr, "n")
  local current_insert_mappings = vim.api.nvim_buf_get_keymap(bufnr, "i")

  -- Set up autocmd to update mappings when buffer content changes
  local autocmds = require("claude-code.autocmds")
  autocmds.setup_input_buffer_text_changed(
    bufnr,
    function() update_movement_mappings(current_normal_mappings, current_insert_mappings) end
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
  setup_both_mode_mappings(keymaps.close, commands.close, bufnr)
end

return M
