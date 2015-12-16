Ext.define 'FM.view.panels.FileListPanel',
  extend: 'Ext.panel.Panel'
  requires: [
    'FM.view.grids.FileList'
    'FM.view.toolbars.FileListTopToolbar'
    'FM.view.toolbars.FileListBottomToolbar'
  ]
  alias: 'widget.filelist-panel'
  cls: 'fm-file-list-panel'
  layout: 'fit'
  tbar:
    xtype: 'file-list-top-toolbar'
  bbar:
    xtype: 'file-list-bottom-toolbar'
  items: [
    {
      xtype: "filelist"
    }
  ]

  initComponent: () ->
    FM.Logger.log('FM.view.panels.FileListPanel init')

    @session = {}
    @actions = {}

    this.callParent(arguments)

  initTopToolBarHandlers: () ->
    FM.Logger.log('initTopToolBarHandlers()')

    # get toolbar and buttons
    toolbar = Ext.ComponentQuery.query('file-list-top-toolbar', @)[0]

    button_root = toolbar.items.get(1)
    button_up = toolbar.items.get(2)

    button_up.setHandler () =>
      FM.Actions.Up.execute(@session.path, @)

    button_root.setHandler () =>
      FM.Actions.Root.execute(@)

  initEmptyContextMenu: () ->
    FM.Logger.debug('call initEmptyContextMenu()')

    items = []

    if FM.helpers.isAllowed(FM.Actions.NewFile, @, [])
      items.push
        text: FM.Actions.NewFile.getMenuText()
        iconCls: FM.Actions.NewFile.getIconCls()
        handler: () =>
          FM.Actions.NewFile.execute(@)

    if FM.helpers.isAllowed(FM.Actions.NewFolder, @, [])
      items.push
        text: FM.Actions.NewFolder.getMenuText()
        iconCls: FM.Actions.NewFolder.getIconCls()
        handler: () =>
          FM.Actions.NewFolder.execute(@)

    if FM.helpers.isAllowed(FM.Actions.Upload, @, [])
      items.push
        text: FM.Actions.Upload.getMenuText()
        iconCls: FM.Actions.Upload.getIconCls()
        handler: () =>
          FM.Actions.Upload.execute()

    if FM.helpers.isAllowed(FM.Actions.Refresh, @, [])
      items.push
        text: FM.Actions.Refresh.getMenuText()
        iconCls: FM.Actions.Refresh.getIconCls()
        handler: () =>
          FM.Actions.Refresh.execute([@])

    @empty_context_menu = Ext.create 'Ext.menu.Menu',
      items: items

  hasContextMenu: (record) ->
    if record.get('name') == '..'
      return false

    if record.get('is_link')
      return false

    return true

  setShareStatus: (is_share, is_share_write) ->
    FM.Logger.debug("setShareStatus() called ", arguments)

    @session.is_share = if is_share == 1 then true else false
    @session.is_share_write = if is_share_write == 1 then true else false

  getContextMenu: (record) ->

    FM.Logger.debug("getContextMenu() called ", record, @session)
    selection_array = @filelist.getView().getSelectionModel().getSelection();
    select_multiply = false;

    # close opened menus
    menus = Ext.ComponentQuery.query('menu[name=fm-file-list-context-menu]')
    for menu in menus
      menu.close()

    if selection_array.length > 1
      select_multiply = true

    items = []

    if FM.helpers.isAllowed(FM.Actions.Open, @, selection_array)
      path = FM.helpers.GetAbsName(@session, record)
      items.push
        text: FM.Actions.Open.getMenuText()
        iconCls: FM.Actions.Open.getIconCls()
        handler: () =>
          FM.Actions.Open.execute(@, path)

    if FM.helpers.isAllowed(FM.Actions.Rename, @, selection_array)
      items.push
        text: FM.Actions.Rename.getMenuText()
        iconCls: FM.Actions.Rename.getIconCls()
        handler: () =>
          FM.Actions.Rename.execute(@, record)

    if FM.helpers.isAllowed(FM.Actions.View, @, selection_array)
      items.push
        text: FM.Actions.View.getMenuText()
        iconCls: FM.Actions.View.getIconCls()
        handler: () =>
          FM.Actions.View.execute(@, record)

    if FM.helpers.isAllowed(FM.Actions.Edit, @, selection_array)
      items.push
        text: FM.Actions.Edit.getMenuText()
        iconCls: FM.Actions.Edit.getIconCls()
        handler: () =>
          FM.Actions.Edit.execute(@, record)

    if FM.helpers.isAllowed(FM.Actions.DownloadBasic, @, selection_array)
      items.push
        text: FM.Actions.DownloadBasic.getMenuText()
        iconCls: FM.Actions.DownloadBasic.getIconCls()
        handler: () =>
          FM.Actions.DownloadBasic.execute(@, record)

    if FM.helpers.isAllowed(FM.Actions.DownloadZip, @, selection_array)
      items.push
        text: FM.Actions.DownloadZip.getMenuText()
        iconCls: FM.Actions.DownloadZip.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.DownloadZip.execute(@, records)

    if FM.helpers.isAllowed(FM.Actions.CreateArchive, @, selection_array)
      items.push
        text: FM.Actions.CreateArchive.getMenuText()
        iconCls: FM.Actions.CreateArchive.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.CreateArchive.execute(@, records)

    if FM.helpers.isAllowed(FM.Actions.ExtractArchive, @, selection_array)
      items.push
        text: FM.Actions.ExtractArchive.getMenuText()
        iconCls: FM.Actions.ExtractArchive.getIconCls()
        handler: () =>
          FM.Actions.ExtractArchive.execute(@, record)

    if FM.helpers.isAllowed(FM.Actions.Copy, @, selection_array)
      items.push
        text: FM.Actions.Copy.getMenuText()
        iconCls: FM.Actions.Copy.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.Copy.execute(@, FM.helpers.NextPanel(@), FM.helpers.NextPanel(@).session.path, records)

    if FM.helpers.isAllowed(FM.Actions.Move, @, selection_array)
      items.push
        text: FM.Actions.Move.getMenuText()
        iconCls: FM.Actions.Move.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.Move.execute(@, FM.helpers.NextPanel(@), records)

    if FM.helpers.isAllowed(FM.Actions.CreateCopy, @, selection_array)
      items.push
        text: FM.Actions.CreateCopy.getMenuText()
        iconCls: FM.Actions.CreateCopy.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.CreateCopy.execute(@, records)

    if FM.helpers.isAllowed(FM.Actions.AnalyzeSize, @, selection_array)
      path = FM.helpers.GetAbsName(@session, record)
      items.push
        text: FM.Actions.AnalyzeSize.getMenuText()
        iconCls: FM.Actions.AnalyzeSize.getIconCls()
        handler: () =>
          FM.Actions.AnalyzeSize.execute(@, path)

    if FM.helpers.isAllowed(FM.Actions.Chmod, @, selection_array)
      items.push
        text: FM.Actions.Chmod.getMenuText()
        iconCls: FM.Actions.Chmod.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          FM.Actions.Chmod.execute(@, records)

    if FM.helpers.isAllowed(FM.Actions.Remove, @, selection_array)
      items.push
        text: FM.Actions.Remove.getMenuText()
        iconCls: FM.Actions.Remove.getIconCls()
        handler: () =>
          records = FM.helpers.GetSelected(@)
          paths = FM.helpers.GetAbsNames(@session, records)
          FM.Actions.Remove.execute(@, paths)

    menu = Ext.create 'Ext.menu.Menu',
      name: 'fm-file-list-context-menu'
      items: items

    return menu

  updateStatusBar: () ->
    FM.Logger.log('updateStatusBar() called', @, arguments)
    size = 0
    dirs = 0
    files = 0

    records = @filelist.store.data.items

    for record in records
      if record.get('is_dir') && record.get('name') != '..'
        dirs++
      else if !record.get('is_dir')
        files++
        size += parseInt(record.get("size"))

    status_bar = Ext.ComponentQuery.query('file-list-status-bar', @)[0]
    status_bar.setText(t("Size: $1, dirs: $2, files: $3", FM.helpers.SizeFormat(size), dirs, files))

  updatePathBar: () ->
    FM.Logger.log('updatePathbar called ', @toString())

    pathbar = Ext.ComponentQuery.query('file-list-path-bar', @)[0]

    # 90: views width
    offset_left = pathbar.getBox().x - pathbar.container.getBox().x
    container_width = pathbar.container.getWidth() - offset_left - 90

    path = @session.path

    # win or unix
    if path.indexOf("\\") != -1
      separator = '\\\\'   # windows
      txt_separator = '\\'
      windows = true
    else
      separator = '/' # unix
      txt_separator = '/'
      windows = false

    # split by regex
    crumbs = path.split(/\\|\//)
    dirs = [];

    for part, key in crumbs
      if part == ''
        continue

      crumb_path = crumbs.slice(0, key + 1).join(separator)

      if windows and key == 0
        crumb_path += '\\\\'

      FM.Logger.debug('crumb_path=', crumb_path)
      dirs.push('<span onclick="FM.Actions.Open.execute(FM.' + @ + ', \'' + crumb_path + '\');">' + part + '</span>')

    if windows
      if dirs.length > 1
        pathbar.setText(dirs.join(txt_separator));
      else
        pathbar.setText(dirs.join(txt_separator) + txt_separator);
    else
      pathbar.setText(txt_separator + dirs.join(txt_separator));

    # Update for big paths
    width = pathbar.getWidth();
    while width >= container_width
      dirs.shift()
      pathbar.setText(".." + txt_separator + dirs.join(txt_separator))
      width = pathbar.getWidth()

  setQuota: (visible = true, percent, text) ->
    size_bar = Ext.ComponentQuery.query('file-list-size-bar', @)[0]

    if visible
      size_bar.show()
    else
      size_bar.hide()

    if text?
      size_bar.updateText(text)
    if percent?
      size_bar.updateProgress(percent)

  setServerName: (server_name) ->
    server_bar = Ext.ComponentQuery.query('file-list-server-bar', @)[0]
    server_bar.setText(server_name)

  setFastMenu: (menu) ->
    FM.Logger.debug("FileListPanel setFastMenu()", @, arguments)

    if !menu.items.length > 0
      return

    fast_button = @getFastMenuButton()
    fast_button.setMenu(menu)

  getFastMenuButton: () ->
    toolbar = Ext.ComponentQuery.query('file-list-top-toolbar', @)[0]
    return toolbar.items.get(0)