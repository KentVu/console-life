" useful vim configs
nnoremap <F10> :mksession! \| :confirm q<CR>
inoremap <F10> <ESC>:mksession! \| :confirm q<CR>

" Copy " register to real clipboard 
function osc52Copy
  "execute "silent !echo -e '".system('yank',@")."'"
  exec '!echo '.shellescape(system('yank',@"))
endfunc
