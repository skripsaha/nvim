:set number
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a



if has('gui_running') || has('termguicolors')
    set termguicolors
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NonText guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
    highlight VertSplit guibg=NONE ctermbg=NONE
    highlight StatusLine guibg=NONE ctermbg=NONE
    highlight StatusLineNC guibg=NONE ctermbg=NONE
endif


call plug#begin()

Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/tpope/vim-commentary'
Plug 'https://github.com/ap/vim-css-color'
Plug 'https://github.com/rafi/awesome-vim-colorschemes'
Plug 'https://github.com/ryanoasis/vim-devicons'
Plug 'https://github.com/tc50cal/vim-terminal'
Plug 'https://github.com/neoclide/coc.nvim'
Plug 'https://github.com/sheerun/vim-polyglot'
Plug 'https://github.com/preservim/nerdcommenter'
Plug 'https://github.com/jiangmiao/auto-pairs'

call plug#end()


:set encoding=UTF-8
"source /home/bluetoothpaste/.local/share/nvim/plugged/awesome-vim-colorschemes/colors/PaperColor.vim
:set completeopt-=preview
:colorscheme PaperColor
:set completeopt-=preview
:set encoding=UTF-8
:highlight Normal guibg=NONE ctermbg=NONE
:highlight NonText guibg=NONE ctermbg=NONE
:highlight LineNr guibg=NONE ctermbg=NONE

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | wincmd p


nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>

"Tab autocomplete
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"
