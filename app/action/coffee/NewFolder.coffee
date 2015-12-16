Ext.define 'FM.action.NewFolder',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.PromtWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-mkdir"
    text: t("New Folder")
    buttonText: t("New Folder [ Ctrl + 7 ]")
    handler: (panel = FM.Active) ->
      FM.Logger.info('Run Action FM.action.NewFolder', arguments)
      session = Ext.ux.Util.clone(panel.session)
      promt = Ext.create 'FM.view.windows.PromtWindow',
        title: t("Make Directory")
        msg: t("Enter name for the new directory:")
        fieldValue: "new_folder"
        ok: (button, promt_window, field) ->
          FM.Logger.debug('ok handler()', arguments)

          button.disable()
          name = field.getValue()

          if panel.filelist.store.find("name", name, 0, false, false, true) > -1
            FM.helpers.ShowError(t("Folder with this name already exists in the current folder."))
            button.enable()
            return

          record = FM.model.File.create
            name: name

          path = FM.helpers.GetAbsName(session, record)

          if session.type == FM.Session.LOCAL_APPLET
            try
              panel.applet.mkdir(path, session, promt_window)
            catch
              button.enable()
              FM.helpers.ShowError(t("Error during operation. <br/>Please contact Support."))
              FM.Logger.error("Applet error")
          else
            FM.backend.ajaxSend '/actions/files/mkdir',
              params:
                session: session
                path: path
              success: (response) =>
                item = Ext.util.JSON.decode(response.responseText).data
                FM.getApplication().fireEvent(FM.Events.file.makeDirectory, item, session)
                promt_window.close()

              failure: (response) =>
                button.enable()
                FM.helpers.ShowError(t("Error during operation. <br/>Please contact Support."))
                FM.Logger.error(response)

      promt.show();