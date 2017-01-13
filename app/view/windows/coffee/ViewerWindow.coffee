Ext.define 'FM.view.windows.ViewerWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'Ext.ux.aceeditor.Panel'
    'FM.view.toolbars.ViewerTopToolbar'
    'FM.view.toolbars.ViewerBottomToolbar'
  ]
  alias: 'widget.viewer-window'
  cls: 'fm-viewer-window'
  layout: "fit"
  constrain: true
  animate: true
  maximizable: true
  border: false
  width: 700
  height: 400
  margin: 0
  viewerMode: "text"
  tbar:
    xtype: 'viewer-top-toolbar'
  bbar:
    xtype: 'viewer-bottom-toolbar'
  initComponent: () ->
    FM.Logger.debug('FM.view.windows.ViewerWindow initComponent() called', arguments)

    @viewerMode = FM.Viewer.getMode(@fileRecord)

    editor = Ext.create "Ext.ux.aceeditor.Panel",
      sourceCode: @fileContent
      parser: @viewerMode
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

  exit: () ->
    FM.Logger.debug('FM.view.windows.ViewerWindow exit() called', arguments)
    @close()

  changeSyntax: (syntax) ->
    FM.Logger.debug('FM.view.windows.ViewerWindow changeSyntax() called', arguments)
    @viewerMode = syntax
    @updateToolbar()
    @updateSettings()

  changeEncoding: (encoding) ->
    FM.Logger.debug('FM.view.windows.ViewerWindow changeEncoding() called', arguments)

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

  initEditor: (ace_editor) ->
    FM.Logger.debug('FM.view.windows.ViewerWindow initEditor() called', arguments)
    @editor = ace_editor

    @editor.setReadOnly(true)
    @editor_mode = Ext.ComponentQuery.query('tbtext[cls=fm-viewer-mode]', @)[0]
    @editor_encoding = Ext.ComponentQuery.query('tbtext[cls=fm-viewer-encoding]', @)[0]
    @editor_size = Ext.ComponentQuery.query('tbtext[cls=fm-viewer-size]', @)[0]
    @editor_status = Ext.ComponentQuery.query('tbtext[cls=fm-viewer-status]', @)[0]
    @editor_position = Ext.ComponentQuery.query('tbtext[cls=fm-viewer-position]', @)[0]

    @editor_mode.setText(Ext.util.Format.format(t("Mode: {0}"), @viewerMode))
    @editor_encoding.setText(@fileEncoding)

    all = @fileRecord.get("size")
    loaded = @fileRecord.get("size")
    percent = (loaded / all).toFixed(2) * 100
    @editor_size.setText(Ext.util.Format.format(t("Loaded {0}% : {1} of {2} bytes"), percent, loaded, all))

    @editor.selection.on "changeCursor", () =>
      c = @editor.selection.getCursor()
      @editor_position.setText((c.row + 1) + " : " + c.column)

  updateToolbar: () ->
    FM.Logger.debug('FM.view.windows.EditorWindow updateToolbar() called', arguments)

    @editor_mode.setText(Ext.util.Format.format(t("Mode: {0}"), @viewerMode))
    @editor_encoding.setText(@fileEncoding)

    all = @fileRecord.get("size")
    loaded = @fileRecord.get("size")
    percent = (loaded / all).toFixed(2) * 100
    @editor_size.setText(Ext.util.Format.format(t("Loaded {0}% : {1} of {2} bytes"), percent, loaded, all))

    c = @editor.selection.getCursor()
    @editor_position.setText((c.row + 1) + " : " + c.column)

    syntax_menu = Ext.ComponentQuery.query('button[cls=button-menu-syntax]', @)[0].getMenu()

    syntax_menu.items.each (item) ->
      if item.text != @viewerMode
        item.setChecked(false)
      else
        item.setChecked(true)
    ,
      @

    encoding_menu = Ext.ComponentQuery.query('button[cls=button-menu-encoding]', @)[0].getMenu()

    encoding_menu.items.each (item) ->
      if item.text != @fileEncoding
        item.setChecked(false)
      else
        item.setChecked(true)
    ,
      @

  updateSettings: () ->
    FM.helpers.SetLoading(@body, t("Applying settings..."))

    if FM.Viewer.settings.print_margin_size?
      @editor.setPrintMarginColumn(FM.Viewer.settings.print_margin_size)

    if FM.Viewer.settings.font_size?
      @editor.setFontSize(FM.Viewer.settings.font_size + "px")

    if FM.Viewer.settings.tab_size?
      @editor.getSession().setTabSize(FM.Viewer.settings.tab_size)

    if FM.Viewer.settings.full_line_selection?
      @editor.setSelectionStyle(if FM.Viewer.settings.full_line_selection then "line" else "text")

    if FM.Viewer.settings.highlight_active_line?
      @editor.setHighlightActiveLine(FM.Viewer.settings.highlight_active_line)

    if FM.Viewer.settings.show_invisible?
      @editor.setShowInvisibles(FM.Viewer.settings.show_invisible)

    if FM.Viewer.settings.wrap_lines?
      @editor.getSession().setUseWrapMode(FM.Viewer.settings.wrap_lines)

    if FM.Viewer.settings.use_soft_tabs?
      @editor.getSession().setUseSoftTabs(FM.Viewer.settings.use_soft_tabs)

    if FM.Viewer.settings.show_line_numbers?
      @editor.renderer.setShowGutter(FM.Viewer.settings.show_line_numbers)

    if FM.Viewer.settings.highlight_selected_word?
      @editor.setHighlightSelectedWord(FM.Viewer.settings.highlight_selected_word)

    if FM.Viewer.settings.show_print_margin?
      @editor.renderer.setShowPrintMargin(FM.Viewer.settings.show_print_margin)

    if FM.Viewer.settings.code_folding_type?
      @editor.getSession().setFoldStyle(FM.Viewer.settings.code_folding_type)

    if FM.Viewer.settings.theme?
      @editor.setTheme("ace/theme/" + FM.Viewer.settings.theme)

    @editor.getSession().setMode("ace/mode/" + @viewerMode)
    FM.helpers.UnsetLoading(@body)