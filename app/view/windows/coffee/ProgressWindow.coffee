Ext.define 'FM.view.windows.ProgressWindow',
  extend: 'Ext.window.Window'
  alias: 'widget.progress-window'
  cls: 'fm-progress-window'
  layout:
    type: 'vbox'
    align: 'center'
  maxWidth: 400
  resizable: false
  title: t("Process")
  waitConfig:
    interval: 200
    animate: true
    text: ''
  cancelable: false
  cancelled: false
  session: null
  target_session: null
  operationStatus: null
  initComponent: (config) ->
    FM.Logger.log('FM.view.windows.ProgressWindow init')

    @items = []

    @progressbar = Ext.create 'Ext.ProgressBar',
      width: 300
      height: 18
      border: 1
      animate: @waitConfig.animate
      interval: @waitConfig.interval
      text: @waitConfig.text
      style:
        borderStyle: 'solid'
        borderColor: '#19639f #d0d4d6 #d0d4d6 #19639f'
      margin: '0 10 10 10'

    @progressbar.wait(@waitConfig)

    if @msg?
      @items.push
        xtype: 'container'
        margin: 0
        padding: '0 15'
        layout:
          type: 'vbox'
          align: 'center'
        items: [
          {
            xtype: 'displayfield'
            fieldLabel: @msg
            labelSeparator: ''
            labelStyle: 'text-align: center; padding-bottom: 10px;'
            labelWidth: 'auto'
            margin: '10 0 0 0'
          },
          @progressbar
        ]

    if @cancelable
      bottomTb = new Ext.toolbar.Toolbar
        ui: 'footer'
        dock: 'bottom'
        layout:
          pack: 'center'
        padding: '0 8 10 16'
        items: [
          {
            handler: () =>
              @cancelled = true
              if @cancel?
                @cancel(@, @session, @operationStatus)
              else
                @close()
            scope: @
            text: t("Cancel")
            minWidth: 75
          }
        ]

      @dockedItems = [bottomTb]
    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  setTargetSession: (session) ->
    @target_session = session

  getTargetSession: () ->
    return @target_session

  hasTargetSession: () ->
    return if @target_session? then true else false

  setOperationStatus: (status) ->
    @operationStatus = status

  hasOperationStatus: () ->
    return if @operationStatus? then true else false

  getOperationStatus: () ->
    return @operationStatus

  updateProgressText: (msg) ->
    FM.Logger.info(msg, @progressbar)
    @progressbar.updateText(t(msg))
    FM.Logger.info('updated', msg, @progressbar)

  updateProgress: (percent, label, animation = true) ->
    FM.Logger.info("updateProgress() ", arguments, animation)

    # really stop animation
    if @progressbar.isWaiting()
      @progressbar.reset()

    @progressbar.updateProgress(percent, t(label), animation)