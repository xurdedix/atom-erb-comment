# erb-comment

 [Atom erb comment package](http://github.com)

Patch for rails html.erb comment.
Comment with ruby ​​comment instead of html comment if it is a file of type "HTML (Rails)" else launches the standard comments `"editor: toggle-line-comments"`

![erb comment example](https://github.com/xurdedix/atom-erb-comment/blob/master/resources/atom-erb-comment.png?raw=true)

### Installation

```
apm install erb-comment
```

Set it to the key you want in the file `atom/keymap.cson`:

```
'atom-text-editor:not([mini])':
   'ctrl-/': 'erb-comment:toggle'
 ```
 or
```
'atom-text-editor:not([mini])':
   'ctrl-shift-c': 'erb-comment:toggle'
 ```
