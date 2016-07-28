Ext.define 'FM.action.CreateCopy',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.QuestionWindow'
    'FM.view.windows.ProgressWindow'
  ]
  config:
    iconCls: "fm-action-create-copy"
    text: t("Create Copy")
    handler: (panel, records = []) ->
      FM.Logger.log('Run Action FM.action.CreateCopy', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      paths = FM.helpers.GetAbsNames(session, records)

      question = Ext.create 'FM.view.windows.QuestionWindow',
        title: t("Create copy")
        msg: Ext.util.Format.format(t("Create copy of {0} items in {1}?"), paths.length, session.path)
        yes: () ->
          FM.Logger.debug('Yes handler()', session, paths)

          wait = Ext.create 'FM.view.windows.ProgressWindow',
            cancelable: true
            msg: t("Creating copy, please wait...")
            cancel: (wait_window, session, status) ->
              if status?
                FM.Actions.CreateCopy.cancel(wait_window, session, status)

          wait.setSession(session)
          FM.Actions.CreateCopy.process(wait, session, paths)

      question.show()

  process: (progress_window, session, paths, status) ->
    FM.Logger.debug('FM.action.CreateCopy process() called = ', arguments)

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
                progress_window.updateProgressText(t("Creating copy..."))

              @process(progress_window, session, paths, status)

            failure: (response) =>
              FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
              FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.createCopyFiles, status, session, progress_window)
    else
      FM.backend.ajaxSend '/actions/files/create_copy',
        params:
          session: session
          paths: paths
        success: (response) =>
          status = Ext.util.JSON.decode(response.responseText).data
          progress_window.setOperationStatus(status)
          progress_window.show()
          @process(progress_window, session, paths, status)

        failure: (response) =>
          FM.helpers.ShowError(t("Error during copy operation start. Please contact Support."))
          FM.Logger.error(response)

  cancel: (progress_window, session, status) ->
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
        FM.helpers.ShowError(t("Error during copy operation aborting. Please contact Support."))
        FM.Logger.error(response)