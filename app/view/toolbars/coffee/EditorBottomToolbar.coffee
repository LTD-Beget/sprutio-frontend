Ext.define 'FM.view.toolbars.EditorBottomToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.editor-bottom-toolbar'
  cls: 'fm-editor-bottom-toolbar'
  items: [
    { xtype: "tbtext", cls: "fm-editor-mode" },
    "-",
    { xtype: "tbtext", cls: "fm-editor-encoding" },
    "-",
    { xtype: "tbtext", cls: "fm-editor-size" },
    "->",
    { xtype: "tbtext", cls: "fm-editor-status", text: "READ" },
    "-",
    { xtype: "tbtext", cls: "fm-editor-position", text: "1 : 0" }
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.EditorBottomToolbar')
    @callParent(arguments)