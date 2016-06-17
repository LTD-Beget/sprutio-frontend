Ext.define 'FM.store.Connections',
  extend: 'Ext.data.Store'
  storeId: 'Connections'
  sortOnLoad: true
  model: 'FM.model.Connection'
  sorters: [
    property: "id"
    direction: "ASC"
  ]