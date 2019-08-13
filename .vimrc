" vim:foldmethod=marker

"source ~/.vim/vundle.vim

map Y y$
map <F2> :w<CR>
imap <F2> <ESC>:w<CR>
map <F3> :set cursorline!<CR>
map <F10> :confirm q<CR>
" eclipse-like scrolling
nmap <C-Up> <C-y>
nmap <C-Down> <C-e>
" search for currently selected text (visual mode)
vnoremap // y:exec '/\M'.escape('<C-R>"', '/')<CR>
if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
  set backupdir=~/.vimbackup
  set undodir=~/.vimbackup
endif
set history=2000		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
" addition
set nowrapscan
set ignorecase
set ts=4 sw=4

filetype plugin on
filetype indent on

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
  set ttymouse=sgr
endif
set foldlevelstart=3

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  set foldmethod=syntax
  set foldcolumn=1
  "colorscheme murphy

  " syntaxes
  let g:sh_fold_enabled= 4
  let java_highlight_java_lang_ids=1
  "let g:xml_syntax_folding = 1
endif
