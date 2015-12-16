Ext.define 'FM.view.toolbars.FileListBottomToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.file-list-bottom-toolbar'
  cls: 'fm-file-list-bottom-toolbar'
  items: []
  requires: [
    'FM.view.toolbars.FileListStatusBar'
    'FM.view.toolbars.FileListServerBar'
    'FM.view.toolbars.FileListSizeBar'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListBottomToolbar init')

    @items = []

    @items.push
      xtype: 'file-list-status-bar'

    @items.push "->"
    @items.push
      xtype: 'file-list-server-bar'

    @items.push
      xtype: 'file-list-size-bar'

    @callParent(arguments);