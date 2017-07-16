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
      if ranges[0].end.column > 0 || ranges[0].start.row == ranges[0].end.row
        editor.selectLinesContainingCursors()
      selection = editor.getSelectedText()
      language = editor.getGrammar().name

      if language == "HTML (Rails)"
        arr = selection.split("\n")
        must_comment = this.commentOrDecomment(selection)
        console.log(must_comment)
        for cad, i in arr
          if must_comment
           arr[i] = this.commentRecursive(cad)
          else
           arr[i] = this.decommentRecursive(cad)
        editor.insertText(arr.join("\n"))
        editor.setSelectedBufferRanges(ranges)
      else
        editor = atom.workspace.getActivePane()
        editor.saveActiveItem()
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'editor:toggle-line-comments')

  commentRecursive: (cad,i=0) ->
    if i > 5 #limite bucle infinito
      throw "limite de interaciones"

    if cad.length > 0
      res = /(.*)(<%=*[^%]*%>)(.*)/g.exec(cad)
      if res != null
        if res[0]!=res[2]
          cad1 = this.commentRecursive(res[1],i+1)
          cad2 = this.commentRecursive(res[2],i+1)
          cad3 = this.commentRecursive(res[3],i+1)
          cad = cad1 + cad2 + cad3
        else #solo un erb
          cad = cad.replace('<%','<%#')
      else
        res = /^(\s|\t)+$/g.exec(cad)
        if res == null
          cad = '<%#*' + cad + '%>'
    cad

  decommentRecursive: (cad,i=0) ->
    if i > 5 #limite bucle infinito
      throw "limite de interaciones"

    if cad.length > 0
      res = /(.*)(<%=*[^%]*%>)(.*)/g.exec(cad)
      if res != null
        if res[0]!=res[2]
          cad1 = this.decommentRecursive(res[1],i+1)
          cad2 = this.decommentRecursive(res[2],i+1)
          cad3 = this.decommentRecursive(res[3],i+1)
          cad = cad1 + cad2 + cad3
        else #solo un erb
          res = /<%#\*/g.exec(cad)
          if res != null
            cad = cad.replace('<%#*','')
            cad = cad.replace('%>','')
          else
            cad = cad.replace('<%#','<%')
    cad


  commentOrDecomment: (selection,i=0) ->
    res = false
    arr = selection.split("\n")
    arr.pop() # Elimino la linean blanco del final
    for cad, i in arr
      if  /^(\s|\t)*$/g.exec(cad) == null
        if this.commentOrDecommentRecursive(cad)
          return true
    return false

  commentOrDecommentRecursive: (cad,i=0) ->
    if i > 5 #limite bucle infinito
      throw "limite de interaciones"
    # console.log("|" + cad + "|" )
    if cad.length > 0
      res = /(.*)(<%=*[^%]*%>)(.*)/g.exec(cad)
      if res != null
        if res[0]!=res[2]
          # console.log('descompone')
          if res[1].length > 0
            # console.log("res 1 " + res[1])
            if this.commentOrDecommentRecursive(res[1],i+1)
              return true
          if res[2].length > 0
            # console.log("res 3 " + res[2])
            if this.commentOrDecommentRecursive(res[2],i+1)
              return true
          if res[3].length > 0
            # console.log("res 2 " + res[3])
            if this.commentOrDecommentRecursive(res[3],i+1)
              return true
        else #solo un erb
          # console.log('solo erb')
          if /<%[^#]/g.exec(cad)==null
            # console.log('con comentario')
            return false
          else
            # console.log('sin comentar')
            return true

      else
        console.log('solo no erb')
        res = /^(\s|\t)+$/g.exec(cad)
        if res != null
          return false
        else
          return true
    else #si es linea vacia
      console.log('linea vacia')
      return true

  # commentLine: (cad) ->
  #   if cad.length > 0
  #     # comenta sin texto ruby  (no contienen <%)
  #     res = /^((?!<%).)*$/g.exec(cad)
  #     if res != null
  #       cad = "<%#*" + cad + "%>"
  #     else
  #       # descomentar html
  #       res = /([\s|\t]*)(<%#\*).*%>.*/g.exec(cad)
  #       if res != null
  #         cad = cad.replace('<%#*','')
  #         cad = cad.replace('%>','')
  #       else
  #         # Descomentar
  #         res = /([\s|\t]*)(<%#).*%>.*/g.exec(cad)
  #         if res != null
  #           cad = cad.replace('<%#','<%')
  #         else
  #           # comentar
  #           res = /([\s|\t]*)(<%)=*.*%>.*/g.exec(cad)
  #           if res != null
  #             cad = cad.replace('<%','<%#')
  #             #res = /(.*%>)(.*)(<%.*)/g.exec(cad)
  #             #if res != null
  #             #  if res[2].length > 0
  #             #  cad = res[1] + '<%#*' + res[2] + '%>' + res[3]
  #   cad
