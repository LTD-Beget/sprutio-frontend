Ext.define 'FM.view.windows.ImageViewer',
  extend: 'Ext.ux.window.Window'
  requires: [
    'ImageViewer'
  ]
  alias: 'widget.image-viewer'
  title: t("Image Viewer")
  cls: 'fm-image-viewer-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: '0 0 20 0'
  width: 400
  height: 300
  resizable:
    minHeight: 300
    maxHeight: 900
    pinned: true
  maximizable: true
  modal: false
  border: false
  first: false
  listeners:
    resize:
      fn: () ->
        # Bug ExtJS 5.1 Layout run failed
        setTimeout () =>
          FM.Logger.debug('FM.view.windows.ImageViewer resize() event called', arguments)
          @viewer.stretchOptimally()
        ,
          200

    show:
      fn: () ->
        FM.Logger.debug('FM.view.windows.ImageViewer show() event called', arguments)

        if @keymap?
          @keymap.destroy()

        @keymap = new Ext.util.KeyMap
          target: @getEl()
          binding: [
#           TODO
#            {
#              key: Ext.event.Event.ENTER
#              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
#                for button in @preset
#                  if button.enter? and button.enter
#                    if button.handler?
#                      button.handler()
#                e.stopEvent()
#            }
          ]

        image = @viewer.query('image')[0]
        win = @

        image.el.dom.onload = () ->
          if win.first == false

            FM.Logger.debug("Image DOM ", image, ' w x h', image.el.dom.naturalWidth, image.el.dom.naturalHeight)

            w = image.el.dom.naturalWidth;
            h = image.el.dom.naturalHeight;

            current_width = win.image_min_width

            # First adjust width by image
            if w >= win.image_min_width and w <= win.image_max_width
              current_width = w
            else if w >= win.image_max_width
              current_width = win.image_max_width
            else
              # for small images
              current_width = w

            # Adjust height proportionally
            current_height = current_width * h / w

            # Adjust window size for toolbars
            w2 = current_width + 12
            h2 = current_height + 60

            # Adjust window size for trashholds sizes like 1x1000, 32x32 etc.
            w2 = if w2 < 200 then 200 else w2
            h2 = if h2 < 200 then 200 else h2

            win.setWidth(w2);
            win.setHeight(h2);

            FM.Logger.debug("Adjusted size w2 x h2 ", w2, h2, " window size w x h ", win.getWidth(), win.getHeight())

            # Adjust Viewer object
            viewer = win.viewer

            viewer.setRotation(0)
            viewer.rotateImage()
            viewer.setOriginalImageWidth(image.el.dom.width)
            viewer.setOriginalImageHeight(image.el.dom.height)
            viewer.setImageWidth(image.el.dom.width)
            viewer.setImageHeight(image.el.dom.height)
            viewer.stretchOptimally()

            win.center()
            win.first = true

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.ImageViewer initComponent() called', arguments)

    @image_min_width = 400
    @image_min_height = 300

    @image_max_width = 800
    @image_max_height = 600

    index = 0
    images_src = []

    for image, i in @imageRecords
      if @imageCurrent.get('src') == image.get('src')
        index = i
      images_src.push(image.get('src'))

    @viewer = Ext.create 'ImageViewer',
      itemId: 'imageviwer'
      src: @imageCurrent.get('src')
      current_index: index
      images: images_src

    @items = [@viewer]
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

  updateSettings: () ->
    FM.helpers.SetLoading(@body, t("Applying settings..."))
    @editor.setPrintMarginColumn(FM.Viewer.settings.print_margin_size)
    @editor.setFontSize(FM.Viewer.settings.font_size + "px")
    @editor.getSession().setTabSize(FM.Viewer.settings.tab_size)

    @editor.setSelectionStyle(if FM.Viewer.settings.full_line_selection then "line" else "text")
    @editor.setHighlightActiveLine(FM.Viewer.settings.highlight_active_line)
    @editor.setShowInvisibles(FM.Viewer.settings.show_invisible)
    @editor.getSession().setUseWrapMode(FM.Viewer.settings.wrap_lines)
    @editor.getSession().setUseSoftTabs(FM.Viewer.settings.use_soft_tabs)
    @editor.renderer.setShowGutter(FM.Viewer.settings.show_line_numbers)
    @editor.setHighlightSelectedWord(FM.Viewer.settings.highlight_selected_word)
    @editor.renderer.setShowPrintMargin(FM.Viewer.settings.show_print_margin)

    @editor.getSession().setFoldStyle(FM.Viewer.settings.code_folding_type)
    @editor.setTheme("ace/theme/" + FM.Viewer.settings.theme)
    @editor.getSession().setMode("ace/mode/" + @viewerMode)
    FM.helpers.UnsetLoading(@body)