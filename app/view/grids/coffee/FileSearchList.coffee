Ext.define 'FM.view.grids.FileSearchList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.file-search-list'
  cls: 'fm-file-search-list'
  columns: []
  stateful: true,   ## <-- ???
  multiSelect: false
  viewConfig:
    stripeRows: false
    deferEmptyText: false
    emptyText: t('No results found')
  requires: [
    'FM.model.File'
  ]
  defaults:
    flex: 1
  height: 150

  initComponent: () ->

    FM.Logger.log('FM.view.grids.FileSearchList init')
    @callParent(arguments)
    @initEventsHandlers()
    @initGridConfig()

    if @ownerCt?
      @ownerCt.fileListStore = @store

  initEventsHandlers: () ->
    @handlers =
      gridview:
        itemdblclick: (view, record) ->
          FM.Actions.Open.execute(FM.Active, record.get('path'))

    FM.Logger.log('FileList initEventsHandlers() called', @handlers)

  initGridConfig: () ->
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
            return value
        },
        {
          header: t("Size"),
          dataIndex: "size",
          width: 55,
          renderer: (value, metaData, record) ->
            if record.get("is_dir") and !record.get('loaded')
              return "[DIR]"
            if record.get("is_link")
              return "[LINK]"

            return Ext.util.Format.fileSize(value)
        },
        {
          header: t("Path")
          dataIndex: "path"
          hidden: false
          flex:true
          renderer: (value, metaData, record) ->
            metaData.style = "background-image: url(/fm/resources/images/sprites/icons_16.png)";
            metaData.tdCls = "cell-icon icon-16-_dir"
            return value
        }
      ]

    gridView = @getView()
    gridView.on
      itemdblclick: @handlers.gridview.itemdblclick

  setFileList: (listing) ->
    FM.Logger.log("setFileList in FileSearchList called ", listing)

    store = Ext.create "Ext.data.Store",
      sortOnLoad: false
      model: 'FM.model.File'

    @ownerCt.updateSearchFilterState listing.length < 1

    @setStore(store)
    @store.loadData(listing)

    if @ownerCt?
      @ownerCt.fileListStore = @store

    columns = Ext.ComponentQuery.query('gridcolumn[dataIndex=name]', @)
    columns[0].sort("ASC")