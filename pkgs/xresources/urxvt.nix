{ pkgs }:
let
  ffnw = import ../ffnw.nix { inherit pkgs; };
in
  pkgs.writeText "urxvt.xresources" ''
! could not get these to work
! urxvt.tabbed.no-tabbedex-keys: yes
! urxvt.keysym.Control-Up: perl:tabbedex:new_tab

! To control tabs use:
! Key           Description
! Shift+Down    New tab
! Shift+Left    Go to left tab
! Shift+Right   Go to right tab
! Ctrl+Left     Move tab to the left
! Ctrl+Right    Move tab to the right
! Ctrl+d        Close tab

urxvt.font: xft:DejaVuSansMono:pixelsize=10
urxvt.background: black
urxvt.foreground: green
urxvt.scrollBar_right: true
urxvt.scrollBar_floating: true
urxvt.scrollTtyOutput: false
urxvt.scrollWithBuffer: false
urxvt.scrollTtyKeypress: true
! selection-to-clipboard : copy selection direct to clipboard
!   Meta-Ctrl-C to copy
!   Meta-Ctrl-V to paste
urxvt.perl-ext-common: default,matcher,url-select,font-size,vtwheel,tabbed,selection-to-clipboard
urxvt.url-launcher: ${ffnw}/bin/ffnw
urxvt.matcher.button: 1
urxvt.keysym.M-u: perl:url-select:select_next
urxvt.url-select.launcher: ${ffnw}/bin/ffnw
urxvt.url-select.underline: true
urxvt.keysym.C-Delete: perl:matcher:last
urxvt.keysym.M-Delete: perl:matcher:list
urxvt.matcher.rend.0: Uline Bold fg8
urxvt.secondaryScreen: 1
urxvt.secondaryScroll: 0
urxvt.keysym.C-plus:    font-size:increase
urxvt.keysym.C-minus:   font-size:decrease
urxvt.keysym.C-M-+:     font-size:incglobal
urxvt.keysym.C-M-minus: font-size:decglobal

urxvt.font-size.smaller: C--
urxvt.resize-font.bigger: C-+

! Usage: put the following lines in your .Xdefaults/.Xresources:
!   urxvt.perl-ext-common: ...,url-select
!   urxvt.keysym.M-u: perl:url-select:select_next

! Use Meta-u to activate URL selection mode, then use the following keys:
!   j/k:      Select next downward/upward URL (also with arrow keys)
!   g/G:      Select first/last URL (also with home/end key)
!   o/Return: Open selected URL in browser, Return: deactivate afterwards
!   y:        Copy (yank) selected URL and deactivate selection mode
!   q/Escape: Deactivate URL selection mode

! Options:
!   urxvt.url-select.autocopy:  If true, selected URLs are copied to PRIMARY
!   urxvt.url-select.button:    Mouse button to click-open URLs (default: 2)
!   urxvt.url-select.launcher:  Browser/command to open selected URL with
!   urxvt.url-select.underline: If set to true, all URLs get underlined
''
