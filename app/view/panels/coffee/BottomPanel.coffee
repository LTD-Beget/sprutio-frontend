Ext.define 'FM.view.panels.BottomPanel',
  extend: 'Ext.panel.Panel'
  alias: 'widget.bottom-panel'
  region: "south"
  id: "fm-hotkeys"
  layout:
    type: "hbox"
    align: "middle"
  defaults:
    flex: 1
    margin: 0
  items: []
  tbar:
    cls: 'fm-windows-toolbar'
    layout:
      type: 'hbox'
      align: 'left'
    defaults:
      margin: 0
    items: []
  initComponent: () ->
    FM.Logger.log('FM.view.panels.BottomPanel')

    @items = [
      Ext.create "Ext.button.Button",
        id: "hot-button-view"
        text: FM.Actions.View.getButtonText()
        handler: () ->
          record = FM.helpers.GetLastSelected(FM.Active)
          FM.Actions.View.execute(FM.Active, record)

      Ext.create "Ext.button.Button",
        id: "hot-button-edit"
        text: FM.Actions.Edit.getText() + ' [ Ctrl + 4 ]'
        handler: () ->
          record = FM.helpers.GetLastSelected(FM.Active)
          FM.Actions.Edit.execute(FM.Active, record)

      Ext.create "Ext.button.Button",
        id: "hot-button-copy"
        text: FM.Actions.Copy.getText() + ' [ Ctrl + 5 ]'
        handler: () ->
          records = FM.helpers.GetSelected(FM.Active)
          FM.Actions.Copy.execute(FM.Active, FM.helpers.NextPanel(FM.Active), FM.helpers.NextPanel(FM.Active).session.path, records)

      Ext.create "Ext.button.Button",
        id: "hot-button-move"
        text: FM.Actions.Move.getText() + ' [ Shift + 5 ]'
        handler: () ->
          records = FM.helpers.GetSelected(FM.Active)
          FM.Actions.Move.execute(FM.Active, FM.helpers.NextPanel(FM.Active), records)

      Ext.create "Ext.button.Button",
        id: "hot-button-rename"
        text: FM.Actions.Rename.getText() + ' [ Ctrl + 6 ]'
        handler: () ->
          record = FM.helpers.GetLastSelected(FM.Active)
          FM.Actions.Rename.execute(FM.Active, record)

      Ext.create "Ext.button.Button",
        id: "hot-button-mkdir"
        text: FM.Actions.NewFolder.getText() + ' [ Ctrl + 7 ]'
        handler: () ->
          FM.Actions.NewFolder.execute(FM.Active)

      Ext.create "Ext.button.Button",
        id: "hot-button-remove"
        text: FM.Actions.Remove.getText() + ' [ Ctrl + 8 ]'
        handler: () ->
          records = FM.helpers.GetSelected(FM.Active)
          if records.length == 0
            return
          else
            FM.Actions.Remove.execute(FM.Active, FM.helpers.GetAbsNames(FM.Active.session, records))
      
      Ext.create "Ext.button.Button",
        id: "hot-button-terminal"
        text: FM.Actions.Terminal.getText() + ' [Ctrl + 9]'
        handler: () ->
          FM.Actions.Terminal.execute(FM.Active)
    ]

    this.callParent(arguments)

  updateState: (panel, files) ->

    view_button = Ext.ComponentQuery.query("#hot-button-view", @)[0]
    edit_button = Ext.ComponentQuery.query("#hot-button-edit", @)[0]
    copy_button = Ext.ComponentQuery.query("#hot-button-copy", @)[0]
    move_button = Ext.ComponentQuery.query("#hot-button-move", @)[0]
    rename_button = Ext.ComponentQuery.query("#hot-button-rename", @)[0]
    mkdir_button = Ext.ComponentQuery.query("#hot-button-mkdir", @)[0]
    remove_button = Ext.ComponentQuery.query("#hot-button-remove", @)[0]
    terminal_button = Ext.ComponentQuery.query("#hot-button-terminal", @)[0]

    if FM.helpers.isAllowed(FM.Actions.View, panel, files)
      view_button.setDisabled(false)
    else
      view_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Edit, panel, files)
      edit_button.setDisabled(false)
    else
      edit_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Copy, panel, files)
      copy_button.setDisabled(false)
    else
      copy_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Move, panel, files)
      move_button.setDisabled(false)
    else
      move_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Rename, panel, files)
      rename_button.setDisabled(false)
    else
      rename_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.NewFolder, panel, files)
      mkdir_button.setDisabled(false)
    else
      mkdir_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Remove, panel, files)
      remove_button.setDisabled(false)
    else
      remove_button.setDisabled(true)

    if FM.helpers.isAllowed(FM.Actions.Terminal, panel, files)
      terminal_button.setDisabled(false)
    else
      terminal_button.setDisabled(true)