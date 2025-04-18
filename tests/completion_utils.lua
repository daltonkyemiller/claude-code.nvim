local stub = require("luassert.stub")
local mock = require("luassert.mock")

describe("completion utils", function()
  local completion_utils = require("claude-code.integrations.completion.utils")
  local terminal
  
  before_each(function()
    terminal = mock(require("claude-code.terminal"))
  end)
  
  after_each(function()
    mock.revert(terminal)
  end)
  
  it("should apply text edits and set cursor position", function()
    local applied = false
    local cursor_set = false
    
    local orig_apply_text_edits = vim.lsp.util.apply_text_edits
    vim.lsp.util.apply_text_edits = function() applied = true end
    
    local orig_win_set_cursor = vim.api.nvim_win_set_cursor
    vim.api.nvim_win_set_cursor = function() cursor_set = true end
    
    local item = {
      textEdit = {
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = 0, character = 5 }
        }
      },
      data = {
        type = "custom"
      }
    }
    
    local callback_called = false
    local callback = function() callback_called = true end
    
    completion_utils.execute_completion(item, callback)
    
    vim.lsp.util.apply_text_edits = orig_apply_text_edits
    vim.api.nvim_win_set_cursor = orig_win_set_cursor
    
    assert.is_true(applied)
    assert.is_true(cursor_set)
    assert.is_true(callback_called)
  end)
  
  it("should handle claude commands", function()
    local item = {
      label = "memory",
      textEdit = {
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = 0, character = 5 }
        }
      },
      data = {
        type = "claude"
      }
    }
    
    local callback_called = false
    local callback = function() callback_called = true end
    
    local orig_input = vim.api.nvim_input
    local input_called = false
    vim.api.nvim_input = function() input_called = true end
    
    completion_utils.execute_completion(item, callback)
    
    assert(terminal.send_input).was.called()
    assert(terminal.send_enter).was.called()
    assert.is_true(input_called)
    assert.is_true(callback_called)
    
    vim.api.nvim_input = orig_input
  end)
  
  it("should call custom callbacks", function()
    local callback_fn_called = false
    local item = {
      textEdit = {
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = 0, character = 5 }
        }
      },
      data = {
        type = "custom",
        callback = function(handle_apply)
          callback_fn_called = true
          handle_apply("test text")
        }
      }
    }
    
    local callback_called = false
    local callback = function() callback_called = true end
    
    completion_utils.execute_completion(item, callback)
    
    assert.is_true(callback_fn_called)
    assert.is_true(callback_called)
  end)
end)