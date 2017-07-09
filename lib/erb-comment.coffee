ErbCommentView = require './erb-comment-view'
{CompositeDisposable} = require 'atom'

module.exports = ErbComment =
  erbCommentView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @erbCommentView = new ErbCommentView(state.erbCommentViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @erbCommentView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'erb-comment:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @erbCommentView.destroy()

  serialize: ->
    erbCommentViewState: @erbCommentView.serialize()

  toggle: ->
    if editor = atom.workspace.getActiveTextEditor()
      ranges = editor.getSelectedBufferRanges()
      selection = editor.getSelectedText()
      if selection == ""
        editor.selectLinesContainingCursors()
        selection = editor.getSelectedText()
      language = editor.getGrammar().name
      if language == "HTML (Rails)"
        arr = selection.split("\n")
        for cad, i in arr
          if cad.length > 0
            # comenta sin texto ruby  (no contienen <%)
            res = /^((?!<%).)*$/g.exec(cad)
            if res != null
              arr[i] = "<%#*" + arr[i] + "%>"
            else
              # descomentar html
              res = /([\s|\t]*)(<%#\*).*%>.*/g.exec(cad)
              if res != null
                arr[i] = arr[i].replace("<%#*",'')
                arr[i] = arr[i].replace("%>",'')
              else
                # Descomentar
                res = /([\s|\t]*)(<%#).*%>.*/g.exec(cad)
                if res != null
                  arr[i] = arr[i].replace("<%#",'<%')
                else
                  # comentar
                  res = /([\s|\t]*)(<%)=.*%>.*/g.exec(cad)
                  if res != null
                    arr[i] = arr[i].replace("<%",'<%#')

        editor.insertText(arr.join("\n"))
        editor.setSelectedBufferRanges(ranges)
      else
        editor = atom.workspace.getActivePane()
        editor.saveActiveItem()
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'editor:toggle-line-comments')
