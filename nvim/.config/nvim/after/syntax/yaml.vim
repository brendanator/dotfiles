" Disable current syntax temporarily
" let s:saved_syntax = b:current_syntax
" unlet! b:current_syntax

" syntax
" syntax/yaml.vim

" hi link yamlBlockMappingKey Special
" hi link yamlFlowMappingKey  Special

" if !exists('b:loaded_python_yaml_syntax_includes')
"   let b:loaded_python_yaml_syntax_includes = 1

"   call SyntaxRange#Include("\v^\z( *)(- )?(pattern|condition|replacement|match|no-match|expect): \|?", "\v^\ze(\z1[^ ]|[a-z\-])", "python", "Special")

"   call SyntaxRange#Include("\v^\z( *)(- )?(description|explanation): \|?", "\v^\ze(\z1[^ ]|[a-z\-])", "markdown", "Special")

" endif


" Restore original syntax.
" let b:current_syntax = s:saved_syntax
" unlet! s:saved_syntax
