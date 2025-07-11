call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

set mouse=a

if filereadable("cscope.out")
    silent! cs add cscope.out
endif

nnoremap <2-LeftMouse> <C-]>
nnoremap <leader>] :tab split \| :tag <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>q :tabclose<CR>

nnoremap <C-s> :cs find s<space>
nnoremap <leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>r :cs find r <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>

nnoremap <leader>t :TagbarToggle<CR>
nnoremap <C-n> :tabe<CR>

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-f> :NERDTreeFind<CR>

let g:airline#extensions#tabline#enabled = 1
let g:NERDTreeWinSize = 30

function! OpenLayout()
  NERDTree
  wincmd l
  TagbarToggle
endfunction

autocmd TabEnter * if winnr('$') == 1 | call OpenLayout() | endif
autocmd VimEnter * call OpenLayout()
