Ext.define 'FM.action.Move',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-move"
    text: t("Move")
    buttonText: t("Move [ Shift + 5 ]")
    handler: (panel, target_panel, records) ->
      FM.Logger.info('Run Action FM.action.Move', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      target_session = Ext.ux.Util.clone(target_panel.session)
      paths = FM.helpers.GetAbsNames(session, records)

      question = Ext.create 'FM.view.windows.QuestionWindow',
        title: t("Move")
        msg: Ext.util.Format.format(t("Move {0} items to {1}?"), paths.length, target_session.path)
        yes: () ->
          file_paths = FM.helpers.GetAbsNames(session, records)
          same_session = FM.helpers.IsSameSession(session, target_session)

          for file_path in file_paths
            if target_session.path.indexOf(file_path, 0) != -1 and same_session
              FM.helpers.ShowError(t("Cannot move folder in its subfolder"))
              return

          FM.helpers.CheckOverwrite target_panel, records, (overwrite) ->
            FM.Logger.debug('yes handler()', arguments)

            wait = Ext.create 'FM.view.windows.ProgressWindow',
              cancelable: true
              msg: t("File moving, please wait...")
              cancel: (wait_window, session, status) ->
                if status?
                  FM.Actions.Move.cancel(wait_window, session, target_session, status)

            wait.setSession(session)
            wait.setTargetSession(target_session)
            FM.Actions.Move.process(wait, session, target_session, paths, overwrite)

      question.show()

  process: (progress_window, session, target_session, paths, overwrite, status) ->
    FM.Logger.debug('FM.action.Move process() called = ', arguments)

    if status?
      if status.status? and (status.status == FM.Status.STATUS_RUNNING or status.status == FM.Status.STATUS_WAIT)
        setTimeout () =>
          FM.backend.ajaxSend '/actions/main/check_status',
          params:
            session: session
            status: status
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data

            if status.progress? and (status.progress.text? or status.progress.percent?)
              text = if status.progress.text? then status.progress.text else ''
              percent = if status.progress.percent? then status.progress.percent else 0
              progress_window.updateProgress(percent, text)
            else
              progress_window.updateProgressText(t("Moving files..."))

            @process(progress_window, session, target_session, paths, overwrite, status)

          failure: (response) =>
            FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
            FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.moveFiles, status, session, target_session, progress_window)
    else
      if session.type == FM.Session.LOCAL_APPLET
        try
          progress_window.show()
          FM.Active.applet.move(paths, session, target_session, overwrite, progress_window)
        catch
          FM.Logger.error("Applet error")
          FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      else
        FM.backend.ajaxSend '/actions/files/move',
          params:
            session: session
            target: target_session
            paths: paths
            overwrite: overwrite
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data

            progress_window.setOperationStatus(status)
            progress_window.show()
            @process(progress_window, session, target_session, paths, overwrite, status)

          failure: (response) =>
            FM.helpers.ShowError(t("Error during move operation start. Please contact Support."))
            FM.Logger.error(response)

  cancel: (progress_window, session, target_session, status) ->
    FM.backend.ajaxSend '/actions/main/cancel_operation',
      params:
        session: session
        status: status
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        FM.Logger.info(response_data)
        progress_window.close()

      failure: (response) =>
        progress_window.close()
        FM.helpers.ShowError(t("Error during move operation aborting. Please contact Support."))
        FM.Logger.error(response)