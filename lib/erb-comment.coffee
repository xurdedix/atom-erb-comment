{CompositeDisposable} = require 'atom'

module.exports = ErbComment =

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'erb-comment:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    if editor = atom.workspace.getActiveTextEditor()
      ranges = editor.getSelectedBufferRanges()
      if ranges[0].end.column > 0 || ranges[0].start.row == ranges[0].end.row
        editor.selectLinesContainingCursors()
      selection = editor.getSelectedText()
      language = editor.getGrammar().name

      if ['HTML (Ruby - ERB)',"HTML (Rails)","JavaScript (Rails)"].includes? language
        text = this.processCommentOrDecomment(selection)
        editor.insertText(text)
        editor.setSelectedBufferRanges(ranges)
      else
        editor = atom.workspace.getActivePane()
        editor.saveActiveItem()
        editorElement = atom.views.getView(atom.workspace.getActiveTextEditor())
        atom.commands.dispatch(editorElement, 'editor:toggle-line-comments')

  processCommentOrDecomment: (selection) ->
    res = this.exclude_character(selection)
    selection   = res.selection
    replace_cad = res.replace_cad

    if this.commentOrDecomment(selection)
       text = this.comment(selection)
    else
       text = this.decomment(selection)

    this.revert_exclude_character(text,replace_cad)

  exclude_character: (selection) ->
    replace_cad = '@@@@'
    regex = new RegExp(replace_cad,"g");
    res = regex.exec(selection)
    while res != null
      replace_cad += "@"
      regex = new RegExp(replace_cad,"g");
      res = regex.exec(selection)

    arr = selection.split("\n")
    for cad, i in arr
      cad_process = cad.replace(/<%/g,'').replace(/%>/g,'')
      if cad_process.replace('%','') != cad_process
        arr[i]= cad.replace(/(.*[^>])(%)([^>].*)/,'$1' + replace_cad + '$3')

    selection = arr.join("\n")


    return {
      selection: selection,
      replace_cad: replace_cad
      }

  revert_exclude_character: (selection,replace_cad) ->
    selection.replace(replace_cad,'%')

  comment: (selection) ->
    arr = selection.split("\n")
    for cad, i in arr
      arr[i] = this.commentRecursive(cad)
    arr.join("\n")

  decomment: (selection) ->
    arr = selection.split("\n")
    for cad, i in arr
      arr[i] = this.decommentRecursive(cad)
    arr.join("\n")

  commentRecursive: (cad,i=0) ->
    if i > 20 #limite bucle infinito
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
    if i > 20 #limite bucle infinito
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
    # arr.pop() # Elimino la linean blanco del final
    for cad, i in arr
      if  /^(\s|\t)*$/g.exec(cad) == null
        if this.commentOrDecommentRecursive(cad)
          return true
    return false

  commentOrDecommentRecursive: (cad,i=0) ->
    if i > 20 #limite bucle infinito
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
        # console.log('solo no erb')
        res = /^(\s|\t)+$/g.exec(cad)
        if res != null
          return false
        else
          return true
    else #si es linea vacia
      # console.log('linea vacia')
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
