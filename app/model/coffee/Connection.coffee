Ext.define 'FM.model.Connection',
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
      name: "port"
    },
    {
      name: "user"
    },
    {
      name: "decryptedPassword"
    },
    {
      name: "type"
    }
  ]
  initConnection: (panel) ->
    FM.Logger.debug('Connection initConnection() choosing...', arguments)

    server_id = parseInt(@get('id').replace(/(sf|f)tp/, ''))

    if @get('type') == 'sftp'
      FM.Logger.debug('Connection initConnection() SFTP called', arguments)
      FM.Actions.OpenRemoteConnection.execute panel,
        type: FM.Session.SFTP
        path: '.'
        server_id: server_id

    if @get('type') == 'ftp' or @get('type') == ''
      FM.Logger.debug('Connection initConnection() FTP called', arguments)
      FM.Actions.OpenRemoteConnection.execute panel,
        type: FM.Session.FTP
        path: '/'
        server_id: server_id
