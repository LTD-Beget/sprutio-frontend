Ext.define 'FM.view.toolbars.FileListSizeBar',
  extend: 'Ext.ProgressBar'
  alias: 'widget.file-list-size-bar'
  width: 300
  height: 18
  border: 1
  style:
    borderStyle: 'solid'
    borderColor: '#19639f #d0d4d6 #d0d4d6 #19639f'
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListSizeBar init')
    @callParent(arguments);