if exists("current_compiler")
  finish
endif
let current_compiler = "mypy"

if exists(":CompilerSet") != 2 " older Vim always used :setlocal
  command! -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C


CompilerSet makeprg=mypy

CompilerSet efm  =%E%f:%l:\ error:\ %m
CompilerSet efm +=%I%f:%l:\ note:\ %m
CompilerSet efm +=%I%f:%l:\ info:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
