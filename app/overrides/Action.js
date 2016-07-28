// Generated by CoffeeScript 1.11.1
Ext.define('FM.overrides.Action', {
  extend: 'Ext.Action',
  getButtonText: function() {
    return this.config.buttonText;
  },
  getMenuText: function() {
    if (this.config.menuText != null) {
      return this.config.menuText;
    }
    return this.config.text;
  },
  getIconCls: function() {
    return this.config.iconCls;
  },
  constructor: function(config) {
    config = Ext.apply({}, config, this.config);
    this.callParent([config]);
    return this.initConfig(config);
  }
});
