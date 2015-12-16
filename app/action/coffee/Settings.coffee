Ext.define 'FM.action.Settings',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.SettingsWindow'
  ]
  config:
    iconCls: "fm-action-settings"
    text: t("System Settings")
    handler: () ->
      FM.Logger.info('Run Action FM.action.Settings', arguments)

      if not FM.Viewer.settings?
        FM.helpers.ShowError(t("Viewer settings not loaded. Please contact Support."))

      if not FM.Editor.settings?
        FM.helpers.ShowError(t("Editor settings not loaded. Please contact Support."))

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]

      win = Ext.create "FM.view.windows.SettingsWindow",
        taskBar: bottom_toolbar
        save: (button, settings_window, e, params) =>
          button.disable()
          FM.helpers.SetLoading(settings_window.body)
          FM.Actions.Settings.process(settings_window, button, params)
      win.show()

  process: (settings_window, button, params) ->
    FM.Logger.debug('FM.action.Settings process() called = ', arguments)

    FM.backend.ajaxSend '/actions/main/save_settings',
      params:
        session:
          type: FM.Session.HOME
        params: params
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        button.enable()
        FM.helpers.UnsetLoading(settings_window.body)
        FM.getApplication().fireEvent(FM.Events.main.saveSettings, response_data)
        settings_window.close()

      failure: (response) =>
        button.enable()
        FM.helpers.UnsetLoading(settings_window.body)
        FM.Logger.debug(response)
        FM.helpers.ShowError(t("Error during saving settings. Please contact Support."))
        FM.Logger.error(response)