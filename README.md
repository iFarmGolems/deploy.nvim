# 🚀 deploy.nvim

A powerful Neovim plugin for seamlessly deploying files to remote servers using `rsync` as the transfer backend.

## ✨ Features

- 📤 **Fast File Deployment** - Deploy files to remote servers on save and/or with a single command
- 🎯 **Multiple Host Support** - Configure multiple deployment targets
- 🔧 **Custom Rewrite Functions** - Transform file paths before deployment or abort deployment
- 📁 **Auto Directory Creation** - Automatically creates remote directories if they don't exist
- 🎨 **Custom Host Input** - Deploy to ad-hoc addresses on the fly
- ⚡ **Async Operations** - Non-blocking deployments using `nvim-nio`

## 📋 Requirements

- Neovim >= 0.9.0
- `rsync` installed on your system
- SSH access to remote servers without password (exchanged SSH keys)
- [nvim-nio](https://github.com/nvim-neotest/nvim-nio) - Dependency for this plugin

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "iFarmGolems/deploy.nvim",
  dependencies = { "nvim-neotest/nvim-nio" },
  config = function()
    require("deploy").setup({
      -- your configuration here
    })
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "iFarmGolems/deploy.nvim",
  requires = { "nvim-neotest/nvim-nio" },
  config = function()
    require("deploy").setup({
      -- your configuration here
    })
  end,
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-neotest/nvim-nio'
Plug 'iFarmGolems/deploy.nvim'

" In your init.vim or init.lua:
lua << EOF
require("deploy").setup({
  -- your configuration here
})
EOF
```

## ⚙️ Configuration

### Basic Setup

```lua
require("deploy").setup({
  timeout = 3, -- rsync timeout in seconds
  hosts = {
    {
      label = "Production Server",
      address = "prod.example.com",
    },
    {
      label = "Staging Server",
      address = "staging.example.com",
    },
  },
  mappings = {
    {
      fs = "~/projects/myapp",
      remote = "/var/www/myapp",
    },
  },
})
```

### Advanced Configuration with Rewrite Functions

```lua
require("deploy").setup({
  timeout = 5,
  hosts = {
    {
      label = "Production",
      address = "prod.example.com",
      -- Optional: Transform paths before deployment for this host
      rewrite = function(context)
        -- context.source: local file path
        -- context.destination: remote file path
        -- context.address: host address
        -- context.extension: file extension

        -- Example: Skip deployment for test files
        if context.source:match("%.test%.") then
          return false -- abort deployment
        end

        -- Modify the destination path
        context.destination = context.destination:gsub("%.dev%.", ".")
        -- Return nil or nothing to continue deployment
      end,
    },
    {
      label = "Development",
      address = "dev.example.com",
    },
  },
  mappings = {
    {
      fs = "~/projects/frontend",
      remote = "/var/www/html",
      -- Optional: Transform paths for this mapping
      rewrite = function(context)
        -- Example: Deploy .ts files as .js files
        if context.extension == "ts" then
          context.destination = context.destination:gsub("%.ts$", ".js")
        end
      end,
    },
    {
      fs = "~/projects/backend",
      remote = "/opt/backend",
    },
  },
})
```

## 🎮 Usage

### Commands

#### Deploy Current File

```vim
:Deploy file
" or
:Deploy buffer
```

Deploys the current buffer to a remote server. You'll be prompted to select a host.

#### Toggle Auto-Deploy on Save

```vim
:Deploy toggle
```

Enables or disables automatic deployment whenever you save a file.

### Lua API

```lua
local deploy = require("deploy.lib")

-- Deploy a specific file
deploy.deploy_file("/path/to/file.lua", {
  silent = false, -- Show notifications
  deploy_to_last_host = false, -- Prompt for host selection
})

-- Deploy to last used host without prompting
deploy.deploy_file("/path/to/file.lua", {
  deploy_to_last_host = true,
})

-- Toggle auto-deploy on save
deploy.toggle_deploy_on_save()

-- Enable auto-deploy on save
deploy.toggle_deploy_on_save(true)

-- Disable auto-deploy on save
deploy.toggle_deploy_on_save(false)

-- Check if a file is deployable
if deploy.is_deployable("/path/to/file.lua") then
  print("File can be deployed")
end

-- Get the mapping for a file
local mapping = deploy.get_file_mapping("/path/to/file.lua")
if mapping then
  print("Local: " .. mapping.fs)
  print("Remote: " .. mapping.remote)
end
```

### Keybindings Example

```lua
vim.keymap.set("n", "<leader>df", ":Deploy file<CR>", { desc = "Deploy current file" })
vim.keymap.set("n", "<leader>dt", ":Deploy toggle<CR>", { desc = "Toggle deploy on save" })

-- Or using Lua API
vim.keymap.set("n", "<leader>df", function()
  require("deploy.lib").deploy_file(vim.fn.expand("%:p"), { silent = false })
end, { desc = "Deploy current file" })

vim.keymap.set("n", "<leader>dl", function()
  require("deploy.lib").deploy_file(vim.fn.expand("%:p"), {
    silent = false,
    deploy_to_last_host = true,
  })
end, { desc = "Deploy to last host" })
```
```

## 🔍 How It Works

1. **File Mapping**: When you deploy a file, deploy.nvim checks your `mappings` configuration to find which local path matches your file
2. **Host Selection**: You're prompted to select a destination host (or it uses the last selected host)
3. **Path Transformation**: The local path is transformed to the remote path based on the mapping
4. **Rewrite Functions**: If configured, rewrite functions are executed (mapping rewrite first, then host rewrite)
5. **Deployment**: `rsync` is used to transfer the file over SSH
6. **Error Handling**: If the remote directory doesn't exist, it's automatically created and deployment is retried

## 📚 Configuration Types

### DeployHost

```lua
---@class DeployHost
---@field address string The host address (e.g., "example.com" or "192.168.1.100")
---@field label string A human-readable label for the host
---@field rewrite? function Optional function to transform paths for this host
```

### DeployMapping

```lua
---@class DeployMapping
---@field fs string Local filesystem folder (e.g., "~/projects/myapp")
---@field remote string Remote folder (e.g., "/var/www/myapp")
---@field rewrite? function Optional function to transform paths for this mapping
```

### DeployConfig

```lua
---@class DeployConfig
---@field timeout number Rsync timeout in seconds (default: 3)
---@field hosts DeployHost[] Array of deployment hosts
---@field mappings DeployMapping[] Array of path mappings
```

## 🩺 Health Check

Run `:checkhealth deploy` to verify your setup and check for:
- Rsync installation
- SSH connectivity
- Configuration issues

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT

## 🙏 Acknowledgments

- Built with [nvim-nio](https://github.com/nvim-neotest/nvim-nio) for async operations
- Uses `rsync` for reliable file transfers
