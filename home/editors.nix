{ pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      filetype plugin indent on

      syntax on
      set background=dark
      colorscheme solarized8

      au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
      au BufNewFile,BufRead *.rs set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
      au BufNewFile,BufRead *.nix set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab autoindent
      au BufNewFile,BufRead *.ml set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab autoindent

      au BufNewFile,BufRead *.md set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab autoindent linebreak

      " Automatically save the current buffer when another buffer is selected *or* when neovim loses
      " focus.
      augroup autosave_buffer
        au!
        au BufLeave * :w
        au FocusLost * :w
      augroup END

      set ruler
      set number

      set listchars=tab:␉·,trail:·,extends:>,precedes:<
      set list

      " Set diagnostic colors to match Solarized.
      highlight DiagnosticError guifg=#dc322f " red
      highlight DiagnosticWarn guifg=#b58900 " yellow
      highlight DiagnosticInfo guifg=#2aa198 " cyan
      highlight DiagnosticHint guifg=#6c71c4 " violet
    '';

    initLua = ''
      -- !! LSP configuration
      -- Nix
      vim.lsp.enable("nixd")

      -- Rust
      vim.lsp.config("rust_analyzer", {
        settings = {
          ['rust-analyzer'] = {
            check = {
              command = "clippy",
            },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      -- Python
      vim.lsp.enable("ruff", {
        init_options = {
          settings = {
          },
        },
      })
      vim.lsp.enable("pyrefly")

      -- Configure autoformatting
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_autoformatting", {}),
        callback = function(event)
          local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
          -- Ideally this would do some kind of feature check, but the one documented on the
          -- neovim website doesn't seem to work for rust-analyzer or ruff ¯\_(ツ)_/¯
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("lsp_autoformatting", {clear=false}),
            buffer = event.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = event.buf, id = client.id, timeout_ms = 1000 })
            end,
          })
        end,
      })

      -- !! Diagnostic UI
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          multilines = {
            enabled = true,
          },
          show_source = {
            enabled = true,
            if_many = true,
          },
        },
      })
    '';

    plugins = with pkgs.vimPlugins; [
      # Integrates direnv from any project directories so that neovim can use the correct
      # environment configuration.
      direnv-vim

      # This plugin adds a lot of fancy features, but I'm mostly interested in the gutter bar
      # features (it shows added and removed lines) and status line integration.
      gitsigns-nvim

      # Contains configuration presets for many common LSP implementations; used for convenience
      # to avoid having to manually configure LSPs.
      nvim-lspconfig

      # Very small GUI upgrade for inline diagnostics to make them prettier and handle line
      # wrapping better.
      tiny-inline-diagnostic-nvim

      # This is the best-looking Solarized theme I have found that works with neovim as of Feb 2026.
      vim-solarized8
    ];

    # New defaults as of 26.05, set explicitly to silence
    # warnings
    withRuby = false;
    withPython3 = false;
  };
}
