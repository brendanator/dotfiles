" function! s:GotoStart(type)
"   call setpos('.', getpos("'["))
" endfunction

" function! s:GotoEnd(type)
"   call setpos('.', getpos("']"))
" endfunction

" " This complements ninja-feet
" " nmap <silent> ga :set opfunc=<sid>GotoStart<cr>g@a
" " nmap <silent> gi :set opfunc=<sid>GotoEnd<cr>g@i

" " omap <silent> ga :set opfunc=<sid>ObjToStart<cr>g@a
" " omap <silent> gi mg:set opfunc=<sid>ObjToEnd<cr>g@i

" call textobj#user#plugin('assignment', {
" \   'assignment-i': {
" \     'pattern': ['^\(  \)*', ' = '],
" \     'select-i': 'iA',
" \     'scan': 'nearest'
" \   },
" \   'assignment-a': {
" \     'pattern': ['^\(  \)*\zs\<', ' = '],
" \     'select-a': 'aA',
" \     'scan': 'nearest'
" \   }})

" function! s:delete_sheath(type)
"   normal q
" 	let pos = getpos("'[")
"   echo @s
"   execute 'normal vi'.@s . '"sy' . 'va'.@s .'"sp'
" 	call setpos('.', pos)
" endfunction

" " nmap ds :call inputsave()<bar>set opfunc=<sid>delete_sheath<cr>g@a
" " nmap ds :set opfunc=<sid>delete_sheath<cr>qsg@a
" " vmap <silent> ds :<c-u>call s:delete_sheath(visualmode())<cr>

" " echo mapcheck("ia", "o")

" " vmap s qs:set opfunc=<sid>sheathe<cr>g@
