" setlocal foldmethod=expr
setlocal foldmethod=manual
" setlocal foldexpr=VimwikiFoldLevel(v:lnum)
setlocal viewoptions+=folds

function! ViewportFoldText()
  let line = getline(v:foldstart)
  let main_text = substitute(line, '^\s*', repeat(' ',indent(v:foldstart)), '')
  let fold_len = v:foldend - v:foldstart + 1
  if line !~# vimwiki#vars#get_syntaxlocal('rxPreStart')
    let [main_text, spare_len] = s:shorten_text(main_text, 50)
    let main_text = substitute(main_text, ' *|[^=]*', '', '')
    let num_tasks = 0
    for linenum in range(v:foldstart+1, v:foldend)
      if getline(linenum) =~ '^ *\* \[ ]'
        let num_tasks += 1
      endif
    endfor
    if num_tasks > 0
      let num_tasks_text = ' - '.num_tasks
    else
      let num_tasks_text = ''
    endif
    return main_text.num_tasks_text.repeat(' ', 500)
  else
    " fold-text for code blocks: use one or two of the starting lines
    let [main_text, spare_len] = s:shorten_text(main_text, 24)
    let line1 = substitute(getline(v:foldstart+1), '^\s*', ' ', '')
    let [content_text, spare_len] = s:shorten_text(line1, spare_len+20)
    if spare_len > s:tolerance && fold_len > 3
      let line2 = substitute(getline(v:foldstart+2), '^\s*', s:newline, '')
      let [more_text, spare_len] = s:shorten_text(line2, spare_len+12)
      let content_text .= more_text
    endif
    let len_text = ' ['.fold_len.'] '
    return main_text.len_text.content_text
  endif
endfunction

setlocal foldtext=ViewportFoldText()


runtime! syntax/markdown.vim

syntax include @markdown syntax/markdown.vim
syntax match TaskWikiTask /^\s*\* \[.\]\s.*$/

let s:conceal = exists("+conceallevel") ? ' conceal': ''

" Conceal the UUID
execute 'syn match TaskWikiTaskUuid containedin=TaskWikiTask /\v#([A-Z]:)?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/'.s:conceal
execute 'syn match TaskWikiTaskUuid containedin=TaskWikiTask /\v#([A-Z]:)?[0-9a-fA-F]{8}$/'.s:conceal
highlight link TaskWikiTaskUuid Comment

" Conceal header definitions
for s:i in range(1,6)
  execute 'syn match TaskWikiHeaderDef containedin=htmlH'.s:i.' contained /|[^=]*/'.s:conceal
endfor

" Define active and deleted task regions
" Will be colored dynamically by Meta().source_tw_colors()
syntax match TaskWikiTaskActive containedin=TaskWikiTask contained /^\s*\*\s\[S\]\s[^#]*/
syntax match TaskWikiTaskCompleted containedin=TaskWikiTask contained /^\s*\*\s\[X\]\s[^#]*/
syntax match TaskWikiTaskDeleted containedin=TaskWikiTask contained /^\s*\*\s*\[D\]\s[^#]*/
syntax match TaskWikiTaskRecurring containedin=TaskWikiTask contained /^\s*\*\s\[R\]\s[^#]*/
syntax match TaskWikiTaskWaiting containedin=TaskWikiTask contained /^\s*\*\s\[W\]\s[^#]*/
syntax match TaskWikiTaskPriority containedin=TaskWikiTask contained /\( !\| !!\| !!!\)\( \)\@=/
syntax match VimwikiListTodo containedin=TaskWikiTask contained /^\s*\*\s\[ \]\s*[^#]*/ contains=TaskWikiTaskMarkdown
syntax match TaskWikiTaskWaiting containedin=TaskWikiTask contained /^\s*\*\s\[W\]\s[^#]*/

syntax match TaskWikiTaskMarkdown containedin=TaskWikiTask contains=@markdown /\(\s*\*\s\[.\]\s\)\@<=[^#]*/
hi def link VimwikiListTodo Identifier
