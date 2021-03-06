// Generated by CoffeeScript 1.11.1
Ext.define('FM.view.windows.PromtWindow', {
  extend: 'Ext.window.Window',
  requires: ['Ext.form.field.Text'],
  alias: 'widget.promt-window',
  cls: 'fm-promt-window',
  layout: {
    type: 'vbox',
    align: 'center'
  },
  width: 300,
  resizable: false,
  buttonsPreset: 'OK_CANCEL',
  fieldValue: '',
  listeners: {
    show: {
      fn: function() {
        if (this.keymap != null) {
          this.keymap.destroy();
        }
        return this.keymap = new Ext.util.KeyMap({
          target: this.getEl(),
          binding: [
            {
              key: Ext.event.Event.ENTER,
              fn: FM.HotKeys.HotKeyDecorator((function(_this) {
                return function(key, e) {
                  var button, i, len, ref;
                  ref = _this.preset;
                  for (i = 0, len = ref.length; i < len; i++) {
                    button = ref[i];
                    if ((button.enter != null) && button.enter && !button.isDisabled()) {
                      if (button.handler != null) {
                        button.handler(button);
                      }
                    }
                  }
                  return e.stopEvent();
                };
              })(this))
            }
          ]
        });
      }
    }
  },
  initComponent: function(config) {
    var bottomTb, buttons, cancel, ok;
    FM.Logger.log('FM.view.windows.PromtWindow init');
    this.items = [];
    buttons = {};
    ok = Ext.create('Ext.button.Button', {
      handler: (function(_this) {
        return function(button, e) {
          if (_this.ok != null) {
            return _this.ok(button, _this, _this.textField, e);
          } else {
            return _this.close();
          }
        };
      })(this),
      scope: this,
      text: t("OK"),
      minWidth: 75,
      enter: true
    });
    cancel = Ext.create('Ext.button.Button', {
      handler: (function(_this) {
        return function() {
          if (_this.cancel != null) {
            return _this.cancel(_this);
          } else {
            return _this.close();
          }
        };
      })(this),
      scope: this,
      text: t("Cancel"),
      minWidth: 75
    });
    buttons.OK_CANCEL = [ok, cancel];
    buttons.OK = [ok];
    this.preset = buttons[this.buttonsPreset];
    this.textField = Ext.create('Ext.form.field.Text', {
      width: 265,
      margin: '-6 0 1 0',
      value: this.fieldValue,
      listeners: {
        afterrender: function(field) {
          return Ext.defer(function() {
            return field.focus(true, 100);
          }, 1);
        }
      }
    });
    this.items.push({
      xtype: 'container',
      margin: 0,
      padding: '10 15 15 15',
      layout: {
        type: 'vbox',
        align: 'center',
        anchor: '100%'
      },
      items: [
        {
          xtype: 'displayfield',
          fieldLabel: this.msg,
          labelSeparator: '',
          labelStyle: 'text-align: left; padding-left: 3px;',
          labelWidth: 260
        }, this.textField
      ]
    });
    bottomTb = new Ext.toolbar.Toolbar({
      ui: 'footer',
      dock: 'bottom',
      layout: {
        pack: 'center'
      },
      padding: '0 8 10 16',
      items: this.preset
    });
    this.dockedItems = [bottomTb];
    return this.callParent(arguments);
  }
});
