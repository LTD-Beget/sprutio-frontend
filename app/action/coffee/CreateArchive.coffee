Ext.define 'FM.action.CreateArchive',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.CreateArchiveWindow'
  ]
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-create-archive"
    text: t("Create Archive")
    handler: (panel = FM.Active, records = []) ->
      FM.Logger.info('Run Action FM.action.CreateArchive', arguments)

      if !records? or records.length == 0
        FM.helpers.ShowError(t("Please select file entry."))
        return

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      win = Ext.create "FM.view.windows.CreateArchiveWindow",
        taskBar: bottom_toolbar
        create: (button, archive_window, e, params) ->
          type = params['type']
          button.disable()
          name = params['archive_name']

          ext = switch
            when type == 'zip'  then '.zip'
            when type == 'bz2'  then '.tar.bz2'
            when type == 'gzip' then '.tar.gz'
            when type == 'tar'  then '.tar'

          full_name = name + ext

          FM.Logger.debug(button, full_name, params)

          if panel.filelist.store.find("name", full_name, 0, false, true, true) > -1
            FM.helpers.ShowError(t("File with this name already exists in the current folder."))
            button.enable()
            return

          wait = Ext.create 'FM.view.windows.ProgressWindow',
            cancelable: true
            msg: t("Creating archive, please wait...")
            cancel: (wait_window, session, status) ->
              FM.Logger.debug('CreateArchive cancel called()', arguments)
              if status?
                FM.Actions.CreateArchive.cancel(wait_window, session, status)

          wait.setSession(session)
          FM.Actions.CreateArchive.process(wait, session, params)
          archive_window.close()

      win.setSession(session)
      win.initRecords(records)
      win.show()

  process: (progress_window, session, params, status) ->
    FM.Logger.debug('FM.action.CreateArchive process() called = ', arguments)

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
        FM.getApplication().fireEvent(FM.Events.archive.createArchive, status, session, progress_window, params)
    else
      FM.backend.ajaxSend '/actions/archive/create',
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

          FM.helpers.ShowError(t("Error during archive creating operation start.<br/> Please contact Support."))
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
        FM.helpers.ShowError(t("Error during abortion of archive creating operation.<br/> Please contact Support."))
        FM.Logger.error(response)