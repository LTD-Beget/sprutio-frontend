Ext.define 'FM.model.Site',
  extend: 'Ext.data.Model'
  fields: [
    {
      name: "id"
      useNull: true
    },
    {
      name: "domain"
    },
    {
      name: "path"
    },
    {
      name: "isolated"
    }
  ]