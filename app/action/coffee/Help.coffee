Ext.define 'FM.action.Help',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-help"
    text: t("Help")
    handler: () ->
      FM.Logger.info('Run Action FM.action.Help', arguments)
      window.open('http://beget.ru/man_filem', '_blank')