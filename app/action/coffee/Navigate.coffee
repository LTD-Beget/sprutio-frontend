Ext.define 'FM.action.Navigate',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-navigate"
    text: t("Navigate")
    handler: () ->
      FM.Logger.info('Run Action FM.action.Navigate', arguments)

      promt = Ext.create 'FM.view.windows.PromtWindow',
        title: t("Navigate")
        msg: t("Enter path to navigate:")
        fieldValue: FM.Active.session.path
        ok: (button, promt_window, field) ->
          FM.Logger.debug('ok handler()', arguments)

          path = field.getValue()
          FM.Actions.Open.execute(FM.Active, path)
          promt_window.close()

      promt.show()