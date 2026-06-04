set clipboard=unnamedplus

" Keep the editor area transparent so the terminal background shows through.
function! s:dotfiles_transparent_background() abort
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NormalNC ctermbg=NONE guibg=NONE
endfunction

augroup dotfiles_transparent_background
  autocmd!
  autocmd VimEnter,ColorScheme * call <SID>dotfiles_transparent_background()
augroup END

let g:dotfiles_ime_off_command = expand('~/dotfiles/bin/ime-off')

function! s:dotfiles_ime_off() abort
  if !executable(g:dotfiles_ime_off_command)
    return
  endif

  if has('nvim')
    call jobstart([g:dotfiles_ime_off_command], {'detach': v:true})
  elseif exists('*job_start')
    call job_start([g:dotfiles_ime_off_command])
  else
    silent call system(shellescape(g:dotfiles_ime_off_command))
  endif
endfunction

augroup dotfiles_ime
  autocmd!
  autocmd InsertLeave * call <SID>dotfiles_ime_off()
augroup END

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
inoremap jj <Esc>
inoremap っj <Esc>
inoremap っｊ <Esc>
inoremap ッj <Esc>
inoremap ッｊ <Esc>

" Command-line mode Emacs-like keybindings
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>

" Command-line completion navigation with C-j/C-k
cnoremap <expr> <C-j> wildmenumode() ? "\<Down>\<Tab>" : "\<C-j>"
cnoremap <expr> <C-k> wildmenumode() ? "\<Up>\<Tab>" : "\<C-k>"
