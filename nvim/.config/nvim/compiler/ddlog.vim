if exists("current_compiler")
  finish
endif
let current_compiler = "ddlog"

if exists(":CompilerSet") != 2 " older Vim always used :setlocal
  command! -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C


CompilerSet makeprg=ddlog
CompilerSet efm  =%Eerror:\ %f:%l.%c-%e.%k:\ %m
CompilerSet efm +=%Eerror:\ %m:\ \"%f\"%.%#line\ %l%.%#column\ %c%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

