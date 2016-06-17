Ext.define 'FM.view.grids.FileList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.filelist'
  cls: 'fm-file-list'
  columns: []
  stateful: true ## <-- ???
  multiSelect: true
  viewConfig:
    stripeRows: false
    markDirty: false
    plugins:
      ptype: "gridviewdragdrop"
      ddGroup: "DDGroup"
      enableDrop: false
  requires: [
    'Ext.grid.plugin.DragDrop'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.grids.FileList init')
    @callParent(arguments)
    @initEventsHandlers()

  getSession: () ->
    return @ownerCt.session

  getActions: () ->
    return @ownerCt.session

  initStore: (listing) ->
    session = @getSession()
    panel = @ownerCt

    FM.Logger.log('initStore listing = ', listing, @, session, session.type)
    @list_cache = {}
    @removeEvents()

    if session? and session.type? and session.type == FM.Session.HOME
      @initHomeConfig()
      @initHomeStore()
      panel.setShareStatus(listing.is_share, listing.is_share_write)
    else if session? and session.type? and session.type == FM.Session.SFTP
      @initHomeConfig()
      @initHomeStore()
    else if session? and session.type? and session.type == FM.Session.PUBLIC_FTP
      @initPublicFtpConfig()
      @initPublicFtpStore()
    else if session? and session.type? and session.type == FM.Session.LOCAL_APPLET
      @initLocalAppletConfig()
      @initLocalAppletStore()

    panel.initEmptyContextMenu()
    @setFileList(listing)

    panel.initTopToolBarHandlers()
    @initDropZone()
    @initHotKeys()

  initDropZone: () ->
    FM.Logger.debug('called initDropZone()')

    view = @getView()
    @drop_zone = Ext.create "Ext.dd.DropZone", view.getEl(),
      ddGroup: "DDGroup"
      # getTargetFromEvent return file or view (on empty area)
      getTargetFromEvent: (e) ->
        target = e.getTarget(view.rowSelector)
        return target ? target : view.getEl()

      onNodeOver: (nodeData, source, e, data) ->
        FM.Logger.debug('onNodeOver()', arguments, view.ownerCt)

        source_panel = FM.helpers.GetComponentByDomEl(source.getEl()).ownerCt
        target_panel = view.ownerCt.ownerCt

        source_records = data.records
        target_record = view.getRecord(e.getTarget())

        FM.Logger.debug('source_panel', source_panel)
        FM.Logger.debug('target_panel', target_panel)

        FM.Logger.debug('source_records', source_records)
        FM.Logger.debug('target_record', target_record)

        if !FM.helpers.isAllowed(FM.Actions.Copy, source_panel, source_records)
          return Ext.dd.DropZone.prototype.dropNotAllowed

        # if drop to gridview container (not item)
        if e.getTarget() == view.getEl().dom
          if not _.isEqual(target_panel.session, source_panel.session)
            return Ext.dd.DropZone.prototype.dropAllowed
          else
            return Ext.dd.DropZone.prototype.dropNotAllowed

        # if drop to item
        if target_record?
          return Ext.dd.DropZone.prototype.dropAllowed

        return Ext.dd.DropZone.prototype.dropNotAllowed

      onNodeDrop: (nodeData, source, e, data) ->
        FM.Logger.debug('onNodeDrop()', arguments, view.ownerCt)

        source_panel = FM.helpers.GetComponentByDomEl(source.getEl()).ownerCt
        target_panel = view.ownerCt.ownerCt

        source_records = data.records
        target_record = view.getRecord(e.getTarget())

        FM.Logger.debug('source_panel', source_panel)
        FM.Logger.debug('target_panel', target_panel)

        FM.Logger.debug('source_records', source_records)
        FM.Logger.debug('target_record', target_record)

        if !FM.helpers.isAllowed(FM.Actions.Copy, source_panel, source_records)
          return

        FM.Logger.debug('to copy')

        if target_record?
          if target_record.get('is_dir')
            FM.Logger.debug('target_path = ', FM.helpers.GetAbsName(target_panel.session, target_record))
            FM.Actions.Copy.execute(source_panel, target_panel, FM.helpers.GetAbsName(target_panel.session, target_record), source_records)
          else
            FM.Logger.debug('target_path = ', target_panel.session.path)
            FM.Actions.Copy.execute(source_panel, target_panel, target_panel.session.path, source_records)
        else
          FM.Logger.debug('target_path = ', target_panel.session.path)
          FM.Actions.Copy.execute(source_panel, target_panel, target_panel.session.path, source_records)

  initEventsHandlers: () ->
    @handlers =
      gridview:
        beforecontainermousedown: (view) ->
          panel = view.ownerCt.ownerCt
          FM.helpers.SetActivePanel(panel)
        beforeitemmousedown: (view) ->
          panel = view.ownerCt.ownerCt
          FM.helpers.SetActivePanel(panel, false, false)
          # close opened menus
          menus = Ext.ComponentQuery.query('menu[name=fm-file-list-context-menu]')
          for menu in menus
            menu.close()
        itemdblclick: (view, record) ->
          panel = view.ownerCt.ownerCt
          FM.Actions.OpenFile.execute(panel, record)
        itemkeydown: (view, record, item, index, e) ->
          panel = view.ownerCt.ownerCt
          key = e.getKey()
          if key == Ext.event.Event.ENTER
            if record.get('is_dir')
              path = FM.helpers.GetAbsName(panel.session, record)
              FM.Actions.Open.execute(panel, path)
        itemcontextmenu: (view, rec, node, index, event) ->
          panel = view.ownerCt.ownerCt
          # stops the default event. i.e. Browser Context Menu
          event.stopEvent()
          if panel.hasContextMenu(rec)
            grid_context_menu = panel.getContextMenu(rec)

            # show context menu where user right clicked
            grid_context_menu.showAt(event.getXY())
        containercontextmenu: (view, event) ->
          panel = view.ownerCt.ownerCt
          # stops the default event. i.e. Browser Context Menu)
          event.stopEvent()
          #show context menu where user right clicked
          panel.empty_context_menu.showAt(event.getXY())
        selectionchange: (selection, selected) ->
          FM.Logger.debug('selectionchange() called', arguments)
          if selection.view?
            panel = selection.view.ownerCt.ownerCt
            real_selected = FM.helpers.GetSelected(panel)
            FM.getApplication().fireEvent(FM.Events.main.selectFiles, panel, real_selected)

    FM.Logger.log('FileList initEventsHandlers() called', @handlers)

  removeEvents: () ->
    FM.Logger.log('Panel removeEvents() called', @handlers)

    gridView = @getView()
    for key of @handlers.gridview
      gridView.removeListener(key, @handlers.gridview[key])

    FM.Logger.debug('Panel events removed', @handlers)

  initHomeConfig: () ->
    @setConfig
      columns: [
        {
          header: t("Name")
          dataIndex: "name"
          hideable: false
          draggable: false
          flex: true
          sort: (direction) ->
            grid = @up('tablepanel')
            store = grid.store

            if not direction?
              dir = if @sortState == 'ASC' then 'DESC' else 'ASC'
            else
              dir = direction

            koef = if dir == 'ASC' then 1 else -1
            field = []

            sorter = Ext.create 'Ext.util.Sorter',
              direction: dir
              sorterFn: (a, b) ->
                an = a.get('name')
                bn = b.get('name')

                adir = a.get('is_dir')
                bdir = b.get('is_dir')

                if an == '..'
                  return -1 * koef
                else if bn == '..'
                  return koef
                else if adir == bdir
                  return if an > bn then 1 else -1
                else
                  if adir
                    return -1
                  else if bdir
                    return 1

                  return if an > bn then 1 else -1

            field.push(sorter)
            Ext.suspendLayouts()
            @sorting = true
            store.sort(field, undefined, if grid.multiColumnSort then 'multi' else 'replace')

            # Теперь адовый костыль ингаче не работает в ExtJS 5 так как в ф-ю setSortState прилетает undefined
            do (sorter) =>
              direction = sorter.getDirection()
              ascCls = @ascSortCls
              descCls = @descSortCls
              rootHeaderCt = @getRootHeaderCt()
              changed = undefined

              if direction == 'DESC'
                if !@hasCls(descCls)
                  @addCls(descCls)
                  @sortState = 'DESC'
                  changed = true
                @removeCls(ascCls)
              else if direction == 'ASC'
                if !@hasCls(ascCls)
                  @addCls(ascCls)
                  @sortState = 'ASC'
                  changed = true
                @removeCls(descCls)
              else
                @removeCls([ascCls, descCls])
                @sortState = null

              if changed
                rootHeaderCt.fireEvent('sortchange', rootHeaderCt, @, direction)
            delete @sorting
            Ext.resumeLayouts(true)

          renderer: (value, metaData, record) ->
            is_dir = record.get("is_dir")
            is_link = record.get("is_link")
            is_share = record.get("is_share")
            ext = ''

            if is_dir
              ext = "_dir"
            else
              ext = record.get("ext").toLowerCase()

            if is_link
              ext = "_link"

            if is_share
              ext = "_share"

            metaData.style = "background-image: url(/fm/resources/images/sprites/icons_16.png)"
            metaData.tdCls = if ext != '' then "cell-icon icon-16-" + ext else "cell-icon icon-16-_blank"
            return if is_dir then value else FM.helpers.GetFileName(value)
        },
        {
          header: t("Type")
          dataIndex: "ext"
          width: 55
        },
        {
          header: t("Size"),
          dataIndex: "size",
          width: 60,
          renderer: (value, metaData, record) ->
            if record.get("is_dir") and !record.get('loaded')
              return "[DIR]"
            if record.get("is_link")
              return "[LINK]"

            return Ext.util.Format.fileSize(value)
        },
        {
          header: t("Owner")
          dataIndex: "owner",
          hidden: false
        },
        {
          header: t("Base64")
          dataIndex: "base64"
          hidden: true
        },
        {
          header: t("Attributes")
          dataIndex: "mode"
          width: 55
        },
        {
          header: t("Modified")
          dataIndex: "mtime"
          width: 125
          renderer: (value, metaData, record) ->
            return record.get("mtime_str")
        }
      ]

    gridView = @getView()
    gridView.on
      beforecontainermousedown: @handlers.gridview.beforecontainermousedown
      beforeitemmousedown: @handlers.gridview.beforeitemmousedown
      itemdblclick: @handlers.gridview.itemdblclick
      itemkeydown: @handlers.gridview.itemkeydown
      itemcontextmenu: @handlers.gridview.itemcontextmenu
      containercontextmenu: @handlers.gridview.containercontextmenu
      selectionchange: @handlers.gridview.selectionchange

  initPublicFtpConfig: () ->
    FM.Logger.debug("initPublicFtpConfig() called", arguments)

    @setConfig
      columns: [
        {
          header: t("Name")
          dataIndex: "name"
          hideable: false
          draggable: false
          flex: true
          sort: (direction) ->
            grid = @up('tablepanel')
            store = grid.store

            if not direction?
              dir = if @sortState == 'ASC' then 'DESC' else 'ASC'
            else
              dir = direction

            koef = if dir == 'ASC' then 1 else -1
            field = []

            sorter = Ext.create 'Ext.util.Sorter',
              direction: dir
              sorterFn: (a, b) ->
                an = a.get('name')
                bn = b.get('name')

                adir = a.get('is_dir')
                bdir = b.get('is_dir')

                if an == '..'
                  return -1 * koef
                else if bn == '..'
                  return koef
                else if adir == bdir
                  return if an > bn then 1 else -1
                else
                  if adir
                    return -1
                  else if bdir
                    return 1

                  return if an > bn then 1 else -1

            field.push(sorter)
            Ext.suspendLayouts()
            @sorting = true
            store.sort(field, undefined, if grid.multiColumnSort then 'multi' else 'replace')

            # Теперь адовый костыль ингаче не работает в ExtJS 5 так как в ф-ю setSortState прилетает undefined
            do (sorter) =>
              direction = sorter.getDirection()
              ascCls = @ascSortCls
              descCls = @descSortCls
              rootHeaderCt = @getRootHeaderCt()
              changed = undefined

              if direction == 'DESC'
                if !@hasCls(descCls)
                  @addCls(descCls)
                  @sortState = 'DESC'
                  changed = true
                @removeCls(ascCls)
              else if direction == 'ASC'
                if !@hasCls(ascCls)
                  @addCls(ascCls)
                  @sortState = 'ASC'
                  changed = true
                @removeCls(descCls)
              else
                @removeCls([ascCls, descCls])
                @sortState = null

              if changed
                rootHeaderCt.fireEvent('sortchange', rootHeaderCt, @, direction)
            delete @sorting
            Ext.resumeLayouts(true)

          renderer: (value, metaData, record) ->
            is_dir = record.get("is_dir")
            is_link = record.get("is_link")
            is_share = record.get("is_share")
            ext = ''

            if is_dir
              ext = "_dir"
            else
              ext = record.get("ext").toLowerCase()

            if is_link
              ext = "_link"

            if is_share
              ext = "_share"

            metaData.style = "background-image: url(/fm/resources/images/sprites/icons_16.png)"
            metaData.tdCls = if ext != '' then "cell-icon icon-16-" + ext else "cell-icon icon-16-_blank"
            return if is_dir then value else FM.helpers.GetFileName(value)
        },
        {
          header: t("Type")
          dataIndex: "ext"
          width: 55
        },
        {
          header: t("Size"),
          dataIndex: "size",
          width: 60,
          renderer: (value, metaData, record) ->
            if record.get("is_dir") and !record.get('loaded')
              return "[DIR]"
            if record.get("is_link")
              return "[LINK]"

            return Ext.util.Format.fileSize(value)
        },
        {
          header: t("Owner")
          dataIndex: "owner",
          hidden: false
        },
        {
          header: t("Base64")
          dataIndex: "base64"
          hidden: true
        },
        {
          header: t("Attributes")
          dataIndex: "mode"
          width: 55
        },
        {
          header: t("Modified")
          dataIndex: "mtime"
          width: 125
          renderer: (value, metaData, record) ->
            return record.get("mtime_str")
        }
      ]

    gridView = @getView()
    gridView.on
      beforecontainermousedown: @handlers.gridview.beforecontainermousedown
      beforeitemmousedown: @handlers.gridview.beforeitemmousedown
      itemdblclick: @handlers.gridview.itemdblclick
      itemkeydown: @handlers.gridview.itemkeydown
      itemcontextmenu: @handlers.gridview.itemcontextmenu
      containercontextmenu: @handlers.gridview.containercontextmenu
      selectionchange: @handlers.gridview.selectionchange

  initLocalAppletConfig: () ->
    @setConfig
      columns: [
        {
          header: t("Name"),
          dataIndex: "name",
          hideable: false,
          draggable: false,
          flex: true,
          renderer: (value, metaData, record) ->
            is_dir = record.get("is_dir");
            is_link = record.get("is_link");
            is_share = record.get("is_share");
            ext = '';

            if is_dir
              ext = "_dir"
            else
              ext = record.get("ext").toLowerCase()

            if is_link
              ext = "_link"

            if is_share
              ext = "_share"

            metaData.style = "background-image: url(/fm/resources/images/sprites/icons_16.png)";
            metaData.tdCls = if ext != '' then "cell-icon icon-16-" + ext else "cell-icon icon-16-_blank";
            return if is_dir then value else FM.helpers.GetFileName(value)
        },
        {
          header: t("Type")
          dataIndex: "ext"
          width: 55
        },
        {
          header: t("Size"),
          dataIndex: "size",
          width: 60,
          renderer: (value, metaData, record) ->
            if record.get("is_dir") and !record.get('loaded')
              return "[DIR]"
            if record.get("is_link")
              return "[LINK]"

            return Ext.util.Format.fileSize(value)
        },
        {
          header: t("Owner")
          dataIndex: "owner",
          hidden: false
        },
        {
          header: t("Base64")
          dataIndex: "base64"
          hidden: true
        },
        {
          header: t("Attributes")
          dataIndex: "mode"
          width: 55
        },
        {
          header: t("Modified")
          dataIndex: "mtime"
          width: 125
          renderer: (value, metaData, record) ->
            return record.get("mtime_str")
        }
      ]

    gridView = @getView()
    gridView.on
      beforecontainermousedown: @handlers.gridview.beforecontainermousedown
      beforeitemmousedown: @handlers.gridview.beforeitemmousedown
      itemdblclick: @handlers.gridview.itemdblclick
      itemkeydown: @handlers.gridview.itemkeydown
      itemcontextmenu: @handlers.gridview.itemcontextmenu
      containercontextmenu: @handlers.gridview.containercontextmenu
      selectionchange: @handlers.gridview.selectionchange

  initHomeStore: () ->
    FM.Logger.debug('call initHomeStore()')

    store = Ext.create "Ext.data.Store",
      autoLoad: false
      sortOnLoad: false
      model: 'FM.model.File'

    @setStore(store)

  initPublicFtpStore: () ->
    FM.Logger.debug("initPublicFtpStore() called", arguments)

    store = Ext.create "Ext.data.Store",
      autoLoad: false
      sortOnLoad: true
      model: 'FM.model.File'
      sorters: [
        property: "name"
        direction: "ASC"
      ]

    @setStore(store)

  initLocalAppletStore: () ->
    store = Ext.create "Ext.data.Store",
      autoLoad: false
      sortOnLoad: true
      model: 'FM.model.File'
      sorters: [
        property: "name"
        direction: "ASC"
      ]
    @setStore(store)

  hasListCache: (path) ->
    FM.Logger.log("checking cache ", path, @list_cache, @list_cache[path]?)

    if @list_cache[path]? and @list_cache[path].items? and @list_cache[path].items.length > 0
      FM.Logger.log("cache exist ", @list_cache[path])
      return true

    FM.Logger.log("no cache ")
    return false

  setListCache: (path, listing) ->
    @list_cache[path] = Ext.ux.Util.clone(listing)

  clearListCache : () ->
    @list_cache = {}

  getListCache: (path) ->
    if @hasListCache(path)
      return @list_cache[path]

    return []

  setFileList: (listing) ->
    FM.Logger.debug("setFileList() called ", @toString(), @getSession, FM.Left.session, FM.Right.session, listing)

    @getStore().loadData(listing.items)

    panel = @ownerCt

    panel.session.path = listing.path
    panel.updatePathBar()
    panel.updateStatusBar()

    @setListCache(listing.path, listing)
    columns = Ext.ComponentQuery.query('gridcolumn[dataIndex=name]', @)
    columns[0].sort("ASC")

    FM.helpers.UnsetLoading(panel.body)

  addFile: (file) ->
    FM.Logger.log("addFile called ", @ownerCt.toString(), @getSession(), FM.Left.session, FM.Right.session, file)

    @getStore().add(file)

    panel = @ownerCt

    panel.updatePathBar()
    panel.updateStatusBar()

    columns = Ext.ComponentQuery.query('gridcolumn[dataIndex=name]', @)
    columns[0].sort("ASC")

  addFiles: (files) ->
    FM.Logger.log("addFiles called ", @ownerCt.toString(), @getSession(), FM.Left.session, FM.Right.session, files)

    for file in files
      @getStore().add(file)

    panel = @ownerCt

    panel.updatePathBar()
    panel.updateStatusBar()

    columns = Ext.ComponentQuery.query('gridcolumn[dataIndex=name]', @)
    columns[0].sort("ASC")

  initHotKeys: () ->
    FM.Logger.log('initHotKeys()', @)
    panel = @ownerCt

    if FM.HotKeys[panel.toString()]?
      FM.HotKeys[panel.toString()].destroy()

    FM.HotKeys[panel.toString()] = new Ext.util.KeyMap
      target: @getEl()
      binding: [
        {
          key: Ext.event.Event.TAB
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            FM.helpers.SetActivePanel(FM.Inactive)
            FM.Active.filelist.getView().focus()
            e.stopEvent()
        },
        {
          key: Ext.event.Event.F2
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            record = FM.helpers.GetLastSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.Rename, FM.Active, [record])
              FM.Actions.Rename.execute(FM.Active, record)
            e.stopEvent()
        },
        {
          key: Ext.event.Event.BACKSPACE
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            record = FM.Active.filelist.getStore().findRecord("name", "..")
            if record?
              path = FM.helpers.GetAbsName(FM.Active.session, record)
              FM.Actions.Open.execute(FM.Active, path)
            e.stopEvent()
        },
        {
          key: Ext.event.Event.DELETE
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            records = FM.helpers.GetSelected(FM.Active)
            if records.length == 0
              e.stopEvent()
              return
            else
              if FM.helpers.isAllowed(FM.Actions.Remove, FM.Active, records)
                FM.Actions.Remove.execute(FM.Active, FM.helpers.GetAbsNames(FM.Active.session, records))
              e.stopEvent()
        },
        {
          key: Ext.event.Event.ENTER
          fn: FM.HotKeys.HotKeyDecorator (key, e) =>
            FM.Logger.debug("ENTER", panel, arguments)
            selection_array = @getView().getSelectionModel().getSelection();

            if selection_array.length > 1
              e.stopEvent()
              return

            if selection_array.length == 1
              record = selection_array[0]
              path = FM.helpers.GetAbsName(@getSession(), record)
              FM.Actions.Open.execute(panel, path)

            e.stopEvent()
        },
        {
          key: Ext.event.Event.ESC
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            FM.helpers.SelectDefault(FM.Active)
            e.stopEvent()
        },
        {
          key: "a"
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            FM.Logger.debug("Ctrl + A", panel, arguments)
            FM.Active.filelist.getView().getSelectionModel().selectAll()
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_THREE, Ext.event.Event.THREE]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            record = FM.helpers.GetLastSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.View, FM.Active, [record])
              FM.Actions.View.execute(FM.Active, record)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_FOUR, Ext.event.Event.FOUR]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            record = FM.helpers.GetLastSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.Edit, FM.Active, [record])
              FM.Actions.Edit.execute(FM.Active, record)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_FIVE, Ext.event.Event.FIVE]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            records = FM.helpers.GetSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.Copy, FM.Active, records)
              FM.Actions.Copy.execute(FM.Active, FM.Inactive, FM.Inactive.session.path, records)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_FIVE, Ext.event.Event.FIVE]
          shift: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            records = FM.helpers.GetSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.Move, FM.Active, records)
              FM.Actions.Move.execute(FM.Active, FM.Inactive, records)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_SIX, Ext.event.Event.SIX]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            record = FM.helpers.GetLastSelected(FM.Active)
            if FM.helpers.isAllowed(FM.Actions.Rename, FM.Active, [record])
              FM.Actions.Rename.execute(FM.Active, record)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_SEVEN, Ext.event.Event.SEVEN]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            if FM.helpers.isAllowed(FM.Actions.NewFolder, panel, [])
              FM.Actions.NewFolder.execute(panel)
            e.stopEvent()
        },
        {
          key: [Ext.event.Event.NUM_EIGHT, Ext.event.Event.EIGHT]
          ctrl: true
          fn: FM.HotKeys.HotKeyDecorator (key, e) ->
            records = FM.helpers.GetSelected(panel)
            if records.length == 0
              e.stopEvent()
              return
            else
              if FM.helpers.isAllowed(FM.Actions.Remove, panel, records)
                FM.Actions.Remove.execute(panel, FM.helpers.GetAbsNames(panel.session, records))
              e.stopEvent()
        },
      ]