" Disable current syntax temporarily
let s:saved_syntax = b:current_syntax
unlet! b:current_syntax

" " Load message syntax
" let g:qf_message_syntax='python'
" if exists('g:qf_message_syntax') && 0
"   execute 'syntax include @MessageSyntax syntax/'.g:qf_message_syntax.'.vim'

"   " Everything up to the second | separator is already matched so match
"   " everything after that
"   syntax region Message start=" \zs" end="$" contains=@MessageSyntax

"   " Redeclare these so they are higher priority than rainbow parens
"   syntax region  pythonString matchgroup=pythonQuotes
"         \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
"         \ contains=pythonEscape,@Spell
"   syntax region  pythonString matchgroup=pythonTripleQuotes
"         \ start=+[uU]\=\z('''\|"""\)+ skip=+\\["']+ end="\z1" keepend
"         \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
"   syntax region  pythonRawString matchgroup=pythonQuotes
"         \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
"         \ contains=@Spell
"   syntax region  pythonRawString matchgroup=pythonTripleQuotes
"         \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
"         \ contains=pythonSpaceError,pythonDoctest,@Spell
"   syntax match pythonBuiltin	"\.\.\."

" endif

" Match strings in qf so rainbow parens work
syntax region  string matchgroup=Quotes
    \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
    \ contains=Escape
syntax region  string matchgroup=TripleQuotes
    \ start=+[uU]\=\z('''\|"""\)+ skip=+\\["']+ end="\z1" keepend
    \ contains=Escape
syntax region  rawString matchgroup=Quotes
    \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
syntax region  rawString matchgroup=TripleQuotes
    \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
syntax match Builtin	"\.\.\."
syn match   Escape	+\\[abfnrtv'"\\]+ contained
syn match   Escape	"\\\o\{1,3}" contained
syn match   Escape	"\\x\x\{2}" contained
syn match   Escape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   Escape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   Escape	"\\$"

let b:current_syntax = s:saved_syntax
unlet! s:saved_syntax
