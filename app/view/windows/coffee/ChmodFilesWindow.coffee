Ext.define 'FM.view.windows.ChmodFilesWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.forms.ChangeAttributesForm'
  ]
  alias: 'widget.chmod-files-window'
  title: t("File Attributes")
  cls: 'fm-chmod-files-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: '15 15 0 15'
  width: 350
  height: 450,
  resizable: false
  maximizable: false
  operationStatus: null
  hasDir: false
  initValue: 0
  modal: true
  border: false
  items: [
    {
      xtype: 'change-attributes-form'
    }
  ]
  listeners:
    show:
      fn: () ->
        if @keymap?
          @keymap.destroy()

        @keymap = new Ext.util.KeyMap
          target: @getEl()
          binding: [
            {
              key: Ext.event.Event.ENTER
              ctrl: true
              fn: FM.HotKeys.HotKeyDecorator (key, e) =>
                FM.Logger.debug('ctrl + enter', arguments, @)
                for button in @preset
                  if button.enter? and button.enter and button.ctrl? and button.ctrl and not button.isDisabled()
                    if button.handler?
                      button.handler(button, e)
                e.stopEvent()
            }
          ]
    beforeshow:
      fn: () ->
        FM.Logger.debug('FM.view.windows.ChmodFilesWindow beforeshow() called', @, arguments)

        if !@hasDir
          Ext.ComponentQuery.query('checkbox[name=apply-recursively]', @)[0].hide()
          Ext.ComponentQuery.query('radiogroup[cls=recursive-mode-group]', @)[0].hide()
          @setHeight(350)

        Ext.ComponentQuery.query('textfield[name=chmod-code]', @)[0].setValue(@initValue)

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.ChmodFilesWindow initComponent() called', arguments)

    @chmod_btn = Ext.create 'Ext.button.Button',
      text: t("Change Attributes")
      cls: 'fm-button-chmod-apply'
      disabled: true
      scope: @
      ctrl: true
      enter: true
      handler: (button, e) =>
        FM.Logger.debug("Chmod files Chmod handler called()", arguments, @)
        if @chmod?
          chmod_code = Ext.ComponentQuery.query('textfield[name=chmod-code]', @)[0].getValue()
          use_recursive = Ext.ComponentQuery.query('checkbox[name=apply-recursively]', @)[0].checked
          recursive_mode = Ext.ComponentQuery.query('radio[name=recursive-mode]', @)[0].getGroupValue()
          paths = @getPaths()

          read_problem = false

          owner_read = if Ext.ComponentQuery.query('checkbox[name=owner-read]', @)[0].checked then true else false
          owner_execute = if Ext.ComponentQuery.query('checkbox[name=owner-execute]', @)[0].checked then true else false

          group_read = if Ext.ComponentQuery.query('checkbox[name=group-read]', @)[0].checked then true else false
          group_execute = if Ext.ComponentQuery.query('checkbox[name=group-execute]', @)[0].checked then true else false

          public_read = if Ext.ComponentQuery.query('checkbox[name=public-read]', @)[0].checked then true else false
          public_execute = if Ext.ComponentQuery.query('checkbox[name=public-execute]', @)[0].checked then true else false

          if use_recursive && recursive_mode != 'files'
            if !(owner_read || group_read || public_read)
              read_problem = true

            if !(owner_execute || group_execute || public_execute)
              read_problem = true

          if read_problem
            question = Ext.create 'FM.view.windows.QuestionWindow',
              title: t("Change files attributes")
              msg: t("Without read and execute rights you will not be able to get access to files within folders. Continue?")
              yes: () =>
                FM.Logger.debug('Read Problem Yes handler()')
                @chmod button, @, e,
                  code: chmod_code
                  recursive: use_recursive
                  recursive_mode: recursive_mode
                  paths: paths

            question.show();
          else
            @chmod button, @, e,
              code: chmod_code
              recursive: use_recursive
              recursive_mode: recursive_mode
              paths: paths

    @cancel_btn = Ext.create 'Ext.button.Button',
      cls: 'fm-button-chmod-cancel'
      scope: @
      text: t("Cancel")
      disabled: false
      hidden: true
      handler: (button, e) =>
        FM.Logger.debug("Chmod files Cancel handler called()", arguments, @)
        @cancelled = true
        if @cancel?
          @cancel(button, @, e, @getOperationStatus())
        else
          @close()

    @close_btn = Ext.create 'Ext.button.Button',
      scope: @
      text: t("Close")
      handler: () =>
        FM.Logger.debug("Chmod files Close handler called()", arguments, @)
        @close()

    @buttons = [@chmod_btn, @cancel_btn, @close_btn ]
    @preset = [@chmod_btn, @close_btn, @cancel_btn]  # <-- WTF @buttons is null after init, so will use @preset

    FM.Logger.debug('ChmodFilesWindow init() done', @, @buttons, @preset)
    @callParent(arguments)

  setSession: (session) ->
    @session = session

  getSession: () ->
    return @session

  hasSession: () ->
    return if @session? then true else false

  setOperationStatus: (status) ->
    @operationStatus = status

  hasOperationStatus: () ->
    return if @operationStatus? then true else false

  getOperationStatus: () ->
    return @operationStatus

  initRecords: (records = []) ->
    @paths = []
    @initValue = records[0].get('mode')

    for record in records
      if record.get('is_dir') == true
        @hasDir = true

      @paths.push
        path: FM.helpers.GetAbsName(@getSession(), record)
        base64: record.get('base64')

  getPaths: () ->
    return @paths