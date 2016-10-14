Ext.define 'FM.view.toolbars.MainTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.main-top-toolbar'
  id: "fm-main-top-toolbar"
  cls: "fm-main-top-toolbar"
  border: false
  style:
    borderStyle: 'none'
  items: []
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.MainTopToolbar init')

    @items = []

    @items.push
      xtype: "button"
      text: t("File")
      menu: [
        {
          text: t("Create")
          iconCls: "fm-action-create"
          name: "fm-action-create"
          menu: [
            {
              text: FM.Actions.NewFile.getMenuText()
              name: FM.Actions.NewFile.getIconCls()
              iconCls: FM.Actions.NewFile.getIconCls()
              handler: () ->
                FM.Actions.NewFile.execute(FM.Active)
            },
            {
              text: FM.Actions.NewFolder.getMenuText()
              name: FM.Actions.NewFolder.getIconCls()
              iconCls: FM.Actions.NewFolder.getIconCls()
              handler: () ->
                FM.Actions.NewFolder.execute(FM.Active)
            }
          ]
        },
        "-",
        {
          text: t("Operations")
          iconCls: "fm-action-operations"
          id: "fm-menu-operations"
          menu: [
            {
              text: FM.Actions.View.getMenuText()
              name: FM.Actions.View.getIconCls()
              iconCls: FM.Actions.View.getIconCls()
              handler: () =>
                record = FM.helpers.GetLastSelected(FM.Active)
                if record? and record.get('name') != '..'
                  FM.Actions.View.execute(FM.Active, record)
                else
                  FM.helpers.ShowError(t("Please select file entry."))
            },
            {
              text: FM.Actions.Edit.getMenuText()
              name: FM.Actions.Edit.getIconCls()
              iconCls: FM.Actions.Edit.getIconCls()
              handler: () =>
                record = FM.helpers.GetLastSelected(FM.Active)
                if record? and record.get('name') != '..'
                  FM.Actions.Edit.execute(FM.Active, record)
                else
                  FM.helpers.ShowError(t("Please select file entry."))
            },
            {
              text: FM.Actions.Rename.getMenuText()
              name: FM.Actions.Rename.getIconCls()
              iconCls: FM.Actions.Rename.getIconCls()
              handler: () =>
                record = FM.helpers.GetLastSelected(FM.Active)
                FM.Actions.Rename.execute(FM.Active, record)
            },
            {
              text: FM.Actions.Copy.getMenuText()
              name: FM.Actions.Copy.getIconCls()
              iconCls: FM.Actions.Copy.getIconCls()
              handler: () ->
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.Copy.execute(FM.Active, FM.Inactive, FM.Inactive.path, records)
            },
            {
              text: FM.Actions.Move.getMenuText()
              name: FM.Actions.Move.getIconCls()
              iconCls: FM.Actions.Move.getIconCls()
              handler: () ->
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.Move.execute(FM.Active, FM.Inactive, records)
            },
            {
              text: FM.Actions.CreateCopy.getMenuText()
              name: FM.Actions.CreateCopy.getIconCls()
              iconCls: FM.Actions.CreateCopy.getIconCls()
              handler: () ->
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.CreateCopy.execute(FM.Active, records)
            },
            {
              text: FM.Actions.CreateArchive.getMenuText()
              name: FM.Actions.CreateArchive.getIconCls()
              iconCls: FM.Actions.CreateArchive.getIconCls()
              handler: () ->
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.CreateArchive.execute(FM.Active, records)
            }
            {
              text: FM.Actions.Chmod.getMenuText()
              name: FM.Actions.Chmod.getIconCls()
              iconCls: FM.Actions.Chmod.getIconCls()
              handler: () ->
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.Chmod.execute(FM.Active, records)
            },
            {
              text: FM.Actions.Remove.getMenuText()
              name: FM.Actions.Remove.getIconCls()
              iconCls: FM.Actions.Remove.getIconCls()
              handler: () ->
                panel = FM.Active
                records = FM.helpers.GetSelected(panel)
                if records.length == 0
                  return
                else
                  FM.Actions.Remove.execute(panel, FM.helpers.GetAbsNames(panel.session, records))
            }
          ]
        },
        "-",
        {
          text: t("Download")
          iconCls: "fm-action-download"
          id: "fm-menu-download"
          menu: [
            {
              text: FM.Actions.DownloadBasic.getMenuText()
              name: FM.Actions.DownloadBasic.getIconCls()
              iconCls: FM.Actions.DownloadBasic.getIconCls()
              handler: () =>
                record = FM.helpers.GetLastSelected(FM.Active)
                FM.Actions.DownloadBasic.execute(FM.Active, record)
            },
            "-"
            {
              text: FM.Actions.DownloadZip.getMenuText()
              name: FM.Actions.DownloadZip.getIconCls()
              iconCls: FM.Actions.DownloadZip.getIconCls()
              handler: () =>
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.DownloadZip.execute(FM.Active, records)
            },
            {
              text: FM.Actions.DownloadGZip.getMenuText()
              name: FM.Actions.DownloadGZip.getIconCls()
              iconCls: FM.Actions.DownloadGZip.getIconCls()
              handler: () =>
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.DownloadGZip.execute(FM.Active, records)
            },
            {
              text: FM.Actions.DownloadBZ2.getMenuText()
              name: FM.Actions.DownloadBZ2.getIconCls()
              iconCls: FM.Actions.DownloadBZ2.getIconCls()
              handler: () =>
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.DownloadBZ2.execute(FM.Active, records)
            },
            {
              text: FM.Actions.DownloadTar.getMenuText()
              name: FM.Actions.DownloadTar.getIconCls()
              iconCls: FM.Actions.DownloadTar.getIconCls()
              handler: () =>
                records = FM.helpers.GetSelected(FM.Active)
                FM.Actions.DownloadTar.execute(FM.Active, records)
            }
          ]
        },
        {
          text: FM.Actions.Upload.getMenuText()
          name: FM.Actions.Upload.getIconCls()
          iconCls: FM.Actions.Upload.getIconCls()
          handler: () =>
            FM.Actions.Upload.execute()
        },
        "-",
        FM.Actions.Logout
      ]

    @items.push
      xtype: "button"
      text: t("Navigation"),
      menu: [
        {
          text: FM.Actions.Open.getMenuText()
          name: FM.Actions.Open.getIconCls()
          iconCls: FM.Actions.Open.getIconCls()
          handler: () =>
            record = FM.helpers.GetLastSelected(FM.Active)

            if record
              if record.get('is_dir')
                FM.Actions.Open.execute(FM.Active, FM.helpers.GetAbsName(FM.Active.session, record))
            else
              FM.helpers.ShowError(t("Please select file entry."))
        },
        "-"
        {
          text: t("Search")
          iconCls: "fm-action-search"
          id: "fm-menu-search"
          menu: [
            {
              text: FM.Actions.SearchFiles.getMenuText()
              name: FM.Actions.SearchFiles.getIconCls()
              iconCls: FM.Actions.SearchFiles.getIconCls()
              handler: () =>
                FM.Actions.SearchFiles.execute(FM.Active)
            },
            {
              text: FM.Actions.SearchText.getMenuText()
              name: FM.Actions.SearchText.getIconCls()
              iconCls: FM.Actions.SearchText.getIconCls()
              handler: () =>
                FM.Actions.SearchText.execute(FM.Active)
            }
          ]
        },
        "-",
        FM.Actions.Navigate,
        {
          text: FM.Actions.Refresh.getMenuText()
          name: FM.Actions.Refresh.getIconCls()
          iconCls: FM.Actions.Refresh.getIconCls()
          handler: () =>
            FM.Actions.Refresh.execute([FM.Left, FM.Right])
        },
        {
          text: FM.Actions.AnalyzeSize.getMenuText()
          name: FM.Actions.AnalyzeSize.getIconCls()
          iconCls: FM.Actions.AnalyzeSize.getIconCls()
          handler: () =>
            FM.Actions.AnalyzeSize.execute(FM.Active, FM.Active.session.path)
        }
        "-",
        {
          text: t("Copy to Clipboard")
          iconCls: "fm-action-copy"
          menu: [
            {
              text: FM.Actions.CopyPath.getMenuText()
              name: FM.Actions.CopyPath.getIconCls()
              iconCls: FM.Actions.CopyPath.getIconCls()
              handler: () ->
                FM.Actions.CopyPath.execute(FM.Active)
            },
            {
              text: FM.Actions.CopyEntry.getMenuText()
              name: FM.Actions.CopyEntry.getIconCls()
              iconCls: FM.Actions.CopyEntry.getIconCls()
              handler: () ->
                FM.Actions.CopyEntry.execute(FM.Active)
            }
          ]
        }
      ]

    @items.push
      xtype: "button"
      text: t("Tools"),
      menu: [
        {
          text: FM.Actions.HomeFtp.getMenuText()
          name: FM.Actions.HomeFtp.getIconCls()
          iconCls: FM.Actions.HomeFtp.getIconCls()
          handler: () ->
            FM.Actions.HomeFtp.execute(FM.Active)
        },
        {
          text: FM.Actions.RemoteConnections.getMenuText()
          name: FM.Actions.RemoteConnections.getIconCls()
          iconCls: FM.Actions.RemoteConnections.getIconCls()
          handler: () ->
            FM.Actions.RemoteConnections.execute(FM.Active)
        },
        {
          text: FM.Actions.RemoteWebDav.getMenuText()
          name: FM.Actions.RemoteWebDav.getIconCls()
          iconCls: FM.Actions.RemoteWebDav.getIconCls()
          handler: () ->
            FM.Actions.RemoteWebDav.execute(FM.Active)
        },
        {
          text: FM.Actions.Terminal.getMenuText()
          name: FM.Actions.Terminal.getIconCls()
          iconCls: FM.Actions.Terminal.getIconCls()
          handler: ()->
            FM.Actions.Terminal.execute(FM.Active)
        }
        "-",
        {
          text: FM.Actions.IPBlock.getMenuText()
          name: FM.Actions.IPBlock.getIconCls()
          iconCls: FM.Actions.IPBlock.getIconCls()
          handler: () ->
            FM.Actions.IPBlock.execute(FM.Active)
        },
        "-",
        FM.Actions.Settings
      ]

    @items.push "->"

    @items.push
      xtype: "button"
      text: t("Language"),
      menu:
        xtype: 'menu'
        items: [
          {
            text: t("Русский")
            href: "/?language=ru"
            iconCls: 'fm-icon-lang-ru'
          },
          {
            text: t("English")
            href: "/?language=en"
            iconCls: 'fm-icon-lang-en'
          },
          {
            text: t("Deutsch")
            href: "/?language=de"
            iconCls: 'fm-icon-lang-de'
          },
        ]


    @items.push FM.Actions.Help
    @items.push FM.Actions.Logout

    @callParent(arguments)