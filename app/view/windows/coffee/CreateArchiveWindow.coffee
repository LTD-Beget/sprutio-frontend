Ext.define 'FM.view.windows.CreateArchiveWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.forms.CreateArchiveForm'
  ]
  alias: 'widget.create-archive-window'
  title: t("Create Archive")
  cls: 'fm-create-archive-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: '15 15 10 15'
  width: 420
  height: 275
  resizable: false
  maximizable: false
  modal: true
  border: false
  items: [
    {
      xtype: 'create-archive-form'
    }
  ]
  operationStatus: null
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
        FM.Logger.debug('FM.view.windows.CreateArchiveWindow beforeshow() called', @, arguments)

        Ext.ComponentQuery.query('textfield[name=archive-file-name]', @)[0].setValue("archive_" + FM.helpers.DateTimestamp())
        Ext.ComponentQuery.query('textfield[name=archive-path-name]', @)[0].setValue(@getSession().path)

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.ChmodFilesWindow initComponent() called', arguments)

    @create_btn = Ext.create 'Ext.button.Button',
      text: t("Create Archive")
      cls: 'fm-button-archive-create'
      disabled: false
      scope: @
      ctrl: true
      enter: true
      handler: (button, e) =>
        FM.Logger.debug("CreateArchive create handler called()", arguments, @)
        if @create?
          path = Ext.ComponentQuery.query('textfield[name=archive-path-name]', @)[0].getValue()
          file = Ext.ComponentQuery.query('textfield[name=archive-file-name]', @)[0].getValue()

          filepath = if path == '/' then path + file else path + '/' + file

          type = Ext.ComponentQuery.query('radio[name=type]', @)[0].getGroupValue()
          paths = @getPaths()

          @create button, @, e,
            path: filepath
            type: type
            files: paths
            archive_name: file

    @cancel_btn = Ext.create 'Ext.button.Button',
      cls: 'fm-button-archive-cancel'
      scope: @
      text: t("Cancel")
      disabled: false
      hidden: true
      handler: (button, e) =>
        FM.Logger.debug("CreateArchive Cancel handler called()", arguments, @)
        @cancelled = true
        if @cancel?
          @cancel(button, @, e, @getOperationStatus())
        else
          @close()

    @close_btn = Ext.create 'Ext.button.Button',
      scope: @
      text: t("Close")
      handler: () =>
        FM.Logger.debug("CreateArchive Close handler called()", arguments, @)
        @close()

    @buttons = [@create_btn, @cancel_btn, @close_btn ]
    @preset = [@create_btn, @close_btn, @cancel_btn]  # <-- WTF @buttons is null after init, so will use @preset

    FM.Logger.debug('CreateArchiveWindow init() done', @, @buttons, @preset)
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

    for record in records
      @paths.push
        path: FM.helpers.GetAbsName(@getSession(), record)
        base64: record.get('base64')

  getPaths: () ->
    return @paths