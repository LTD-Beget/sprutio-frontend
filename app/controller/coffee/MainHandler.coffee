Ext.define 'FM.controller.MainHandler',
  extend: 'Ext.app.Controller'
  views: []

  init: () ->
    FM.Logger.log('MainHandler init!')

    @listen
      controller:
        '*':
          eventMainRestoreSession: 'restoreSession'
          eventMainSaveSession: 'saveSession'
          eventMainInitSession: 'initSession'
          eventMainLoadSettings: 'loadSettings'
          eventMainSaveSettings: 'saveSettings'
          eventMainSelectPanel: 'selectPanel'
          eventMainSelectFiles: 'selectFiles'

  onLaunch: () ->
    # empty

  loadSettings: (data) ->
    FM.Logger.log('Event loadSettings run in MainHandler! data = ', arguments)

    if data.editor_settings?
      FM.Editor.settings = data.editor_settings

    if data.viewer_settings?
      FM.Viewer.settings = data.viewer_settings

  selectFiles: (panel, files) ->
    FM.Logger.log('Event selectFiles run in MainHandler! data = ', arguments)

    FM.panels.Top.updateButtonsState(panel, files)
    FM.panels.Top.updateMenuState(panel, files)
    FM.panels.Bottom.updateState(panel, files)

  selectPanel: (panel, files) ->
    FM.Logger.log('Event selectPanel run in MainHandler! data = ', arguments)

    FM.panels.Top.updateButtonsState(panel, files)
    FM.panels.Top.updateMenuState(panel, files)
    FM.panels.Bottom.updateState(panel, files)

  saveSession: (panels) ->
    FM.Logger.log('Event saveSession run in MainHandler! data = ', arguments)

    for panel in panels
      if panel.session.type == FM.Session.LOCAL_APPLET
        return

      FM.backend.ajaxSend '/actions/main/save_session',
        params:
          session: panel.session
          order: panel.toString()
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          FM.Logger.info('Session saved ', response_data, panel)
        failure: (response) =>
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Unable to save session state.<br/> Please contact support."))
          FM.Logger.error(response)

  restoreSession: (data) ->
    FM.Logger.log('Event restoreSession run in MainHandler! data = ', data, FM.Left)

    FM.helpers.SetLoading(FM.Right.body, t("Loading..."))
    FM.helpers.SetLoading(FM.Left.body, t("Loading..."))

    FM.backend.ajaxSend '/actions/main/load_settings',
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        @fireEvent(FM.Events.main.loadSettings, response_data)
      failure: (response) ->
        FM.Logger.debug(response)
        FM.helpers.ShowError(t("Unable to load settings.<br/> Please contact support."))
        FM.Logger.error(response)

    if !data.restore
      FM.backend.ajaxSend '/actions/main/init_session',
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          listing = response_data.listing

          if listing.path != '/'
            listing.items.unshift
              name: ".."
              is_dir: true

          @fireEvent(FM.Events.main.initSession, response_data, [FM.Right, FM.Left])
        failure: (response) ->
          FM.helpers.UnsetLoading(FM.Left.body)
          FM.helpers.UnsetLoading(FM.Right.body)
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Unable to restore session state.<br/> Please contact support."))
          FM.Logger.error(response)

    if data.restore
      if data.same
        FM.backend.ajaxSend '/actions/main/init_session',
          params:
            session: data.session.Left
          success: (response) =>
            response_data = Ext.util.JSON.decode(response.responseText).data

            listing = response_data.listing

            if listing.path != '/'
              listing.items.unshift
                name: ".."
                is_dir: true

            @fireEvent(FM.Events.main.initSession, response_data, [FM.Right, FM.Left])
          failure: (response) =>
            FM.Logger.debug(response)
            FM.Logger.error(response)
            @initDefaultSession([FM.Right, FM.Left])

      else
        FM.backend.ajaxSend '/actions/main/init_session',
          params:
            session: data.session.Left
          success: (response) =>
            response_data = Ext.util.JSON.decode(response.responseText).data
            listing = response_data.listing

            if listing.path != '/'
              listing.items.unshift
                name: ".."
                is_dir: true

            @fireEvent(FM.Events.main.initSession, response_data, [FM.Left])

          failure: (response) =>
            FM.Logger.debug(response)
            FM.Logger.error(response)
            @initDefaultSession([FM.Left])


        FM.backend.ajaxSend '/actions/main/init_session',
          params:
            session: data.session.Right
          success: (response) =>
            response_data = Ext.util.JSON.decode(response.responseText).data
            listing = response_data.listing

            if listing.path != '/'
              listing.items.unshift
                name: ".."
                is_dir: true

            @fireEvent(FM.Events.main.initSession, response_data, [FM.Right])

          failure: (response) =>
            FM.Logger.debug(response)
            FM.Logger.error(response)
            @initDefaultSession([FM.Right])

  initDefaultSession: (panels) ->
    FM.backend.ajaxSend '/actions/main/init_session',
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        listing = response_data.listing

        if listing.path != '/'
          listing.items.unshift
            name: ".."
            is_dir: true

        @fireEvent(FM.Events.main.initSession, response_data, panels)
      failure: (response) ->
        for panel in panels
          FM.helpers.UnsetLoading(panel.body)
        FM.Logger.debug(response)
        FM.helpers.ShowError(t("Unable to restore session state.<br/> Please contact support."))
        FM.Logger.error(response)

  initSession: (data, panels) ->
    FM.Logger.log('Event initSession run in MainHandler! data = ', data, panels)

    for panel in panels
      panel.session = Ext.ux.Util.clone(data.session)
      panel.actions = Ext.ux.Util.clone(data.actions)

      # update toolbars state
      if panel == FM.Active
        FM.panels.Top.updateButtonsState(panel, [])
        FM.panels.Top.updateMenuState(panel, [])
        FM.panels.Bottom.updateState(panel, [])

      panel.filelist.initStore(data.listing)

      if panel.session.host?
        panel.setServerName(panel.session.host)
      else
        panel.setServerName('')

      button = panel.getFastMenuButton()

      if panel.session.type == FM.Session.HOME
        button.setConfig
          text: FM.Actions.HomeFtp.getMenuText()
          iconCls: FM.Actions.HomeFtp.getIconCls()

      if panel.session.type == FM.Session.PUBLIC_FTP
        button.setConfig
          text: FM.Actions.RemoteFtp.getMenuText()
          iconCls: FM.Actions.RemoteFtp.getIconCls()

      if panel.session.type == FM.Session.LOCAL_APPLET
        button.setConfig
          text: FM.Actions.Local.getMenuText()
          iconCls: FM.Actions.Local.getIconCls()

    # loading extra data from home
    @fireEvent(FM.Events.home.homeInitCallback, panels)
    @fireEvent(FM.Events.main.saveSession, panels)

  saveSettings: (data) ->
    FM.Logger.log('Event saveSettings run in MainHandler! data = ', data)

    FM.Editor.settings = data.editor_settings
    FM.Viewer.settings = data.viewer_settings

    editors = Ext.ComponentQuery.query("editor-window")
    viewers = Ext.ComponentQuery.query("viewer-window")

    for editor in editors
      editor.updateSettings()

    for viewer in viewers
      viewer.updateSettings()