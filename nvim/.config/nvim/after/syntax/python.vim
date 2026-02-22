" Disable current syntax temporarily
" let s:saved_syntax = b:current_syntax
" unlet! b:current_syntax

" Update syntax/python.vim
syn keyword pythonStatement     match case
syntax match pythonBuiltin	"\.\.\."  " Ellipsis
syntax match pythonBuiltinType '\v\.@<!<%(complex)>'
syntax match Type '\${[^}]*}'

" Load SQL syntax
syntax include @SQL syntax/sql.vim
syntax region SQLEmbedded start=+\C\z(['"]\)\zs\_\s*\v(ALTER|CALL|COMMENT|COMMIT|CONNECT|CREATE|DELETE|DROP|EXPLAIN|EXPORT|GRANT|IMPORT|INSERT|LOAD|LOCK|MERGE|REFRESH|RENAME|REPLACE|REVOKE|ROLLBACK|SELECT|SET|TRUNCATE|UNLOAD|UNSET|UPDATE|UPSERT)+ skip=+\\\z1+ end=+\ze\z1+ contains=@SQL containedin=pythonString,pythonFString

if !exists('b:loaded_yaml_syntax_includes')
  let b:loaded_yaml_syntax_includes = 1
  call SyntaxRange#Include("```yaml", "```", 'yaml', 'Comment')
  call SyntaxRange#Include("`#!yaml", "`", 'yaml', 'Ignore')
endif

if !exists('b:loaded_python_syntax_includes')
  let b:loaded_python_syntax_includes = 1
  call SyntaxRange#Include("```python", "```", 'python', 'Comment')
  call SyntaxRange#Include("`#!py", "`", 'python', 'Ignore')
endif


" Restore original syntax.
" let b:current_syntax = s:saved_syntax
" unlet! s:saved_syntax
