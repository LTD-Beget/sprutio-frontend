Ext.define 'FM.view.windows.InfoWindow',
  extend: 'Ext.window.Window'
  alias: 'widget.info-window'
  cls: 'fm-info-window'
  layout:
    type: 'vbox'
    align: 'center'
  width: 300
  resizable: false
  initComponent: (config) ->
    FM.Logger.log('FM.view.windows.InfoWindow init')

    @items = []

    @items.push
      xtype: 'container'
      cls: 'fm-msg-info'
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
      items: [
        {
          handler: () =>
            @close()
            if @btnCallback?
              @btnCallback()
          scope: @
          text: t("OK")
          minWidth: 75
        }
      ]

    @dockedItems = [bottomTb]
    @callParent(arguments)