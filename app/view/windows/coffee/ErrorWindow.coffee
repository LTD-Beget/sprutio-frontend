Ext.define 'FM.view.windows.ErrorWindow',
  extend: 'Ext.window.Window'
  alias: 'widget.error-window'
  cls: 'fm-error-window'
  layout:
    type: 'vbox'
    align: 'center'
  width: 300
  resizable: false
  title: t('Error')
  buttonsPreset: 'OK'
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
                  if button.enter? and button.enter and not button.isDisabled()
                    if button.handler?
                      button.handler(button)
                e.stopEvent()
            }
          ]
  initComponent: (config) ->
    FM.Logger.log('FM.view.windows.ErrorWindow init')

    @items = []

    buttons = {}

    ok = Ext.create 'Ext.button.Button',
        handler: (button, e) =>
          if @ok?
            @ok(button, @, @textField, e)
          else
            @close()
        scope: @
        text: t("OK")
        minWidth: 75
        enter: true

    buttons.OK = [ok]

    @preset = buttons[@buttonsPreset]

    @items.push
      xtype: 'container'
      cls: 'fm-msg-error'
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
            labelWidth: 260
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