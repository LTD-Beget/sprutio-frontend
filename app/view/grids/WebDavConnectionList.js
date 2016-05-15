// Generated by CoffeeScript 1.9.3
Ext.define('FM.view.grids.WebDavConnectionList', {
  extend: 'Ext.grid.Panel',
  alias: 'widget.webdav-connection-list',
  cls: 'fm-webdav-connection-list',
  columns: [],
  stateful: true,
  multiSelect: false,
  tbar: {
    xtype: 'webdav-connection-list-top-toolbar'
  },
  viewConfig: {
    stripeRows: false
  },
  plugins: [
    Ext.create("Ext.ux.grid.plugin.RowEditing", {
      clicksToMoveEditor: 1,
      clicksToEdit: 0,
      autoCancel: true
    })
  ],
  requires: ['FM.view.toolbars.WebDavConnectionListTopToolbar', 'FM.model.WebDavConnection', 'Ext.ux.grid.plugin.RowEditing'],
  initComponent: function() {
    FM.Logger.log('FM.view.grids.WebDavConnectionList init');
    this.callParent(arguments);
    this.initGridConfig();
    this.initHandlers();
    return this.setStore(FM.Stores.WebDavConenctions);
  },
  initHandlers: function() {
    var panel;
    panel = this;
    return (function(panel) {
      var dialog, gridView, selection, toolbar;
      gridView = panel.getView();
      selection = gridView.getSelectionModel();
      toolbar = Ext.ComponentQuery.query('webdav-connection-list-top-toolbar', panel)[0];
      dialog = toolbar.findParentByType('window');
      gridView.on({
        itemdblclick: function(view, record, el, index, event) {
          FM.Logger.debug('WebDavConnectionList itemdblclick() called', panel, arguments);
          event.preventDefault();
          event.stopPropagation();
          event.stopEvent();
          record.initConneciton(FM.Active);
          return dialog.close();
        }
      });
      return selection.on({
        selectionchange: function(view, records) {
          FM.Logger.debug('WebDavConnectionList selectionchange() called', panel, arguments);
          if (records.length > 0) {
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-remove"]', toolbar)[0].setDisabled(false);
            return Ext.ComponentQuery.query('button[cls="fm-webdav-connection-edit"]', toolbar)[0].setDisabled(false);
          } else {
            Ext.ComponentQuery.query('button[cls="fm-webdav-connection-remove"]', toolbar)[0].setDisabled(true);
            return Ext.ComponentQuery.query('button[cls="fm-webdav-connection-edit"]', toolbar)[0].setDisabled(true);
          }
        }
      });
    })(panel);
  },
  initGridConfig: function() {
    return this.setConfig({
      columns: [
        {
          header: t("WDHost"),
          dataIndex: "host",
          flex: true,
          editor: {
            allowBlank: false,
            vtype: "host",
            maxLength: 255
          },
          field: {
            xtype: 'combobox',
            store: new Ext.data.SimpleStore({
              data: [['https://webdav.yandex.ru', 'Yandex Disk'], ['', 'Custom Drive']],
              id: 0,
              fields: ['hostaddress', 'text']
            }),
            valueField: 'hostaddress',
            displayField: 'text',
            editable: true
          }
        }, {
          header: t("User"),
          dataIndex: "user",
          editor: {
            allowBlank: false,
            maxLength: 32
          }
        }, {
          header: t("Password"),
          dataIndex: "decryptedPassword",
          renderer: function(value) {
            return value.replace(/./g, "*").substr(0, 8);
          },
          editor: {
            allowBlank: false,
            maxLength: 32
          }
        }
      ]
    });
  }
});
