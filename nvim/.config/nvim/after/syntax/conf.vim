" Disable current syntax temporarily
let s:saved_syntax = b:current_syntax
unlet! b:current_syntax

" Load SQL syntax
syntax include @MARKDOWN syntax/markdown.vim

"	Set markdown syntax in .git/PULLREQ_EDITMSG after initial comments
syntax region MarkdownEmbedded start=+of text is the title and the rest is the description\zs+ skip=+\_.+ end="$" contains=@MARKDOWN containedin=confComment

" Restore original syntax.
let b:current_syntax = s:saved_syntax
unlet! s:saved_syntax

