Ext.define 'FM.view.grids.FileSizeList',
  extend: 'Ext.grid.Panel'
  alias: 'widget.file-size-list'
  cls: 'fm-file-size-list'
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
  minHeight: 230
  maxHeight: 230
  initComponent: () ->
    FM.Logger.log('FM.view.grids.FileSizeList init')
    @callParent(arguments)
    @initGridConfig()

    FM.Logger.debug('FM.view.grids.FileSizeList finish')

  initGridConfig: () ->

    FM.Logger.debug('FM.view.grids.FileSizeList initGridConfig() call')

    @setConfig
      columns: [
        {
          header: t("Color")
          width: 55
          renderer: (value, metaData, record) ->
            return '<div class="color-box" style="background-color: ' + record.get('color') + '">'
        },
        {
          header: t("Size")
          dataIndex: "size"
          width: 75
          renderer: (value, metaData, record) ->
            if record.get("is_dir") and !record.get('loaded') and not (value > 0)
              return "[DIR]"
            if record.get("is_link") and not (value > 0)
              return "[LINK]"

            return Ext.util.Format.fileSize(value)
        },
        {
          header: t("Name")
          dataIndex: "name"
          hideable: false
          draggable: false
          width: 350
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
          header: t("Path")
          dataIndex: "path"
          hidden: false
          width: 100
          renderer: (value, metaData, record) ->
            metaData.style = "background-image: url(/fm/resources/images/sprites/icons_16.png)";
            metaData.tdCls = "cell-icon icon-16-_dir"
            return value
        }
      ]

  setFileList: (listing) ->
    FM.Logger.log("setFileList in FileSizeList called ", listing)

    store = Ext.create "Ext.data.Store",
      sortOnLoad: false
      model: 'FM.model.File'

    @setStore(store)
    @store.loadData(listing)
    columns = Ext.ComponentQuery.query('gridcolumn[dataIndex=size]', @)
    columns[0].sort("DESC")