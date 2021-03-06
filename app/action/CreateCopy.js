// Generated by CoffeeScript 1.11.1
Ext.define('FM.action.CreateCopy', {
  extend: 'FM.overrides.Action',
  requires: ['FM.view.windows.QuestionWindow', 'FM.view.windows.ProgressWindow'],
  config: {
    iconCls: "fm-action-create-copy",
    text: t("Create Copy"),
    handler: function(panel, records) {
      var paths, question, session;
      if (records == null) {
        records = [];
      }
      FM.Logger.log('Run Action FM.action.CreateCopy', arguments);
      if ((records == null) || records.length === 0) {
        FM.helpers.ShowError(t("Please select file entry."));
        return;
      }
      session = Ext.ux.Util.clone(panel.session);
      paths = FM.helpers.GetAbsNames(session, records);
      question = Ext.create('FM.view.windows.QuestionWindow', {
        title: t("Create copy"),
        msg: Ext.util.Format.format(t("Create copy of {0} items in {1}?"), paths.length, session.path),
        yes: function() {
          var wait;
          FM.Logger.debug('Yes handler()', session, paths);
          wait = Ext.create('FM.view.windows.ProgressWindow', {
            cancelable: true,
            msg: t("Creating copy, please wait..."),
            cancel: function(wait_window, session, status) {
              if (status != null) {
                return FM.Actions.CreateCopy.cancel(wait_window, session, status);
              }
            }
          });
          wait.setSession(session);
          return FM.Actions.CreateCopy.process(wait, session, paths);
        }
      });
      return question.show();
    }
  },
  process: function(progress_window, session, paths, status) {
    FM.Logger.debug('FM.action.CreateCopy process() called = ', arguments);
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
                var percent, text;
                status = Ext.util.JSON.decode(response.responseText).data;
                if ((status.progress != null) && ((status.progress.text != null) || (status.progress.percent != null))) {
                  text = status.progress.text != null ? status.progress.text : '';
                  percent = status.progress.percent != null ? status.progress.percent : 0;
                  progress_window.updateProgress(percent, text);
                } else {
                  progress_window.updateProgressText(t("Creating copy..."));
                }
                return _this.process(progress_window, session, paths, status);
              },
              failure: function(response) {
                FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."));
                return FM.Logger.error(response);
              }
            });
          };
        })(this), FM.Time.REQUEST_DELAY);
      } else {
        return FM.getApplication().fireEvent(FM.Events.file.createCopyFiles, status, session, progress_window);
      }
    } else {
      return FM.backend.ajaxSend('/actions/files/create_copy', {
        params: {
          session: session,
          paths: paths
        },
        success: (function(_this) {
          return function(response) {
            status = Ext.util.JSON.decode(response.responseText).data;
            progress_window.setOperationStatus(status);
            progress_window.show();
            return _this.process(progress_window, session, paths, status);
          };
        })(this),
        failure: (function(_this) {
          return function(response) {
            FM.helpers.ShowError(t("Error during copy operation start. Please contact Support."));
            return FM.Logger.error(response);
          };
        })(this)
      });
    }
  },
  cancel: function(progress_window, session, status) {
    return FM.backend.ajaxSend('/actions/main/cancel_operation', {
      params: {
        session: session,
        status: status
      },
      success: (function(_this) {
        return function(response) {
          var response_data;
          response_data = Ext.util.JSON.decode(response.responseText).data;
          FM.Logger.info(response_data);
          return progress_window.close();
        };
      })(this),
      failure: (function(_this) {
        return function(response) {
          progress_window.close();
          FM.helpers.ShowError(t("Error during copy operation aborting. Please contact Support."));
          return FM.Logger.error(response);
        };
      })(this)
    });
  }
});
