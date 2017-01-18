Ext.define 'FM.view.toolbars.ConnectionListTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.connection-list-top-toolbar'
  cls: 'fm-connection-list-top-toolbar'
  items: []
  height: 40
  layout:
    type: "hbox"
  defaults:
    margin: 0
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.ConnectionListTopToolbar')

    @items = []

    @items.push
      text: t("Save")
      cls: "fm-connection-save"
      iconCls: "fm-icon-save"
      handler: () =>
        FM.Logger.debug("ConnectionListTopToolbar edit() handler called", arguments)

        modified = @ownerCt.getStore().getModifiedRecords()

        for connection in modified
          FM.Logger.debug("Modified connection id: " + connection.get('id'))

          id = parseInt connection.get('id').replace(/(sf|f)tp/, "")

          if id > 0
            if connection.get('type') == 'sftp'
              FM.backend.ajaxSend '/actions/sftp/update',
                params:
                  params:
                    id: id
                    host: connection.get('host')
                    port: connection.get('port')
                    user: connection.get('user')
                    password: connection.get('decryptedPassword')
                success: (response) =>
                  response_data = Ext.util.JSON.decode(response.responseText).data
                  FM.Logger.debug(response_data)

                  for key of response_data
                    connection.set(key, response_data[key])

                  if response_data['id']
                    connection.set('id', 'sftp' + response_data['id'])
                  connection.commit()

                  FM.Logger.debug(connection)

                failure: (response) =>
                  FM.Logger.debug(response)
                  FM.helpers.ShowError(t("Error during sftp connection update.<br/> Please contact Support."))
                  FM.Logger.error(response)
            if connection.get('type') == 'ftp'
              FM.backend.ajaxSend '/actions/ftp/update',
                params:
                  params:
                    id: id
                    host: connection.get('host')
                    port: connection.get('port')
                    user: connection.get('user')
                    password: connection.get('decryptedPassword')
                success: (response) =>
                  response_data = Ext.util.JSON.decode(response.responseText).data
                  FM.Logger.debug(response_data)

                  for key of response_data
                    connection.set(key, response_data[key])

                  if response_data['id']
                    connection.set('id', 'ftp' + response_data['id'])
                  connection.commit()

                  FM.Logger.debug(connection)

                failure: (response) =>
                  FM.Logger.debug(response)
                  FM.helpers.ShowError(t("Error during ftp connection update.<br/> Please contact Support."))
                  FM.Logger.error(response)
          else
            if connection.get('type') == 'sftp'
              FM.backend.ajaxSend '/actions/sftp/create',
                params:
                  params:
                    host: connection.get('host')
                    port: connection.get('port')
                    user: connection.get('user')
                    password: connection.get('decryptedPassword')
                success: (response) =>
                  response_data = Ext.util.JSON.decode(response.responseText).data
                  FM.Logger.debug(response_data)

                  for key of response_data
                    connection.set(key, response_data[key])

                  if response_data['id']
                    connection.set('id', 'sftp' + response_data['id'])
                  connection.commit()

                  FM.Logger.debug(connection)

                failure: (response) =>
                  FM.Logger.debug(response)
                  FM.helpers.ShowError(t("Error during sftp connection creation.<br/> Please contact Support."))
                  FM.Logger.error(response)
            if connection.get('type') == 'ftp'
              FM.backend.ajaxSend '/actions/ftp/create',
                params:
                  params:
                    host: connection.get('host')
                    port: connection.get('port')
                    user: connection.get('user')
                    password: connection.get('decryptedPassword')
                success: (response) =>
                  response_data = Ext.util.JSON.decode(response.responseText).data
                  FM.Logger.debug(response_data)

                  for key of response_data
                    connection.set(key, response_data[key])

                  if response_data['id']
                    connection.set('id', 'ftp' + response_data['id'])
                  connection.commit()

                  FM.Logger.debug(connection)

                failure: (response) =>
                  FM.Logger.debug(response)
                  FM.helpers.ShowError(t("Error during ftp connection creation.<br/> Please contact Support."))
                  FM.Logger.error(response)

    @items.push
      text: t("Edit")
      cls: "fm-connection-edit"
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
      text: t("New connection")
      cls: "fm-connection-add"
      iconCls: "fm-icon-add"
      handler: () =>
        FM.Logger.debug("ConnectionListTopToolbar new() handler called", arguments)
        plugin = @ownerCt.getPlugin()

        if plugin.editing
          return false

        plugin.editor.floatingButtons.items.get(0).setText(t("Save"))
        plugin.editor.floatingButtons.items.get(1).setText(t("Cancel"))

        plugin.startAdd
          host: "domain.com"
          port: "21"
          user: "user"
          decryptedPassword: "password"
          type: "ftp"
          id: "zzzz-" + @ownerCt.getStore().count() # this will set record last in list

    @items.push
      text: t("Remove connection")
      cls: "fm-connection-remove"
      iconCls: "fm-icon-remove"
      disabled: true
      handler: () =>
        FM.Logger.debug("ConnectionListTopToolbar remove() handler called", arguments)

        question = Ext.create 'FM.view.windows.QuestionWindow',
          title: t("Delete Connection")
          msg: t("Do you really want to remove this conneciton?")
          modal: true
          yes: () =>
            grid = @ownerCt
            grid.getPlugin().cancelEdit()

            row = grid.getSelectionModel().getSelection()

            if row.length == 0
              return false

            connection = row[0]

            if connection.get('id').toString().indexOf('FM.model.Connection') == -1
              id = parseInt connection.get('id').replace(/(sf|f)tp/, "")

              if not id
                @updateConnection connection.data
                grid.getStore().remove(connection)
                return

              if connection.get('type') == 'sftp'
                FM.backend.ajaxSend '/actions/sftp/remove',
                  params:
                    params:
                      id: id
                  success: () =>
                    @updateConnection connection.data
                    grid.getStore().remove(connection)
                  failure: (response) ->
                    FM.Logger.debug(response)
                    FM.helpers.ShowError(t("Error during sftp connection removal.<br/> Please contact Support."))
                    FM.Logger.error(response)
              if connection.get('type') == 'ftp'
                FM.backend.ajaxSend '/actions/ftp/remove',
                  params:
                    params:
                      id: id
                  success: () =>
                    @updateConnection connection.data
                    grid.getStore().remove(connection)
                  failure: (response) ->
                    FM.Logger.debug(response)
                    FM.helpers.ShowError(t("Error during ftp connection removal.<br/> Please contact Support."))
                    FM.Logger.error(response)

        question.show()

    @callParent(arguments)

  updateConnection: (connection) ->
    connection['id'] = parseInt(connection['id'].replace(/(s)ftp/, ''))

    if FM.Left.session['type'] == connection['type'] and FM.Left.session['server_id'] == connection['id']
      FM.helpers.SetLoading(FM.Left.body, t("Loading..."))
      FM.backend.ajaxSend '/actions/main/init_session',
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          listing = response_data.listing

          if listing.path != '/'
            listing.items.unshift
              name: ".."
              is_dir: true

          FM.getApplication().fireEvent(FM.Events.main.initSession, response_data, [FM.Left])
        failure: (response) ->
          FM.helpers.UnsetLoading(FM.Left.body)
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Unable to open connection.<br/> Please contact support."))
          FM.Logger.error(response)
    if FM.Right.session['type'] == connection['type'] and FM.Right.session['server_id'] == connection['server_id']
      FM.helpers.SetLoading(FM.Right.body, t("Loading..."))
      FM.backend.ajaxSend '/actions/main/init_session',
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          listing = response_data.listing

          if listing.path != '/'
            listing.items.unshift
              name: ".."
              is_dir: true

          FM.getApplication().fireEvent(FM.Events.main.initSession, response_data, [FM.Right])
        failure: (response) ->
          FM.helpers.UnsetLoading(FM.Right.body)
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Unable to open connection.<br/> Please contact support."))
          FM.Logger.error(response)