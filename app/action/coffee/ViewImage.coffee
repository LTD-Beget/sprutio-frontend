Ext.define 'FM.action.ViewImage',
  extend: 'FM.overrides.Action'
  requires: [
    'FM.view.windows.ImageViewer'
    'FM.view.windows.ProgressWindow'
  ]
  config:
    iconCls: "fm-action-view-image"
    text: t("View Image")
    handler: (panel, record) ->
      FM.Logger.info('Run Action FM.action.ViewImage', arguments)

      if record.get("size") > FM.File.MAX_SIZE
        return FM.helpers.ShowError(t("The file is too large for viewing."))

      bottom_toolbar = Ext.ComponentQuery.query("bottom-panel")[0].getDockedItems("toolbar[dock='top']")[0]
      session = Ext.ux.Util.clone(panel.session)

      wait = Ext.create 'FM.view.windows.ProgressWindow',
        cancelable: false
        msg: t("Reading image, please wait...")

      wait.show()

      # Now loading all images in current session for cache
      images_list = FM.helpers.GetImageFiles(panel)

      FM.backend.ajaxSend '/actions/files/read_images',
        params:
          session: session
          paths: FM.helpers.GetAbsNames(session, images_list)
        success: (response) =>
          response_data = Ext.util.JSON.decode(response.responseText).data
          wait.close()

          for image_name in response_data.file_list.succeed
            if record.get('name') == image_name
              record.set('src', '/image_cache/' + response_data.sid + '/' + response_data.hash + '/' + image_name)

            for image_record in images_list
              if image_record.get('name') == image_name
                image_record.set('src', '/image_cache/' + response_data.sid + '/' + response_data.hash + '/' + image_name)

          FM.Logger.debug('Success', response_data, images_list, record)

          win = Ext.create "FM.view.windows.ImageViewer",
            taskBar: bottom_toolbar
            imageRecords: images_list
            imageCurrent: record

          win.setSession(session)
          win.show()
          FM.Logger.info('Viewer window done', win)

        failure: (response) =>
          wait.close()
          FM.helpers.ShowError(t("Error during reading image.<br/> Please contact Support."))
          FM.Logger.error(response)