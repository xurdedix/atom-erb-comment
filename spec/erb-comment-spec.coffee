ErbComment = require '../lib/erb-comment'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ErbComment", ->
  describe "when a one line with several ruby", ->
    it "comment and decoment line ", ->
      text   = "<%= content_tag :h1, 'title', :class=>'red' %><% var = '' %>"
      result = "<%#= content_tag :h1, 'title', :class=>'red' %><%# var = '' %>"

      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)


  describe "when a one line with ruby like <%= %>", ->
    it "comment and decoment line ", ->
      text   = "<%= content_tag :h1, 'title', :class=>'red' %>"
      result = "<%#= content_tag :h1, 'title', :class=>'red' %>"
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)

  describe "when a one line with ruby like <% %>", ->
    it "comment and decoment line ", ->
      text   = "<% var = '' %>"
      result = "<%# var = '' %>"
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)


  describe "when a one line with html is comment", ->
    it "comment line", ->
      text   = "<br>"
      result = "<%#*<br>%>"
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)

  describe "when a one line with html and ruby is comment", ->
    it "comment line", ->
      text   = "<img src='<%= img.src %>' class='<%= myclass %>'>"
      result = "<%#*<img src='%><%#= img.src %><%#*' class='%><%#= myclass %><%#*'>%>"
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)

  describe "when multiline with html and ruby is comment", ->
    it "comment line", ->
      text   = "\n\
      <% var = '' %>\n\
      <%= content_tag :h1, 'title', :class=>'red' %><% var = '' %>\n\
         <br>\n\
      <img src='<%= img.src %>' class='<%= myclass %>'>\n\
      "
      result = "\n\
      <%# var = '' %>\n\
      <%#= content_tag :h1, 'title', :class=>'red' %><%# var = '' %>\n\
         <%#*<br>%>\n\
      <%#*<img src='%><%#= img.src %><%#*' class='%><%#= myclass %><%#*'>%>\n\
      "
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)

  describe "when multiline with html and ruby and With some previous comments", ->
    it "comment line", ->
      text   = "\n\
      <% var = '' %>\n\
      <%= content_tag :h1, 'title', :class=>'red' %><% var = '' %>\n\
         <%#*<br>%>\n\
      <img src='<%= img.src %>' class='<%= myclass %>'>\n\
      "
      result = "\n\
      <%# var = '' %>\n\
      <%#= content_tag :h1, 'title', :class=>'red' %><%# var = '' %>\n\
         <%##*<br>%>\n\
      <%#*<img src='%><%#= img.src %><%#*' class='%><%#= myclass %><%#*'>%>\n\
      "
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)

  describe "when multiline with html and ruby is comment with % character", ->
    it "comment line", ->
      text   = "\n\
      <% var = '' %>\n\
      <%= content_tag :h1, 'title', :style=>\"width: 100%\" %>\n
      <%= content_tag :h1, 'title', :class=>'red' %><% var = '' %>\n\
         <br>\n\
      <img src='<%= img.src %>' class='<%= myclass %>'>\n\
      "
      result = "\n\
      <%# var = '' %>\n\
      <%#= content_tag :h1, 'title', :style=>\"width: 100%\" %>\n
      <%#= content_tag :h1, 'title', :class=>'red' %><%# var = '' %>\n\
         <%#*<br>%>\n\
      <%#*<img src='%><%#= img.src %><%#*' class='%><%#= myclass %><%#*'>%>\n\
      "
      expect(ErbComment.processCommentOrDecomment(text)).toBe(result)
      expect(ErbComment.processCommentOrDecomment(result)).toBe(text)
