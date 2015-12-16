Ext.define 'FM.view.toolbars.FileListServerBar',
  extend: 'Ext.toolbar.TextItem'
  alias: 'widget.file-list-server-bar'
  cls: 'fm-serverbar'
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListServerBar init')
    @callParent(arguments);