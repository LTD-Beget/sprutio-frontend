Ext.define 'FM.controller.SearchHandler',
  extend: 'Ext.app.Controller'
  views: []

  init: () ->
    FM.Logger.log('SearchHandler init!')

    @listen
      controller:
        '*':
          eventSearchFindFiles: 'findFiles'
          eventSearchFindText: 'findText'

  onLaunch: () ->
    # empty

  findFiles: (status, session, search_window, files_list) ->
    FM.Logger.log('Event findFiles run in SearchHandler! data = ', arguments)

    search_window.cancel_btn.setVisible(false)
    search_window.search_btn.setVisible(true)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('findFiles Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

      try
        files_list.setFileList(status.data)
      catch e
        FM.Logger.info('Exception updating filelist, skip')

      FM.helpers.UnsetLoading(files_list)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      FM.helpers.UnsetLoading(files_list)
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.UnsetLoading(files_list)
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return

  findText: (status, session, search_window, files_list) ->
    FM.Logger.debug('Event findText run in SearchHandler! data = ', arguments)

    search_window.cancel_btn.setVisible(false)
    search_window.search_btn.setVisible(true)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('findText Operation Aborted', status)
      else
        FM.Logger.info('findText Operation success', status)

      try
        files_list.setFileList(status.data)
      catch e
        FM.Logger.info('Exception updating filelist, skip')

      FM.helpers.UnsetLoading(files_list)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      FM.helpers.UnsetLoading(files_list)
      error = t("Error during operation. Please contact Support.")
      if status.data? and status.data.message?
        error = FM.helpers.ParseErrorMessage(status.data.message, error)
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(error)
      return
    else
      FM.helpers.UnsetLoading(files_list)
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return