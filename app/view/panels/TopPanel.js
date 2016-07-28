// Generated by CoffeeScript 1.11.1
Ext.define('FM.view.panels.TopPanel', {
  extend: 'Ext.panel.Panel',
  requires: ['FM.view.toolbars.MainTopToolbar', 'FM.view.toolbars.MainButtonsToolbar'],
  alias: 'widget.top-panel',
  region: "north",
  id: 'top-panel',
  tbar: {
    xtype: 'main-top-toolbar'
  },
  overflowX: 'auto',
  overflowY: 'hidden',
  items: {
    xtype: "main-buttons-toolbar"
  },
  initComponent: function() {
    FM.Logger.log('FM.view.panels.TopPanel init');
    return this.callParent(arguments);
  },
  updateButtonsState: function(panel, files) {
    var analyze_size_button, create_archive_button, download_archive_button, home_button, mkdir_button, refresh_button, remote_button, search_files_button, search_text_button, upload_button;
    home_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.HomeFtp.getIconCls() + "]", this.items.get(0))[0];
    remote_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.RemoteConnections.getIconCls() + "]", this.items.get(0))[0];
    refresh_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.Refresh.getIconCls() + "]", this.items.get(0))[0];
    mkdir_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.NewFolder.getIconCls() + "]", this.items.get(0))[0];
    upload_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.Upload.getIconCls() + "]", this.items.get(0))[0];
    create_archive_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.CreateArchive.getIconCls() + "]", this.items.get(0))[0];
    download_archive_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.DownloadArchive.getIconCls() + "]", this.items.get(0))[0];
    search_files_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.SearchFiles.getIconCls() + "]", this.items.get(0))[0];
    search_text_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.SearchText.getIconCls() + "]", this.items.get(0))[0];
    analyze_size_button = Ext.ComponentQuery.query("button[name=" + FM.Actions.AnalyzeSize.getIconCls() + "]", this.items.get(0))[0];
    if (FM.helpers.isAllowed(FM.Actions.HomeFtp, panel, files)) {
      home_button.setDisabled(false);
    } else {
      home_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.RemoteConnections, panel, files)) {
      remote_button.setDisabled(false);
    } else {
      remote_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Refresh, panel, files)) {
      refresh_button.setDisabled(false);
    } else {
      refresh_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.NewFolder, panel, files)) {
      mkdir_button.setDisabled(false);
    } else {
      mkdir_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Upload, panel, files)) {
      upload_button.setDisabled(false);
    } else {
      upload_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.CreateArchive, panel, files)) {
      create_archive_button.setDisabled(false);
    } else {
      create_archive_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadArchive, panel, files)) {
      download_archive_button.setDisabled(false);
    } else {
      download_archive_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.SearchFiles, panel, files)) {
      search_files_button.setDisabled(false);
    } else {
      search_files_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.SearchText, panel, files)) {
      search_text_button.setDisabled(false);
    } else {
      search_text_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.AnalyzeSize, panel, files)) {
      return analyze_size_button.setDisabled(false);
    } else {
      return analyze_size_button.setDisabled(true);
    }
  },
  updateMenuState: function(panel, files) {
    var analyze_size_button, chmod_button, copy_button, create_archive_button, create_copy_button, download_basic_button, download_button, download_bzip_button, download_gzip_button, download_tar_button, download_zip_button, edit_button, home_button, ipblock_button, mkdir_button, move_button, new_button, new_file_button, operations_button, refresh_button, remote_button, remove_button, rename_button, search_files_button, search_menu, search_text_button, toolbar, upload_button, view_button;
    toolbar = Ext.ComponentQuery.query('main-top-toolbar', this)[0];
    home_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.HomeFtp.getIconCls() + "]", toolbar)[0];
    remote_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.RemoteConnections.getIconCls() + "]", toolbar)[0];
    refresh_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Refresh.getIconCls() + "]", toolbar)[0];
    mkdir_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.NewFolder.getIconCls() + "]", toolbar)[0];
    new_file_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.NewFile.getIconCls() + "]", toolbar)[0];
    new_button = Ext.ComponentQuery.query("menuitem[name=fm-action-create]", toolbar)[0];
    upload_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Upload.getIconCls() + "]", toolbar)[0];
    download_button = Ext.ComponentQuery.query("#fm-menu-download", toolbar)[0];
    download_basic_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.DownloadBasic.getIconCls() + "]", toolbar)[0];
    download_zip_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.DownloadZip.getIconCls() + "]", toolbar)[0];
    download_gzip_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.DownloadGZip.getIconCls() + "]", toolbar)[0];
    download_bzip_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.DownloadBZ2.getIconCls() + "]", toolbar)[0];
    download_tar_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.DownloadTar.getIconCls() + "]", toolbar)[0];
    search_menu = Ext.ComponentQuery.query("#fm-menu-search", toolbar)[0];
    search_files_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.SearchFiles.getIconCls() + "]", toolbar)[0];
    search_text_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.SearchText.getIconCls() + "]", toolbar)[0];
    analyze_size_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.AnalyzeSize.getIconCls() + "]", toolbar)[0];
    operations_button = Ext.ComponentQuery.query("#fm-menu-operations", toolbar)[0];
    view_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.View.getIconCls() + "]", toolbar)[0];
    edit_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Edit.getIconCls() + "]", toolbar)[0];
    rename_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Rename.getIconCls() + "]", toolbar)[0];
    copy_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Copy.getIconCls() + "]", toolbar)[0];
    move_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Move.getIconCls() + "]", toolbar)[0];
    create_copy_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.CreateCopy.getIconCls() + "]", toolbar)[0];
    create_archive_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.CreateArchive.getIconCls() + "]", toolbar)[0];
    chmod_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Chmod.getIconCls() + "]", toolbar)[0];
    remove_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.Remove.getIconCls() + "]", toolbar)[0];
    ipblock_button = Ext.ComponentQuery.query("menuitem[name=" + FM.Actions.IPBlock.getIconCls() + "]", toolbar)[0];
    if (FM.helpers.isAllowed(FM.Actions.HomeFtp, panel, files)) {
      home_button.setDisabled(false);
    } else {
      home_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.RemoteConnections, panel, files)) {
      remote_button.setDisabled(false);
    } else {
      remote_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Refresh, panel, files)) {
      refresh_button.setDisabled(false);
    } else {
      refresh_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.NewFolder, panel, files)) {
      mkdir_button.setDisabled(false);
    } else {
      mkdir_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.NewFile, panel, files)) {
      new_file_button.setDisabled(false);
    } else {
      new_file_button.setDisabled(true);
    }
    if (mkdir_button.isDisabled() && new_file_button.isDisabled()) {
      new_button.setDisabled(true);
    } else {
      new_button.setDisabled(false);
    }
    if (FM.helpers.isAllowed(FM.Actions.Upload, panel, files)) {
      upload_button.setDisabled(false);
    } else {
      upload_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.CreateArchive, panel, files)) {
      create_archive_button.setDisabled(false);
    } else {
      create_archive_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadZip, panel, files)) {
      download_zip_button.setDisabled(false);
    } else {
      download_zip_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadBasic, panel, files)) {
      download_basic_button.setDisabled(false);
    } else {
      download_basic_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadGZip, panel, files)) {
      download_gzip_button.setDisabled(false);
    } else {
      download_gzip_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadBZ2, panel, files)) {
      download_bzip_button.setDisabled(false);
    } else {
      download_bzip_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.DownloadTar, panel, files)) {
      download_tar_button.setDisabled(false);
    } else {
      download_tar_button.setDisabled(true);
    }
    if (download_zip_button.isDisabled() && download_basic_button.isDisabled() && download_gzip_button.isDisabled() && download_bzip_button.isDisabled() && download_tar_button.isDisabled()) {
      download_button.setDisabled(true);
    } else {
      download_button.setDisabled(false);
    }
    if (FM.helpers.isAllowed(FM.Actions.SearchFiles, panel, files)) {
      search_files_button.setDisabled(false);
    } else {
      search_files_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.SearchText, panel, files)) {
      search_text_button.setDisabled(false);
    } else {
      search_text_button.setDisabled(true);
    }
    if (search_files_button.isDisabled() && search_text_button.isDisabled()) {
      search_menu.setDisabled(true);
    } else {
      search_menu.setDisabled(false);
    }
    if (FM.helpers.isAllowed(FM.Actions.AnalyzeSize, panel, files)) {
      analyze_size_button.setDisabled(false);
    } else {
      analyze_size_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.View, panel, files)) {
      view_button.setDisabled(false);
    } else {
      view_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Edit, panel, files)) {
      edit_button.setDisabled(false);
    } else {
      edit_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Rename, panel, files)) {
      rename_button.setDisabled(false);
    } else {
      rename_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Copy, panel, files)) {
      copy_button.setDisabled(false);
    } else {
      copy_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Move, panel, files)) {
      move_button.setDisabled(false);
    } else {
      move_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.CreateCopy, panel, files)) {
      create_copy_button.setDisabled(false);
    } else {
      create_copy_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Chmod, panel, files)) {
      chmod_button.setDisabled(false);
    } else {
      chmod_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.Remove, panel, files)) {
      remove_button.setDisabled(false);
    } else {
      remove_button.setDisabled(true);
    }
    if (FM.helpers.isAllowed(FM.Actions.IPBlock, panel, files)) {
      ipblock_button.setDisabled(false);
    } else {
      ipblock_button.setDisabled(true);
    }
    if (view_button.isDisabled() && edit_button.isDisabled() && rename_button.isDisabled() && copy_button.isDisabled() && move_button.isDisabled() && create_copy_button.isDisabled() && create_archive_button.isDisabled() && chmod_button.isDisabled() && remove_button.isDisabled()) {
      return operations_button.setDisabled(true);
    } else {
      return operations_button.setDisabled(false);
    }
  }
});
