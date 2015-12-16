Ext.define 'FM.view.toolbars.FileListPathBar',
  extend: 'Ext.toolbar.TextItem'
  alias: 'widget.file-list-path-bar'
  cls: 'fm-pathbar'
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListPathBar init')
    @callParent(arguments);