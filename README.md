# ERB Comment

[![Build Status](https://travis-ci.org/xurdedix/atom-erb-comment.svg?branch=master)](https://travis-ci.org/xurdedix/atom-erb-comment)

[Atom erb comment package](https://atom.io/packages/erb-comment)

Patch for rails html.erb comment.
Comment with ruby ​​comment instead of html comment if it is a file of type "HTML (Rails)" else launches the standard comments `"editor: toggle-line-comments"`

![erb comment example](https://github.com/xurdedix/atom-erb-comment/blob/master/resources/atom-erb-comment.gif?raw=true)

### Installation

```
apm install erb-comment
```
### Key config
Set the key you want in the Edit > Keymap menu. Adding this code to the end of the file `keymap.cson`:
```
'atom-text-editor:not([mini])':
   'ctrl-/': 'erb-comment:toggle'
 ```
 or
```
'atom-text-editor:not([mini])':
   'ctrl-shift-c': 'erb-comment:toggle'
 ```

For more info about keymap see [atom documentation](http://flight-manual.atom.io/using-atom/sections/basic-customization/#customizing-keybindings):
