Ext.define 'FM.view.windows.IPBlockWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.forms.IPBlockForm'
  ]
  alias: 'widget.ip-block-window'
  title: t("IP block")
  cls: 'fm-ip-block-window'
  animate: true
  constrain: true
  bodyPadding: '10 0 0 0'
  layout: 'fit'
  width: 600
  height: 605
  resizable: true
  maximizable: true
  modal: false
  border: false
  items: [
    {
      xtype: 'ip-block-form'
    }
  ]
  listeners:
    show:
      fn: () ->
        if @keymap?
          @keymap.destroy()

        @keymap = new Ext.util.KeyMap
          target: @getEl()
          binding: [
            {
              key: Ext.event.Event.ENTER
              ctrl: true
              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
                FM.Logger.debug('ctrl + enter', arguments, @)
                for button in @preset
                  if button.enter? and button.enter and button.ctrl? and button.ctrl and not button.isDisabled()
                    if button.handler?
                      button.handler(button, e)
                e.stopEvent()
            }
          ]
    resize:
      fn: () ->
        FM.Logger.debug("IPBlockWindow resize()", arguments)
        grids = Ext.ComponentQuery.query('ip-block-list', @)

        h = @getHeight()

        for grid in grids
          grid.setHeight((h-306) / 2)

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.IPBlockWindow initComponent() called', arguments)

    @save_btn = Ext.create 'Ext.button.Button',
      text: t("Save")
      cls: 'fm-button-ip-block-save'
      disabled: false
      scope: @
      ctrl: true
      enter: true
      handler: (button, e) =>
        FM.Logger.debug("IP Block save handler called()", arguments, @)
        if @save?

          allow_all = if Ext.ComponentQuery.query('checkbox[name=allow-all]', @)[0].checked then true else false
          deny_all = if Ext.ComponentQuery.query('checkbox[name=deny-all]', @)[0].checked then true else false

          order_value = Ext.ComponentQuery.query('combobox[name=rule-process]', @)[0].getValue()

          if order_value == 'allow-deny'
            order = 'Allow,Deny'
          else if order_value == 'deny-allow'
            order = 'Deny,Allow'

          allowed = []
          denied = []

          allowed_grid = Ext.ComponentQuery.query('ip-block-list[name=ip-allowed-list]', @)[0]
          denied_grid = Ext.ComponentQuery.query('ip-block-list[name=ip-denied-list]', @)[0]

          allowed_grid.getStore().getData().each (record) ->
            allowed.push
              ip: record.get('ip')
              comment: record.get('comment')

          denied_grid.getStore().getData().each (record) ->
            denied.push
              ip: record.get('ip')
              comment: record.get('comment')

          @save button, @, e,
            allow_all: allow_all
            deny_all: deny_all
            order: order
            denied: denied
            allowed: allowed

    @close_btn = Ext.create 'Ext.button.Button',
      scope: @
      cls: 'fm-button-ip-block-close'
      text: t("Close")
      handler: () =>
        FM.Logger.debug("IP Block close handler called()", arguments, @)
        @close()

    @buttons = [@save_btn, @close_btn]
    @preset = [@save_btn, @close_btn] # <-- WTF @buttons is null after init, so will use @preset

    FM.Logger.debug('FM.view.windows.IPBlockWindow init done', @, @buttons, @preset)
    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  setRules: (rules) ->
    FM.Logger.debug("FIPBlockWindow setRules() called", arguments)

    Ext.ComponentQuery.query('checkbox[name=allow-all]', @)[0].setValue(rules.allow_all)
    Ext.ComponentQuery.query('checkbox[name=deny-all]', @)[0].setValue(rules.deny_all)

    if rules.order == 'Allow,Deny'
      Ext.ComponentQuery.query('combobox[name=rule-process]', @)[0].setValue('allow-deny')
    else if rules.order == 'Deny,Allow'
      Ext.ComponentQuery.query('combobox[name=rule-process]', @)[0].setValue('deny-allow')

    allowed_grid = Ext.ComponentQuery.query('ip-block-list[name=ip-allowed-list]', @)[0]
    denied_grid = Ext.ComponentQuery.query('ip-block-list[name=ip-denied-list]', @)[0]

    allowed_grid.getStore().loadData(rules.allowed)
    denied_grid.getStore().loadData(rules.denied)