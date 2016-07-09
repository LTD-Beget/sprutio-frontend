Ext.define 'FM.view.toolbars.WebDavConnectionListTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.webdav-connection-list-top-toolbar'
  cls: 'fm-webdav-connection-list-top-toolbar'
  items: []
  height: 40
  layout:
    type: "hbox"
  defaults:
    margin: 0
  initComponent: () ->

    FM.Logger.log('FM.view.toolbars.WebDavConnectionListTopToolbar')

    @items = []

    @items.push
      text: t("Save")
      cls: "fm-webdav-connection-save"
      iconCls: "fm-icon-save"
      handler: () =>
        FM.Logger.debug("WebDavConnectionListTopToolbar edit() handler called", arguments)

        modified = @ownerCt.getStore().getModifiedRecords()

        for connection in modified
          if connection.get('id') > 0
            FM.backend.ajaxSend '/actions/webdav/update',
              params:
                params:
                  id: connection.get('id')
                  host: connection.get('host')
                  user: connection.get('user')
                  password: connection.get('decryptedPassword')
              success: (response) =>
                response_data = Ext.util.JSON.decode(response.responseText).data
                FM.Logger.debug(response_data)

                for key of response_data
                  connection.set(key, response_data[key])
                connection.commit()

              failure: (response) =>
                FM.Logger.debug(response)
                FM.helpers.ShowError(t("Error during webdav server update.<br/> Please contact Support."))
                FM.Logger.error(response)
          else
            FM.backend.ajaxSend '/actions/webdav/create',
              params:
                params:
                  host: connection.get('host')
                  user: connection.get('user')
                  password: connection.get('decryptedPassword')
              success: (response) =>
                response_data = Ext.util.JSON.decode(response.responseText).data
                FM.Logger.debug(response_data)

                for key of response_data
                  connection.set(key, response_data[key])
                connection.commit()

              failure: (response) =>
                FM.Logger.debug(response)
                FM.helpers.ShowError(t("Error during webdav connection creation.<br/> Please contact Support."))
                FM.Logger.error(response)

    @items.push
      text: t("Edit")
      cls: "fm-webdav-connection-edit"
      iconCls: "fm-icon-edit"
      disabled: true
      handler: () =>
        FM.Logger.debug("ConnectionListTopToolbar edit() handler called", arguments)

        grid = @ownerCt
        plugin = grid.getPlugin()

        if plugin.editing
          return false

        row = grid.getSelectionModel().getSelection()

        if row.length == 0
          return false

        plugin.editor.floatingButtons.items.get(0).setText(t("Update"))
        plugin.editor.floatingButtons.items.get(1).setText(t("Cancel"))

        connection = row[0]
        plugin.startEdit(connection, 0);

    @items.push
      text: t("New WebDav")
      cls: "fm-webdav-connection-add"
      iconCls: "fm-icon-add"
      handler: () =>
        FM.Logger.debug("WebDavConnectionListTopToolbar new() handler called", arguments)
        plugin = @ownerCt.getPlugin()

        if plugin.editing
          return false

        plugin.editor.floatingButtons.items.get(0).setText(t("Save"))
        plugin.editor.floatingButtons.items.get(1).setText(t("Cancel"))

        plugin.startAdd
          host: ""
          user: "user"
          decryptedPassword: "password"

    @items.push
      text: t("Remove WebDav")
      cls: "fm-webdav-connection-remove"
      iconCls: "fm-icon-remove"
      disabled: true
      handler: () =>
        FM.Logger.debug("WebDavConnectionListTopToolbar remove() handler called", arguments)

        question = Ext.create 'FM.view.windows.QuestionWindow',
          title: t("Delete WebDav Connection")
          msg: t("Do you really want to remove this conneciton?")
          modal: true
          yes: () =>

            grid = @ownerCt
            grid.getPlugin().cancelEdit()

            row = grid.getSelectionModel().getSelection()

            if row.length == 0
              return false

            connection = row[0]
            grid.getStore().remove(connection)

            FM.backend.ajaxSend '/actions/webdav/remove',
              params:
                params:
                  id: connection.get('id')
              failure: (response) =>
                FM.Logger.debug(response)
                FM.helpers.ShowError(t("Error during webdav connection removal.<br/> Please contact Support."))
                FM.Logger.error(response)

        question.show()

    @callParent(arguments)