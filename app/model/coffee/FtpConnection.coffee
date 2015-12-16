Ext.define 'FM.model.FtpConnection',
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
    FM.Logger.debug('FtpConnection initConnection() called', arguments)
    FM.Actions.OpenFtp.execute panel,
      type: FM.Session.PUBLIC_FTP
      path: '/'
      server_id: @get('id')