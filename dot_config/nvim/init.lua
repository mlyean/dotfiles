-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = '-'
vim.g.maplocalleader = '\\'

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    { "rose-pine/neovim", name = "rose-pine" },
    {
      "lervag/vimtex",
      lazy = false,     -- we don't want to lazy load VimTeX
      -- tag = "v2.15", -- uncomment to pin to a specific release
      init = function()
        -- VimTeX configuration goes here, e.g.
        vim.env.GDK_BACKEND = 'x11'
        vim.g.vimtex_view_method = "zathura"
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    },
    {
      "kylechui/nvim-surround",
      version = "^3.1.8", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
        })
      end
    },
    -- { 'neoclide/coc.nvim', branch = 'release', },
    {
      'Julian/lean.nvim',
      event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      opts = {
        mappings = true,
      }
    },
    { 'junegunn/fzf' },
    { 'junegunn/fzf.vim' }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

-- Print the line number in front of each line
vim.o.number = true

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
vim.o.relativenumber = true

vim.opt.pumwidth = 40

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight the line where the cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Show <tab> and trailing spaces
vim.o.list = true

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.o.confirm = true

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    vim.o.tabstop = 2
    vim.o.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  command = 'setlocal spell spelllang=en_us'
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = {'*.sage', '*.spyx', '*.pyx'},
  command = 'set filetype=python'
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
vim.cmd('packadd! nohlsearch')
vim.cmd('colorscheme rose-pine')

vim.diagnostic.config({ virtual_text = true })
vim.lsp.enable('haskell')

local Rule = require('nvim-autopairs.rule')
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- _G.MUtils= {}

-- MUtils.completion_confirm=function()
--     if vim.fn["coc#pum#visible"]() ~= 0  then
--         return vim.fn["coc#pum#confirm"]()
--     else
--         return npairs.autopairs_cr()
--     end
-- end

-- remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

npairs.add_rule(Rule("$","$","tex"))

-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua

-- -- Some servers have issues with backup files, see #649
-- vim.opt.backup = false
-- vim.opt.writebackup = false
-- 
-- -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- -- delays and poor user experience
-- vim.opt.updatetime = 300
-- 
-- -- Always show the signcolumn, otherwise it would shift the text each time
-- -- diagnostics appeared/became resolved
-- vim.opt.signcolumn = "yes"
-- 
-- local keyset = vim.keymap.set
-- -- Autocomplete
-- function _G.check_back_space()
--   local col = vim.fn.col('.') - 1
--   return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
-- end
-- 
-- -- Use Tab for trigger completion with characters ahead and navigate
-- -- NOTE: There's always a completion item selected by default, you may want to enable
-- -- no select by setting `"suggest.noselect": true` in your configuration file
-- -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- -- other plugins before putting this into your config
-- local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
-- keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
-- keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
-- 
-- -- Make <CR> to accept selected completion item or notify coc.nvim to format
-- -- <C-g>u breaks current undo, please make your own choice
-- keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
-- 
-- -- Use <c-j> to trigger snippets
-- keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- -- Use <c-space> to trigger completion
-- keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})
-- 
-- -- Use `[g` and `]g` to navigate diagnostics
-- -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
-- keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
-- keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})
-- 
-- -- GoTo code navigation
-- keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
-- keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
-- keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
-- keyset("n", "gr", "<Plug>(coc-references)", {silent = true})
-- 
-- 
-- -- Use K to show documentation in preview window
-- function _G.show_docs()
--   local cw = vim.fn.expand('<cword>')
--   if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
--     vim.api.nvim_command('h ' .. cw)
--   elseif vim.api.nvim_eval('coc#rpc#ready()') then
--     vim.fn.CocActionAsync('doHover')
--   else
--     vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
--   end
-- end
-- keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
-- 
-- 
-- -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
-- vim.api.nvim_create_augroup("CocGroup", {})
-- vim.api.nvim_create_autocmd("CursorHold", {
--   group = "CocGroup",
--   command = "silent call CocActionAsync('highlight')",
--   desc = "Highlight symbol under cursor on CursorHold"
-- })
-- 
-- 
-- -- Symbol renaming
-- keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})
-- 
-- 
-- -- Formatting selected code
-- keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
-- keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
-- 
-- 
-- -- Setup formatexpr specified filetype(s)
-- vim.api.nvim_create_autocmd("FileType", {
--   group = "CocGroup",
--   pattern = "typescript,json",
--   command = "setl formatexpr=CocAction('formatSelected')",
--   desc = "Setup formatexpr specified filetype(s)."
-- })
-- 
-- -- Apply codeAction to the selected region
-- -- Example: `<leader>aap` for current paragraph
-- local opts = {silent = true, nowait = true}
-- keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
-- keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
-- 
-- -- Remap keys for apply code actions at the cursor position.
-- keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- -- Remap keys for apply source code actions for current file.
-- keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- -- Apply the most preferred quickfix action on the current line.
-- keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)
-- 
-- -- Remap keys for apply refactor code actions.
-- keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
-- keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
-- keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
-- 
-- -- Run the Code Lens actions on the current line
-- keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)
-- 
-- 
-- -- Map function and class text objects
-- -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
-- keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
-- keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
-- keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
-- keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
-- keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
-- keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
-- keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
-- keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)
-- 
-- 
-- -- Remap <C-f> and <C-b> to scroll float windows/popups
-- ---@diagnostic disable-next-line: redefined-local
-- local opts = {silent = true, nowait = true, expr = true}
-- keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
-- keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
-- keyset("i", "<C-f>",
-- 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
-- keyset("i", "<C-b>",
-- 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
-- keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
-- keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
-- 
-- 
-- -- Use CTRL-S for selections ranges
-- -- Requires 'textDocument/selectionRange' support of language server
-- keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
-- keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
-- 
-- 
-- -- Add `:Format` command to format current buffer
-- vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
-- 
-- -- " Add `:Fold` command to fold current buffer
-- vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})
-- 
-- -- Add `:OR` command for organize imports of the current buffer
-- vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
-- 
-- -- Add (Neo)Vim's native statusline support
-- -- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- -- provide custom statusline: lightline.vim, vim-airline
-- vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
-- 
-- -- Mappings for CoCList
-- -- code actions and coc stuff
-- ---@diagnostic disable-next-line: redefined-local
-- local opts = {silent = true, nowait = true}
-- -- Show all diagnostics
-- keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- -- Manage extensions
-- keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- -- Show commands
-- keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- -- Find symbol of current document
-- keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- -- Search workspace symbols
-- keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- -- Do default action for next item
-- keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- -- Do default action for previous item
-- keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- -- Resume latest coc list
-- keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)

require('lualine').setup()
