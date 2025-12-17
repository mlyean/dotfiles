return {
    cmd = { 'haskell-language-server-wrapper', "--lsp" },
    filetypes = { 'haskell' },
    root_markers = { ".cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml" },
}
