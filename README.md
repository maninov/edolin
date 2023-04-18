# edolin

## language
* dart language(flutter)

## concept
* I arranged the line editor (EDLIN), which is an internal command of MS-DOS, into a modern style (only the sound is covered with kotlin). The key bindings are emacs-like and implement only the bare minimum. Of course, it supports Japanese, and this README.md is also created with edolin. It is coded in about 250 lines.

## environment
* linux

##  execution example

```
% git clone https://github.com/maninov/edolin.git
% flutter create edolin_sample
% cp edolin/lib/* edolin_sample/lib
% cd edolin_sample
% flutter pub add  google_fonts scrollable_positioned_list
% echo test > todo
% flutter run
```

## usage ('C-' is notation while pressing Ctrl key)
* cursor move

key | action
----------------|-------------
C-p,C-n,C-b,C-f | up,down,left,right
C-a,C-e | first line,end line
ESC-<,ESC->,C-v | top of page,bottom of page,feed of page
C-l | refresh of page

* editing

key | action
----------------|-----------------
C-d,BackSpace | position character erase
C-k | delete after cursor or delete row
C-y | paste of 'C-k'
C-t | character swap
C-x | saved
Tab | indent of 2 single-byte spaces
Enter | confirm or newline


