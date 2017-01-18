Ext.define 'FM.view.forms.SearchFileForm',
  extend: 'Ext.form.Panel'
  alias: 'widget.search-file-form'
  cls: 'fm-search-file-form'
  items: []
  bodyStyle:
    background: 'none'
  bodyPadding: '10 15 15 15'
  requires: [
    'Ext.ux.form.SearchField'
    'Ext.form.field.Checkbox'
    'Ext.form.Label'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.fieldsets.SearchTextForm init')

    @items = []

    @items.push
      xtype: 'textfield'
      name: 'search-file-name'
      cls: 'search-file-name'
      fieldLabel: t("File Name")
      labelAlign: 'top'
      allowBlank: false
      minLength: 1
      maxLength: 255
      enforceMaxLength: 255
      regex: /^[a-zA-Z.0-9\-_\*а-яА-Я]{1,255}$/
      regexText: t("Incorrect filename")
      anchor: '100%'

    @items.push
      xtype: 'textfield'
      name: 'search-file-path'
      cls: 'search-file-path'
      fieldLabel: t("Search Path")
      labelAlign: 'top'
      allowBlank: false
      minLength: 1
      maxLength: 255
      enforceMaxLength: 255
      regex: /^[a-zA-Z.0-9\-_а-яА-Я\/]{1,255}$/
      regexText: t("Incorrect path")
      anchor: '100%'

    @items.push
      xtype: 'form'
      layout:
        type: 'hbox'
        padding: 1
      bodyStyle:
        background: 'none'
      bodyPadding: '3 0 3 0'
      items: [
        {
          xtype: 'checkbox'
          checked: true
          boxLabel: t("Files")
          name: 'search-type-file'
          margin: '6 50 0 0'
          listeners:
            change: (field, newValue) =>
              if newValue
                Ext.ComponentQuery.query("[name=search-file-size]", @)[0].setDisabled(false)
                Ext.ComponentQuery.query("[name=search-file-size-direction]", @)[0].setDisabled(false)
                Ext.ComponentQuery.query("[name=search-file-size-label]", @)[0].setDisabled(true)
              else
                Ext.ComponentQuery.query("[name=search-file-size]", @)[0].setDisabled(true)
                Ext.ComponentQuery.query("[name=search-file-size-direction]", @)[0].setDisabled(true)
                Ext.ComponentQuery.query("[name=search-file-size-label]", @)[0].setDisabled(true)
        },
        {
          xtype: 'checkbox'
          checked: true
          boxLabel: t("Directories")
          name: 'search-type-dir'
          margin: '6 0 0 0'
        },
        {
          xtype: 'combobox'
          name: 'search-file-size-direction'
          fieldLabel: t("File Size")
          displayField: 'title'
          labelAlign: 'right'
          valueField: 'slug'
          queryMode: 'local'
          width: 230
          hideLabel: false
          labelWidth: 100
          value: 'more'
          store: new Ext.data.Store
            fields: ['title', 'slug']
            id: "size-direction-store"
            data: [
              {
                title: t("More")
                slug: 'more'
              },
              {
                title: t("Lower")
                slug: 'lower'
              }
            ]
            forceSelection: true
        },
        {
          xtype: 'textfield'
          name: 'search-file-size'
          cls: 'search-file-size'
          allowBlank: true
          style: "margin-left: 5px;"
          width: 115
          minLength: 0
          hideLabel: false
          maxLength: 16
          enforceMaxLength: 16
          maskRe: /[0-9]/
          regex: /^[0-9]{0,16}$/
          regexText: t("Incorrect size")
        },
        {
          xtype: 'label'
          name: 'search-file-size-label'
          text: t("Mb")
          padding: 7
        }
      ]

    store = Ext.create "Ext.data.Store",
      model: 'FM.model.File'

    @items.push
      xtype: 'searchfield'
      fieldLabel: t("Filter")
      labelAlign: 'top'
      name: 'search-file-filter'
      cls: 'search-file-filter'
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