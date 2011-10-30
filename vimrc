" Vim configuration

" ------------------------------------------------------------------------
" Initial config, library and plugin loading {{{

" This needs to be first, because it changes Vim's behavior in many places.
" Turn off vi compatibility. If I wanted vi, I would use vi.
set nocompatible

" Define my leader key (my personal namespace in the keymap).
let mapleader=","

" Load Pathogen (sanely manages and compartmentalizes plugins, etc.)
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Use filetype detection, including syntax-aware indenting
filetype plugin indent on

" Load matchit library. This lets % match if/elsif/else/end, open/close
" XML tags, stuff like that, instead of just brackets and parens.
runtime macros/matchit.vim

" }}}
" --------------------------------------------------------------------
" Tab settings {{{

" My general indent strategy is to use real h-tabs (0x09) on the left column
" and spaces everywhere else. That way relative indentation is always the
" same regardless of someone's tab stop, but formatting of right-hand
" indentation is consistent even when tab stop is not.
"
" I use Smart-Tabs (plugin/ctab.vim) to make Tab do that automatically.
" https://github.com/vim-scripts/Smart-Tabs

" Use tabs, not spaces
set noexpandtab

" My tab width is 4. Because 8 is too much, but 2 is visually too small
" for code nesting IMO. Should match shiftwidth. Sometimes I do use an
" indent of 2, e.g. in YAML files, due to convention.
set tabstop=4
set softtabstop=0

" Number of columns to use for (auto)indent. Generally this should be the
" same as the tabstop.
set shiftwidth=4

" Set the indent width to 2, 4, or 8
nnoremap <Leader>2 :setlocal tabstop=2 shiftwidth=2<CR>
nnoremap <Leader>4 :setlocal tabstop=4 shiftwidth=4<CR>
nnoremap <Leader>8 :setlocal tabstop=8 shiftwidth=8<CR>

" Re-tab the current file (changes tab->space or space->tab depending on the
" current setting of expandtab). This can be dangerous, because on occasion
" a raw tab will be embedded in a non-whitespace area like a string. One
" hopes not, since we have things like \t, but you never know.
"nnoremap <silent> <Leader>T :if &expandtab <Bar>
	"\    set noexpandtab<CR>
	"\    retab!<CR>
	"\    echo "Converted spaces to tabs." <Bar>
	"\else <Bar>
	"\    set expandtab<CR>
	"\    retab!<CR>
	"\    echo "Converted tabs to spaces." <Bar>
	"\endif<CR>

" This is slightly hacky, but it's easy and it works. Tab uses normal
" tab behavior. Leader-Tab will always insert space-expanded tabs, but
" honors the current tab stop.
" This is not needed with Smart-Tab in place.
"inoremap <Leader><Tab> <Esc>:set expandtab<CR>a<Tab><Esc>:set noexpandtab<CR>a

" }}}
" --------------------------------------------------------------------
" Indenting {{{

" autoindent, smartindent turned off in favor of
" 'filetype indent on' (see above).
"
" So sayeth vimgor on #vim:
"     Don't you mean stupidindent? In all seriousness, 'smartindent' is an
" obsolete option for C-like syntax. It has been replaced with 'cindent', and
" setting 'cindent' also overrides 'smartindent'. Vim has indentation support
" for many languages out-of-the-box, and setting 'smartindent' (or 'cindent',
" for that matter) in your .vimrc might interfere with this. Use 'filetype
" indent on' and be happy.

"  Good for coding. Handles indenting of blocks automatically.
"set autoindent

" Copies the indentation characters of the previous line.
"set copyindent

" Preserve the existing indent as much as possible, when shifting indentation
"set preserveindent

" An indent is automatically inserted:
" - After a line ending in '{'.
" - After a line starting with a keyword from 'cinwords'.
" - Before a line starting with '}' (only with the "O" command).
" When typing '}' as the first character in a new line, that line is
" given the same indent as the matching '{'.
" When typing '#' as the first character in a new line, the indent for
" that line is removed, the '#' is put in the first column.  The indent
" is restored for the next line.  If you don't want this, use this
" mapping: ":inoremap # X^H#", where ^H is entered with CTRL-V CTRL-H.
" When using the ">>" command, lines starting with '#' are not shifted
" right.
"set smartindent

" This prevents smartindent from pushing # to the start of a line, I want
" it at the same indent I'm currently at, usually.
inoremap # X#

" When changing indent with < and >, use a multiple of shiftwidth.
set shiftround

" Keep selection when indent/dedenting in select mode
vnoremap > >gv
vnoremap < <gv

" }}}
" --------------------------------------------------------------------
" Wrapping {{{

" I use Vim mostly to write code. This doesn't auto-wrap lines, it only does
" a soft wrap to the window width.
set wrap

" No fixed width; 0 means to use the current window width, max out at 79.
set textwidth=0

" Break lines at whitespace or special characters (when tw != 0). Avoids lines
" where a word shows up on both the right and left edges of the screen. Which
" makes copy/paste into other apps FUN. Screws up coding. Off normally.
set nolinebreak

" Backspace over indentation, end-of-line, and start-of-line.
set backspace=indent,eol,start

" Define wrapping behavior.
"set whichwrap=<,>,h,l
"set whichwrap=b,s,<,>

" Set up soft-wrapping (not for coding, this will break lines based on words,
" which screws up copy and paste for code). This would be useful for display
" of English text, for instance. Note: You have to turn off list for linebreak
" to work properly.
command! -nargs=* Wrap setlocal wrap linebreak nolist

" Turn the wrapping off (back to defaults...)
command! -nargs=* Nowrap setlocal nolinebreak

" For writing prose, not code.
command! -nargs=* Prose setlocal wrap linebreak nolist colorcolumn=""

" Undo the Prose settings if I do not actually want that right now.
command! -nargs=* Noprose setlocal textwidth=0 formatoptions-=at colorcolumn=81

" }}}
" --------------------------------------------------------------------
" Search and replace {{{

" Highlight search - show the current search pattern.
set hlsearch

" Clear the highlighted words from an hlsearch. (Can be visual clutter)
nnoremap <Leader><Space> :nohlsearch<CR>

" Turn hlsearch on or off.
nnoremap <Leader>h :set hlsearch!<CR>

" Incremental search - live updating, like Emacs or iTunes.
set incsearch

" Ignore the case in search patterns.
set ignorecase

" Ignore case in search patterns unless an uppercase character is used
" in the search, then pay attention to case. Requires ignorecase.
set smartcase

" Turn off vim's default regex and use normal regexes (behaves more
" like Perl regex now...) - this is "very magic" mode. Only alphanumerics
" and underscore are *not* quoted with backslash. See ":help magic".
nnoremap / /\v
vnoremap / /\v

" Use 'magic' patterns (extended regex) in search patterns. ("\s\+").
" This isn't used by the / search due to the above remappings, but it
" does give you better regex options for :s and :g and so forth.
set magic

" Assume /g at the end of any :s command. I usually want that anyway.
set gdefault

" Open fuzzyfinder in line mode (search current buffer)
nnoremap <silent> <Leader>/ :FufLine<CR>

" Use ack. Grep, refined. (Trailing space on this map is intentional.)
nnoremap <Leader>a :Ack --smart-case 

" }}}
" --------------------------------------------------------------------
" Sounds and alerts {{{

set noerrorbells

" Show a report when N lines were changed. report=0 means "show all changes".
set report=0

" Kind of messages to show. Abbreviate them all.
set shortmess=atI

" Flash the screen instead of making a beep.
set visualbell

if !has("gui_running")

	" Terminal's visual bell - turned off to make Vim quiet.
	set t_vb=

endif

" }}}
" --------------------------------------------------------------------
" Status indicators {{{

" Set the title bar if running as GUI, never in terminals. If set in
" a terminal, it will wipe away my title and not reset it on exit.
if has("gui_running")
	set title
else
	set notitle
endif

" Show the status line
set laststatus=2

" Settings for vim-statline plugin. See :help statline
" https://github.com/millermedeiros/vim-statline
let g:statline_syntastic      = 1
let g:statline_fugitive       = 1
let g:statline_rvm            = 0
let g:statline_trailing_space = 1
let g:statline_mixed_indent   = 1
let g:statline_show_charcode  = 0

" Old status line format
"set statusline=%<%f\ %h%m%r%y\ %=%-14.(%l,%c%V%)\ %P

" Show current uncompleted command.
set showcmd

" When positioned on a bracket, highlight its partner.
set showmatch

" Show the current mode.
set showmode

" Whether and how to display tabs and EOL
if has("multi_byte")
	set encoding=utf-8
	set nolist
	set listchars=tab:▸\ ,eol:¬
else
	set nolist
	set listchars=tab:>-,eol:$
endif

" Turn invisibles on/off.
nnoremap <silent> <Leader>i :set list!<CR>

" This only works in iTerm2. Change cursor to a bar in insert mode,
" a block in other modes.
" http://code.google.com/p/iterm2/wiki/ProprietaryEscapeCodes
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" }}}
" --------------------------------------------------------------------
" Line numbering / position indicators {{{

" Show line numbers as relative to current, not as absolute. This makes it
" easy to use count-based commands, e.g. 5dd or 10j. Fall back to regular
" numbering if we're on an old vim.
" Map <leader>n to toggle the number column. They get in the way of copying
" in a terminal.
if v:version >= 703
	set relativenumber
	nnoremap <silent> <Leader>n :set relativenumber!<CR>
else
	set number
	nnoremap <silent> <Leader>n :set number!<CR>
endif

" Show row/col of cursor position, and percentage into the file we are.
set ruler

" Show current cursor line position
set cursorline

" Warn on long lines. Looks like crap.
"set colorcolumn=81

" }}}
" --------------------------------------------------------------------
" Formatting {{{

" Text formatting options, used by 'gq', 'gw' and elsewhere. :help fo-table
set formatoptions=qrn1

" Insert two spaces after a period with every joining of lines?
" No! The 'two spaces' rule is an archaic typewriter-era practice.
set nojoinspaces

" Reformat current selection or paragraph.
" gq reformats a paragraph/selection; gw does it without moving the cursor.
vnoremap Q gw
nnoremap Q gwip

" Toggle autoclose mode
nnoremap <Leader>A <Plug>ToggleAutoCloseMappings

" Strip trailing whitespace file-wide, preserving cursor location
nnoremap <Leader>W :call Preserve("%s/\\s\\+$//e")<CR>

" Swap ' for " (or vice versa) on strings, preserving cursor location
nnoremap <silent> <Leader>' :call Preserve("normal cs\"'")<CR>
nnoremap <silent> <Leader>" :call Preserve("normal cs'\"")<CR>

" Insert a space (easier for code reformatting sometimes...)
"nnoremap <space> i<space><esc>l
" and have backspace become destructive...
"nnoremap <BS> X

" Bubble single lines
nmap <S-Up>   [e
nmap <S-Down> ]e

" Bubble multiple lines
vmap <S-Up>   [egv
vmap <S-Down> ]egv

" Remap ~ to use a function if invoked in visual mode. Cycles through
" uppercase, lowercase, title-case.
vnoremap ~ ygv"=TwiddleCase(@")<CR>Pgv

" In a visual block selection, space will insert a space, then return to
" the selection. This is intended to push a block over to the right,
" e.g. a fixed-width area in a mediawiki document.
vnoremap <Space> I<Space><Esc>gv
" Same thing but using a tab
"vnoremap <Tab> I<Tab><Esc>gv

" }}}
" --------------------------------------------------------------------
" Navigation {{{

" Do not jump to line start with page commands, i.e. keep current column.
set nostartofline

" Keep a few lines above/below the cursor when I scroll to next screen.
set scrolloff=3

" By default, ' jumps to the line you marked, and ` jumps to line -and- col
" that you marked. So ` is more useful. But harder to type. So swap them.
noremap ' `
noremap ` '

" When I have long lines and 'wrap' is true, I often use j,k to move up or
" down, and it skips to the next real line, rather than the next line
" on the display, and that's annoying. These remaps make j and k honor the
" _displayed_ lines instead of the actual lines. 'v' maps make this work in
" a wrapped-line selection as well. You can use the 'g' prefix for 0 and $
" also, but I don't want those mappings by default.
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" Go to matching brace / delimiter using <Tab>. % still works.
" Turning this off - since <Tab> == ^I, this breaks ^O / ^I jumps.
"nnoremap <tab> %
"vnoremap <tab> %

" If I wanted to live in insert mode, I'd use emacs or pico.
set noinsertmode

" Open quickfix window
nnoremap <Leader>q :cwindow<CR>

" Go to next/previous quickfix entry (C-arrow doesn't work)
"nnoremap <C-Down> :cnext<CR>
"nnoremap <C-Up> :cprevious<CR>

" Make Vim act like a pager, kinda.
" This sounds great in theory, but is very annoying in practice.
"nnoremap <Space> <PageDown>
"nnoremap <Backspace> <PageUp>

" Scroll the viewport a little faster than one line at a time
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" }}}
" ----------------------------------------------------------------------
" Folding {{{

" Use explicit markers for folding (triple curly-brace)
set foldmethod=marker

" Fold current HTML tag.
nnoremap <Leader>Ft Vatzf

" }}}
" ----------------------------------------------------------------------
" Syntax-related mappings {{{

" Toggle syntax highlighting.
nnoremap <silent> <Leader>S :if exists("g:syntax_on") <Bar>
	\    syntax off <Bar>
	\else <Bar>
	\    source $MYVIMRC <Bar>
	\endif<CR>

" Toggle spellcheck mode
nnoremap <Leader>s :set spell!<CR>

" Re-indent entire file, preserving cursor location
nnoremap <Leader>= :call Preserve("normal gg=G")<CR>

" Create an HTML version of our syntax highlighting for display or printing.
nnoremap <Leader>H :TOhtml<CR>

" A couple of conveniences for Markdown and others
inoremap <Leader>uu <Esc>kyypVr-o
inoremap <Leader>UU <Esc>kyypVr=o
nnoremap <Leader>uu ddkYpVr-$
nnoremap <Leader>UU ddkYpVr=$

" Ask Vim for the syntax type at cursor location
nnoremap <Leader>? :call SynStack()<CR>

" }}}
" ----------------------------------------------------------------------
" Vim pseudo-windows and tabpages {{{

" Create new windows below current one, if no direction was specified.
set splitbelow

" Create a new vertical window to the right, and switch to it.
nnoremap <silent> <Leader>w :wincmd v<CR>:wincmd l<CR>

" Easier navigation keys (ctrl + normal movement keys h,j,k,l)
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>

" Use default split window height (0 disables special help height).
set helpheight=0

" Open a new tab in the current view
nnoremap <silent> <Leader>t :tabnew<CR>

" Navigate left/right through tabs using shift + left/right arrow keys.
nnoremap <silent> <S-Left>  :tabprevious<CR>
nnoremap <silent> <S-Right> :tabnext<CR>
"vnoremap <silent> <S-Left>  :tabprevious<CR>
"vnoremap <silent> <S-Right> :tabnext<CR>
"inoremap <silent> <S-Left>  <Esc>:tabprevious<CR>
"inoremap <silent> <S-Right> <Esc>:tabnext<CR>

" }}}
" --------------------------------------------------------------------
" File handling, system interaction {{{

" Automatically save modifications to files when you use
" critical (rxternal) commands.
set autowrite

" List of directories to search when I specify a file with an edit command.
set path=.

" Ignore filename with any of these suffixes when using the
" ":edit" command. Most of these are files created by LaTeX.
set suffixes=.aux,.bak,.dvi,.gz,.idx,.log,.ps,.swp,.tar,.tgz,.sit,.dmg,.hqx

" Write a backup before overwriting a file. This backup is then erased,
" unless 'backup' is also set. I hate tilde files, isn't this what the
" .<filename>.swp file is for?
set nobackup
set nowritebackup

" Where to store swap files. Putting them in . is good, because then you
" can't edit the same file twice. However, when using a remote volume,
" like one mounted over ssh via Transmit, it's very, very slow. So
" going to use ~/.tmp-vim first if it exists. Usually it won't.
"set directory=~/.tmp-vim//,.,/var/tmp,/tmp

" Shell to use. Stick with the old standard.
let &shell="/bin/sh"

" }}}
" --------------------------------------------------------------------
" Expansion / completion {{{

" Add the dash ('-'), the dot ('.'), and the '@' as "letters" to "words".
" This makes it possible to expand email addresses, e.g. guckes-www@vim.org
set iskeyword=@,48-57,_,192-255,-,.,@-@

" The char/key-combo used for "expansion" on the command line. Default is ^E.
set wildchar=<Tab>

" Show me more than the first possible completion.
set wildmenu

" Behave like a shell, show me completion only to point of ambiguity.
set wildmode=list:longest

" Turn English-word completion from system dictionary on or off. (^N, ^P)
set dictionary=/usr/share/dict/words
nnoremap <silent> <Leader>E :call ToggleFlag('complete', 'k', 'English completion')<CR>

" }}}
" --------------------------------------------------------------------
" Copy and paste {{{

" Key combo to toggle paste-mode
set pastetoggle=,,

" Duplicate current selection (best used for lines, but can be used
" with any selection). Pastes duplicate at end of select region.
vnoremap D y`>p

" Reselect what was just pasted so I can so something with it.
" (To reslect last selection even if it is not the last paste, use gv.)
nnoremap <Leader>v `[v`]

" Toggle Yankring window
nnoremap <silent> <Leader>y :YRShow<CR>

" Where to store the history file (don't want it in $HOME)
let g:yankring_history_dir = '$HOME/.vim'

"if has("gui_running")

	" Disabling ,Y and ,P mappings - no point when cmd-C, cmd-V are
	" already available, and I just end up using these in terminal
	" sessions where they don't work. cmd-C and cmd-V work either way.

	" Copy current line or selection to OS X clipboard
	"nnoremap <Leader>Y "*yy
	"vnoremap <Leader>Y "*y

	" Paste from OS X clipboard explicitly. If something was copied to the
	" OS X clipboard after the last time something was copied to MacVim's
	" clipboard, then 'p' will behave the same way, but these will always
	" go directly to the OS X clipboard, bypassing anything in MacVim's.
	"nnoremap <Leader>P "*p
	"vnoremap <Leader>P "*p

	" Whatever we copy, send to the system clipboard too.
	" I don't like this, it can obliterate my Launchbar clipboard history
	" quickly. Replaced this with ,Y and ,P mappings to easily interact with
	" the system pasteboard in a more explicit way.
	"set clipboard+=unnamed

"endif

" }}}
" --------------------------------------------------------------------
" History and undo {{{

" What info to store from an editing session in the viminfo file;
" can be used at next session.
set viminfo=%,'50,\"100,:100,n~/.viminfo

" Increase the history size (default is 20).
set history=100

" Create an undo cache file for each edited file, so we can undo even
" after closing/opening a file (<filename>.un~). This has some appeal,
" but I don't want the litter.
"set undofile

" }}}
" --------------------------------------------------------------------
" Finding and opening files {{{

" Toggle the NERDTree browser.
nnoremap <Leader>f :NERDTreeToggle<CR>

" This variant is supposed to honor the current working directory, but that
" does not work with :cd as I expected it would.
"nnoremap <Leader>f :execute 'NERDTreeToggle ' . getcwd()<CR>

" NERDTree should close when I choose a file to open
let NERDTreeQuitOnOpen = 1

" Open FuzzyFinder in file mode. This *does* work properly with :cd.
nnoremap <Leader>* :FufFile<CR>

" Preload the :edit command with the directory where the file in
" the current buffer is located.
" This is no longer useful, there's now an autocmd that cd's to the current
" directory whenever you load a file.
"nnoremap <Leader>e :edit <C-R>=expand("%:p:h") . "/" <CR>

" Variants that open in split, vsplit or a tab
"nnoremap <Leader>es :sp <C-R>=expand("%:p:h") . "/" <CR>
"nnoremap <Leader>ev :vsp <C-R>=expand("%:p:h") . "/" <CR>
"nnoremap <Leader>et :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Open filename under cursor (optionally in new tab or window)
nnoremap <Leader>of gf
vnoremap <Leader>of gf
nnoremap <Leader>ow :wincmd f
vnoremap <Leader>ow :wincmd f
nnoremap <Leader>ot :wincmd gf
vnoremap <Leader>ot :wincmd gf

" }}}
" --------------------------------------------------------------------
" Misc. settings {{{

" Allow "hidden" buffers. :help hidden
set hidden

" Modelines are kind of ugly, and I've read there are security problems
" with them. Disabling.
" Hah, this is funny, I was just trying to convince my team to start using
" modelines, and here I have them disabled, claiming security problems.
set nomodeline
set modelines=0

" Spellcheck language
set spelllang=en_us

" Turn off " pairing in vim files (plugin: autoclose [my fork])
let g:autoclose_vim_commentmode = 1

if has("gui_running")

	" Disable the toolbar
	set guioptions=-t

	" Enable the right scrollbar
	"set guioptions=+r

else

	" Are we using a fast terminal?
	set ttyfast

endif

" }}}
" --------------------------------------------------------------------
" Custom command mappings {{{

" Read current buffer, turn it into a bookmarklet, insert that bookmarklet
" in a comment on line 1 (discarding previously inserted bookmarklet if it
" exists), copy bookmarklet to the clipboard.
nnoremap <silent> <Leader>B :%!$HOME/.vim/bin/bookmarklet_build.pl<CR>

" Preview a markdown file in the default browser
nnoremap <Leader>M :w!<CR>:!$HOME/.vim/bin/markdownify % > /tmp/%.html && open /tmp/%.html<CR><CR>

" QuickRun the current buffer, autodetecting syntax
nnoremap <Leader>r :QuickRun<CR>

" Convert file, or selection, so each contiguous non-whitespace blob is
" on its own line. Strip all other whitespace.
nnoremap <Leader>1 :%!$HOME/bin/convert-to-one-string-per-line.rb<CR>
vnoremap <Leader>1 :!$HOME/bin/convert-to-one-string-per-line.rb<CR>

" }}}
" --------------------------------------------------------------------
" Misc. mappings {{{

" Use jj to get back to command mode instead of Esc, which is out of the
" way. Esc still works too.
" Turning this off, probably easier to map this only one way (in my head).
"inoremap jj <Esc>

" Remap F1 to Esc, because they're right next to each other, and I know how
" to type ":h" already, thank you very much.
inoremap <F1> <Esc>
nnoremap <F1> <Esc>
vnoremap <F1> <Esc>

" Swap ; in place of : for commands - no need to hit shift constantly.
" Note: do not map : back to ; to try to reclaim the ';' functionality,
" it'll break half the plugins.
" Undoing this map. I think losing the ; function is not worth it just
" to avoid hitting shift for commands.
"nnoremap ; :

" Define "del" char to be the same backspace (saves a LOT of trouble!)
" As the angle notation cannot be use with the LeftHandSide
" with mappings you must type this in *literally*!
" map <C-V>127 <C-H>
"cmap <C-V>127 <C-H>
" the same for Linux Debian which uses
inoremap <Esc>[3~ <C-H>
inoremap  <C-H>
cnoremap  <C-H>

" Unmap the K key, it usually doesn't do anything useful anyway.
nnoremap K <Nul>

" Example of changing the contents of a tag to TitleCase.
" e.g.: <foo>BAR BAZ</foo> becomes <foo>Bar Baz</foo>
"nnoremap <Leader>x vit:s/\%V\<\(\w\)\(\w*\)\>/\u\1\L\2/<CR>

" Hit ^L in insert mode to skip the rest of this line and go to the next
" line. This is handy when I've gotten to the end of the line, but autoclose
" has added a bunch of closing punctuation to the right. I can skip to the
" next line without having to get into normal mode and start a new line, or
" typing out the closing marks to skip them.
inoremap <C-l> <Esc>A<CR>

" When I type 'o' to start a new line, it copies the indent from the current
" line but if I then hit enter, it leaves whitespace behind on an otherwise
" blank line. 'A' does not do that. So I remap o to A. Cheap, but it works.
nnoremap o A<CR>

" }}}
" --------------------------------------------------------------------
" Auto-command triggers {{{

if has("autocmd")
	autocmd!

	autocmd BufNewFile,BufRead *.t                            set filetype=perl
	autocmd BufNewFile,BufRead *.inc                          set filetype=php
	autocmd BufNewFile,BufRead *.com                          set filetype=bindzone
	autocmd BufNewFile,BufRead *.wiki,*ISSwiki*               set filetype=mediawiki
	autocmd BufNewFile,BufRead *Safari*WordPress*,*.md        set filetype=markdown
	autocmd BufNewFile,BufRead .bash/*,bash/*,.dotfiles/bash* set filetype=sh
	autocmd BufNewFile,BufRead distfile.common                set filetype=rdist
	autocmd BufNewFile,BufRead ejabberd.cfg                   set filetype=erlang
	autocmd BufNewFile,BufRead aliases.*                      set filetype=mailaliases
	autocmd BufNewFile,BufRead [Mm]akefile*                   set filetype=make
	autocmd BufNewFile,BufRead *.global                       set filetype=m4
	autocmd BufNewFile,BufRead exim.cf*                       set filetype=exim

	" Look inside .epub files
	au BufReadCmd *.epub call zip#Browse(expand("<amatch>"))

	" Italic, bold surrounds for Mediawiki (plugin 'surround')
	autocmd FileType mediawiki let g:surround_{char2nr('i')} = "''\r''"
	autocmd FileType mediawiki let g:surround_{char2nr('b')} = "'''\r'''"
	" Header levels 2, 3, 4
	autocmd FileType mediawiki let g:surround_{char2nr('2')} = "==\r=="
	autocmd FileType mediawiki let g:surround_{char2nr('3')} = "===\r==="
	autocmd FileType mediawiki let g:surround_{char2nr('4')} = "====\r===="

	" Bold for Markdown (plugin 'surround')
	autocmd FileType markdown let g:surround_{char2nr('b')} = "**\r**"

	" Save all unclean buffers when focus is lost (ala TextMate).
	" Not sure whether I like this idea. This is GUI only, terminal
	" vim has no concept of focus (or does it know it was backgrounded?)
	"autocmd FocusLost * :wa

	" cd to the directory of the current file. Makes it easier to :e
	" files in the same directory.
	autocmd BufEnter * cd %:p:h

	" Automatically reload .vimrc if we edited it.
	autocmd BufWritePost .vimrc,vimrc,.dotfiles/vimrc source $MYVIMRC

	" Restore cursor position from our last session, if known.
	autocmd BufReadPost *
		\ if line("'\"") > 1 && line("'\"") <= line("$") |
		\     execute "normal! g`\"" |
		\ endif

endif

" }}}
" --------------------------------------------------------------------
" Fonts and colors {{{

" How many colors my terminal is capable of displaying. This assumes
" that terminfo for xterm-256color is present.
" According to deryni on #vim this is autodetected. Apparently so.
"if !has("gui") && has("terminfo")
	"set t_Co=256
"endif

if has("gui_running")
	set guifont=Menlo:h14
	set antialias
endif

" Activate syntax highlighting
" 'syntax enable' will turn on syntax highlighting without wiping out
" any highlight commands already in place. 'syntax on' will reset it
" all to defaults. So I use 'syntax on' and put my highlight commands
" after this point, that way I can ':so ~/.vimrc' and reset everything
" whenever I want.

"syntax enable
syntax on

" I'm using Solarized Light everywhere no, no need to do a check anymore.
set background=light

"if has("gui_running")
	" Use light scheme in GUI to differentiate it from terminal
	"set background=light
"else
	" I usually use a dark-background terminal
	"set background=dark
"endif

" Colorscheme: Zenburn {{{

" High contrast mode for rooms with more light
"let g:zenburn_high_Contrast = 1

" More contrast in a visual selection
"let g:zenburn_alternate_Visual = 1

" http://www.vim.org/scripts/script.php?script_id=415
" http://slinky.imukuppi.org/zenburnpage/
"colorscheme zenburn

" Mute tabs, control characters, other invisibles in zenburn.
"highlight SpecialKey ctermfg=240 gui=bold guifg=#5b605e
""highlight NonText ctermfg=240 gui=bold guifg=#5b605e

" Make cursorline stand out a little more.
""highlight CursorLine guibg=#565656

" }}}

" Colorscheme: Solarized {{{

colorscheme solarized

" }}}

" Mark trailing whitespace with a red background to make it stand out
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
highlight EOLWS ctermbg=cyan guibg=gray

" Terminal setup before xterm-256color {{{
"if !has("gui") && has("terminfo")
	"set t_Co=16
	"set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
	"set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
"else
	"set t_Co=16
	"set t_Sf=[3%dm
	"set t_Sb=[4%dm
"endif
" }}}

" Custom colors (pre-zenburn) {{{
"highlight Comment ctermfg=darkgrey guifg=#858585
"highlight Statement cterm=bold ctermfg=blue gui=bold guifg=blue
"highlight Identifier cterm=bold ctermfg=darkcyan gui=bold guifg=darkcyan
"highlight Search ctermbg=14
"highlight CursorLine cterm=NONE ctermbg=11
"highlight StatusLine cterm=NONE ctermfg=white ctermbg=darkgrey
" invisibles...
"highlight NonText ctermfg=grey guifg=#eeeeee
"highlight SpecialKey ctermfg=grey guifg=#eeeeee
" }}}

" }}}
" --------------------------------------------------------------------
" Window size (GUI) {{{

" Only set the window size if it was not set already.
if has("gui_running") && !exists('g:dmlSetWindowSize')
	set lines=40
	set columns=90
	let g:dmlSetWindowSize=1
endif

" }}}
" --------------------------------------------------------------------
" Local customizations {{{

" In case I or someone else wants to override this file without
" modifying the master copy in git.
if filereadable($HOME . '/.vimrc.local')
	source ~/.vimrc.local
endif

" }}}
" --------------------------------------------------------------------
