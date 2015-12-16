Ext.define 'FM.controller.ArchiveHandler',
  extend: 'Ext.app.Controller'
  views: []

  init: () ->
    FM.Logger.log('ArchiveHandler init!')

    @listen
      controller:
        '*':
          eventArchiveCreate: 'createArchive'
          eventArchiveExtract: 'extractArchive'

  onLaunch: () ->
    # empty

  createArchive: (status, session, progress_window, params) ->
    FM.Logger.log('Event createArchive run in ArchiveHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.close()

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          FM.Actions.Refresh.execute([panel])

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('createArchive Operation Aborted', status)
      else
        FM.Logger.info('createArchive Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.close()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return

  extractArchive: (status, session, progress_window, params) ->
    FM.Logger.log('Event extractArchive run in ArchiveHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.close()

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          FM.Actions.Refresh.execute([panel])

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('extractArchive Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.close()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return