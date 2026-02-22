function! s:set_path()
  let virtual_env = $VIRTUAL_ENV
  if virtual_env != ''
    let venv_lib_python = globpath(virtual_env.'/lib', 'python*')
    let venv_site_packages = globpath(venv_lib_python.'/site-packages', '*', 0, 1)
    let &g:path='.,' . venv_lib_python . ',' . venv_lib_python.'/site-package' . ',,'
  endif
endfunction

setlocal wildignore=*.pyc,*.dist-info,__pycache__,_pytest,.tox
" nnoremap <buffer> <silent> K :YcmCompleter GetDoc<cr>

function! PylintDisable()
    let [l:info, l:loc] = ale#util#FindItemAtCursor(bufnr())
    let l:pylint_code = l:loc['code']
    let l:disable = '  # noqa: '.l:pylint_code
    exec 'normal A'.l:disable
endfunction
nnoremap <leader>dp :call PylintDisable()<cr>

let b:pythonImports = expand('~/.config/nvim/python-imports.cfg')
"call LoadPythonImports(b:pythonImports)


function! PylintRemoveUnusedImport()
    let l:loclist = ale#util#FindItemAtCursor(bufnr(''))[0]['loclist']
    for error in reverse(l:loclist)
      if error['bufnr'] == bufnr() && error['linter_name'] == 'pylint' && error['code'] == 'unused-import'
        let words = split(error['text'])
        if len(words) == 5
          let unusedImport = words[1]
        else
          let unusedImport = words[2]
        endif
        let lnum = error['lnum']
        for line in getline(lnum, '$')
          if stridx(line, unusedImport) >= 0
            if line =~ "^ *".unusedImport."," || line =~ "import *".unusedImport."$"
              execute lnum.'delete _'
            else
              let line = substitute(line, ", ".unusedImport, '', '')
              let line = substitute(line, unusedImport.", ", '', '')
              let line = substitute(line, 'import '.unusedImport, 'import ', '')
              call setline(lnum, line)
            endif
            break
          endif
          let lnum = lnum + 1
        endfor
      endif
    endfor
endfunction

nnoremap <leader>in :ImportName!<cr>
execute 'nnoremap <silent> <leader>ie :e '.b:pythonImports.'<cr>'
nnoremap <silent> <leader>ir :call LoadPythonImports(b:pythonImports)<cr>
nnoremap <silent> <leader>id :call PylintRemoveUnusedImport()<cr>

nnoremap <leader>ti miA  # type: ignore<esc>`i

nnoremap <leader>tm :Dispatch mypy<cr>
nnoremap <leader>tp :Dispatch pylint<cr>
nnoremap <leader>tv :Dispatch vulture<cr>
