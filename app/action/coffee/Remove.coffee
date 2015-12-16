Ext.define 'FM.action.Remove',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.QuestionWindow'
    'FM.view.windows.ProgressWindow'
  ]
  config:
    iconCls: "fm-action-remove"
    text: t("Remove")
    buttonText: t("Remove [ Ctrl + 8 ]")
    handler: (panel, paths) ->

      FM.Logger.info('Run Action FM.action.Remove', arguments)
      session = Ext.ux.Util.clone(panel.session)

      question = Ext.create 'FM.view.windows.QuestionWindow',
        title: t("Delete files")
        msg: t("Do you really want to remove all selected elements?")
        yes: () ->
          FM.Logger.debug('yes handler()', arguments)

          wait = Ext.create 'FM.view.windows.ProgressWindow',
            cancelable: true
            msg: t("Deleting files, please wait...")
            cancel: (wait_window, session, status) ->
              FM.Logger.debug('cancel handler()', arguments)
              if status?
                FM.Actions.Remove.cancel(wait_window, session, status)

          wait.setSession(session)
          FM.Actions.Remove.process(wait, session, paths)

      question.show()

  process: (progress_window, session, paths, status) ->
    FM.Logger.debug('FM.action.Remove process() called = ', arguments)

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
              progress_window.updateProgressText(t("Deleting files..."))

            @process(progress_window, session, paths, status)

          failure: (response) =>
            FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
            FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.removeFiles, status, session, progress_window)
    else
      if session.type == FM.Session.LOCAL_APPLET
        try
          progress_window.show()
          FM.Active.applet.remove_files(paths, session, progress_window)
        catch
          FM.Logger.error("Applet error")
          FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      else
        FM.backend.ajaxSend '/actions/files/remove',
          params:
            session: session
            paths: paths
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data
            progress_window.setOperationStatus(status)
            progress_window.show()
            @process(progress_window, session, paths, status)

          failure: (response) =>
            FM.helpers.ShowError(t("Error during removal operation start.<br/> Please contact Support."))
            FM.Logger.error(response)

  cancel: (progress_window, session, status) ->
    FM.backend.ajaxSend '/actions/main/cancel_operation',
      params:
        session: session
        status: status
      success: () =>
        progress_window.close()

      failure: (response) =>
        progress_window.close()
        FM.helpers.ShowError(t("Error during abortion of removal operation.<br/> Please contact Support."))
        FM.Logger.error(response)