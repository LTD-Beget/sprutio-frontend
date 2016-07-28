Ext.define 'FM.view.windows.EditorWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'Ext.ux.aceeditor.Panel'
    'FM.view.toolbars.EditorTopToolbar'
    'FM.view.toolbars.EditorBottomToolbar'
  ]
  alias: 'widget.editor-window'
  cls: 'fm-editor-window'
  layout: "fit"
  constrain: true
  animate: true
  maximizable: true
  border: false
  width: 700
  height: 400
  margin: 0
  editorMode: "text"
  editorModified: false
  tbar:
    xtype: 'editor-top-toolbar'
  bbar:
    xtype: 'editor-bottom-toolbar'
  listeners:
    show:
      fn: () ->
        if @keymap?
          @keymap.destroy()

        @keymap = new Ext.util.KeyMap
          target: @getEl()
          binding: [
            {
              key: 's'
              ctrl: true
              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
                FM.Logger.debug('ctrl + s', arguments, @)
                @save()
                e.stopEvent()
            }
          ]
    beforeshow:
      fn: () ->
        FM.Logger.debug('FM.view.windows.EditorWindow beforeshow() called', @, arguments)

    beforeclose:
      fn: (editor_window) ->
        FM.Logger.debug('FM.view.windows.EditorWindow beforeclose() called', @, arguments)
        if not @editorModified
          return true

        question = Ext.create 'FM.view.windows.QuestionWindow',
          title: t("File Modified")
          msg: t("File was modified.<br/>Save changes?")
          buttonsPreset: 'YES_NO_CANCEL'
          cancel: () ->
            return false
          no: () ->
            FM.Logger.debug("no() handler")
            editor_window.editorModified = false
            editor_window.close()
            return true
          yes: () ->
            editor_window.save editor_window.fileEncoding, () ->
              editor_window.close()

        question.show()
        return false

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.EditorWindow initComponent() called', arguments)

    @editorMode = FM.Editor.getMode(@fileRecord)

    editor = Ext.create "Ext.ux.aceeditor.Panel",
      sourceCode: @fileContent
      parser: @editorMode
      listeners:
        editorcreated: (editor_panel) =>
          @initEditor(editor_panel.editor)
          @updateSettings()

    @items = [editor]
    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  save: (encoding, callback) ->
    FM.Logger.debug('FM.view.windows.EditorWindow save() called', arguments)

    FM.helpers.SetLoading(@body, t("Saving file..."))
    FM.backend.ajaxSend '/actions/files/write',
      params:
        session: @getSession()
        path: FM.helpers.GetAbsName(@getSession(), @fileRecord)
        content: @editor.getValue()
        encoding: (if encoding? then encoding else @fileEncoding)
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data

        @fileEncoding = response_data.encoding
        @fileRecord.set("size", response_data.item.size, dirty: false)

        FM.helpers.UnsetLoading(@body)
        @editorModified = false
        @editor_status.setText(t("READ"))
        @updateToolbar()

        if callback?
          callback(@)

      failure: (response) =>
        FM.helpers.UnsetLoading(@body)
        FM.helpers.ShowError(t("Error during saving file.<br/> Please contact Support."))
        FM.Logger.error(response)

  exit: () ->
    FM.Logger.debug('FM.view.windows.EditorWindow exit() called', arguments)
    @close()

  changeEncoding: (encoding) ->
    FM.Logger.debug('FM.view.windows.EditorWindow changeEncoding() called', arguments)
    @fileEncoding = encoding
    @updateToolbar()
    @updateSettings()

    FM.helpers.SetLoading(@body, t("Applying settings..."))
    FM.backend.ajaxSend '/actions/files/read',
      params:
        session: @getSession()
        path: FM.helpers.GetAbsName(@getSession(), @fileRecord)
        encoding: encoding
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        FM.helpers.UnsetLoading(@body)
        @fileContent = response_data.content
        @editor.setValue(@fileContent)
        @fileEncoding = encoding
        @updateToolbar()
        @updateSettings()

      failure: (response) =>
        FM.helpers.UnsetLoading(@body)
        json_response = Ext.util.JSON.decode(response.responseText)
        error = FM.helpers.ParseErrorMessage(json_response.message, t("Error during reading file.<br/> Please contact Support."))
        FM.helpers.ShowError(error)
        FM.Logger.error(response)

  changeSyntax: (syntax) ->
    FM.Logger.debug('FM.view.windows.EditorWindow changeSyntax() called', arguments)
    @editorMode = syntax
    @updateToolbar()
    @updateSettings()

  initEditor: (ace_editor) ->
    FM.Logger.debug('FM.view.windows.EditorWindow initEditor() called', arguments)
    @editor = ace_editor

    @editor_mode = Ext.ComponentQuery.query('tbtext[cls=fm-editor-mode]', @)[0]
    @editor_encoding = Ext.ComponentQuery.query('tbtext[cls=fm-editor-encoding]', @)[0]
    @editor_size = Ext.ComponentQuery.query('tbtext[cls=fm-editor-size]', @)[0]
    @editor_status = Ext.ComponentQuery.query('tbtext[cls=fm-editor-status]', @)[0]
    @editor_position = Ext.ComponentQuery.query('tbtext[cls=fm-editor-position]', @)[0]

    @editor_mode.setText(Ext.util.Format.format(t("Mode: {0}"), @editorMode))
    @editor_encoding.setText(@fileEncoding)
    @editor_size.setText(Ext.util.Format.format(t("Loaded {0} bytes"), @fileRecord.get("size")))

    @editor.on "change", () =>
      if not @editorModified
        @editorModified = true
        @editor_status.setText(t("MODIFIED"))

    @editor.selection.on "changeCursor", () =>
      c = @editor.selection.getCursor()
      @editor_position.setText((c.row + 1) + " : " + c.column)

  updateToolbar: () ->
    FM.Logger.debug('FM.view.windows.EditorWindow updateToolbar() called', arguments)

    @editor_mode.setText(Ext.util.Format.format(t("Mode: {0}"), @editorMode))
    @editor_encoding.setText(@fileEncoding)
    @editor_size.setText(Ext.util.Format.format(t("Loaded {0} bytes"), @fileRecord.get("size")))
    @editor_status.setText(if @editorModified then t("MODIFIED") else t("READ"))
    c = @editor.selection.getCursor()
    @editor_position.setText((c.row + 1) + " : " + c.column)

    encoding_menu = Ext.ComponentQuery.query('button[cls=button-menu-encoding]', @)[0].getMenu()
    syntax_menu = Ext.ComponentQuery.query('button[cls=button-menu-syntax]', @)[0].getMenu()

    encoding_menu.items.each (item) ->
      if item.text != @fileEncoding
        item.setChecked(false)
      else
        item.setChecked(true)
    ,
      @

    syntax_menu.items.each (item) ->
      if item.text != @editorMode
        item.setChecked(false)
      else
        item.setChecked(true)
    ,
      @

  updateSettings: () ->
    FM.helpers.SetLoading(@body, t("Applying settings..."))

    if FM.Editor.settings.print_margin_size?
      @editor.setPrintMarginColumn(FM.Editor.settings.print_margin_size)

    if FM.Editor.settings.font_size?
      @editor.setFontSize(FM.Editor.settings.font_size + "px")

    if FM.Editor.settings.tab_size?
      @editor.getSession().setTabSize(FM.Editor.settings.tab_size)

    if FM.Editor.settings.full_line_selection?
      @editor.setSelectionStyle(if FM.Editor.settings.full_line_selection then "line" else "text")

    if FM.Editor.settings.highlight_active_line?
      @editor.setHighlightActiveLine(FM.Editor.settings.highlight_active_line)

    if FM.Editor.settings.show_invisible?
      @editor.setShowInvisibles(FM.Editor.settings.show_invisible)

    if FM.Editor.settings.wrap_lines?
      @editor.getSession().setUseWrapMode(FM.Editor.settings.wrap_lines)

    if FM.Editor.settings.use_soft_tabs?
      @editor.getSession().setUseSoftTabs(FM.Editor.settings.use_soft_tabs)

    if FM.Editor.settings.show_line_numbers?
      @editor.renderer.setShowGutter(FM.Editor.settings.show_line_numbers)

    if FM.Editor.settings.highlight_selected_word?
      @editor.setHighlightSelectedWord(FM.Editor.settings.highlight_selected_word)

    if FM.Editor.settings.show_print_margin?
      @editor.renderer.setShowPrintMargin(FM.Editor.settings.show_print_margin)

    if FM.Editor.settings.code_folding_type?
      @editor.getSession().setFoldStyle(FM.Editor.settings.code_folding_type)

    if FM.Editor.settings.theme?
      @editor.setTheme("ace/theme/" + FM.Editor.settings.theme)

    @editor.getSession().setMode("ace/mode/" + @editorMode)

    if FM.Editor.settings.use_autocompletion?
      @editor.setOptions
        enableBasicAutocompletion: FM.Editor.settings.use_autocompletion
        enableSnippets: FM.Editor.settings.use_autocompletion

    if FM.Editor.settings.enable_emmet?
      @editor.setOptions
        enableEmmet: FM.Editor.settings.enable_emmet

    FM.helpers.UnsetLoading(@body)