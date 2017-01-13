Ext.define 'FM.view.forms.SearchTextForm',
  extend: 'Ext.form.Panel'
  alias: 'widget.search-text-form'
  cls: 'fm-search-text-form'
  items: []
  bodyStyle:
    background: 'none'
  bodyPadding: '10 15 15 15'
  requires: [
    'Ext.ux.form.SearchField'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.fieldsets.SearchTextForm init')

    @items = []

    @items.push
      xtype: 'textfield'
      name: 'search-file-text'
      cls: 'search-file-text'
      fieldLabel: t("Text In File")
      labelAlign: 'top'
      allowBlank: false
      minLength: 1
      maxLength: 255
      enforceMaxLength: 255
      regex: /^[a-zA-Z\.0-9:\-_\*\$@%\/а-яА-Я]{1,255}$/
      regexText: t("Incorrect text")
      anchor: '100%'

    @items.push
      xtype: 'textfield'
      name: 'search-text-path'
      cls: 'search-text-path'
      fieldLabel: t("Search Path")
      labelAlign: 'top'
      allowBlank: false
      minLength: 1
      maxLength: 255
      enforceMaxLength: 255
      regex: /^[a-zA-Z.0-9\-_а-яА-Я\/]{1,255}$/
      regexText: t("Incorrect path")
      anchor: '100%'

    store = Ext.create "Ext.data.Store",
      model: 'FM.model.File'

    @items.push
      xtype: 'searchfield'
      fieldLabel: t("Filter")
      labelAlign: 'top'
      name: 'search-text-filter'
      cls: 'search-text-filter'
      anchor: '100%'
      store: store

      onClearClick: () ->
        if @activeFilter
          @setValue ''

          fileListStore = @ownerCt.ownerCt.fileListStore
          fileListStore.getFilters().remove @activeFilter

          @activeFilter = null
          @getTrigger('clear').hide()
          @updateLayout()


      onSearchClick: () ->
        # we need to go deeper :D
        fileListStore = @ownerCt.ownerCt.fileListStore
        @activeFilter = new Ext.util.Filter
          anyMatch: true
          exactMatch: false
          caseSensitive: true
          property: 'name'
          value: @getValue()

        fileListStore.addFilter @activeFilter

        @getTrigger('clear').show()
        @updateLayout()

    @callParent(arguments)