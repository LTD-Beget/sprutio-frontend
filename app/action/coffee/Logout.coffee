Ext.define 'FM.action.Logout',
  extend: 'FM.overrides.Action'
  config:
    iconCls: "fm-action-logout"
    text: t("Logout")
    handler: () ->
      FM.Logger.info('Run Action FM.action.Logout', arguments)

      FM.backend.ajaxSend '/actions/main/logout',
        success: () ->
          location.reload()

        failure: (response) ->
          FM.Logger.debug(response)
          FM.helpers.ShowError(t("Error during logout. Please contact Support."))
          FM.Logger.error(response)