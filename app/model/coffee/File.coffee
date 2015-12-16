Ext.define 'FM.model.File',
  extend: 'Ext.data.Model'
  fields: [
    { name: "is_dir", type: "boolean", defaultValue: false },
    { name: "is_link", type: "boolean", defaultValue: false },
    { name: "is_share", type: "boolean", defaultValue: false },
    { name: "is_share_write", type: "boolean", defaultValue: false },
    { name: "loaded", type: "boolean", defaultValue: false },
    { name: "name" },
    { name: "path" },
    { name: "src", defaultValue: undefined },
    { name: "ext", defaultValue: '' },
    { name: "owner" },
    { name: "base64", defaultValue: '' },
    { name: "color", defaultValue: false },
    { name: "mode" },
    { name: "size", type: "int", defaultValue: 0 },
    { name: "mtime", type: "date", dateFormat: "timestamp" },
    { name: "mtime_str" },
    { name: "pid" }
  ]

  isAllowed: (action, panel, multiple = false) ->

    # name of the action class
    action_name = action.self.getName()
    FM.Logger.debug('Checking isAllowed() record action', arguments)

    allowed_multiple = {}

    allowed_multiple[FM.Actions.DownloadArchive.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadZip.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadBZ2.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadGZip.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadTar.self.getName()] = true
    allowed_multiple[FM.Actions.CreateArchive.self.getName()] = true
    allowed_multiple[FM.Actions.CreateCopy.self.getName()] = true
    allowed_multiple[FM.Actions.Copy.self.getName()] = true
    allowed_multiple[FM.Actions.Move.self.getName()] = true
    allowed_multiple[FM.Actions.Chmod.self.getName()] = true
    allowed_multiple[FM.Actions.Remove.self.getName()] = true
    allowed_multiple[FM.Actions.Refresh.self.getName()] = true

    if multiple and not allowed_multiple[action_name]? and not allowed_multiple[action_name]
      return false

    # hacks
    if FM.Actions.ExtractArchive.self.getName() == action_name and @get("ext") in ['zip','rar', '7z', 'gz', 'bz2', 'arch']
      return true

    if panel.actions[action_name]?
      panel_action = panel.actions[action_name]
      record_actions = @get('actions')

      if record_actions? and record_actions[action_name]?
        record_action = record_actions[action_name]
        return if record_action then true else false

      else
        return if panel_action then true else false

    return false