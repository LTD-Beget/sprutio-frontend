Ext.define 'FM.action.Local',
  extend: 'FM.overrides.Action'
  config:
    scale: "large"
    iconAlign: "top"
    iconCls: "fm-action-local"
    text: t("My Computer")
    handler: (panel) ->
      FM.Logger.debug('Run Action FM.action.Local', arguments, panel.toString())

      if panel.toString() == 'Right'
        panel.applet = Ext.getElementById('applet_right')
      else
        panel.applet = Ext.getElementById('applet_left')

#      if not FM.Active.applet.start?
#        console.log(FM.Active.applet)
#        FM.Active.applet = Ext.getElementById('applet_right_embed');

      panel.applet.start(panel.toString())