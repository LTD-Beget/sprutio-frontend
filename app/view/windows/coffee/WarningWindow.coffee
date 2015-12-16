Ext.define 'FM.view.windows.WarningWindow',
  extend: 'Ext.window.Window'
  alias: 'widget.warning-window'
  cls: 'fm-warning-window'
  layout:
    type: 'vbox'
    align: 'center'
  maxWidth: 400
  title: t('Warning')
  resizable: false
  buttonsPreset: 'OK'
  msgWidth: 260
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
              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
                for button in @preset
                  if button.enter? and button.enter
                    if button.handler?
                      button.handler()
                e.stopEvent()
            }
          ]

  initComponent: (config) ->
    FM.Logger.log('FM.view.windows.WarningWindow init')

    @items = []

    buttons = {}
    buttons.YES_NO = [
        {
          handler: () =>
            @close()
            if @yes?
              @yes()
          scope: @
          text: t("Yes")
          minWidth: 75
          enter: true
        },
        {
          handler: () =>
            @close()
            if @no?
              @no()
          scope: @
          text: t("No")
          minWidth: 75
        }
      ]

    buttons.OK = [
        {
          handler: () =>
            @close()
            if @ok?
              @ok()
          scope: @
          text: t("OK")
          minWidth: 75
          enter: true
        }
      ]

    buttons.YES_NO_CANCEL = [
        {
          handler: () =>
            @close()
            if @yes?
              @yes()
          scope: @
          text: t("Yes")
          minWidth: 75
          enter: true
        },
        {
          handler: () =>
            @close()
            if @no?
              @no()
          scope: @
          text: t("No")
          minWidth: 75
        },
        {
          handler: () =>
            @close()
            if @cancel?
              @cancel()
          scope: @
          text: t("Cancel")
          minWidth: 75
        }
      ]

    @preset = buttons[@buttonsPreset]

    @items.push
      xtype: 'container'
      cls: 'fm-msg-warning'
      height: 42
      width: 42
      margin: '15 0 10 0'

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
            labelWidth: @msgWidth
          }
        ]

    bottomTb = new Ext.toolbar.Toolbar
      ui: 'footer'
      dock: 'bottom'
      layout:
        pack: 'center'
      padding: '0 8 10 16'
      items: @preset

    @dockedItems = [bottomTb]
    @callParent(arguments)