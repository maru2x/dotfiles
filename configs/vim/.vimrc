set clipboard=unnamedplus

" Insert mode Emacs-like keybindings
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-p> <Up>
inoremap <C-n> <Down>
inoremap <C-d> <Delete>
inoremap <C-h> <BS>

" Completion navigation with C-j/C-k
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Command-line mode Emacs-like keybindings
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>

" Command-line completion navigation with C-j/C-k
cnoremap <expr> <C-j> wildmenumode() ? "\<Down>\<Tab>" : "\<C-j>"
cnoremap <expr> <C-k> wildmenumode() ? "\<Up>\<Tab>" : "\<C-k>"
