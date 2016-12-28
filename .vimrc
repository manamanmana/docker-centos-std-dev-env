set autoindent
set nosmartindent
set expandtab
set tabstop=2
set shiftwidth=4
set encoding=utf-8
set fileformats=unix,dos,mac
syntax enable

augroup vimrc
autocmd! FileType perl setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd! FileType python setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd! FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd! FileType sh setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd! FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd! FileType css  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd! FileType go setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd! FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
augroup END


"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=/home/gaku/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('/home/gaku/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'Shougo/unite.vim'
" Static Analyze
" For ruby: 
"   gem install rubocop refe2
"   gem list | grep -e rubocop -e refe2
" For NodeJS:
"   npm install -g eslint
NeoBundle 'scrooloose/syntastic'

" Golang Settings
NeoBundle 'fatih/vim-go'

" Ruby related Settings
" Document Refering
NeoBundle 'thinca/vim-ref'
NeoBundle 'yuku-t/vim-ref-ri'
" Jump to Definitions
" sudo yum install ctags -y
NeoBundle 'szw/vim-tags'
" Auto Closing
NeoBundle 'tpope/vim-endwise'

" NodeJS Settings
" JSDoc Comment
NeoBundleLazy 'heavenshell/vim-jsdoc' , {'autoload': {'filetypes': ['javascript']}}
" require() module jump with gf
NeoBundle 'moll/vim-node'
" Indent and Syntax color
NeoBundle 'pangloss/vim-javascript'
" Auto close
NeoBundle 'Townk/vim-autoclose'

" Python Settings
NeoBundleLazy "davidhalter/jedi-vim", {
    \ "autoload": { "filetypes": [ "python", "python3", "djangohtml"] }} 


" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------

" unite settings
nnoremap [unite]    <Nop>
nmap     <Space>u [unite]
"let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
nnoremap <silent> [unite]y :<C-u>Unite history/yank<CR>
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]u :<C-u>Unite file_mru buffer<CR>

" --------------------------------
"  " syntastic
"  " --------------------------------
let g:syntastic_check_on_open=0 "ファイルを開いたときはチェックしない
let g:syntastic_check_on_save=1 "保存時にはチェック
let g:syntastic_check_on_wq = 0 " wqではチェックしない
let g:syntastic_auto_loc_list=1 "エラーがあったら自動でロケーションリストを開く
let g:syntastic_loc_list_height=6 "エラー表示ウィンドウの高さ
set statusline+=%#warningmsg# "エラーメッセージの書式
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_javascript_checkers = ['eslint'] "ESLintを使う
let g:syntastic_ruby_checkers = ['rubocop'] " rubocop
let g:syntastic_mode_map = {
      \ 'mode': 'active',
      \ 'active_filetypes': ['javascript', 'ruby'],
      \ 'passive_filetypes': []
      \ }

" --------------------------------
"  " Jedi for Python
"  " --------------------------------
if ! empty(neobundle#get("jedi-vim"))
  let g:jedi#auto_initialization = 1
  let g:jedi#auto_vim_configuration = 1

  nnoremap [jedi] <Nop>
  xnoremap [jedi] <Nop>
  nmap <Leader>j [jedi]
  xmap <Leader>j [jedi]

  let g:jedi#completions_command = "<C-space>"    " 補完キーの設定この場合はCtrl + Space
  let g:jedi#goto_assignments_command = "<C-g>"   " 変数の宣言場所へジャンプ（Ctrl + g)
  let g:jedi#goto_definitions_command = "<C-d>"   " クラス、関数定義にジャンプ（Gtrl + d）
  let g:jedi#documentation_command = "<C-k>"      " Pydocを表示（Ctrl + k）
  let g:jedi#rename_command = "[jedi]r"
  let g:jedi#usages_command = "[jedi]n"
  let g:jedi#popup_select_first = 0
  let g:jedi#popup_on_dot = 0

  autocmd FileType python setlocal completeopt-=preview

  " for w/ neocomplete
    if ! empty(neobundle#get("neocomplete.vim"))
        autocmd FileType python setlocal omnifunc=jedi#completions
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0
        let g:neocomplete#force_omni_input_patterns.python =
                        \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
    endif
endif

