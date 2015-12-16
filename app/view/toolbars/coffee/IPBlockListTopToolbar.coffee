Ext.define 'FM.view.toolbars.IPBlockListTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.ip-block-list-top-toolbar'
  cls: 'fm-ip-block-list-top-toolbar'
  items: []
  height: 40
  layout:
    type: "hbox"
  defaults:
    margin: 0
  initComponent: () ->

    FM.Logger.log('FM.view.toolbars.IPBlockListTopToolbar')

    @items = []

    @items.push
      text: t("Edit")
      cls: "fm-ip-edit"
      iconCls: "fm-icon-edit"
      disabled: true
      handler: (button) ->
        FM.Logger.debug("IP Edit handler called!", arguments, button.ownerCt.ownerCt)

        grid = button.ownerCt.ownerCt
        plugin = grid.getPlugin()

        if plugin.editing
          return false

        row = grid.getSelectionModel().getSelection()

        if row.length == 0
          return

        plugin.editor.floatingButtons.items.get(0).setText(t("Update"))
        plugin.editor.floatingButtons.items.get(1).setText(t("Cancel"))

        ip_rule = row[0]
        plugin.startEdit(ip_rule, 0)

    @items.push
      text: t("Add IP")
      cls: "fm-ip-add"
      iconCls: "fm-icon-add"
      handler: (button) ->
        FM.Logger.debug("IP Add handler called!", arguments, button.ownerCt.ownerCt)

        plugin = button.ownerCt.ownerCt.getPlugin()

        if plugin.editing
          return false

        plugin.editor.floatingButtons.items.get(0).setText(t("Save"))
        plugin.editor.floatingButtons.items.get(1).setText(t("Cancel"))

        plugin.startAdd
          ip: "0.0.0.0"

    @items.push
      text: t("Remove IP")
      cls: "fm-ip-remove"
      iconCls: "fm-icon-remove"
      disabled: true
      handler: (button) ->
        FM.Logger.debug("IP Delete handler called!", arguments)

        grid = button.ownerCt.ownerCt

        grid.getPlugin().cancelEdit()
        grid.getStore().remove(grid.getSelectionModel().getSelection())

    @callParent(arguments)