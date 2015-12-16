Ext.define 'FM.action.NewFile',
  extend: 'FM.overrides.Action'
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-newfile"
    text: t("New File")
    handler: (panel = FM.Active) ->
      FM.Logger.info('Run Action FM.action.NewFile', arguments)

      session = Ext.ux.Util.clone(panel.session)
      promt = Ext.create 'FM.view.windows.PromtWindow',
        title: t("New File")
        msg: t("Enter a name of file to create:")
        fieldValue: "new_file.txt"
        ok: (button, promt_window, field) ->
          FM.Logger.info('OK handler()', session, arguments)

          button.disable()
          name = field.getValue()

          if panel.filelist.store.find("name", name, 0, false, false, true) > -1
            FM.helpers.ShowError(t("File with this name already exists in the current folder."))
            button.enable()
            return

          record = FM.model.File.create
            name: name

          path = FM.helpers.GetAbsName(session, record)

          if session.type == FM.Session.LOCAL_APPLET
            try
              panel.applet.newfile(path, session, promt_window)
            catch
              button.enable()
              FM.helpers.ShowError(t("Error during operation. <br/>Please contact Support."))
              FM.Logger.error("Applet error")
          else
            FM.backend.ajaxSend '/actions/files/newfile',
              params:
                session: session
                path: path
              success: (response) =>
                item = Ext.util.JSON.decode(response.responseText).data
                FM.getApplication().fireEvent(FM.Events.file.newFile, item, session)
                promt_window.close();

              failure: (response) =>
                button.enable()
                FM.helpers.ShowError(t("Error during operation. <br/>Please contact Support."))
                FM.Logger.error(response)

      promt.show();