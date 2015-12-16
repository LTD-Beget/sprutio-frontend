Ext.define 'FM.view.toolbars.FileListStatusBar',
  extend: 'Ext.toolbar.TextItem'
  alias: 'widget.file-list-status-bar'
  cls: 'fm-serverbar'
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.FileListStatusBar init')

    @text = t("Loading...")
    @callParent(arguments);