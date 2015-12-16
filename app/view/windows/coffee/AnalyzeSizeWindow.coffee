Ext.define 'FM.view.windows.AnalyzeSizeWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.grids.FileSizeList'
    'FM.view.charts.FileSizeChart'
  ]
  alias: 'widget.analyze-size-window'
  cls: 'fm-analyze-size-window'
  title: t("Folder Size")
  animate: true
  constrain: true
  layout:
    type: 'vbox'
    align: 'stretch'
    pack: 'start'
  bodyPadding: '0 0 20 0'
  width: 600
  height: 600
  resizable:
    handles: 's n'
    minHeight: 300
    maxHeight: 900
    pinned: true
  maximizable: true
  modal: false
  border: false
  session: null
  path: null
  operationStatus: null
  items: [
    {
      xtype: 'file-size-chart'
    },
    {
      xtype: 'file-size-list'
    }
  ]
  initComponent: () ->
    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  setPath: (path) ->
    @path = path

  getPath: () ->
    return @path

  hasPath: () ->
    return if @path? then true else false

  setOperationStatus: (status) ->
    @operationStatus = status

  hasOperationStatus: () ->
    return if @operationStatus? then true else false

  getOperationStatus: () ->
    return @operationStatus