" useful vim commands
" Copy " register to real clipboard 
function osc52Copy
  "execute "silent !echo -e '".system('yank',@")."'"
  exec '!echo '.shellescape(system('yank',@"))
endfunc
