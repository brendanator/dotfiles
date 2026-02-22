if exists("current_compiler")
  finish
endif
let current_compiler = "python"

if exists(":CompilerSet") != 2 " older Vim always used :setlocal
  command! -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C


CompilerSet makeprg=pytest
CompilerSet makeprg=python
CompilerSet makeprg=pipenv

" Continuation lines
CompilerSet efm  =%C\ \ \ \ %p^,                   "        ^
CompilerSet efm +=%CE\ \ \ \ \ %p^,                " E        ^
CompilerSet efm +=%CINTERNALERROR>\ \ \ \ \ %m,    " INTERNALERROR>
CompilerSet efm +=%-G\ \ \ \ !!!\ error\ pretty\ printing\ value:%.%#,                             " <blank>
CompilerSet efm +=%+G\ \ \ \ %.%#:%.%#,                    "     raise ValueError(err.message)
CompilerSet efm +=%C\ \ \ \ %m,                    "     raise ValueError(err.message)
CompilerSet efm +=%CE\ \ \ \ \ \ \ %m,             " E      raise ValueError(err.message)
CompilerSet efm +=%+GINFO\ %.%#,
CompilerSet efm +=%+GWARNING\ %.%#,
CompilerSet efm +=%+GDEBUG\ %.%#,

if get(g:, 'python_short_trace', 1)
  " Ignore stack trace from libraries
  " CompilerSet efm +=%-G%.%#/%\\%.local/share/%.%#, " ../.local/share/file.py:23 in bla
endif
" CompilerSet efm +=%-G\ \ \ \ %.%#,                 "     raise ValueError(err.message)
" CompilerSet efm +=%-GE\ \ \ \ \ \ \ %[A-Za-z]%.%#, " E      raise ValueError(err.message)
CompilerSet efm +=%+G,                             " <blank>
" CompilerSet efm +=%-GE\ %#,                        " E
" CompilerSet efm +=%-GE\ %#+\ %#where%.%#,          " E    +  where ...
" CompilerSet efm +=%-GE\ %#+\ %#and%.%#,            " E    +  and ...

" Extract useful information
CompilerSet efm +=%Efile\ %f\\,\ line\ %l,         " file module/code.py, line 41
CompilerSet efm +=%IE\ \ \ Failed:\ %f:%l:\ %m,
CompilerSet efm +=%EINTERNALERROR>\ \ \ File\ \"%f\"\\,\ line\ %l\\,\ in\ %.%#,
CompilerSet efm +=%I%f:%l:\ in\ %.%#,              " test/test_code.py:36: in test_some_code
CompilerSet efm +=%I\ \ File\ \"%f\"\\,\ line\ %l\\,\ in\ %.%#,
CompilerSet efm +=%I\ \ File\ \"%f\"\\,\ line\ %l,
CompilerSet efm +=%IE\ \ \ \ \ File\ \"%f\"\\,\ line\ %l\\,\ in\ %.%#,
CompilerSet efm +=%IE\ \ \ \ \ File\ \"%f\"\\,\ line\ %l,
CompilerSet efm +=%N%f:%l\ %m,                     " debug()

" Ignore Pytest excess
CompilerSet efm +=%-G%[%.EFxs]%\\+,                " E...F...FF..
CompilerSet efm +=%-G%.\+[100%%],                  " F..FF.                           [100%]
CompilerSet efm +=%-G=%#\ ERRORS\ =%#,             " === ERRORS ===
CompilerSet efm +=%-G=%#\ FAILURES\ =%#,           " === FAILURES ===
CompilerSet efm +=%-Ggw0\ %.%#,                    " gw0 [45]
CompilerSet efm +=%-Gscheduling\ tests\ via\ %.%#,
CompilerSet efm +=%-G=%#\ test\ session\ starts\ =%#,
CompilerSet efm +=%-GLoading\ .env\ environment\ variables%.%#,
CompilerSet efm +=%-GUsing\ --randomly-seed=%.%#,
CompilerSet efm +=%-Gasyncio:\ mode=auto, 
CompilerSet efm +=%-Gcollecting\ ...\ collected\ %.%#\ item%.,
CompilerSet efm +=%-Ghypothesis\ profile\ %.%#,
CompilerSet efm +=%-Gcachedir:\ .pytest_cache, 
CompilerSet efm +=%-Gplatform\ linux%.%#,
CompilerSet efm +=%-Gplatform\ darwin%.%#,
CompilerSet efm +=%-Gtimeout\ %.%#,
CompilerSet efm +=%-Gconfigfile:\ %.%#,
CompilerSet efm +=%-Grootdir:\ %.%#,
CompilerSet efm +=%-Gplugins:\ %.%#,
CompilerSet efm +=%-Gcollected\ %.%#,
CompilerSet efm +=%-Gtest/%f,
CompilerSet efm +=%-G%.%#Traceback%.%#,            " Traceback (most recent call last):
CompilerSet efm +=%-G!%\\+\ Interrupted%.%#,       " !!!! Interruped !!!!
CompilerSet efm +=%-G%\\s%\\*%\\d%\\+\ tests\ deselected%.%#,
CompilerSet efm +=%-G%.%#\ passed\ in\ %.%#,          " 1 failed, 3 passed in 3.14 seconds
" CompilerSet efm +=%-G%.%#\ failed\ in\ %.%#,          " 1 failed, 3 passed in 3.14 seconds

" Ignore tensorflow guff
CompilerSet efm +=%-GE%.%#[[Node:\ %.%#,           " E    [[Node:
CompilerSet efm +=%-G%.%#/replica:0/%.%#,          " .../replica:0/...

let &cpo = s:cpo_save
unlet s:cpo_save
