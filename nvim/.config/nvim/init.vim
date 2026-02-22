let mapleader=" "
let maplocalleader=" "

" Plugins {{{1
call plug#begin('$VIMDATA/plugged')

" augroup Fugitive
"     autocmd!
"     autocmd BufReadPost fugitive://* set bufhidden=delete
"     autocmd User fugitive
"                 \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
"                 \   nnoremap <buffer> .. :edit %:h<CR> |
"                 \ endif
" augroup END

" Colour scheme
Plug 'morhetz/gruvbox'
let g:gruvbox_italic=1

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'chrisbra/Colorizer'
let g:colorizer_auto_filetype='css,html'
let g:colorizer_swap_fgbg = 1

Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
let g:python_recommend_style = 0
let g:python3_host_prog = '~/.local/share/virtualenvs/neovim/bin/python'

Plug 'tommcdo/vim-lion'
let g:lion_squeeze_spaces = 1

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'bfrg/vim-fzy'

Plug 'Asheq/close-buffers.vim'

Plug 'itchyny/lightline.vim'

" Tags
Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_cache_dir = $VIMDATA.'/gutentags'
let g:gutentags_ctags_extra_args=['--python-kinds=-i']

" TODO Don't overwrite gd and suchlike
Plug 'junegunn/vim-slash'
noremap <silent> <plug>(slash-after) :call UpdateSearchStatus(@/, 0)<cr>
function! UpdateSearchStatus(query, force)
  " Inspired by https://github.com/henrik/vim-indexed-search
  let winview = winsaveview()
  let line = winview["lnum"]
  let col = winview["col"] + 1
  let [total, exact, after] = [0, -1, 0]

  call cursor(1, 1)
  let [matchline, matchcol] = searchpos(a:query, 'Wc')
  while matchline && (total <= 1000 || a:force)
    let total += 1
    if (matchline == line && matchcol == col)
      let exact = total
    elseif matchline < line || (matchline == line && matchcol < col)
      let after = total
    endif
    let [matchline, matchcol] = searchpos(a:query, 'W')
  endwhile
  call winrestview(winview)

  if exact >= 0
    let g:search_status = exact."/".total
  elseif after == 0
    let g:search_status = "<"."1/".total
  elseif after == total
    let g:search_status = ">".total."/".total
  else
    let g:search_status = after.(after+1)"/".total
  endif
endfunction

Plug 'tommcdo/vim-exchange'

Plug 'simnalamburt/vim-mundo'

Plug 'luochen1990/rainbow'

let g:rainbow_conf = {
      \	'separately': {
      \		'qf': {
      \			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/', 'start=/(/ end=/)/ containedin=Message', 'start=/\[/ end=/\]/ containedin=Message', 'start=/{/ end=/}/ containedin=Message']
      \		}
      \ }
      \}

" Async Linter Engine - ALE
Plug 'w0rp/ale'

Plug 'mgedmin/python-imports.vim'

function! MdFormat(buffer) abort
  return {
  \   'command': 'mdformat --number --wrap 80 -'
  \}
endfunction
let g:ale_pattern_options = {
      \ '.*\.md$': {'ale_enabled': 0}
      \}
let g:ale_fixers = {
      \ 'css': ['prettier'],
      \ 'python': ['isort', 'yapf', 'black'],
      \ 'javascript': ['prettier'],
      \ 'typescript': ['prettier'],
      \ 'typescriptreact': ['prettier'],
      \ 'rust': ['rustfmt']
      \}
let g:ale_linters = {
      \ 'python': ['pydocstyle', 'pylint', 'mypy'],
      \ 'rust': ['rust-analyzer'],
      \ 'typescript': ['eslint'],
      \}
" Some linters can only run on saved files - :h ale-support
let g:ale_lint_on_text_changed = 1
let g:ale_fix_on_save = 1
let g:ale_set_loclist = 0
let g:ale_python_autoflake_options='--remove-all-unused-imports'
let g:ale_javascript_prettier_executable='npx prettier'


" Mappings in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

Plug 'vim-python/python-syntax'
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

Plug 'guns/vim-sexp',    {'for': 'clojure'}
Plug 'liquidz/vim-iced', {'for': 'clojure'}
Plug 'liquidz/vim-iced-coc-source', {'for': 'clojure'}
let g:iced_enable_default_key_mappings = v:true
aug VimIcedAutoFormatOnWriting
  au!
  " Format whole buffer on writing files
  au BufWritePre *.clj,*.cljs,*.cljc,*.edn execute ':IcedFormatSyncAll'

  " Format only current form on writing files
  " au BufWritePre *.clj,*.cljs,*.cljc,*.edn execute ':IcedFormatSync'
aug END

Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'mxw/vim-jsx'

Plug 'direnv/direnv.vim'
Plug 'hashivim/vim-terraform'

Plug 'maxbrunsfeld/vim-yankstack'
let g:yankstack_yank_keys = ['c', 'C', 'd', 'D', 'y']

Plug 'justinmk/vim-sneak'
let g:sneak#s_next = 1 " Pressing f, t, x again goes to next match
let g:sneak#use_ic_scs = 1 " Use smartcase
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
map s <Plug>Sneak_s
map S <Plug>Sneak_S
map ; <Plug>Sneak_;
map , <Plug>Sneak_,

Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-speeddating'

" Restore editing sessions
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
let g:prosession_dir = $VIMDATA.'/prosession'
" let g:prosession_tmux_title = 1
" let g:prosession_tmux_title_format = 'vim @@@'

Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_math = 1
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_fenced_languages = ['csharp=cs', 'c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini']
let g:vim_markdown_new_list_item_indent = 0
" Plug 'masukomi/vim-markdown-folding'

Plug 'ZeroKnight/vim-signjump'
let g:signjump = {
      \ 'create_mappings': 0,
      \ 'debug': 0,
      \ 'use_jumplist': 0,
      \ 'wrap': 0
      \}

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'

Plug 'romainl/vim-qf'
let g:qf_auto_open_quickfix = 0

Plug 'romainl/vim-qlist'

Plug 'gh:brendanator/vim-dispatch', { 'do': 'git remote add old gh:tpope/vim-dispatch' }
Plug 'datanoise/vim-dispatch-neovim'  " Fixes bugs from 'radenling/vim-dispatch-neovim'
nnoremap <leader>d :Dispatch<cr>
nnoremap <leader>D :FocusDispatch  <c-h>
let g:dispatch_quickfix_on_error = 1

Plug 'janko-m/vim-test'
let test#strategy = 'dispatch_background'
" let g:test#runner_commands = ['PyTest', 'ZigTest']
let test#python#pytest#options = '--tb=short'
augroup test
  autocmd!
  " autocmd BufWritePost * if test#exists() | TestFile | endif
augroup END
nnoremap <leader>tn :noautocmd write \| TestNearest<cr>
nnoremap <leader>tf :noautocmd write \| PyTest --last-failed<cr>
nnoremap <leader>tt :noautocmd write \| TestFile<cr>
nnoremap <leader>tl :noautocmd write \| TestLast<cr>
nnoremap <leader>ts :noautocmd write \| TestSuite<cr>
nnoremap <leader>tc :Coveragepy refresh<cr>
nnoremap <silent> <leader>gf :cfirst<cr>
nnoremap <silent> <leader>gl :clast<cr>

nnoremap <leader>df :noautocmd write \| PyTest -strategy=vimspector --last-failed<cr>
nnoremap <leader>dn :noautocmd write \| TestNearest -strategy=vimspector<CR>
nnoremap <leader>dl :noautocmd write \| TestLast -strategy=vimspector<cr>
nnoremap <leader>dt :noautocmd write \| TestFile -strategy=vimspector<CR>
nnoremap <leader>ds :noautocmd write \| TestSuite -strategy=vimspector<CR>

nnoremap <leader>gt :e ~/sourcery-ai/notes/todo.md<cr>

" yank relative path to clipboard
nnoremap <leader>yp :let @*=expand("%")<CR> 
" absolute path  (/something/src/foo.txt)
nnoremap <leader>yP :let @*=expand("%:p")<CR>
" filename       (foo.txt)
nnoremap <leader>yf :let @*=expand("%:t")<CR>
" directory name (/something/src)
nnoremap <leader>yd :let @*=expand("%:p:h")<CR>
" relative path and line number
nnoremap <leader>yl :let @*=expand("%").":".line(".")<CR>

nnoremap <leader>wc :!wc %<CR>



Plug 'puremourning/vimspector'
let g:vimspector_enable_mappings = 'HUMAN'
nmap <Leader>di <Plug>VimspectorBalloonEval
xmap <Leader>di <Plug>VimspectorBalloonEval
nmap <Leader><F11> <Plug>VimspectorUpFrame
nmap <Leader><F12> <Plug>VimspectorDownFrame

function VimTestVimspectorStrategy(cmd)
  if !(filereadable(".vimspector.json"))
    echo "No '.vimspector.json' found, starting with vscode-node sample"
    system('cp ~/.vimspector.json.sample ./.vimspector.json')
  endif

  let l:vimspector_config = json_decode(join(readfile('.vimspector.json')))

  " Assign program
  " let l:program = split(a:cmd, ' ')[0]
  " let l:vimspector_config['configurations']['run']['configuration']['program'] =
        \ '${workspaceFolder}/' . l:program

  " Assign program_args
  " Remove the program from the string
  let l:program_args = join(split(a:cmd, " ")[1:], " ")

  " split by spaces unless within quotes.  No good way to do this with vimscript
  " TODO: is this escaping enough?
  let l:split_cmd = 'printf "%s" "' . escape(l:program_args, '"') . '" | xargs -n 1 printf "%s\n"'
  let l:print_output = system(l:split_cmd)
  let l:program_args = split(l:print_output, "\n")

  " Re-quote strings with spaces in them
  call map(l:program_args, { _, arg -> match(arg, ' ') >= 0 ? "'" . arg . "'" : arg })

  let l:vimspector_config['configurations']['run']['configuration']['args'] = l:program_args

  call writefile(split(json_encode(l:vimspector_config), "\n"), glob('.vimspector.json'), 'b')

  " Format file using jq
  let l:jq_cmd = 'jq . ' . glob('.vimspector.json') . ' > ' . glob('.vimspector.json').'.tmp && mv ' . glob('.vimspector.json').'.tmp ' . glob('.vimspector.json')
  echo l:jq_cmd
  call system(l:jq_cmd)

  " Start the debugger
  call vimspector#Continue()
endfunction

let g:test#custom_strategies = {
      \ 'vimspector': function('VimTestVimspectorStrategy'),
      \ }


" Plug 'autozimu/LanguageClient-neovim', {'tag': 'binary-*-x86_64-unknown-linux-musl'}
" let g:LanguageClient_serverCommands = {
"       \ 'javascript': ['javascript-typescript-stdio'],
"       \ 'javascript.jsx': ['javascript-typescript-stdio'],
"       \ }
" " \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
" " \ 'python': ['pyls', '-v'],

" Completions
function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py --clang-completer --gocode-completer
  endif
endfunction
Plug 'tabnine/YouCompleteMe', { 'for': ['c', 'cpp', 'rust', 'tex'], 'do': function('BuildYCM') }
let g:ycm_key_list_select_completion = ['<c-n>']
let g:ycm_key_list_previous_completion = ['<c-p>']
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_python_binary_path = 'python'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions =  [ 'coc-json', 'coc-markdownlint', 'coc-pyright', 'coc-rust-analyzer', 'coc-tabnine', 'coc-yaml' ]

nmap <silent> [g <plug>(coc-diagnostic-prev)
nmap <silent> ]g <plug>(coc-diagnostic-next)
" echo CocAction('runCommand', 'detect_clones', {'all_uris': [{ 'path': '/home/brendanator/sourcery-ai/core/data/other/fruit.py' }]})
" Plug 'zxqfl/tabnine-vim'

Plug 'codota/tabnine-nvim', { 'do': './dl_binaries.sh' }


Plug 'github/copilot.vim'
nnoremap <c-s> :Copilot<cr>
inoremap <c-s> <Plug>(copilot-suggest)
inoremap <c-a> <Plug>(copilot-previous)
inoremap <c-l> <Plug>(copilot-next)

Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'

Plug 'pangloss/vim-javascript'    " JavaScript support
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
Plug 'jparise/vim-graphql'        " GraphQL syntax
Plug 'inkarkat/vim-SyntaxRange'   " Syntax within ranges

Plug 'jiangmiao/auto-pairs' " Autocloses brackets, etc.
let g:AutoPairsShortcutToggle = ''

" Eunuch (unix)
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-scriptease'

Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'

" Git
Plug 'jreybert/vimagit'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'
" Plug 'APZelos/blamer.nvim'
" let g:blamer_enabled = 1
" let g:blamer_date_format = '%Y/%m/%d'
Plug 'junegunn/gv.vim'
let g:gitgutter_map_keys = 0
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 0
let g:gitgutter_use_location_list = 1
nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)
nmap <Leader>hs <Plug>(GitGutterStageHunk)
nmap <Leader>hu <Plug>(GitGutterUndoHunk)
nmap <Leader>hp <Plug>(GitGutterPreviewHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nnoremap <silent> <leader>gb :Git blame<cr>
nnoremap <silent> <leader>gl :GitGutterQuickFix \| call ToggleList("Location List", 'l', 1)<cr>
augroup Fugitive
    autocmd!
    autocmd BufReadPost fugitive://* set bufhidden=delete
augroup END
Plug 'ruanyl/vim-gh-line'
let g:gh_github_domain = "github.com"


if &diff
  set cursorline
  " nmap <c-down> ]c
  " nmap <c-up> [c
  " nmap <c-left> diffput
  " nmap <c-right> diffget
  nmap J ]h
  nmap K [h
  nnoremap L :diffget<cr>
  nnoremap H :diffput<cr>
endif

Plug 'machakann/vim-highlightedyank'

" Vim surround
Plug 'gh:brendanator/vim-surround', { 'do': 'git remote add old gh:tpope/vim-surround' }
nmap x ys
nmap X ys$
xmap x S
" Brackets
let g:surround_{char2nr('b')} = "(\r)"            " Brackets
let g:surround_{char2nr('B')} = "{\r}"            " curly Brackets
let g:surround_{char2nr('c')} = "{\r}"            " Curly
let g:surround_{char2nr('g')} = "<\r>"            " anGled
let g:surround_{char2nr('r')} = "[\r]"            " squaRe
" Quotes
let g:surround_{char2nr('s')} = "'\r'"            " Single
let g:surround_{char2nr('d')} = "\"\r\""          " Double
let g:surround_{char2nr('k')} = "`\r`"            " bacKtick
" Triples don't work
let g:surround_{char2nr('S')} = "\"\"\"\r\"\"\""  " Triple
let g:surround_{char2nr('D')} = "'''r'''"         " Triple
" Markdown
let g:surround_{char2nr('o')} = "$\r$"            " dOllar
let g:surround_{char2nr('O')} = "$$\r$$"          " dOuble dOllar
let g:surround_{char2nr('e')} = "*\r*"            " astErisk
let g:surround_{char2nr('u')} = "_\r_"            " underscore

" Text objects
Plug 'wellle/targets.vim'
" Add consistent mappings for surround brackets and quotes
let g:targets_pairs = '()b {}B []r <>g {}c'
let g:targets_quotes = '"d ''s `k $o *e u_'  """T
" Include all bracket types for arguments
let g:targets_argOpening = '[({[]'
let g:targets_argClosing = '[]})]'
" Prefer multiline targets around cursor over distant targets within cursor line:
" Only seek if next/last targets touch the current line
let g:targets_seekRanges = 'cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al'
" Use better inner args by default
omap ia Ia

Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-lastpat'
Plug 'kana/vim-textobj-line'
Plug 'Julian/vim-textobj-variable-segment'
Plug 'bps/vim-textobj-python'
Plug 'jceb/vim-textobj-uri'
Plug 'reedes/vim-textobj-sentence'
Plug 'saaguero/vim-textobj-pastedtext'
Plug 'tommcdo/vim-ninja-feet'

Plug 'gokcehan/vim-opex'

Plug 'LnL7/vim-nix'

Plug 'powerman/vim-plugin-AnsiEsc'
" Plug 'farseer90718/vim-taskwarrior'

Plug 'majutsushi/tagbar'

" Plug 'reedes/vim-wordy'
Plug 'tpope/vim-abolish'
" Plug 'arthurxavierx/vim-caser'
" let g:caser_prefix = 'cr'

" Plug 'mg979/vim-visual-multi'

Plug 'gh:brendanator/coveragepy.vim', { 'do': 'git remote add old gh:alfredodeza/coveragepy.vim' }
Plug 'vmware/differential-datalog', {'rtp': 'tools/vim'}


Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
Plug 'stevearc/oil.nvim'

Plug 'embear/vim-localvimrc'
let g:localvimrc_persistent = 2
let g:localvimrc_persistence_file = expand('$HOME') . '/.local/share/nvim/localvimrc_persistence'

Plug 'tpope/vim-apathy'
Plug 'jeanCarloMachado/vim-toop'
Plug 'vim-scripts/ReplaceWithRegister'

Plug 'wakatime/vim-wakatime'

" TODO Try out
" Plug 'alok/notational-fzf-vim'

call plug#end()

runtime macros/matchit.vim

execute ale#fix#registry#Add('mdformat', 'MdFormat', ['markdown'], 'mdformat for markdown')

let g:copilot_no_tab_map = v:true
inoremap <silent><expr> <tab>
      \ exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") :
      \ "\<Tab>"
inoremap <silent><expr> <c-f> coc#pum#visible() ? coc#pum#confirm() : "\<C-f>"
inoremap <expr> <c-j> coc#pum#visible() ? coc#pum#next(0) : "\<C-j>"
inoremap <expr> <c-k> coc#pum#visible() ? coc#pum#prev(0) : "\<C-k>"
inoremap <expr> <c-n> coc#pum#visible() ? coc#pum#next(0) : "\<C-n>"
inoremap <expr> <c-p> coc#pum#visible() ? coc#pum#prev(0) : "\<C-p>"

nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gR :call CocAction('jumpReferences', 'quickfix')<CR>

nnoremap <silent> <leader>cl :CocDiagnostics<cr>
nnoremap <silent> <leader>ch :call CocAction('doHover')<cr>
nnoremap <silent> <leader>cf <plug>(coc-codeaction-cursor)
nnoremap <silent> <leader>ca <plug>(coc-fix-current)
nnoremap <silent> <leader>cr :CocRestart<cr>
inoremap <silent><expr> <c-space> coc#refresh()

nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)


call signjump#create_map('[R', 'first', ['ALEError'])
call signjump#create_map('[r', 'next', ['ALEError'])
call signjump#create_map(']r', 'prev', ['ALEError'])
call signjump#create_map(']R', 'last', ['ALEError'])

call toop#mapShell('md-list bullets', '<leader>sl')
call toop#mapShell('md-list numbers', '<leader>sn')
call toop#mapShell('sort', '<leader>ss')
call toop#mapShell('tac', '<leader>st')
call toop#mapShell('jq', '<leader>jq')

nnoremap <expr> g/ GoSearch()
xnoremap <expr> g/ GoSearch()
nnoremap <expr> g// GoSearch() .. '_'
function! GoSearch(type='')
  if a:type == ''
    set opfunc=GoSearch
    return 'g@'
  endif

  let sel_save = &selection
  let reg_save = getreginfo('"')
  let cb_save = &clipboard
  let visual_marks_save = [getpos("'<"), getpos("'>")]

  try
    set clipboard= selection=inclusive
    let commands = #{line: "'[V']y", char: "`[v`]y", block: "`[\<c-v>`]y"}
    silent exe 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
    " echo "normal /".getreg('"')."\<cr>N"
    " execute "normal /".getreg('"')."/\<cr>N"
    call search(getreg('"'))
    normal N
  finally
    " call setpos("'<", visual_marks_save[0])
    " call setpos("'>", visual_marks_save[1])
    let &clipboard = cb_save
    let &selection = sel_save
  endtry
endfunction

nnoremap <leader>ftm :set filetype=markdown<cr>
nnoremap <leader>ftp :set filetype=python<cr>

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [['mode', 'paste'], ['search', 'relativepath', 'fugitive', 'modified']],
      \   'right': [['lineinfo'], ['percent'], ['readonly', 'linter_errors', 'linter_warnings', 'linter_infos']]
      \ },
      \ 'inactive' : {
      \   'left': [['relativepath']],
      \   'right': [['lineinfo'], ['percent']]
      \ },
      \ 'component': {
      \   'search': '%{v:hlsearch && exists("g:search_status") ? g:search_status : ""}'
      \ },
      \ 'component_visible_condition': {
      \   'search': 'v:hlsearch && exists("g:search_status") && g:search_status'
      \ },
      \ 'component_expand': {
      \   'linter_infos': 'LightlineLinterInfos',
      \   'linter_warnings': 'LightlineLinterWarnings',
      \   'linter_errors': 'LightlineLinterErrors',
      \   'linter_ok': 'LightlineLinterOK',
      \   'fugitive': 'LightlineGit',
      \ },
      \ 'component_type': {
      \   'readonly': 'error',
      \   'linter_infos': 'ok',
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \   'linter_ok': 'ok',
      \ },
      \ }

function! LightlineLinterInfos() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  return counts.info == 0 ? '' : printf('%d💡', counts.info)
endfunction


function! LightlineLinterWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  return counts.warning == 0 ? '' : printf('%d⚠️', counts.warning)
endfunction

function! LightlineLinterErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:all_errors == 0 ? '' : printf('%d❌', all_errors)
endfunction

function! LightlineLinterOK() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '✓' : ''
endfunction
augroup Lightline
  autocmd!
  autocmd User ALELintPost call lightline#update()
  " Background colour comes from `hi LightlineLeft_active_1`
  " gruvbox guibg=#504945
  " onedark guibg=#3E4452
  autocmd ColorScheme *
        \ highlight LightlineGitAdd guifg=#b8bb26 guibg=#504945|
        \ highlight LightlineGitChange guifg=#8ec07c guibg=#504945 |
        \ highlight LightlineGitDelete guifg=#fb4934 guibg=#504945
augroup END
function! LightlineGit()
  let [added, modified, removed] = GitGutterGetHunkSummary()
  let added_status = '%#LightlineGitAdd#' . added . g:gitgutter_sign_added . '%#LightlineLeft_active_1#'
  let modified_status = '%#LightlineGitChange#' .modified . g:gitgutter_sign_modified . '%#LightlineLeft_active_1#'
  let removed_status = '%#LightlineGitDelete#' .removed . '-' . '%#LightlineLeft_active_1#'

  let added_status = added . g:gitgutter_sign_added
  let modified_status = modified . g:gitgutter_sign_modified
  let removed_status = removed . '-'

  let git_status = fugitive#head()
  if empty(git_status)
    return ''
  endif

  let git_status = ' ' . git_status

  if added
    let git_status .= ' ' . added_status
  endif
  if modified
    let git_status .= ' ' . modified_status
  endif
  if removed
    let git_status .= ' ' . removed_status
  endif
  return git_status
endfunction

" Profiling
nnoremap <leader>PP :exe ":profile start /tmp/profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
nnoremap <leader>PS :exe ":profile stop"<cr>:e /tmp/profile.log<cr>G
" " nnoremap <silent> <leader>PP :exe ":profile pause"<cr>
" nnoremap <silent> <leader>PC :exe ":profile continue"<cr>
" nnoremap <silent> <leader>PQ :exe ":profile pause"<cr>:noautocmd qall!<cr>

augroup grep
  autocmd!
  if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  endif
  nnoremap <leader>gs :lgrep --sort path . -e  <bs>
  nnoremap <leader>gw :lgrep --sort path . -e  <bs>'\b<c-r><c-w>\b'<cr>
  nnoremap <leader>gw :lgrep --sort path . -e  <bs>'\b<c-r><c-w>\b'<cr>
  nnoremap <leader>ga :lgrep --sort path . -e  <bs>'\b<c-r><c-a>\b'<cr>
  nnoremap <expr> <leader>gg LGrep()
  xnoremap <expr> <leader>gg LGrep()

  function! LGrep(type='') abort
	  if a:type == ''
	    set opfunc=LGrep
	    return 'g@'
	  endif

	  let sel_save = &selection
	  let reg_save = getreginfo('"')
	  let cb_save = &clipboard
	  let visual_marks_save = [getpos("'<"), getpos("'>")]

	  try
	    set clipboard= selection=inclusive
	    let commands = #{line: "'[V']y", char: "`[v`]y", block: "`[\<c-v>`]y"}
	    silent exe 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
      execute "lgrep --sort path . -e '".getreg('"')."'"
	  finally
	    call setreg('"', reg_save)
	    call setpos("'<", visual_marks_save[0])
	    call setpos("'>", visual_marks_save[1])
	    let &clipboard = cb_save
	    let &selection = sel_save
	  endtry
  endfunction
  " nnoremap <leader>bg :Grepper -buffer -tool rg<cr>

  " nmap gs <plug>(GrepperOperator)
  " xmap gs <plug>(GrepperOperator)
  " nnoremap <leader>g :Grepper -tool rg<cr>
  " nnoremap <leader>bg :Grepper -buffer -tool rg<cr>
  command! TODO :lgrep --sort path . -e '(TODO\|FIXME\|XXX)'
augroup END

" Basic settings {{{1

" set number
" augroup LineNumbers
"     autocmd!

"     let excluded_number_filetypes = ['fzf', 'help', 'man', 'qf', '']
"     autocmd Filetype *
"           \ if index(excluded_number_filetypes, expand('<amatch>')) == -1 |
"           \   set number |
"           \ else |
"           \   set nonumber |
"           \ endif

"     autocmd BufEnter,WinEnter,FocusGained * if &nu | set rnu   | endif
"     autocmd BufLeave,WinLeave,FocusLost   * if &nu | set nornu | endif

"     autocmd CmdWinEnter *
"           \ set nonumber norelativenumber |
"           \ nnoremap <silent> <buffer> q <c-w>q
" augroup END

augroup QuickFixNavigation
  autocmd!
  " Navigate to first error
  nmap <silent> <c-q> :cfirst<cr>:cnext<cr>
  nmap <silent> Q     :clast<cr>:cprevious<cr>
  autocmd Filetype qf
        \ set nonumber norelativenumber |
        \ nnoremap <buffer> <c-k> :TmuxNavigatePrevious<cr> |
        \ nnoremap <buffer> <c-h> :TmuxNavigatePrevious<cr>:TmuxNavigateLeft<cr> |
        \ nnoremap <buffer> <c-l> :TmuxNavigatePrevious<cr>:TmuxNavigateRight<cr> |
        \ call ResizeList()
augroup END

let g:max_list_size = 0.33
function! ResizeList()
  if !empty(getloclist(0))
    let list = getloclist(0)
    let opencmd = 'lopen'
  elseif !empty(getqflist())
    let list = getqflist()
    let opencmd = 'copen'
  else
    return
  endif

  " Handle wrapped text
  let list_height = 0
  let type_descriptions = {'E': ' error', 'W': ' warning', 'I': ' info', '': ''}
  for item in list
    if item.lnum
      let bufname = bufname(item.bufnr)
      if item.col
        let loc = item.lnum . ' col ' . item.col
      else
        let loc = item.lnum
      end
    else
      let bufname = ''
      let loc = ''
    endif
    let type = get(type_descriptions, item.type)

    let text = bufname . '|' . loc . type . '| ' . item.text

    let text_len = min([len(text), 1024]) " Text is trimmed at 1024 chars
    let wrapped_lines = text_len / &columns

    let list_height += wrapped_lines + 1
  endfor

  if type(g:max_list_size) == v:t_float
    let max_height = min([float2nr(g:max_list_size * &lines), list_height])
  else
    let max_height = g:max_list_size
  endif
  let newsize = min([max_height, list_height])
  if winheight(winnr()) != newsize
    silent exe 'resize ' . newsize
  endif
endfunction

set noshowmode
set showcmd
set hidden
set history=1000
set cursorline
set fillchars=vert:│,fold:─,diff:─
set pumheight=10

set inccommand=split

set noswapfile
set undofile
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

set gdefault

set wildmenu
set wildmode=longest:full,full

set ignorecase
set smartcase

" Speed up vim
set nocursorline
set nocursorcolumn
set lazyredraw

set scrolloff=5
set sidescrolloff=5
set conceallevel=2
set foldmethod=manual
set foldlevelstart=99
set foldcolumn=0
augroup Folding
  autocmd!
  " autocmd InsertLeave,WinEnter * if exists('b:oldfoldmethod') | let &b:foldmethod = b:oldfoldmethod | endif
  " autocmd InsertEnter,WinLeave * let b:oldfoldmethod = &b:foldmethod | setlocal foldmethod=manual

  " autocmd InsertLeave,WinEnter * setlocal foldmethod=expr
  " autocmd InsertEnter,WinLeave * setlocal foldmethod=manual
augroup END

set autoread
augroup AutoReadWrite
  autocmd!
  autocmd FocusGained,BufEnter * :checktime
  autocmd FileType * :EditorConfigReload
  " Don't run linting/tests when autosaving buffer
  autocmd FocusLost,BufLeave * :silent! noautocmd write
augroup END


" Don't move cursor back a char
inoremap <Esc> <Esc>`^

set splitright splitbelow

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
" nnoremap <c-s-j> i<cr><esc><bs>

for char in split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", '\zs')
  execute "nnoremap '".char." '".char."'\""
  execute "nnoremap `".char." `".char."`\""
endfor

nmap Y y$

nmap <Up> <c-w>2-
nmap <Down> <c-w>2+
nmap <Left> <c-w>2<
nmap <Right> <c-w>2>

set linebreak
set breakindent
set breakindentopt=shift:2
set showbreak=↪\  " Keep comment so space is preserved
set list
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·

set tabstop=2
set shiftwidth=2
" set shiftround  " Round tab to multiple of shiftwidth
set expandtab

set updatetime=250  " Trigger CursorHold quickly for linting
set mouse=a

set termguicolors
set background=dark
colorscheme gruvbox
highlight! link QuickFixLine DiffAdd

nnoremap <leader>sy :syntax sync fromstart<CR>

" Leaders {{{1
nnoremap <silent> <leader>a :A<cr>

nnoremap <silent> <leader>vs :source $MYVIMRC<cr>g;
" nnoremap <silent> <leader>es :edit <C-r>=resolve(expand('%'))<CR><CR>
nnoremap <silent> <leader>fs :write<cr>
nnoremap <silent> <leader>h :Helptags<cr>

function! DeleteBuffer(force)
  set bufhidden=wipe
  try
    execute "normal! \<c-^>"
  catch
    try
      enew
    catch
      bdelete!
    endtry
  endtry
endfunction

function! FzyCommand(list_command, vim_command) abort
    let l:callback = {
                \ 'window_id': win_getid(),
                \ 'filename': tempname()
                \ }
    let l:fzy_command = 'fzy'
    let l:vim_command = a:vim_command

    function! l:callback.on_exit(job_id, data, event) abort
        bdelete!
        call win_gotoid(self.window_id)
        if filereadable(self.filename)
            try
                let l:selected_filename = readfile(self.filename)[0]
                exec "e " . l:selected_filename
            catch /E684/
            endtry
            call delete(self.filename)
        endif
    endfunction

    execute 'botright 10 new'
    let l:term_command = a:list_command . '|' . l:fzy_command . '>' .
                \ l:callback.filename
    let l:term_job_id = termopen(l:term_command, l:callback)
    setlocal nonumber norelativenumber
    startinsert
endfunction

command! GFiles call FzyCommand("git ls-files", ":e")
" nnoremap <leader><leader> :call FzyCommand("git ls-files", ":e")<cr>
" nnoremap <leader>e :call FzyCommand("find . -type f", ":e")<cr>
" nnoremap <leader>v :call FzyCommand("find . -type f", ":vs")<cr>
" nnoremap <leader>s :call FzyCommand("find . -type f", ":sp")<cr>

nnoremap <silent> <leader>bb :Buffers<cr>
nnoremap <silent> <leader>bd :call DeleteBuffer(0)<cr>
nnoremap <silent> <leader>bD :call DeleteBuffer(1)<cr>
nnoremap <silent> <leader>e :GFiles<cr>
nnoremap <silent> <leader><leader> :GFiles<cr>
nnoremap <silent> <bs> :GFiles<cr>
" tnoremap <silent> <leader><leader> <c-\><c-n>:GFiles<cr>
nnoremap <silent> <leader>t :Tags<cr>
if systemlist('which mru')[0] != 'mru not found' && getcwd() != $HOME
  nnoremap <silent> <bs> :GFiles<cr>
  " tnoremap <silent> <leader><leader> <c-\><c-n>:GFiles<cr>
  nnoremap <silent> <leader>t :Tags<cr>
else
  nnoremap <silent> <bs> :GFiles<cr>
  " tnoremap <silent> <leader><leader> <c-\><c-n>:GFiles<cr>
endif
nnoremap <silent> <leader>t :Tags<cr>

nnoremap <leader>u :MundoToggle<cr>


function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx, forceopen)
  let buflist = GetBufferList()

  " Close list if open and return
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      if a:forceopen
        return
      endif
      if winnr() == bufwinnr(bufnum)
        noautocmd wincmd p
      endif
      noautocmd exec a:pfx.'close'

      let curwinnr = winnr()
      for winnr in range(1, winnr('$'))
        if getbufvar(winbufnr(winnr), '&filetype') =~ 'qf'
          noautocmd execute winnr . ' wincmd w'
          call ResizeList()
        elseif bufname(winbufnr(winnr)) =~ '^term://'
          noautocmd execute winnr . ' wincmd w'
          noautocmd wincmd k
          if winnr != winnr()
            noautocmd execute winnr . ' wincmd w'
            noautocmd 10 wincmd _
          endif
        endif
      endfor
      noautocmd execute curwinnr . ' wincmd w'

      return
    endif
  endfor

  let list = a:pfx == 'c' ? getqflist() : getloclist(0)
  let size = len(list)
  if size == 0
    echohl ErrorMsg
    echo a:bufname.' is Empty.'
    return
  endif
  let winnr = winnr()
  execute ('botright '.a:pfx.'open') (size > 10 ? 10 : size)
  if winnr() != winnr
    noautocmd wincmd p
  endif
endfunction

nmap <silent> <leader>l :call ToggleList("Location List", 'l', 0)<CR>
nmap <silent> <leader>q :call ToggleList("Quickfix List", 'c', 0)<CR>
nmap <silent> <leader>p :pclose<CR>

" Command search {{{1
cnoremap <c-j> <down>
cnoremap <c-k> <up>

" Window navigation {{{1
nnoremap <silent> <leader><tab> <c-^>
nnoremap <silent> <leader>1 1<c-w><c-w>
nnoremap <silent> <leader>2 2<c-w><c-w>
nnoremap <silent> <leader>3 3<c-w><c-w>
nnoremap <silent> <leader>4 4<c-w><c-w>
nnoremap <silent> <leader>5 5<c-w><c-w>
nnoremap <silent> <leader>6 6<c-w><c-w>
nnoremap <silent> <leader>7 7<c-w><c-w>
nnoremap <silent> <leader>8 8<c-w><c-w>
nnoremap <silent> <leader>9 9<c-w><c-w>

augroup Terminal " {{{1
  autocmd!
  autocmd TermOpen * set nonumber norelativenumber
  autocmd BufEnter,BufWinEnter,WinEnter term://* :startinsert
  autocmd BufLeave,BufWinLeave term://* :stopinsert
  autocmd BufEnter,BufWinEnter term://* :highlight! link TermCursorNC PMenuThumb
  autocmd BufLeave,BufWinLeave term://* :highlight! link TermCursorNC None
  if has('nvim') && executable('nvr')
    let $VISUAL="env DUMMY=vim nvr -cc split --remote-wait"
  endif
  tnoremap <silent> jj <C-\><C-n>
  " nnoremap <silent> <c-p> :TmuxNavigatePrevious<cr>
  " tnoremap <silent> <c-p> <c-\><c-n>:TmuxNavigatePrevious<cr>
  tnoremap <silent> <c-h> <c-\><c-n>:TmuxNavigateLeft<cr>
  tnoremap <silent> <c-l> <c-\><c-n>:TmuxNavigateRight<cr>
  " tnoremap <silent> <leader><tab> <C-\><C-n><c-^>
  " tnoremap <silent> <leader>1 <C-\><C-n>1<c-w>w
  " tnoremap <silent> <leader>2 <C-\><C-n>2<c-w>w
  " tnoremap <silent> <leader>3 <C-\><C-n>3<c-w>w
  " tnoremap <silent> <leader>4 <C-\><C-n>4<c-w>w
  " tnoremap <silent> <leader>5 <C-\><C-n>5<c-w>w
  " tnoremap <silent> <leader>6 <C-\><C-n>6<c-w>w
  " tnoremap <silent> <leader>7 <C-\><C-n>7<c-w>w
  " tnoremap <silent> <leader>8 <C-\><C-n>8<c-w>w
  " tnoremap <silent> <leader>9 <C-\><C-n>9<c-w>w
augroup END

augroup Help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | call SetupHelp() | endif
  autocmd BufEnter __doc__ nnoremap <silent> <buffer> q :set bufhidden=wipe \| call CloseWindow()<cr>
  autocmd Filetype man call SetupHelp()
  function! SetupHelp()
    nnoremap <silent> <buffer> q :call CloseWindow()<cr>
  endfunction

  function! CloseWindow()
    let winnr = winnr()
    wincmd p
    exe winnr . ' wincmd q'
  endfunction
augroup END


" Handle ex output {{{1
function! RedirMessages(msgcmd, destcmd)
  " https://stackoverflow.com/a/2573758
  " Redirect messages to a variable.
  redir => message
  silent execute a:msgcmd
  redir END

  if strlen(a:destcmd) " destcmd is not an empty string
    silent execute a:destcmd
  endif

  " Place the messages in the destination buffer.
  silent put=message
  if a:destcmd
    nnoremap <silent> <buffer> q :set bufhidden=wipe \| call CloseWindow()<cr>
  endif
endfunction

command! -nargs=+ -complete=command BufMessage call RedirMessages(<q-args>, ''       )
command! -nargs=+ -complete=command WinMessage call RedirMessages(<q-args>, 'new'    )
command! -nargs=+ -complete=command TabMessage call RedirMessages(<q-args>, 'tabnew' )

augroup vimtmuxclipboard
  autocmd!
  autocmd FocusLost     *  silent! call system('tmux loadb -',@")
  autocmd FocusGained   *  let @" = system('tmux show-buffer')
augroup END

augroup highlight_follows_focus
  autocmd!
  autocmd WinEnter * set cursorline
  autocmd WinLeave * set nocursorline
augroup END

augroup BlockDotfiles
  autocmd!
  autocmd BufEnter,BufWinEnter *
        \   if strftime('%u') < 0 |
        \     let bufname = fnamemodify(expand('<amatch>'), ':~')[2:-1] |
        \     let config_files = split(system('git -C ~/.git ls-files')) |
        \     if index(config_files, bufname) >= 0 || fnamemodify(bufname, ":e") ==# 'vim' || &filetype ==# 'help' |
        \       set bufhidden=wipe |
        \       enew |
        \       echo 'A student enquired of Master Wq, “When will I know I have mastered Vimscript?”' |
        \	      echo 'Master Wq answered, “When you never use it.”' |
        \     endif |
        \   endif
augroup END

lua << EOF
  -- disable netrw at the very start of your init.lua
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- set termguicolors to enable highlight groups
  vim.opt.termguicolors = true

  -- empty setup using defaults
  vim.keymap.set("n", "gt", "<CMD>NvimTreeToggle<CR>", { desc = "Open nvim-tree directory explorer" })

  -- OR setup with some options
  require("nvim-tree").setup({
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
    update_focused_file = {
      enable = true,
    },
  })

  require("oil").setup()
  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
EOF
