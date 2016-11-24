// Generated by CoffeeScript 1.11.1
Ext.define('FM.action.ExtractArchive', {
  extend: 'FM.overrides.Action',
  config: {
    scale: "large",
    iconAlign: "top",
    iconCls: "fm-action-extract-archive",
    text: t("Extract Archive"),
    handler: function(panel, record) {
      var promt, session;
      if (panel == null) {
        panel = FM.Active;
      }
      FM.Logger.info('Run Action FM.action.ExtractArchive', arguments);
      session = Ext.ux.Util.clone(panel.session);
      promt = Ext.create('FM.view.windows.PromtWindow', {
        title: t("Extract Archive"),
        msg: t("Enter a path to extract:"),
        fieldValue: session.path,
        ok: function(button, promt_window, field) {
          var params, wait;
          FM.Logger.info('OK handler()', session, arguments);
          button.disable();
          params = {
            file: {
              path: FM.helpers.GetAbsName(session, record),
              base64: record.get('base64')
            },
            extract_path: field.getValue()
          };
          wait = Ext.create('FM.view.windows.ProgressWindow', {
            cancelable: true,
            msg: t("Extracting archive, please wait..."),
            cancel: function(wait_window, session, status) {
              FM.Logger.debug('ExtractArchive cancel called()', arguments);
              if (status != null) {
                return FM.Actions.ExtractArchive.cancel(wait_window, session, status);
              }
            }
          });
          wait.setSession(session);
          FM.Actions.ExtractArchive.process(wait, session, params);
          return promt_window.close();
        }
      });
      return promt.show();
    }
  },
  process: function(progress_window, session, params, status) {
    FM.Logger.debug('FM.action.ExtractArchive process() called = ', arguments);
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
                  progress_window.updateProgressText(t("Estimating operation length..."));
                }
                return _this.process(progress_window, session, params, status);
              },
              failure: function(response) {
                FM.helpers.ShowError(t("Error during check operation status.<br/>Please contact Support."));
                return FM.Logger.error(response);
              }
            });
          };
        })(this), FM.Time.REQUEST_DELAY);
      } else {
        return FM.getApplication().fireEvent(FM.Events.archive.extractArchive, status, session, progress_window, params);
      }
    } else {
      if (session.type === FM.Session.LOCAL_APPLET) {
        try {
          return FM.Active.applet.extract(progress_window, session, params);
        } catch (error) {
          FM.Logger.error("Applet error");
          return FM.helpers.ShowError(t("Error during operation. Please contact Support."));
        }
      } else {
        return FM.backend.ajaxSend('/actions/archive/extract', {
          params: {
            session: session,
            params: params
          },
          success: (function(_this) {
            return function(response) {
              status = Ext.util.JSON.decode(response.responseText).data;
              progress_window.setOperationStatus(status);
              progress_window.show();
              return _this.process(progress_window, session, params, status);
            };
          })(this),
          failure: (function(_this) {
            return function(response) {
              FM.Logger.debug(response);
              FM.helpers.ShowError(t("Error during archive extracting operation start.<br/> Please contact Support."));
              return FM.Logger.error(response);
            };
          })(this)
        });
      }
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
          FM.Logger.debug(response_data);
          return progress_window.close();
        };
      })(this),
      failure: (function(_this) {
        return function(response) {
          progress_window.close();
          FM.helpers.ShowError(t("Error during abortion of archive extracting operation.<br/> Please contact Support."));
          return FM.Logger.error(response);
        };
      })(this)
    });
  }
});
