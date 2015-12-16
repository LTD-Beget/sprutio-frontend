Ext.define 'FM.view.forms.IPBlockForm',
  extend: 'Ext.form.Panel'
  requires: [
    'Ext.form.field.Text'
    'FM.view.grids.IPBlockList'
  ]
  alias: 'widget.ip-block-form'
  cls: 'fm-ip-block-form'
  items: []
  bodyStyle:
    background: 'none'

  initComponent: () ->
    FM.Logger.log('FM.view.forms.IPBlockForm init')

    @items = []

    @items.push
      xtype: 'box'
      html: t("Allowed IP")
      padding: '0 15 5 15'

    @items.push
      xtype: 'ip-block-list'
      name: 'ip-allowed-list'
      height: 150
      margin: '0 0 10 0'

    @items.push
      xtype: 'checkbox'
      boxLabel: t("Allow All")
      name: 'allow-all'
      padding: '0 15 5 15'
      listeners:
        change: (field, newValue) =>
          if newValue
            grid = Ext.ComponentQuery.query('ip-block-list', @)[0]
            grid.setDisabled(true)

            ## hack because bug in x-mask on toolbar
            $('#' + grid.getId() + ' .x-toolbar .x-mask').removeClass('x-mask')
          else
            grid = Ext.ComponentQuery.query('ip-block-list', @)[0]
            grid.setDisabled(false)

            ## hack because bug in x-mask on toolbar
            $('#' + grid.getId() + ' .x-toolbar .x-mask').removeClass('x-mask')

    @items.push
      xtype: 'box'
      html: '<hr style="height: 1px; border: 0; color: #AEB8C4; background-color: #AEB8C4;"/>'

    @items.push
      xtype: 'box'
      html: t("Blocked IP")
      padding: '5 15 5 15'

    @items.push
      xtype: 'ip-block-list'
      name: 'ip-denied-list'
      height: 150
      margin: '0 0 10 0'

    @items.push
      xtype: 'checkbox'
      boxLabel: t("Deny All")
      name: 'deny-all'
      padding: '0 15 5 15'
      listeners:
        change: (field, newValue) =>
          if newValue
            grid = Ext.ComponentQuery.query('ip-block-list', @)[1]
            grid.setDisabled(true)

            ## hack because bug in x-mask on toolbar
            $('#' + grid.getId() + ' .x-toolbar .x-mask').removeClass('x-mask')
          else
            grid = Ext.ComponentQuery.query('ip-block-list', @)[1]
            grid.setDisabled(false)

            ## hack because bug in x-mask on toolbar
            $('#' + grid.getId() + ' .x-toolbar .x-mask').removeClass('x-mask')

    @items.push
      xtype: 'combobox'
      name: 'rule-process'
      displayField: 'title'
      valueField: 'slug'
      queryMode: 'local'
      fieldLabel: t("Advanced Params")
      emptyText: 'Rule'
      labelAlign: 'top'
      hideLabel: false
      layout: "anchor"
      anchor: "100%"
      border: '1 0 0 0'
      defaults:
        flex: 1
      padding: '5 15 5 15'
      store: new Ext.data.Store
        fields: ['title', 'slug']
        data: [
          {
            title: t("Allow, Deny")
            slug: 'allow-deny'
          },
          {
            title: t("Deny, Allow")
            slug: 'deny-allow'
          }
        ]

    @callParent(arguments)