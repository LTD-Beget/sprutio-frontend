Ext.define 'FM.action.Copy',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.QuestionWindow'
    'FM.view.windows.ProgressWindow'
  ]
  config:
    iconCls: "fm-action-copy"
    text: t("Copy")
    buttonText: t("Copy [ Ctrl + 5 ]")
    handler: (panel, target_panel, target_path, records) ->
      FM.Logger.info('Run Action FM.action.Copy', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      session = Ext.ux.Util.clone(panel.session)
      target_session = Ext.ux.Util.clone(target_panel.session)
      target_session.path = target_path

      paths = FM.helpers.GetAbsNames(session, records)

      question = Ext.create 'FM.view.windows.QuestionWindow',
        title: t("Copy")
        msg: Ext.util.Format.format(t("Copy {0} items to {1}?"), paths.length, target_session.path)
        yes: () ->
          FM.helpers.CheckOverwrite target_panel, records, (overwrite) ->
            FM.Logger.debug('Yes handler()', session, paths)

            wait = Ext.create 'FM.view.windows.ProgressWindow',
              cancelable: true
              msg: t("File copying, please wait...")
              cancel: (wait_window, session, status) ->
                if status?
                  FM.Actions.Copy.cancel(wait_window, session, status)

            wait.setSession(session)
            wait.setTargetSession(target_session)
            FM.Actions.Copy.process(wait, session, target_session, paths, overwrite)

      question.show()

  process: (progress_window, session, target_session, paths, overwrite, status) ->
    FM.Logger.debug('FM.action.Copy process() called = ', arguments)

    if status?
      if status.status? and (status.status == FM.Status.STATUS_RUNNING or status.status == FM.Status.STATUS_WAIT)
        setTimeout () =>
          FM.backend.ajaxSend '/actions/main/check_status',
          params:
            # передаем сессию home если копирование идет на него с удаленного ftp так как прогресс получаем через агента
            session: if (session.type == FM.Session.PUBLIC_FTP or session.type == FM.Session.SFTP) and target_session.type == FM.Session.HOME then target_session else session
            status: status
          success: (response) =>
            status = Ext.util.JSON.decode(response.responseText).data

            if status.progress? and (status.progress.text? or status.progress.percent?)
              text = if status.progress.text? then status.progress.text else ''
              percent = if status.progress.percent? then status.progress.percent else 0
              progress_window.updateProgress(percent, text)
            else
              progress_window.updateProgressText(t("Creating copy..."))

            @process(progress_window, session, target_session, paths, overwrite, status)

          failure: (response) =>
            FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
            FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.file.copyFiles, status, session, target_session, progress_window)
    else
      FM.backend.ajaxSend '/actions/files/copy',
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