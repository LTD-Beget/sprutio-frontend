Ext.define 'FM.action.ExtractArchive',
  extend: 'FM.overrides.Action'
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-extract-archive"
    text: t("Extract Archive")
    handler: (panel = FM.Active, record) ->
      FM.Logger.info('Run Action FM.action.ExtractArchive', arguments)

      session = Ext.ux.Util.clone(panel.session)

      promt = Ext.create 'FM.view.windows.PromtWindow',
        title: t("Extract Archive")
        msg: t("Enter a path to extract:")
        fieldValue: session.path
        ok: (button, promt_window, field) ->
          FM.Logger.info('OK handler()', session, arguments)

          button.disable()

          params = {
            file:
              path: FM.helpers.GetAbsName(session, record)
              base64: record.get('base64')
            extract_path: field.getValue()
          }

          wait = Ext.create 'FM.view.windows.ProgressWindow',
            cancelable: true
            msg: t("Extracting archive, please wait...")
            cancel: (wait_window, session, status) ->
              FM.Logger.debug('ExtractArchive cancel called()', arguments)
              if status?
                FM.Actions.ExtractArchive.cancel(wait_window, session, status)

          wait.setSession(session)
          FM.Actions.ExtractArchive.process(wait, session, params)
          promt_window.close()

      promt.show()

  process: (progress_window, session, params, status) ->
    FM.Logger.debug('FM.action.ExtractArchive process() called = ', arguments)

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
                progress_window.updateProgressText(t("Estimating operation length..."))

              @process(progress_window, session, params, status)

            failure: (response) =>
              FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."))
              FM.Logger.error(response)
        ,
          FM.Time.REQUEST_DELAY
      else
        FM.getApplication().fireEvent(FM.Events.archive.extractArchive, status, session, progress_window, params)
    else
      FM.backend.ajaxSend '/actions/archive/extract',
        params:
          session: session
          params: params
        success: (response) =>
          status = Ext.util.JSON.decode(response.responseText).data
          progress_window.setOperationStatus(status)
          progress_window.show()
          @process(progress_window, session, params, status)

        failure: (response) =>
          FM.Logger.debug(response)

          FM.helpers.ShowError(t("Error during archive extracting operation start.<br/> Please contact Support."))
          FM.Logger.error(response)

  cancel: (progress_window, session, status) ->
    FM.backend.ajaxSend '/actions/main/cancel_operation',
      params:
        session: session
        status: status
      success: (response) =>
        response_data = Ext.util.JSON.decode(response.responseText).data
        FM.Logger.debug(response_data)
        progress_window.close()

      failure: (response) =>
        progress_window.close()
        FM.helpers.ShowError(t("Error during abortion of archive extracting operation.<br/> Please contact Support."))
        FM.Logger.error(response)