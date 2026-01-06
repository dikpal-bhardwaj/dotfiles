" =========================
" LSP Configuration
" =========================

" Enable diagnostics highlighting
let lspOpts = #{
    \ autoHighlightDiags: v:true,
    \ diagSignErrorText: '✘',
    \ diagSignWarningText: '▲',
    \ diagSignInfoText: '»',
    \ diagSignHintText: '⚑',
    \}
autocmd User LspSetup call LspOptionsSet(lspOpts)

" =========================
" LSP Servers
" =========================
let lspServers = [
    \ #{
    \   name: 'rust-analyzer',
    \   filetype: ['rust'],
    \   path: 'rust-analyzer',
    \   args: []
    \ },
    \ #{
    \   name: 'html-languageserver',
    \   filetype: ['html'],
    \   path: 'vscode-html-language-server',
    \   args: ['--stdio']
    \ },
    \ #{
    \   name: 'css-languageserver',
    \   filetype: ['css'],
    \   path: 'vscode-css-language-server',
    \   args: ['--stdio']
    \ },
    \ #{
    \   name: 'tailwindcss-ls',
    \   filetype: ['html', 'css', 'javascript', 'typescript', 'typescriptreact', 'javascriptreact'],
    \   path: 'tailwindcss-language-server',
    \   args: ['--stdio']
    \ },
    \ #{
    \   name: 'tsserver',
    \   filetype: ['javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'jsx', 'tsx'],
    \   path: 'typescript-language-server',
    \   args: ['--stdio']
    \ },
    \ #{
    \   name: 'clangd',
    \   filetype: ['c', 'cpp'],
    \   path: 'clangd',
    \   args: []
    \ },
    \ #{
    \   name: 'pylsp',
    \   filetype: ['python'],
    \   path: 'pylsp',
    \   args: []
    \ },
    \ #{
    \   name: 'gopls',
    \   filetype: ['go'],
    \   path: 'gopls',
    \   args: []
    \ },
\ ]

autocmd User LspSetup call LspAddServer(lspServers)

" =========================
" Key Mappings
" =========================
nnoremap gd :LspGotoDefinition<CR>
nnoremap gr :LspShowReferences<CR>
nnoremap K  :LspHover<CR>
nnoremap gl :LspDiag current<CR>
nnoremap <leader>nd :LspDiag next \| LspDiag current<CR>
nnoremap <leader>pd :LspDiag prev \| LspDiag current<CR>
inoremap <silent> <C-Space> <C-x><C-o>

" =========================
" Completion
" =========================
autocmd FileType rust,html,css,javascript,typescript,jsx,tsx,c,cpp,python,go setlocal omnifunc=lsp#complete

