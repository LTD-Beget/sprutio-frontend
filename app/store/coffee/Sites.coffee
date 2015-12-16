Ext.define 'FM.store.Sites',
  extend: 'Ext.data.Store'
  storeId: 'FtpConnections'
  sortOnLoad: true
  model: 'FM.model.Site'
  sorters: [
    property: "id"
    direction: "ASC"
  ]