Ext.define 'FM.action.View',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.ViewerWindow'
    'FM.view.windows.ProgressWindow'
  ]
  config:
    iconCls: "fm-action-view"
    text: t("View")
    buttonText: t("View [ Ctrl + 3 ]")
    handler: (panel, record) ->
      FM.Logger.info('Run Action FM.action.View', arguments)

      if record.get('ext').match(FM.Regex.ImageFilesExt)
        FM.Actions.ViewImage.execute(panel, record)
        return

      if record.get("size") > FM.File.MAX_SIZE
        return FM.helpers.ShowError(t("The file is too large for viewing."))

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      wait = Ext.create 'FM.view.windows.ProgressWindow',
        cancelable: false
        msg: t("Reading file, please wait...")

      wait.show()

      FM.backend.ajaxSend '/actions/files/read',
        params:
          session: session
          path: FM.helpers.GetAbsName(session, record)
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          wait.close()

          win = Ext.create "FM.view.windows.ViewerWindow",
            taskBar: bottom_toolbar
            fileRecord: record
            fileContent: response_data.content
            fileEncoding: response_data.encoding
            title: Ext.util.Format.format(t("Viewer: {0}"), record.get("name"))

          win.setSession(session)
          win.show()
          FM.Logger.info('Viewer window done', win)

        failure: (response) =>
          wait.close()
          json_response = Ext.util.JSON.decode(response.responseText)
          error = FM.helpers.ParseErrorMessage(json_response.message, t("Error during reading file.<br/> Please contact Support."))
          FM.helpers.ShowError(error)
          FM.Logger.error(response)