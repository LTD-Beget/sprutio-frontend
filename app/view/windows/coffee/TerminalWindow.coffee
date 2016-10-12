Ext.define 'FM.view.windows.TerminalWindow',
  extend: 'Ext.ux.window.Window'
  alias: 'widget.terminal-window'
  cls: 'fm-terminal-window'
  layout: "fit"
  constrain: true
  animate: true
  maximizable: true
  border: false
  width: 700
  height: 500
  margin: 0
  listeners:
    beforeshow:
      fn: () ->
        FM.Logger.debug('FM.view.windows.TerminalWindow beforeshow() called', @, arguments)

    beforeclose:
      fn: (editor_window) ->
        FM.Logger.debug('FM.view.windows.TerminalWindow beforeclose() called', @, arguments)
        return true

  initComponent: () ->
    FM.Logger.log('FM.view.windows.Terminal initComponent() called', arguments)
    @items = []

    @items.push
      frame: false,
      border: false,
      xtype: "component",
      autoEl: {
        tag: "iframe",
        src: @address,
        frameborder: 0
      }
    @callParent(arguments)

  exit: () ->
    FM.Logger.debug('FM.view.windows.TerminalWindow exit() called', arguments)
    @close()
