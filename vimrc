set nocp

execute pathogen#infect()

set autoindent
set background=dark
set backspace=indent,eol,start
set fileencodings=ucs-bom,utf-8,default,latin1
set guioptions=aegi
set helplang=en
set history=50
set nomodeline
set ruler

set suffixes=.class,.jar,.war,.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set termencoding=utf-8

" Make it pretty
colorscheme twilight256
syntax on

" Coding style rules
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set number

" Decorate the status bar with various useful bits of info and keep it always
" visible
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ %{fugitive#statusline()}
set laststatus=2

" Highlight trailing whitespace
hi link localWhitespaceError Error
au Syntax * syn match localWhitespaceError /\(\zs\%#\|\s\)\+$/ display
au Syntax * syn match localWhitespaceError / \+\ze\t/ display

map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map <C-}> :tnext<cr>

nnoremap <C-H> :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" Eliminate Help
noremap  <F1> :set invfullscreen<CR>
inoremap <F1> <ESC>:set invfullscreen<CR>a

" Mark <C-N> as cnext
nnoremap <C-N> :cnext<CR>
nnoremap <C-M> :cprevious<CR>

" Mark F5 for :make
map <F5> :make<cr>

" Fix Makefile tablature since it requires hard tabs
autocmd FileType make setlocal noexpandtab

" Waf wscripts
autocmd BufRead,BufNewFile wscript setlocal noexpandtab syntax=python

" Add Waf as a valid build command

" My preferred wildcard list modes
set wildmode=longest,list,full
set wildmenu

" When using with vimrc
set guifont=Consolas:h16

" Disable console bell
set vb t_vb=

filetype plugin indent on

" For some reason these languages seem to stink less with 2-space tabs
autocmd filetype html setlocal ts=2 sts=2 sw=2
autocmd filetype ruby setlocal ts=2 sts=2 sw=2
autocmd filetype javascript setlocal ts=2 sts=2 sw=2
autocmd filetype xml setlocal ts=2 sts=2 sw=2

if filereadable(getcwd()."/Makefile")
    set makeprg=make 
elseif filereadable(getcwd()."/wscript")
    if filereadable(getcwd()."/waf")
        " Use the local version of waf
        execute "set makeprg=" . fnameescape(getcwd()."/waf")
    else
        " Hopefully we have a universal waf somewhere in our path
        set makeprg=waf
    endif
endif
