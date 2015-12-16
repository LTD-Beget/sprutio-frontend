Ext.define 'FM.controller.HomeHandler',
  extend: 'Ext.app.Controller'
  views: []

  init: () ->
    FM.Logger.log('HomeHandler init!')

    @listen
      controller:
        '*':
          eventHomeInitCallback: 'homeInitCallback'
          eventHomeProcessInit: 'processInit'

  onLaunch: () ->
    # empty

  homeInitCallback: (panels) ->
    FM.Logger.log('Event homeInitCallback run in HomeHandler! panels = ', panels)

    FM.backend.ajaxSend '/actions/home/init_callback',
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        @fireEvent(FM.Events.home.processInit, response_data, panels)

  processInit: (data, panels) ->
    FM.Logger.log('Event processInit run in HomeHandler! data = ', data, panels)

    FM.Home = {}
    FM.Home.ftp_connections = []

    if data.quota?
      FM.Home.quota = data.quota
      @processQuota(data.quota, panels)

    if data.account?
      FM.Home.account = data.account
      @processAccount(data.account, panels)

    if data.ftp_connections?
      FM.Home.ftp_connections = []
      @processConnections(data.ftp_connections)

    @processFastMenu(data, panels)

  processFastMenu: (data, panels) ->
    FM.Logger.log('processFastMenu() called arguments =', arguments)
    for panel in panels
      do (panel) ->
        fast_menu = {
          xtype: 'menu'
          items: []
        }

        # Home Ftp and domains menu
        home_menu = {
          xtype: 'menuitem',
          text: FM.Actions.HomeFtp.getMenuText()
          iconCls: FM.Actions.HomeFtp.getIconCls()
          handler: () =>
            FM.Actions.HomeFtp.execute(panel)
        }

        fast_menu.items.push(home_menu)

        # Ftp menu
        if data.ftp_connections? && data.ftp_connections.length > 0
          menu_element = {
            xtype: 'menuitem',
            text: FM.Actions.RemoteFtp.getMenuText()
            iconCls: FM.Actions.RemoteFtp.getIconCls()
            handler: () =>
              FM.Actions.RemoteFtp.execute()
          }

          ftp_connection_menu = []

          # тормозят контекстные меню если они большие, поэтому в целях оптимизации их нет если оч много объектов
          if data.ftp_connections.length <= 100
            for connection in data.ftp_connections
              do(connection) ->
                connection_menu_element = {
                  xtype: 'menuitem'
                  text: connection.user + "@" + connection.host
                  iconCls: 'fm-action-connect-ftp'
                  handler: () =>
                    FM.Actions.OpenFtp.execute panel,
                      type: FM.Session.PUBLIC_FTP
                      path: '/'
                      server_id: connection.id
                }

                ftp_connection_menu.push(connection_menu_element)

          if ftp_connection_menu.length > 0
            menu_element.menu = ftp_connection_menu
          fast_menu.items.push(menu_element)

        panel.setFastMenu(fast_menu)

  processAccount: (account, panels) ->
    login = if account.login? then account.login else ''
    server_name = if account.server? then account.server else ''

    for panel in panels
      if panel.session.type == FM.Session.HOME
        panel.setServerName(login + '@' + server_name)

  processConnections: (ftp_connections) ->
    FM.Logger.log('processConnections() called arguments =', arguments)

    FM.Stores.FtpConenctions.loadData(ftp_connections)

  processQuota: (quota, panels) ->
    FM.Logger.log('processQuota() called arguments =', arguments)

    used = parseInt(quota.blockUsed) / 1024
    all = parseInt(quota.blockHard) / 1024
    used_files = parseInt(quota.FileUsed) / 1000
    all_files = parseInt(quota.FileHard) / 1000

    free = (all - used) / 1024
    rounded = (used / 1024).toFixed(2)
    rounded_all = (all / 1000).toFixed(2)
    rounded_files = (used_files / 1000).toFixed(2)
    rounded_all_files = (all_files / 1000).toFixed(2)

    file_quota = false
    percent = used / all

    if all_files != 0 and all != 0
        if (used_files / all_files) > (used / all)
            file_quota = true
            percent = used_files / all_files

    if all == 0
      text = "Без ограничений"
      percent = 0
    else if file_quota
      text = "Занято " + rounded_files + "k " + rounded_all_files + "k файлов"
    else
      text = "Занято " + rounded + "Гб / " + rounded_all + "Гб"

    warning = false

    for panel in panels
      if panel.session.type == FM.Session.HOME
        panel.setQuota(true, percent, text)

        if percent > FM.Quota.WARNING_PERCENT
          warning = true
      else
        panel.setQuota(false)

    if warning
      if file_quota
        FM.helpers.ShowWarning(t("Your file quota is almost full. <br/>For this reason some file operations may not work."))
      else
        FM.helpers.ShowWarning(t("Your account quota is almost full. <br/>For this reason some file operations may not work."))