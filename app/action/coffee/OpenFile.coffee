Ext.define 'FM.action.OpenFile',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-open-file"
    text: t("Open File")
    handler: (panel, record) ->
      FM.Logger.info('Run Action FM.action.OpenFile', arguments)

      if record.get('is_dir')
        path = FM.helpers.GetAbsName(panel.session, record)
        FM.Actions.Open.execute(panel, path)

      if record.get('is_link')
        return

      extension = record.get("ext")
      name = record.get('name')

      # Auto open text files
      if extension.match(FM.Regex.TextFilesExt)
        if FM.helpers.isAllowed(FM.Actions.Edit, panel, [record])
          FM.Actions.Edit.execute(panel, record)
        else if FM.helpers.isAllowed(FM.Actions.View, panel, [record])
          FM.Actions.View.execute(panel, record)
        return

      if name.match(FM.Regex.TextFilesConf)
        if FM.helpers.isAllowed(FM.Actions.Edit, panel, [record])
          FM.Actions.Edit.execute(panel, record)
        else if FM.helpers.isAllowed(FM.Actions.View, panel, [record])
          FM.Actions.View.execute(panel, record)
        return

      # Auto open image files
      if extension.match(FM.Regex.ImageFilesExt)
        if FM.helpers.isAllowed(FM.Actions.View, panel, [record])
          FM.Actions.View.execute(panel, record)
        return

      # Download in any case
      if FM.helpers.isAllowed(FM.Actions.DownloadBasic, panel, [record])
        FM.Actions.DownloadBasic.execute(panel, record)

      return