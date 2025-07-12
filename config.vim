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
nnoremap <leader>s :tab split \| :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>c :tab split \| :cs find c <C-R>=expand("<cword>")<CR><CR>

nnoremap <Leader>f :vimgrep /\<<C-R><C-W>\>/j % \| wincmd p \| copen<CR>
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

""""" highlights """""

highlight CustomHighlight1  ctermbg=yellow     guibg=yellow
highlight CustomHighlight2  ctermbg=cyan       guibg=cyan
highlight CustomHighlight3  ctermbg=magenta    guibg=magenta
highlight CustomHighlight4  ctermbg=green      guibg=lightgreen
highlight CustomHighlight5  ctermbg=blue       guibg=lightblue
highlight CustomHighlight6  ctermbg=red        guibg=red
highlight CustomHighlight7  ctermbg=white      guibg=white        ctermfg=black        guifg=black
highlight CustomHighlight8  ctermbg=darkgray   guibg=gray
highlight CustomHighlight9  ctermbg=darkblue   guibg=#5f87ff
highlight CustomHighlight10 ctermbg=darkgreen  guibg=#5fff5f


let g:highlight_matches = []
let g:highlight_index = 1
let g:highlight_max = 10

function! AddWordHighlight()
  let word = expand('<cword>')
  if len(word) == 0
    echo "No word on the cursor."
    return
  endif

  let group = 'CustomHighlight' . g:highlight_index
  let pattern = '\V\<'.word.'\>'

  let matchid = matchadd(group, pattern)
  call add(g:highlight_matches, matchid)

  let g:highlight_index = g:highlight_index % g:highlight_max + 1
endfunction

function! ClearAllHighlights()
  for id in g:highlight_matches
    call matchdelete(id)
  endfor
  let g:highlight_matches = []
  let g:highlight_index = 1
endfunction

nnoremap <silent> <leader>g :call AddWordHighlight()<CR>
nnoremap <silent> <C-g> :call ClearAllHighlights()<CR>
