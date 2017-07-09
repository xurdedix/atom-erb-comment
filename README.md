# erb-comment package

Patch for rails html.erb comment.
Comment with ruby ​​comment instead of html comment if it is a file of type "HTML (Rails)" else launches the standard comments `"editor: toggle-line-comments"`

![erb comment example](https://github.com/xurdedix/atom-erb-comment/blob/master/resources/atom-erb-comment.png?raw=true)

Set it to the key you want in the file `atom/keymap.cson`:

`'atom-text-editor:not([mini])':`
<space>&nbsp;&nbsp;&nbsp;&nbsp;`'ctrl-shift-c': 'erb-comment:toggle'`
