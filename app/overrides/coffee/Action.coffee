Ext.define 'FM.overrides.Action',
  extend: 'Ext.Action'
  getButtonText: () ->
    return @config.buttonText
  getMenuText: () ->
    if @config.menuText?
      return @config.menuText
    return @config.text
  getIconCls: () ->
    return @config.iconCls
  constructor: (config) ->
    config = Ext.apply {}, config, @config

    #Calling the parent class constructor
    @callParent([config])

    # Initializing the component
    @initConfig(config)