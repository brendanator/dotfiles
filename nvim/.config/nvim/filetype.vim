augroup filetypedetect
  au!

  au BufNewFile,BufRead *.ini         setfiletype toml
  au BufNewFile,BufRead *.pyi         setfiletype python
  au BufNewFile,BufRead .coveragerc   setfiletype toml
  au BufNewFile,BufRead .editorconfig setfiletype toml
  au BufNewFile,BufRead Pipfile       setfiletype toml
  au BufNewFile,BufRead Pipfile.lock  setfiletype json
  au BufNewFile,BufRead pylintrc      setfiletype toml
  au BufNewFile,BufRead setup.cfg     setfiletype toml
  au BufNewFile,BufRead setup.cfg     setfiletype toml
  au BufNewFile,BufRead .env.*        setfiletype sh
  au BufNewFile,BufRead *.dl          setfiletype dl

  au BufNewFile,BufRead $XDG_CONFIG_HOME/git/config-*	setf gitconfig

augroup END
