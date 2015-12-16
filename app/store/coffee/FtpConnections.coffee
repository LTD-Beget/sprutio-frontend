Ext.define 'FM.store.FtpConnections',
  extend: 'Ext.data.Store'
  storeId: 'FtpConnections'
  sortOnLoad: true
  model: 'FM.model.FtpConnection'
  sorters: [
    property: "id"
    direction: "ASC"
  ]