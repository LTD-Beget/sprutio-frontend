// Generated by CoffeeScript 1.11.1
Ext.define('FM.action.SearchText', {
  extend: 'FM.overrides.Action',
  requires: ['FM.view.grids.FileSearchList', 'FM.view.forms.SearchTextForm', 'FM.view.windows.SearchTextWindow'],
  config: {
    scale: "large",
    iconAlign: "top",
    iconCls: "fm-action-search-text",
    text: t("Search Text"),
    handler: function(panel) {
      var bottom_toolbar, session, win;
      if (panel == null) {
        panel = FM.Active;
      }
      FM.Logger.info('Run Action FM.action.SearchText', arguments);
      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0];
      session = Ext.ux.Util.clone(panel.session);
      win = Ext.create("FM.view.windows.SearchTextWindow", {
        taskBar: bottom_toolbar,
        taskBar: bottom_toolbar,
        search: (function(_this) {
          return function(button, search_window, e, params) {
            var files_list;
            search_window.cancel_btn.setVisible(true);
            button.setVisible(false);
            files_list = Ext.ComponentQuery.query("file-search-list", search_window)[0];
            FM.helpers.SetLoading(files_list, t("Loading search result..."));
            return FM.Actions.SearchText.process(button, search_window, search_window.getSession(), params, files_list);
          };
        })(this),
        cancel: (function(_this) {
          return function(button, search_window, e, status) {
            var files_list;
            FM.Logger.info('aborting search files', arguments);
            files_list = Ext.ComponentQuery.query("file-search-list", search_window)[0];
            return FM.Actions.SearchText.cancel(button, search_window, search_window.getSession(), status, files_list);
          };
        })(this)
      });
      win.setSession(session);
      return win.show();
    }
  },
  process: function(button, search_window, session, params, files_list, status) {
    FM.Logger.debug('FM.action.SearchText process() called = ', arguments);
    if (status != null) {
      if ((status.status != null) && (status.status === FM.Status.STATUS_RUNNING || status.status === FM.Status.STATUS_WAIT)) {
        return setTimeout((function(_this) {
          return function() {
            return FM.backend.ajaxSend('/actions/main/check_status', {
              params: {
                session: session,
                status: status
              },
              success: function(response) {
                status = Ext.util.JSON.decode(response.responseText).data;
                return _this.process(button, search_window, session, params, files_list, status);
              },
              failure: function(response) {
                var error, json_response;
                json_response = Ext.util.JSON.decode(response.responseText);
                error = FM.helpers.ParseErrorMessage(json_response.message, t("Error during check operation status.<br/>Please contact Support."));
                FM.helpers.ShowError(error);
                FM.Logger.error(response);
                button.setVisible(false);
                search_window.search_btn.setVisible(true);
                return FM.helpers.UnsetLoading(files_list);
              }
            });
          };
        })(this), FM.Time.REQUEST_DELAY);
      } else {
        FM.Logger.debug('ready to fire event FM.Events.search.findText', status, session, search_window, files_list);
        return FM.getApplication().fireEvent(FM.Events.search.findText, status, session, search_window, files_list);
      }
    } else {
      return FM.backend.ajaxSend('/actions/find/text', {
        params: {
          session: session,
          params: params
        },
        success: (function(_this) {
          return function(response) {
            status = Ext.util.JSON.decode(response.responseText).data;
            search_window.setOperationStatus(status);
            return _this.process(button, search_window, session, params, files_list, status);
          };
        })(this),
        failure: (function(_this) {
          return function(response) {
            FM.Logger.debug(response);
            search_window.cancel_btn.setVisible(false);
            button.setVisible(true);
            FM.helpers.UnsetLoading(files_list);
            FM.helpers.ShowError(t("Error during text searching operation start.<br/> Please contact Support."));
            return FM.Logger.error(response);
          };
        })(this)
      });
    }
  },
  cancel: function(button, search_window, session, status, files_list) {
    FM.Logger.debug('FM.action.SearchText cancel() called = ', arguments);
    if (status != null) {
      return FM.backend.ajaxSend('/actions/main/cancel_operation', {
        params: {
          session: session,
          status: status
        },
        success: function() {},
        failure: function(response) {
          button.setVisible(false);
          search_window.search_btn.setVisible(true);
          FM.helpers.ShowError(t("Error during abortion of text searching operation.<br/> Please contact Support."));
          return FM.Logger.error(response);
        }
      });
    } else {
      button.setVisible(false);
      search_window.search_btn.setVisible(true);
      return FM.helpers.UnsetLoading(files_list);
    }
  }
});
