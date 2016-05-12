Ext.define 'FM.model.WebDavConnection',
  extend: 'Ext.data.Model'
  fields: [
    {
      name: "id"
      useNull: true
    },
    {
      name: "host"
    },
    {
      name: "user"
    },
    {
      name: "decryptedPassword"
    }
  ]
  initConneciton: (panel) ->
    FM.Logger.debug('WebDavConnection initConnection() called', arguments)
    FM.Actions.OpenWebDav.execute panel,
      type: FM.Session.PUBLIC_WEBDAV
      path: '/'
      server_id: @get('id')