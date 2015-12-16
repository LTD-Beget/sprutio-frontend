Ext.define 'FM.view.windows.PromtWindow',
  extend: 'Ext.window.Window'
  requires: [
    'Ext.form.field.Text'
  ]
  alias: 'widget.promt-window'
  cls: 'fm-promt-window'
  layout:
    type: 'vbox'
    align: 'center'
  width: 300
  resizable: false
  buttonsPreset: 'OK_CANCEL'
  fieldValue: ''
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
    FM.Logger.log('FM.view.windows.PromtWindow init')

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

    cancel = Ext.create 'Ext.button.Button',
        handler: () =>
          if @cancel?
            @cancel(@)
          else
            @close()
        scope: @
        text: t("Cancel")
        minWidth: 75

    buttons.OK_CANCEL = [ok, cancel]
    buttons.OK = [ok]

    @preset = buttons[@buttonsPreset]

    @textField = Ext.create 'Ext.form.field.Text',
      width: 265
      margin: '-6 0 1 0'
      value: @fieldValue
      listeners:
        afterrender: (field) ->
          Ext.defer () ->
            field.focus(true, 100)
          ,
            1



    @items.push
      xtype: 'container'
      margin: 0
      padding: '10 15 15 15'
      layout:
        type: 'vbox'
        align: 'center'
        anchor: '100%'
      items: [
        {
          xtype: 'displayfield'
          fieldLabel: @msg
          labelSeparator: ''
          labelStyle: 'text-align: left; padding-left: 3px;'
          labelWidth: 260
        },
        @textField
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