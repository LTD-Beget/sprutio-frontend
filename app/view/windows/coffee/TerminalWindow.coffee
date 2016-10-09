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
  height: 600
  margin: 0
  items: [{
    id: "idTerm"
    frame: false,
    border: false,
    xtype: "component",
    autoEl: {
      id: "idTerminal",
      tag: "iframe",
      src: "https://localhost:3000",
      frameborder: 0
    }
  }]
  listeners:
    beforeshow:
      fn: () ->
        FM.Logger.debug('FM.view.windows.TerminalWindow beforeshow() called', @, arguments)

    beforeclose:
      fn: (editor_window) ->
        FM.Logger.debug('FM.view.windows.TerminalWindow beforeclose() called', @, arguments)
        return true

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.Terminal initComponent() called', arguments)
    @callParent(arguments)

  setCredentials: (host, user) ->
    pattern = ({user, host}) -> "https://localhost:3000/wetty/ssh/#{user}/#{host}"
    Ext.get('idTerm').dom.src = pattern {user, host};


  exit: () ->
    FM.Logger.debug('FM.view.windows.TerminalWindow exit() called', arguments)
    @close()
