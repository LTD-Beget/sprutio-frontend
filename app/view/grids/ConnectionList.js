// Generated by CoffeeScript 1.9.3
Ext.define('FM.view.grids.ConnectionList', {
  extend: 'Ext.grid.Panel',
  alias: 'widget.connection-list',
  cls: 'fm-connection-list',
  columns: [],
  stateful: true,
  multiSelect: false,
  tbar: {
    xtype: 'connection-list-top-toolbar'
  },
  viewConfig: {
    stripeRows: false
  },
  plugins: [
    Ext.create("Ext.ux.grid.plugin.RowEditing", {
      clicksToMoveEditor: 1,
      clicksToEdit: 0,
      autoCancel: true,
      listeners: {
        beforeEdit: function(boundEl, value) {
          if (value.record.get('id') > 0) {
            return boundEl.editor.getComponent('combobox-connection-type-component').disable();
          } else {
            return boundEl.editor.getComponent('combobox-connection-type-component').enable();
          }
        }
      }
    })
  ],
  requires: ['FM.view.toolbars.ConnectionListTopToolbar', 'FM.model.Connection', 'Ext.ux.grid.plugin.RowEditing'],
  initComponent: function() {
    FM.Logger.log('FM.view.grids.ConnectionList init');
    this.callParent(arguments);
    this.initGridConfig();
    this.initHandlers();
    return this.setStore(FM.Stores.Conenctions);
  },
  initHandlers: function() {
    var panel;
    panel = this;
    return (function(panel) {
      var dialog, gridView, selection, toolbar;
      gridView = panel.getView();
      selection = gridView.getSelectionModel();
      toolbar = Ext.ComponentQuery.query('connection-list-top-toolbar', panel)[0];
      dialog = toolbar.findParentByType('window');
      gridView.on({
        itemdblclick: function(view, record, el, index, event) {
          FM.Logger.debug('ConnectionList itemdblclick() called', panel, arguments);
          event.preventDefault();
          event.stopPropagation();
          event.stopEvent();
          record.initConneciton(FM.Active);
          return dialog.close();
        }
      });
      return selection.on({
        selectionchange: function(view, records) {
          FM.Logger.debug('ConnectionList selectionchange() called', panel, arguments);
          if (records.length > 0) {
            Ext.ComponentQuery.query('button[cls="fm-connection-remove"]', toolbar)[0].setDisabled(false);
            return Ext.ComponentQuery.query('button[cls="fm-connection-edit"]', toolbar)[0].setDisabled(false);
          } else {
            Ext.ComponentQuery.query('button[cls="fm-connection-remove"]', toolbar)[0].setDisabled(true);
            return Ext.ComponentQuery.query('button[cls="fm-connection-edit"]', toolbar)[0].setDisabled(true);
          }
        }
      });
    })(panel);
  },
  initGridConfig: function() {
    return this.setConfig({
      columns: [
        {
          header: t("Type"),
          dataIndex: "type",
          maxWidth: 80,
          align: 'center',
          renderer: function(value) {
            return '<img align="left" src="fm/resources/images/icons/16/' + value + '.png">' + value.toUpperCase();
          },
          editor: {
            id: 'combobox-connection-type-component',
            xtype: 'combobox',
            listeners: {
              change: function() {
                var port;
                port = Ext.getCmp('port-cell-id-for-finding-in-combobox-change-func');
                if (this.getValue() === 'sftp' && port.value === '21') {
                  port.setValue('22');
                }
                if (this.getValue() === 'ftp' && port.value === '22') {
                  return port.setValue('21');
                }
              }
            },
            editable: false,
            triggerAction: 'all',
            allowBlank: false,
            valueField: 'value',
            displayField: 'display',
            store: Ext.create('Ext.data.Store', {
              fields: ['display', 'value'],
              data: [
                {
                  display: 'ftp',
                  value: 'ftp'
                }, {
                  display: 'sftp',
                  value: 'sftp'
                }
              ]
            })
          }
        }, {
          header: t("Host"),
          dataIndex: "host",
          flex: true,
          editor: {
            allowBlank: false,
            maxLength: 255
          }
        }, {
          header: t("Port"),
          dataIndex: "port",
          maxWidth: 55,
          editor: {
            id: 'port-cell-id-for-finding-in-combobox-change-func',
            allowBlank: false,
            maxLength: 5
          }
        }, {
          header: t("User"),
          dataIndex: "user",
          flex: true,
          editor: {
            allowBlank: false,
            maxLength: 32
          }
        }, {
          header: t("Password"),
          dataIndex: "decryptedPassword",
          flex: true,
          renderer: function(value) {
            return value.replace(/./g, "*").substr(0, 8);
          },
          editor: {
            allowBlank: false,
            maxLength: 64
          }
        }
      ]
    });
  }
});
