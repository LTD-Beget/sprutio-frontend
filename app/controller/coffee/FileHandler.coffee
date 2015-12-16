Ext.define 'FM.controller.FileHandler',
  extend: 'Ext.app.Controller'
  views: []

  init: () ->
    FM.Logger.log('FileHandler init!')

    @listen
      controller:
        '*':
          eventFilesDirectoryOpen: 'openDirectory'
          eventFilesListFiles: 'listFiles'
          eventFilesRemoveFiles: 'removeFiles'
          eventFilesChmodFiles: 'chmodFiles'
          eventFilesMakeDirectory: 'makeDirectory'
          eventFilesNewFile: 'newFile'
          eventFilesRenameFile: 'renameFile'
          eventFilesAnalyzeSize: 'analyzeSize'
          eventFilesCreateCopy: 'createCopy'
          eventFilesCopy: 'copyFiles'
          eventFilesMove: 'moveFiles'

  onLaunch: () ->
    # empty

  openDirectory: (session, path, panels) ->
    FM.Logger.log('Event openDirectory run in FileHandler! data = ', session, path, panels)

    for panel in panels
      if panel.filelist.hasListCache(path)
        FM.Logger.log('Has cache for path = ', path)
        @fireEvent(FM.Events.file.listFiles, panel.filelist.getListCache(path), [panel])
      else
        FM.helpers.SetLoading(panel.body, t("Loading..."))

        if session.type == FM.Session.LOCAL_APPLET
          try
            panel.applet.listdir(path, panel.toString())
          catch
            FM.helpers.UnsetLoading(panel.body)
        else
          FM.backend.ajaxSend '/actions/files/list',
            params:
              session: session
              path: path
            success: (response) =>
              response_data = Ext.util.JSON.decode(response.responseText).data
              listing = response_data

              if listing.path != '/'
                listing.items.unshift
                  name: ".."
                  is_dir: true

              @fireEvent(FM.Events.file.listFiles, listing, [panel])
              @fireEvent(FM.Events.main.saveSession, [panel])
            failure: () =>
              FM.helpers.UnsetLoading(panel.body)

  listFiles: (listing, panels) ->
    FM.Logger.log('Event listFiles run in FileHandler! data = ', listing, panels)

    for panel in panels
      if panel.session.type == FM.Session.HOME
        panel.setShareStatus(listing.is_share, listing.is_share_write)
      panel.filelist.setFileList(listing)
      FM.helpers.SelectDefault(panel)

  makeDirectory: (item, session) ->
    FM.Logger.log('Event makeDirectory run in FileHandler! data = ', item, session)

    FM.helpers.ApplySession session, (panel) ->
      panel.filelist.clearListCache()

      # Update grids if same path
      if panel.session.path == session.path
        name = FM.helpers.GetRelativePath(panel.session, item.name);

        panel.filelist.addFile
          is_dir: true
          name: name
          mode: item.mode
          mtime: item.mtime

  renameFile: (source, target, session) ->
    FM.Logger.log('Event renameFile run in FileHandler! data = ', arguments)

    FM.helpers.ApplySession session, (panel) ->
      panel.filelist.clearListCache()

      # Update grids if same path
      if panel.session.path == session.path
        record = panel.filelist.store.findRecord("name", source.name);
        if record?
          record.set("name", target.name, dirty: false)
          record.set("ext", target.ext, dirty: false)
        else
          panel.filelist.addFile(target)

        # Removes column resize artifacts
        panel.filelist.getView().refresh()

  newFile: (item, session) ->
    FM.Logger.log('Event newFile run in FileHandler! data = ', item, session)

    FM.helpers.ApplySession session, (panel) ->
      panel.filelist.clearListCache()

      # Update grids if same path
      if panel.session.path == session.path
        item.name = FM.helpers.GetRelativePath(panel.session, item.name)
        panel.filelist.addFile(item)

  removeFiles: (status, session, progress_window) ->
    FM.Logger.log('Event removeFiles run in FileHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.hide()

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          if status.data.success?
            for file in status.data.success
              file_name = FM.helpers.GetRelativePath(panel.session, file)
              record = panel.filelist.store.findRecord("name", file_name)
              panel.filelist.store.remove(record)

          panel.updateStatusBar()
          #FM.helpers.SelectDefault(panel)

          if status.status == FM.Status.STATUS_ABORT
            FM.Actions.Refresh.execute([panel])
        else
          if status.data.success?
            for file in status.data.success
              if FM.helpers.IsSubpathOf(panel.session, file)
                FM.Actions.Open.execute(panel, FM.helpers.GetRootPath(panel.session))
                break

      if status.data.errors? and status.data.errors.length > 0
        FM.helpers.ShowError(Ext.util.Format.format(t("Unable to remove {0} elements."), status.data.errors.length))

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Remove Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.hide()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))

  createCopy: (status, session, progress_window) ->
    FM.Logger.log('Event createCopy run in FileHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.close()

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          if status.data.items?
            panel.filelist.addFiles(status.data.items)

          panel.updateStatusBar()

          if status.status == FM.Status.STATUS_ABORT
            FM.Actions.Refresh.execute([panel])

      if status.data.errors? and status.data.errors.length > 0
        FM.helpers.ShowError(Ext.util.Format.format(t("Unable to copy {0} elements."), status.data.errors.length))

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Create Copy Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.hide()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return

  copyFiles: (status, session, target_session, progress_window) ->
    FM.Logger.log('Event copyFiles run in FileHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.hide()

      FM.helpers.ApplySession target_session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == target_session.path
          FM.Actions.Refresh.execute([panel])

      if status.data.errors? and status.data.errors.length > 0
        FM.helpers.ShowError(Ext.util.Format.format(t("Unable to copy {0} elements."), status.data.errors.length))

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Copy Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.hide()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return

  moveFiles: (status, session, target_session, progress_window) ->
    FM.Logger.log('Event moveFiles run in FileHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.hide()

      FM.helpers.ApplySession target_session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == target_session.path
          FM.Actions.Refresh.execute([panel])

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          FM.Actions.Refresh.execute([panel])

      if status.data.errors? and status.data.errors.length > 0
        FM.helpers.ShowError(Ext.util.Format.format(t("Unable to move {0} elements."), status.data.errors.length))

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Move Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      progress_window.hide()
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return

  chmodFiles: (status, session, progress_window, params) ->
    FM.Logger.log('Event chmodFiles run in FileHandler! data = ', arguments)

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)
      progress_window.close()

      FM.helpers.ApplySession session, (panel) ->
        panel.filelist.clearListCache()

        # Update grids if same path
        if panel.session.path == session.path
          FM.Actions.Refresh.execute([panel])

      if status.data.errors? and status.data.errors.length > 0
        FM.helpers.ShowError(Ext.util.Format.format(t("Unable to change attributes of {0} elements."), status.data.errors.length))

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Remove Operation Aborted', status)
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

  analyzeSize: (status, session, chart_window) ->
    FM.Logger.log('Event analyzeSize run in FileHandler! data = ', arguments)

    files_list = Ext.ComponentQuery.query("file-size-list", chart_window)[0]
    files_chart = Ext.ComponentQuery.query("file-size-chart", chart_window)[0]

    if status.status? and (status.status == FM.Status.STATUS_SUCCESS or status.status == FM.Status.STATUS_ABORT)

      if status.status == FM.Status.STATUS_ABORT
        FM.Logger.info('Analyze Size Operation Aborted', status)
      else
        FM.Logger.info('Operation success', status)

      # Normalize chart data
      chart_list = []

      if status.data? and status.data.length > 0

        total_size = 0
        min_sector = 3;

        other_data = []
        other_size = 0

        for item in status.data
          total_size += item.size

        for item in status.data
          percent = (item.size / total_size) * 100;

          if percent <= min_sector
            other_data.push(item)
          else
            chart_list.push(item)

        if other_data.length > 0
          for item in other_data
            other_size += item.size

          chart_list.push
            name: t("others")
            size: other_size

      else
        chart_list.push
          name: chart_window.getPath()
          size:0

      files_chart.setChartData(chart_list)
      chart_series = files_chart.series.getAt(0)

      # assign chart colors to file list, 'others' object is always last in array
      chart_colors = []
      index = 0

      chart_series.eachRecord (record) ->
        FM.Logger.debug('Chart series record color', record, @getLegendColor(index))
        chart_colors.push
          item: record
          color: @getLegendColor(index)
        index++
      ,
        chart_series

      for item in status.data
        for file in chart_colors
          if file.item.get('name') == item.name
            item.color = file.color
        if not item.color
          item.color = chart_colors[chart_colors.length-1].color

      FM.Logger.info('Chart colors', )

      files_list.setFileList(status.data)
      FM.helpers.UnsetLoading(files_list.body)
      FM.helpers.UnsetLoading(files_chart)

    else if status.status? and status.status == FM.Status.STATUS_ERROR
      FM.helpers.UnsetLoading(files_list.body)
      FM.helpers.UnsetLoading(files_chart)
      FM.Logger.info('Operation error', status)
      FM.helpers.ShowError(t("Error during operation. Please contact Support."))
      return
    else
      FM.helpers.UnsetLoading(files_list.body)
      FM.helpers.UnsetLoading(files_chart)
      FM.helpers.ShowError(t("Unknown operation status. Please contact Support."))
      return