-- Function to run make with a specific target

local function escape_shell_arg(arg)
  return '"' .. arg:gsub('"', '\\"') .. '"'
end

local function make_target(target)
  local file_no_ext = vim.fn.expand '%:t:r' -- Get the current file name without extension
  local file_dir = vim.fn.expand '%:p:h' -- Get the directory of the current file
  local makefile_path = file_dir .. '/Makefile'

  -- Check if Makefile exists
  if vim.fn.filereadable(makefile_path) == 0 then
    -- Create a default Makefile if it doesn't exist
    local default_makefile = [[
CXX = g++
CXXFLAGS =  -std=c++17 -g

# The default target
.DEFAULT_GOAL := all

# Targets
all: compile

compile: "$(TARGET)"
	$(CXX) $(CXXFLAGS) "$(TARGET).cpp" -o "$(TARGET)"

run: compile
	./"$(TARGET)"

compile_and_run: compile run

clean:
	rm -f "$(TARGET)"

# Define the target as an environment variable
TARGET ?= main  # Default target file if none specified
]]
    -- Write the default Makefile
    local file = io.open(makefile_path, 'w')
    file:write(default_makefile)
    file:close()
  end

  -- Run make with the specified target, changing to the file's directory
  local escaped_file_no_ext = escape_shell_arg(file_no_ext)
  local cmd = string.format('cd %s && make TARGET=%s %s', escape_shell_arg(file_dir), escaped_file_no_ext, target)
  vim.api.nvim_command('! ' .. cmd)
end

-- Create commands to call the makefile targets
vim.api.nvim_create_user_command('MakeCompile', function()
  make_target 'compile'
end, {})
vim.api.nvim_create_user_command('MakeCompileAndRun', function()
  make_target 'compile_and_run'
end, {})

-- Optional: Map the commands to key combinations
vim.api.nvim_set_keymap('n', '<leader>cc', ':MakeCompile<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cr', ':MakeCompileAndRun<CR>', { noremap = true, silent = true })

return {}
