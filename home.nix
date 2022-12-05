{ config, pkgs, ... }:

{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "matt";
    homeDirectory = "/home/matt";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";

    packages = with pkgs; [
      # Shell
      bash
      starship
      tmux

      # Workflow
      direnv
      git
      pre-commit

      # Languages
      nixfmt
      poetry
      python310
      rustup

      # Utils
      bat
      exa
      fd
      htop
      jq
      ripgrep
    ];

    file = { ".config/alacritty/alacritty.yml".source = ./alacritty.yml; };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    sessionVariables = { EDITOR = "vim"; };
    shellAliases = {
      cat = "bat";
      grep = "rg";
      ls = "exa";
      find = "fd";
    };
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [ tmuxPlugins.better-mouse-mode ];

    extraConfig = ''
      # Set prefix key to c-f instead of default c-b
      unbind C-b
      set -g prefix C-f
      bind C-f send-prefix

      # toogle last window by hitting again C-f
      bind-key C-f last-window

      # if multiple clients are attached to the same window, maximize it to the
      # bigger one
      set-window-option -g aggressive-resize

      # Start windows and pane numbering with index 1 instead of 0
      set -g base-index 1
      setw -g pane-base-index 1

      # re-number windows when one is closed
      set -g renumber-windows on

      # word separators for automatic word selection
      setw -g word-separators ' @"=()[]_-:,.'
      setw -ag word-separators "'"

      # Show times longer than supposed
      set -g display-panes-time 2000

      # tmux messages are displayed for 4 seconds
      set -g display-time 4000

      # {n}vim compability
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set -g default-terminal "screen-256color"

      # Split horiziontal and vertical splits, instead of % and ". We also open them
      # in the same directory.  Because we use widescreens nowadays, opening a
      # vertical split that takes half of the screen is not worth. For vertical we
      # only open 100 lines width, for horizontal it's 20 columns.
      bind-key v split-window -h -l 100 -c '#{pane_current_path}'
      bind-key s split-window -v -l 30 -c '#{pane_current_path}'

      # Pressing Ctrl+Shift+Left (will move the current window to the left. Similarly
      # right. No need to use the modifier (C-b).
      bind-key -n C-S-Left swap-window -t -1
      bind-key -n C-S-Right swap-window -t +1


      # Source file
      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      # Use vim keybindings in copy mode
      setw -g mode-keys vi

      # Enter copy mode with /
      bind-key / copy-mode \; send-key ?

      # Update default binding of `Enter` and `Space to also use copy-pipe
      unbind -T copy-mode-vi Enter
      unbind -T copy-mode-vi Space

      bind-key -T edit-mode-vi Up send-keys -X history-up
      bind-key -T edit-mode-vi Down send-keys -X history-down

      # setup 'v' to begin selection as in Vim
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection

      # copy text with `y` in copy mode
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

      # copy text with mouse selection without pressing any key
      bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel

      # emacs key bindings in tmux command prompt (prefix + :) are better than
      # vi keys, even for vim users
      set -g status-keys emacs

      # focus events enabled for terminals that support them
      set -g focus-events on

      # Sync panes (Send input to all panes in the window). When enabled, pane
      # borders become red as an indication.
      bind C-s if -F '#{pane_synchronized}' \
                           'setw synchronize-panes off; \
                            setw pane-active-border-style fg=colour63,bg=default; \
                            setw pane-border-format       " #P "' \
                         'setw synchronize-panes on; \
                          setw pane-active-border-style fg=red; \
                          setw pane-border-format       " #P - Pane Synchronization ON "'

      # Faster command sequence
      set -s escape-time 0

      # Have a very large history
      set -g history-limit 1000000

      # Mouse mode on
      set -g mouse on

      # Set title
      set -g set-titles on
      set -g set-titles-string "#T"

      # Equally resize all panes
      bind-key = select-layout even-horizontal
      bind-key | select-layout even-vertical

      # Resize panes
      bind-key J resize-pane -D 10
      bind-key K resize-pane -U 10
      bind-key H resize-pane -L 10
      bind-key L resize-pane -R 10

      # Select panes 
      # NOTE(arslan): See to prevent cycling https://github.com/tmux/tmux/issues/1158
      bind-key j select-pane -D 
      bind-key k select-pane -U 
      bind-key h select-pane -L 
      bind-key l select-pane -R 

      # Disable confirm before killing
      bind-key x kill-pane
    '';
  };

  #programs.alacritty = {
  #  enable = true;
  #  settings = {
  #    shell = {
  #      program = "${pkgs.tmux}/bin/tmux";
  #      args = [ "new-session" "-A" "-D" "-s" "main" ];
  #    };
  #    key_bindings = [
  #      # Create Vertical Pane
  #      {
  #        key = "V";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x76";
  #      }
  #      # Create Horizontal Pane
  #      {
  #        key = "H";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x73";
  #      }
  #      # Close a Pane
  #      {
  #        key = "Delete";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x78";
  #      }
  #      # Move between Pane
  #      # Left
  #      {
  #        key = "Left";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x68";
  #      }
  #      # Down
  #      {
  #        key = "Down";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x6a";
  #      }
  #      # Up
  #      {
  #        key = "Up";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x6b";
  #      }
  #      # Right
  #      {
  #        key = "Right";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x6c";
  #      }
  #      # Create a Tab
  #      {
  #        key = "T";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x63";
  #      }
  #      {
  #        key = "Numpad1";
  #        mods = "Control";
  #        chars = "\\x06\\x31";
  #      }
  #      {
  #        key = "Numpad2";
  #        mods = "Control";
  #        chars = "\\x06\\x32";
  #      }
  #      {
  #        key = "Numpad3";
  #        mods = "Control";
  #        chars = "\\x06\\x33";
  #      }
  #      {
  #        key = "Numpad4";
  #        mods = "Control";
  #        chars = "\\x06\\x34";
  #      }
  #      {
  #        key = "Numpad5";
  #        mods = "Control";
  #        chars = "\\x06\\x35";
  #      }
  #      {
  #        key = "Numpad6";
  #        mods = "Control";
  #        chars = "\\x06\\x36";
  #      }
  #      {
  #        key = "Numpad7";
  #        mods = "Control";
  #        chars = "\\x06\\x37";
  #      }
  #      {
  #        key = "Numpad8";
  #        mods = "Control";
  #        chars = "\\x06\\x38";
  #      }
  #      {
  #        key = "Numpad9";
  #        mods = "Control";
  #        chars = "\\x06\\x39";
  #      }
  #      # Resize panes
  #      # Left
  #      {
  #        key = "A";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x48";
  #      }
  #      # Down
  #      {
  #        key = "S";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x4a";
  #      }
  #      # Up
  #      {
  #        key = "W";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x4b";
  #      }
  #      # Right
  #      {
  #        key = "D";
  #        mods = "Control|Shift";
  #        chars = "\\x06\\x4c";
  #      }
  #    ];

  #  };
  #};

  programs.starship.enable = true;

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ syntastic vim-nix rust-vim vim-prettier ];
    settings = { ignorecase = true; };
    extraConfig = ''
      " ~/.vimrc (configuration file for vim only)

      " Description {{{
      " This vimrc can load computer specific vimrcs before and after it actually
      " loads.
      "
      "   This file should set the following optional variables:
      "   g:workspace            The environmental variable containing the current
      "                          workspace. The variable should include the dollar
      "                          sign in it's definition.
      "   g:developmentUsername  The username of the development account.
      "   g:javaCompiler         The build tool used for java.
      "   g:charLimit            The amount of characters allowed per line
      "
      "   Example File Contents:
      "
      "   let g:workspace="$WORKSPACE"
      let g:developmentUsername="matt"
      let g:javaCompiler="gradle"
      let g:charLimit=120
      "
      " }}}

      " Uncomment to debug this vimrc
      " set verbose=15
      " set verbosefile=~/vimLog.txt

      " To toggle open/close a fold type 'za'.
      " To open all folds type 'zR'.
      " To close all folds type 'zM'.

      " Color Scheme {{{
          " This section is to set any settings that effect the color scheme of a generic file. File type
          " specifics schemes should be in syntax files.
          syntax on
          " Normal settings {{{
              highlight Normal term=none cterm=none ctermfg=White ctermbg=Black gui=none guifg=White guibg=Black
          " }}}
          " VimDiff settings {{{
              highlight DiffAdd cterm=none ctermfg=Black ctermbg=DarkGreen gui=none guifg=fg guibg=Green
              highlight DiffDelete cterm=none ctermfg=Black ctermbg=DarkRed gui=none guifg=fg guibg=Red
              highlight DiffChange cterm=none ctermfg=Black ctermbg=DarkYellow  gui=none guifg=fg guibg=Orange
              highlight DiffText cterm=none ctermfg=Black ctermbg=White gui=none guifg=bg guibg=White
          " }}}
          " Tab settings {{{
              highlight TabLineSel cterm=none ctermfg=Black ctermbg=White gui=none guifg=fg guibg=Green
              highlight TabLineFill cterm=none ctermfg=White ctermbg=Black gui=none guifg=fg guibg=Green
          " }}}
          " Custom Categories {{{
              highlight CharLimit ctermbg=Red guibg=Red
              highlight TrailingWhitespace ctermbg=Red guibg=Red
          " }}}
              if version >= 702
                  " This should fix performance issues caused by a memory leak in vim. This should not
                  " negatively effect experience since matches are made every time BufWinEnter is called
                  " which is called every time a buffer is displayed.
                  autocmd BufWinLeave * call clearmatches()
              endif
      " }}}
      " Shell Correction {{{
          " Making Ctrl+arrow keys handle like Ctrl+arrow keys in putty.
          map <ESC>[D <C-Left>
          map <ESC>[C <C-Right>
          map <ESC>[A <C-Up>
          map <ESC>[B <C-Down>

          map! <ESC>[D <C-Left>
          map! <ESC>[C <C-Right>
          map! <ESC>[A <C-Up>
          map! <ESC>[B <C-Down>
      " }}}
      " Tab Management {{{
          if v:version >= 700 " {{{
              " Ctrl-Left switches to previous tab.
              nnoremap <C-Left> :tabprevious<CR>
              " Ctrl-Right switches to next tab.
              nnoremap <C-Right> :tabnext<CR>
              " Ctrl-Up moves tab left.
              nnoremap <silent> <C-Up> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
              " Ctrl-Down moves tab right.
              nnoremap <silent> <C-Down> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
          endif " }}}
      " }}}
      " Settings {{{
          " Set leader to ','.
          let mapleader = ","

          " Don't be compatible with vi.
          set nocompatible

          " Fixes backspace on certain systems.
          set backspace=2

          " Auto read when a file is changed from the outside.
          set autoread

          " Enable visual autocomplete for command menu.
          set wildmenu

          " Enable utf-8 encoding.
          set encoding=utf-8

          " Open man files with ':Man [command name]'.
          source $VIMRUNTIME/ftplugin/man.vim

          " Enable file type detection as well as the loading of file type specific indent files.
          filetype indent on

          " Search modifiers {{{
              " Highlight all matches to the last search pattern.
              set hlsearch
              " Jump to the first match of the search pattern being typed as it is typed.
              set incsearch
          " }}}

          " Visual Settings {{{
              " Display the line number.
              set number

              " Always show the current cursor position in the bottom right corner of the screen.
              set ruler

              " Enable spell check.
              set spell

              if v:version >= 700 " {{{
                  " Highlight the current line that the cursor is on.
                  set cursorline
              endif " }}}

              " Don't resize windows on close.
              set noequalalways
          " }}}
          " Indentation modifiers {{{
              " Set a tab to being visually identical to 4 spaces.
              set tabstop=4
              " Set the number of spaces to use when auto-indenting.
              set shiftwidth=4
              " Set the number of spaces inserted into a file when hitting the tab key in insert mode.
              set softtabstop=4
          " }}}
      " }}}
      " Mappings {{{
          " Ctrl-Space initiates auto-complete {{{
              inoremap <Nul> <C-n>
          " }}}
          " Resizing windows {{{
              " Increases the window size.
              nnoremap <C-o> <C-w>>
              " Decreases the window size.
              nnoremap <C-p> <C-w><
          " }}}
          " Traversing wrapped lines as if they were separate lines {{{
              " Moving up
              nnoremap <Up> gk
              " Moving down
              nnoremap <Down> gj
          " }}}
          " Insert lines without going into insert mode {{{
              " Insert a line below the current line and then go back to the current line.
              nmap <leader>o o<Esc>k
              " Insert a line above the current line and then go back to the current line.
              nmap <leader>p O<Esc>
          " }}}
          " Switch buffers {{{
              " Switch to the next buffer.
              nnoremap <C-n> :bn<CR>
              " Switch to the previous buffer.
              nnoremap <C-p> :bp<CR>
          " }}}
      " }}}
      " Aliases {{{
          " Aliases for spelling correction purposes {{{
              cnoreabbrev W w
              cnoreabbrev Q q
              cnoreabbrev QA qa
              cnoreabbrev Qa qa
              cnoreabbrev q!! q!
          " }}}
          " Aliases to save typing {{{
              cnoreabbrev vs vsplit
              exe "cnoreabbrev so so /home/" . g:developmentUsername . "/.vimrc"
              if v:version >= 700 " {{{
                  cnoreabbrev te tabedit
                  exe "cnoreabbrev mod tabedit /home/" . g:developmentUsername . "/.vimrc"
              " }}}
              else " {{{
                  cnoreabbrev te edit
                  exe "cnoreabbrev mod edit /home/" . g:developmentUsername . "/.vimrc"
              endif " }}}
          " }}}
          " Aliases to User Functions {{{
              cnoreabbrev FL) FL0
          " }}}
      " }}}
      " FileType specific functions {{{
          " Vimscript {{{
              autocmd FileType vim call VimscriptSettings()
              function! VimscriptSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')
                  call matchadd('CharLimit', '\%' . string(g:charLimit+1) . 'v.\+')
                  execute 'setlocal textwidth=' . string(g:charLimit)

                  setlocal autoindent
                  setlocal expandtab
                  setlocal foldcolumn=3 " Shows the fold levels on the left of the buffer's window.
                  setlocal foldmethod=marker " Fold on triple curly-braces.
                  setlocal smarttab
                  setlocal wrap! " Don't wrap the lines.

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k oecho "' . g:developmentUsername . ':" <Esc>'
                  execute 'noremap <buffer> <leader>l oecho "' . g:developmentUsername . ':" <Esc>i'
              endfunction
          " }}}
          " C {{{
              autocmd FileType c call CSettings()
              function! CSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')
                  call matchadd('CharLimit', '\%' . string(g:charLimit+1) . 'v.\+')
                  execute 'setlocal textwidth=' . string(g:charLimit)

                  setlocal autoindent
                  setlocal cindent
                  setlocal expandtab
                  setlocal foldlevel=99
                  setlocal foldmethod=syntax
                  setlocal smarttab

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k oprintf("' . g:developmentUsername . ':");<Esc>'
                  execute 'noremap <buffer> <leader>l oprintf("' . g:developmentUsername . ':");<Esc>2hi'

                  if exists("g:workspace")
                      exe "cd " . g:workspace . "/src"
                      exe "setlocal tags=" . g:workspace . "/tags"
                  endif
              endfunction
          " }}}
          " C++ {{{
              autocmd FileType cpp call CppSettings()
              function! CppSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')
                  call matchadd('CharLimit', '\%' . string(g:charLimit+1) . 'v.\+')
                  execute 'setlocal textwidth=' . string(g:charLimit)

                  setlocal autoindent
                  setlocal cindent
                  setlocal expandtab
                  setlocal foldlevel=99
                  setlocal foldmethod=syntax
                  setlocal smarttab

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k ostd::cout << "' . g:developmentUsername . ':" <<__PRETTY_FUNCTION__ << " :" << std::endl;<Esc>'
                  execute 'noremap <buffer> <leader>l ostd::cout << "' . g:developmentUsername . ':" <<__PRETTY_FUNCTION__ << " :" << std::endl;<Esc>14hi'

                  if exists("g:workspace")
                      exe "cd " . g:workspace . "/src"
                      exe "setlocal tags=" . g:workspace . "/tags"
                  endif
              endfunction
          " }}}
          " Java {{{
              autocmd FileType java call JavaSettings()
              function! JavaSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')
                  call matchadd('CharLimit', '\%' . string(g:charLimit+1) . 'v.\+')
                  execute 'setlocal textwidth=' . string(g:charLimit)

                  setlocal autoindent
                  setlocal expandtab
                  setlocal foldlevel=99
                  setlocal foldmethod=syntax
                  setlocal smarttab

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k oSystem.out.println("' . g:developmentUsername . ':" + " ");<Esc>'
                  execute 'noremap <buffer> <leader>l oSystem.out.println("' . g:developmentUsername . ':" + " ");<Esc>2hi'

                  if exists("g:workspace")
                      execute "cd " . g:workspace
                  endif

                  if exists("g:javaCompiler")
                      execute "compiler! " . g:javaCompiler
                  endif

                  let &errorformat =
                      \ '%E%\m:%\%%(compileJava%\|compileTarget%\)%f:%l: error: %m,' .
                      \ '%E%f:%l: error: %m,' .
                      \ '%Z%p^,' .
                      \ '%-G%.%#'
              endfunction
          " }}}
          " Python {{{
              autocmd FileType python call PythonSettings()
              function! PythonSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')

                  setlocal expandtab
                  setlocal autoindent
                  setlocal foldmethod=indent

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k oprint "' . g:developmentUsername . ':" <Esc>'
                  execute 'noremap <buffer> <leader>l oprint "' . g:developmentUsername . ':" <Esc>hi'
              endfunction
          " }}}
          " Bash {{{
              autocmd FileType sh call BashSettings()
              function! BashSettings()
                  call matchadd('TrailingWhitespace', '\s\+$')
                  execute 'setlocal textwidth=' . string(g:charLimit)

                  setlocal autoindent
                  setlocal expandtab
                  setlocal smarttab
                  setlocal foldmethod=syntax

                  " Hotkey a generic trace statement for easy insertion.
                  execute 'noremap <buffer> <leader>k oecho "' . g:developmentUsername . ': " <Esc>'
                  execute 'noremap <buffer> <leader>l oecho "' . g:developmentUsername . ': " <Esc>i'
              endfunction
          " }}}
          " Xml {{{
              autocmd FileType xml call XmlSettings()
              function! XmlSettings()
                  setlocal autoindent
                  setlocal expandtab
                  setlocal foldlevel=99
                  setlocal foldmethod=syntax
              endfunction
          " }}}
      " }}}
      " ~/.vimrc ends here
    '';
  };

  programs.direnv.enable = true;

  programs.git = {
    enable = true;
    userName = "matt";
    userEmail = "mattbelle17@gmail.com";

    aliases = { d = "difftool"; };

    extraConfig = {
      diff = { tool = "vimdiff"; };
      merge = { tool = "vimdiff"; };
      diffTool = { prompt = false; };
    };

  };
}
