" install vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

" Disable compatibility mode
set nocp

" Start vim-plug
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'bronson/vim-trailing-whitespace'

Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'junegunn/rainbow_parentheses.vim'

Plug 'itchyny/lightline.vim'

Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'piec/vim-lsp-clangd'

call plug#end()

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

" Bring on the GDB
packadd termdebug

" Make it pretty
colorscheme twilight256
syntax on

" Coding style rules
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set number

" Set up rainbow parens
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
autocmd VimEnter * RainbowParentheses

" Decorate the status bar with various useful bits of info and keep it always
" visible
"set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ %{fugitive#statusline()}

" Hide the mode on the bottom line
set noshowmode

" Configure Lightline
let g:lightline = {
    \   'colorscheme': 'jellybeans',
    \   'active' : {
    \     'left' : [ [ 'mode', 'paste' ],
    \                [ 'readonly', 'filename', 'modified' ] ],
    \     'right': [ [ 'lineinfo' ],
    \                [ 'percent' ],
    \                [ 'fileformat', 'fileencoding', 'filetype', 'gitbranch' ] ]
    \   },
    \   'component_function' : {
    \     'gitbranch' : 'fugitive#statusline'
    \   },
    \ }

" Enable the status line
set laststatus=2

" Set up the LSP, if clangd is available
if executable('clangd')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'clangd',
    \ 'cmd': {server_info->['clangd', '-background-index']},
    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
    \ })
endif

" Enable LSP
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Enable autocomplete pop-up for C-space
function! Auto_complete_string()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<C-x>\<C-o>\<C-r>=Auto_complete_opened()\<CR>"
    end
endfunction

function! Auto_complete_opened()
    if pumvisible()
        return "\<Down>"
    end
    return ""
endfunction

inoremap <expr> <Nul> Auto_complete_string()
inoremap <expr> <C-Space> Auto_complete_string()


map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map <C-}> :tnext<cr>

" Mappings for Toggling Hexmode
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

" Map Ctrl+F5 to enter debugging
map <C-F5> :Termdebug<cr>

" Map Ctrl+S to single step
map <C-S> :Step<cr>

" Map Ctrl+O to step over
map <C-O> :Over<cr>

" Map Ctrl+F to finish
map <C-F> :Finish<cr>

" Map Ctrl+B to insert a breakpoint under the cursor
map <C-B> :Break<cr>


" Fix Makefile tablature since it requires hard tabs
autocmd FileType make setlocal noexpandtab

" Waf wscripts
autocmd BufRead,BufNewFile wscript setlocal noexpandtab syntax=python

" Kill if Nerd-Tree is the only thing open
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:plug_window = 'noautocmd vertical topleft new'

" If more than one window and previous buffer was NERDTree, go back to it.
"autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif

" My preferred wildcard list modes
set wildmode=longest,list,full
set wildmenu

" When using with vimrc
set guifont=Consolas:h16

" Disable console bell
set vb t_vb=

if !has('gui_running')
  set t_Co=256
endif

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
