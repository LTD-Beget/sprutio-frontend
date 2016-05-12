# The main application class. An instance of this class is created by app.js when it calls
# Ext.application(). This is the ideal place to handle application launch and initialization
# details.

class FMLogger

  levels:
    log: 'log'
    info: 'info'
    warning: 'warning'
    error: 'error'
    debug: 'debug'

  enabled: []

  console: () ->
    if console?
      console.log.apply(console, arguments)

  log: () ->
    for level in @enabled
      if level == @levels.log
        if console? and console.log?
          console.log.call(console, arguments)
          return

  debug: () ->
    for level in @enabled
      if level == @levels.debug
        if console? and console.log?
          console.log.call(console, arguments)
          return

  info: () ->
    for level in @enabled
      if level == @levels.log or level == @levels.info
        if console? and console.info?
          console.info.call(console, arguments)
          return

  warning: () ->
    for level in @enabled
      if level == @levels.log or level == @levels.warning
        if console? and console.warn?
          console.warn.call(console, arguments)
          return

  error: () ->
    for level in @enabled
      if level == @levels.log or level == @levels.warning or level == @levels.error
        if console? and console.error?
          # multiline cause firefox hide arguments in console as [arguments] during error
          for argument in arguments
            console.error(argument)
          return

Ext.define 'FM.Application',
  extend: 'Ext.app.Application'
  name: 'FM'

  # autoloading components
  requires: [
    'Ext.layout.container.Border'
    'Ext.container.Viewport'
    'Ext.form.Panel'
    'Ext.Action'

    'FM.model.File'
    'Ext.util.Cookies'
    'Ext.ux.Util'

    # overrides classes
    'FM.overrides.Action'

    # errors windows
    'FM.view.windows.ErrorWindow'
    'FM.view.windows.WarningWindow'
  ]

  views: [
    # TODO: add views here
  ]

  controllers: ['Index', 'MainHandler', 'FileHandler', 'ArchiveHandler', 'HomeHandler', 'SearchHandler']
  actions: {}

  stores: [
    # TODO: add stores here
  ],

  init: () ->
    FM.backend = {}
    FM.backend.ajaxSend = @ajaxSend
    FM.backend.ajaxSubmit = @ajaxSubmit

    FM.Logger = new FMLogger

    debug = parseInt($('body').attr('data-debug'))

    if debug == 1
      FM.Logger.enabled = [
        FM.Logger.levels.debug
        FM.Logger.levels.log
        FM.Logger.levels.info
        FM.Logger.levels.warning
        FM.Logger.levels.error
      ]
    else
      FM.Logger.enabled = [
        FM.Logger.levels.warning
        FM.Logger.levels.error
      ]

    FM.Logger.log('Application Init')

    @initHelpers()
    @initConstants()
    @initEditor()

  launch: () ->
    FM.viewport = @createViewport()
    FM.Logger.info('FM Application ready', @)

  initEditor: () ->
    FM.Editor = {}
    FM.Editor.settings = {}

    FM.Viewer = {}
    FM.Viewer.settings = {}

    FM.Editor.getMode = @GetEditorMode
    FM.Editor.getEncodings = @GetEditorEncodings
    FM.Editor.getModes = @GetEditorModes

    FM.Viewer.getMode = @GetEditorMode
    FM.Viewer.getEncodings = @GetEditorEncodings
    FM.Viewer.getModes = @GetEditorModes

  initHelpers: () ->
    FM.helpers = {}
    FM.helpers.SetLoading = @SetLoading
    FM.helpers.UnsetLoading = @UnsetLoading
    FM.helpers.CopyToClipboard = @CopyToClipboard
    FM.helpers.ConvertToBinary = @ConvertToBinary
    FM.helpers.DateTimestamp = @DateTimestamp
    FM.helpers.EscapeUtf = @EscapeUtf

    FM.helpers.GetFileName = @GetFileName
    FM.helpers.GetFileExt = @GetFileExt
    FM.helpers.GetAbsName = @GetAbsName
    FM.helpers.GetAbsNames = @GetAbsNames
    FM.helpers.GetParentPath = @GetParentPath
    FM.helpers.GetRelativePath = @GetRelativePath
    FM.helpers.GetRootPath = @GetRootPath
    FM.helpers.GetSelected = @GetSelected
    FM.helpers.GetLastSelected = @GetLastSelected
    FM.helpers.SetActivePanel = @SetActivePanel
    FM.helpers.SelectDefault = @SelectDefault
    FM.helpers.NextPanel = @NextPanel
    FM.helpers.GetFilesNames = @GetFilesNames
    FM.helpers.GetFilesList = @GetFilesList
    FM.helpers.GetImageFiles = @GetImageFiles
    FM.helpers.CheckOverwrite = @CheckOverwrite
    FM.helpers.IsWindowsPath = @IsWindowsPath
    FM.helpers.IsSubpathOf = @IsSubpathOf

    FM.helpers.SizeFormat = @SizeFormat
    FM.helpers.SizeFormat = @SizeFormat
    FM.helpers.ShowError = @ShowError
    FM.helpers.ShowWarning = @ShowWarning
    FM.helpers.ApplyBoth = @ApplyBoth
    FM.helpers.ApplySession = @ApplySession
    FM.helpers.IsSameSession = @IsSameSession
    FM.helpers.ParseErrorMessage = @ParseErrorMessage
    FM.helpers.isAllowed = @isAllowed
    FM.helpers.GetComponentByDomEl = @GetComponentByDomEl

  GetFilesList: (panel) ->
    records = _.filter panel.filelist.store.getRange(), (record) ->
      if record.get("name") != ".."
        if record.get("is_link") != true
          return true
      return false
    return records

  GetImageFiles: (panel) ->
    file_list = FM.helpers.GetFilesList(panel)

    images = []

    for file in file_list
      if file.get('ext').match(FM.Regex.ImageFilesExt)
        images.push(file)

    return images

  GetComponentByDomEl: (target) ->
    topmost = document.body

    while target? and target.nodeType == 1 and target != topmost
      cmp = Ext.getCmp(target.id)
      if cmp
        return cmp

      target = target.parentNode

    return null

  isAllowed: (action, panel, files) ->

    allowed_any = {}
    allowed_no_files = {}

    allowed_any[FM.Actions.HomeFtp.self.getName()] = true
    allowed_any[FM.Actions.RemoteFtp.self.getName()] = true
    allowed_any[FM.Actions.RemoteWebDav.self.getName()] = true
    allowed_any[FM.Actions.Local.self.getName()] = true
    allowed_any[FM.Actions.Refresh.self.getName()] = true

    allowed_no_files[FM.Actions.Upload.self.getName()] = true
    allowed_no_files[FM.Actions.SearchFiles.self.getName()] = true
    allowed_no_files[FM.Actions.SearchText.self.getName()] = true
    allowed_no_files[FM.Actions.AnalyzeSize.self.getName()] = true
    allowed_no_files[FM.Actions.NewFile.self.getName()] = true
    allowed_no_files[FM.Actions.NewFolder.self.getName()] = true
    allowed_no_files[FM.Actions.IPBlock.self.getName()] = true

    # name of the action class
    action_name = action.self.getName()

    if allowed_any[action_name]?
      return if allowed_any[action_name] then true else false

    if allowed_no_files[action_name]? and allowed_no_files[action_name]
      if panel.actions? and panel.actions[action_name]?
        return if panel.actions[action_name] then true else false

    if files.length == 0
      return false

    allowed_multiple = {}
    allowed_dir = {}

    allowed_multiple[FM.Actions.DownloadArchive.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadZip.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadBZ2.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadGZip.self.getName()] = true
    allowed_multiple[FM.Actions.DownloadTar.self.getName()] = true
    allowed_multiple[FM.Actions.CreateArchive.self.getName()] = true
    allowed_multiple[FM.Actions.CreateCopy.self.getName()] = true
    allowed_multiple[FM.Actions.Copy.self.getName()] = true
    allowed_multiple[FM.Actions.Move.self.getName()] = true
    allowed_multiple[FM.Actions.Chmod.self.getName()] = true
    allowed_multiple[FM.Actions.Remove.self.getName()] = true

    allowed_dir[FM.Actions.Open.self.getName()] = true
    allowed_dir[FM.Actions.DownloadArchive.self.getName()] = true
    allowed_dir[FM.Actions.DownloadZip.self.getName()] = true
    allowed_dir[FM.Actions.DownloadBZ2.self.getName()] = true
    allowed_dir[FM.Actions.DownloadGZip.self.getName()] = true
    allowed_dir[FM.Actions.DownloadTar.self.getName()] = true
    allowed_dir[FM.Actions.CreateArchive.self.getName()] = true
    allowed_dir[FM.Actions.CreateCopy.self.getName()] = true
    allowed_dir[FM.Actions.Copy.self.getName()] = true
    allowed_dir[FM.Actions.Move.self.getName()] = true
    allowed_dir[FM.Actions.Chmod.self.getName()] = true
    allowed_dir[FM.Actions.Remove.self.getName()] = true
    allowed_dir[FM.Actions.Rename.self.getName()] = true
    allowed_dir[FM.Actions.Refresh.self.getName()] = true

    # panels
    next_panel = FM.helpers.NextPanel(panel)
    if action_name == FM.Actions.Copy.self.getName() and next_panel.session.type == FM.Session.LOCAL_APPLET
      return false

    if action_name == FM.Actions.Move.self.getName() and next_panel.session.type == FM.Session.LOCAL_APPLET
      return false

    # hacks
    if files.length == 1
      if panel.session.type == FM.Session.HOME
        if FM.Actions.ExtractArchive.self.getName() == action_name and files[0].get("ext") in ['zip','rar', '7z', 'gz', 'bz2', 'arch', 'tar', 'tgz']
          return true

      if files[0].get('is_link')
        return false

      if files[0].get('is_dir') and not allowed_dir[action_name]? and not allowed_dir[action_name]
        return false

      if !files[0].get('is_dir') and !files[0].get('is_link') and FM.Actions.Open.self.getName() == action_name
        return false

    if files.length > 1
      if (not allowed_multiple[action_name]? or not allowed_multiple[action_name])
        return false
      if panel.actions? and panel.actions[action_name]?
        return if panel.actions[action_name] then true else false

    if files.length == 1
      if panel.actions[action_name]?
        panel_action = panel.actions[action_name]
        record_actions = files[0].get('actions')

        if record_actions? and record_actions[action_name]?
          record_action = record_actions[action_name]
          return if record_action then true else false

        else
          return if panel_action then true else false

    return false

  ParseErrorMessage: (message, default_message) ->

    login_incorrect = /(.)*(530 login incorrect)(.)*/i;
    login_incorrect2 = /(.)*(Authorisation error)(.)*/i;
    cant_create_file_ftp = /(.)*(553 Could not create file)(.)*/;
    cant_create_dir_ftp = /(.)*(550 Create directory operation failed)(.)*/
    no_such_file = /(.)*(No such file or directory)(.)*/
    upload_error = /(.)*(Upload exception, filed to upload file)(.)*/
    rename_error_agent_no_file = /(.)*(Unable to rename source element No such file or directory)(.)*/
    rename_failed = /(.)*(Element with target name already exists)(.)*/i
    list_permission_denied = /(.)*(List Folder Permission denied)(.)*/i
    file_binary = /(.)*(File has binary content)(.)*/i
    operation_timeout_exceeded = /(.)*(Operation timeout exceeded)(.)*/i

    if message.match(operation_timeout_exceeded)
        return t("Operation timeout exceeded.")

    if message.match(login_incorrect) or message.match(login_incorrect2)
        return t("Authorisation error. Try to log out and sign in again.")

    if message.match(rename_failed)
        return t("File with this name already exists in the current folder.")

    if message.match(rename_error_agent_no_file)
        return t("Unable to rename source element. No such file or directory")

    if message.match(list_permission_denied)
        return t("Unable to list folder. Permission Denied")

    if message.match(cant_create_file_ftp)
        return t("Could not create file - ftp server error.<br/>Check your file or folder permissions")

    if message.match(cant_create_dir_ftp)
        return t("Could not create dir - ftp server error.<br/>Check folder permissions or the dir already exists")

    if message.match(no_such_file)
        return t("No such file or directory.")

    if message.match(upload_error)
        return t("Error during file upload. Check rights and try again later.")

    if message.match(file_binary)
        return t("File has binary content and cannot be viewed")

    if default_message?
      return t(default_message)
    else
      return t("FileManager Server Error")

  EscapeUtf: (string) ->

    escapable = /[\\"\x00-\x1f\x7f-\uffff]/g

    # table of character substitutions
    meta = {
      '\b': '\\b',
      '\t': '\\t',
      '\n': '\\n',
      '\f': '\\f',
      '\r': '\\r',
      '"' : '\\"',
      '\\': '\\\\'
    }

    # If the string contains no control characters, no quote characters, and no
    # backslash characters, then we can safely slap some quotes around it.
    # Otherwise we must also replace the offending characters with safe escape
    # sequences.

    escapable.lastIndex = 0;

    if escapable.test(string)
      escaped = string.replace escapable, (a) ->
        c = meta[a];
        if typeof c == 'string'
          return c
        else
          return '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4)

      result = escaped
    else
      result = string

    return result

  GetFilesNames: (records) ->
    return Ext.Array.map records, (record) ->
      return record.get("name")

  CheckOverwrite: (panel, records, callback) ->
    FM.Logger.debug("CheckOverwrite() called ", arguments)
    intersection =  Ext.Array.intersect(FM.helpers.GetFilesNames(records), FM.helpers.GetFilesNames(panel.filelist.store.data.items))
    if intersection.length == 0
      return callback(false)

    question = Ext.create 'FM.view.windows.WarningWindow',
      title: t("Overwrite")
      msg: Ext.util.Format.format(t("{0} items with matching names have been identified.<br/>Would you like to overwrite them?"), intersection.length)
      buttonsPreset: 'YES_NO_CANCEL'
      msgWidth: 350
      yes: () ->
        FM.Logger.debug("CheckOverwrite yes() called")
        callback(true)
      no: () ->
        FM.Logger.debug("CheckOverwrite no() called")
        callback(false)

    question.show()

  NextPanel: (panel) ->
    return if FM.Left == panel then FM.Right else FM.Left

  GetEditorEncodings: () ->
    return [
      "ascii",
      "big5",
      "euc-jp",
      "euc-kr",
      "gb2312",
      "hz-gb-2312",
      "ibm855",
      "ibm866",
      "iso-2022-jp",
      "iso-2022-kr",
      "iso-8859-2",
      "iso-8859-5",
      "iso-8859-7",
      "iso-8859-8",
      "koi8-r",
      "maccyrillic",
      "shift_jis",
      "tis-620",
      "utf-8",
      "utf-16le",
      "utf-16be",
      "utf-32le",
      "utf-32be",
      "windows-1250",
      "windows-1251",
      "windows-1252",
      "windows-1253",
      "windows-1255"
    ]

  GetEditorModes: () ->
    return [
      "c_cpp",
      "clojure",
      "coffee",
      "coldfusion",
      "csharp",
      "css",
      "golang",
      "groovy",
      "haxe",
      "html",
      "java",
      "javascript",
      "json",
      "latex",
      "less",
      "liquid",
      "lua",
      "markdown",
      "ocaml",
      "perl",
      "pgsql",
      "php",
      "powershell",
      "python",
      "ruby",
      "scad",
      "scala",
      "scss",
      "sh:",
      "sql",
      "svg",
      "text",
      "textile",
      "xml",
      "xquery"
    ]

  GetEditorMode: (record) ->
    FM.Logger.debug("GetEditorMode() called ", arguments)
    ext = record.get('ext')

    types = {
      c_cpp: "c,cc,cpp,cxx,h,hh,hpp,hxx"
      clojure: "clj"
      coffee: "coffee"
      coldfusion: "cfm"
      csharp: "cs,csx"
      css: "css"
      golang: "go"
      groovy: "groovy,gvy,gy,gsh"
      haxe: "hx,hxml"
      html: "html,htm,shtml,shtm,xhtml,hta,htx"
      java: "java"
      javascript: "js"
      json: "json"
      latex: "latex,tex,ltx,bib"
      less: "less"
      liquid: "liquid"
      lua: "lua"
      markdown: "markdown,mdown,mkdn,md,mkd,mdwn,mdtxt,mdtext"
      ocaml: "ocaml,ml,mli"
      perl: "pl,cgi,pm,plx"
      pgsql: "pgsql,psql"
      php: "php,php3,phtml"
      powershell: "ps1"
      python: "py,pyw"
      ruby: "rb,rbw,ru,gemspec,rake"
      scad: "scad"
      scala: "scala,kbm,scb,scl"
      scss: "scss,sass"
      sh: "sh,bsh,bash,bat"
      sql: "sql"
      svg: "svg"
      text: "txt"
      textile: "textile"
      xml: "xml,xsml,xsl,xslt,xsd,kml,wsdl,rdf,rss,atom,methml,mml,xul,xbl"
      xquery: "xquery,xq"
    }

    editor_mode = "text"

    for mode, values of types
      if values.split(",").indexOf(ext) != -1
        editor_mode = mode

    FM.Logger.debug("GetEditorMode() returns ", editor_mode)
    return editor_mode;

  DateTimestamp: () ->
    today = new Date()
    dd = today.getDate()
    mm = today.getMonth() + 1 # January is 0!
    hh = today.getHours()
    mins = today.getMinutes()

    yyyy = today.getFullYear()

    dd = if dd < 10 then '0' + dd else dd
    mm = if mm < 10 then '0' + mm else mm
    hh = if hh < 10 then '0' + hh else hh
    mins = if mins < 10 then '0' + mins else mins

    today = dd + mm + yyyy + '_' + hh + mins
    return today

  ConvertToBinary: (dec, leading_zero = true) ->
    bits = [];
    dividend = parseInt(dec);
    remainder = 0;

    while dividend >= 2
      remainder = dividend % 2;
      bits.push(remainder);
      dividend = (dividend - remainder) / 2;

    bits.push(dividend);
    bits.reverse();

    result = bits.join("");

    if leading_zero
      if result.length == 0
        result = "000"

      if result.length == 1
        result = "00" + result

      if result.length == 2
        result = "0" + result

    return result

  CopyToClipboard: (value, message = t("Copy to clipboard: press Ctrl+C then Enter")) ->
    FM.Logger.info("CopyToClipboard() called ", arguments)

    promt = Ext.create 'FM.view.windows.PromtWindow',
      title: t("Copy to clipboard")
      msg: message
      buttonsPreset: 'OK'
      fieldValue: value
      ok: (button, promt_window, field) ->
        FM.Logger.info('OK handler()', arguments)
        promt_window.close()

    promt.show()

  GetRelativePath: (session, path) ->
    FM.Logger.info("GetRelativePath() called ", arguments)

    win = /^[A-Z][:][\\][.]*/i

    if win.test(session.path) == true
      FM.Logger.debug('This is windows!!!')
      windows = true
    else
      FM.Logger.debug('This is not windows!!!')
      windows = false

    if windows
      rel_path = path.substr(path.lastIndexOf("\\") + 1)
    else
      rel_path = path.substr(path.lastIndexOf("/") + 1)

    return rel_path

  ApplySession: (session, callback) ->
    FM.Logger.info('ApplySession() called', session, FM.Left, FM.Right)

    tmp_session = Ext.ux.Util.clone(session)
    delete tmp_session.path

    panels = []

    tmp_left_session = Ext.ux.Util.clone(FM.Left.session)
    delete tmp_left_session.path
    if _.isEqual(tmp_session, tmp_left_session)
      panels.push(FM.Left)

    tmp_right_session = Ext.ux.Util.clone(FM.Right.session)
    delete tmp_right_session.path
    if _.isEqual(tmp_session, tmp_right_session)
      panels.push(FM.Right)

    for fm_panel in panels
      if callback?
        callback(fm_panel)

  IsSameSession: (session, compare_session) ->
    FM.Logger.info('IsSameSession() called', session, compare_session, FM.Left, FM.Right)

    tmp_session = Ext.ux.Util.clone(session)
    delete tmp_session.path

    tmp_compare_session = Ext.ux.Util.clone(compare_session)
    delete tmp_compare_session.path

    if not _.isEqual(tmp_session, tmp_compare_session)
      return false

    return true

  ApplyBoth: (panel, callback) ->
    FM.Logger.info('ApplyBoth() called', panel, FM.Left, FM.Right)
    panels = []

    if _.isEqual(panel.session, FM.Left.session)
      panels.push(FM.Left)

    if _.isEqual(panel.session, FM.Right.session)
      panels.push(FM.Right)

    for fm_panel in panels
      if callback?
        callback(fm_panel)

  ShowError: (msg, callback) ->
    FM.Logger.error(msg)
    window = Ext.create 'FM.view.windows.ErrorWindow',
      msg: t(msg)
      ok: callback

    window.show()

  ShowWarning: (msg, callback) ->
    FM.Logger.error(msg)
    window = Ext.create 'FM.view.windows.WarningWindow',
      msg: t(msg)
      ok: callback

    window.show()

  createViewport: () ->
    viewport = Ext.create "Ext.container.Viewport",
      layout: "border"
      minWidth: 800
      minHeight: 600
      defaults:
        border: false,
        autoScroll: true
      items: [
        {
          xtype: 'top-panel'
        },
        {
          xtype: 'center-panel'
        },
        {
          xtype: 'bottom-panel'
        }
      ]

    return viewport

  ajaxSend: (url, options) ->
    config =
      method: 'POST'
      timeout: 300000
      headers:
        'Content-Type': 'application/json;charset=utf-8'

    options = Ext.apply {}, options, config
    options.url = url

    if options.params?
      options.params = Ext.JSON.encode(options.params)

    return Ext.Ajax.request(options)

  ajaxSubmit: (url, options) ->
    config =
      method: 'POST'
      standardSubmit: true
      hidden: true

    options = Ext.apply {}, options, config

    form = Ext.create('Ext.form.Panel', options)

    submit_params = {
      target: '_blank'
      url: url
    }

    if options.params?
      submit_params.params = options.params

    if options.target?
      submit_params.target = options.target

    # Call the submit
    form.submit(submit_params)

    # Clean-up the form after 100 milliseconds.
    # Once the submit is called, the browser does not care anymore with the form object.
    Ext.defer () ->
      form.close()
      if options.success?
        options.success()
    , 100

    return true

  SetLoading: (component, msg) ->
    component.mask msg

  UnsetLoading: (component) ->
    component.unmask()

  GetFileName: (filename, is_dir = false) ->
    if is_dir
      return filename

    filename = filename.substring(0, (Math.max(0, filename.lastIndexOf(".")) || filename.length))
    return filename

  GetFileExt: (filename, is_dir = false) ->
    if is_dir
      return ''

    ext = filename.substring((Math.max(0, filename.lastIndexOf(".")) || filename.length) + 1)
    return ext

  GetAbsName: (session, record) ->
    FM.Logger.debug('Helper GetAbsName() called', arguments)
    path = session.path
    name = record.get('name')

    windows = @IsWindowsPath(path)
    FM.Logger.debug("GetAbsName() called = ", path, name, session, windows)

    if name == '..'
      parent_path = @GetParentPath(session, path)
      return parent_path
    else
      if path == '/' and windows
        abs_path = name
      else if path == '/' and !windows
        abs_path = path + name
      else if windows and path.match(/^[A-Z]:\\$/)
        abs_path = path + name
      else if windows
        abs_path = path + '\\' + name
      else
        abs_path = path + '/' + name

    FM.Logger.debug("GetAbsName() abs_path = ", abs_path)
    return abs_path

  GetAbsNames: (session, records) ->
    names = []
    for record in records
      names.push(@GetAbsName(session, record))

    return names

  IsWindowsPath: (path) ->
    # win or unix
    if path.indexOf("\\") != -1
      windows = true
    else
      windows = false

    return windows

  IsSubpathOf: (session, path) ->
    FM.Logger.debug('Called IsSubpathOf()', arguments)
    if session.path?
      if session.path.substring(0, path.length) == path
        return true
    return false

  GetParentPath: (session, path) ->
    FM.Logger.debug('Called GetParentPath()', arguments)

    windows = @IsWindowsPath(path)

    if windows
      separator = '\\'
    else
      separator = '/'

    parent_path = path.substr(0, path.lastIndexOf(separator));
    FM.Logger.debug('parent_path =', parent_path, 'path = ', path)

    if parent_path.length == 0 or (windows and path.match(/^[A-Z]:\\$/))
      parent_path = '/'

    # disk path
    if windows and parent_path.match(/^[A-Z]:$/)
      parent_path += '\\'

    return parent_path

  GetRootPath: (session) ->
    return '/'

  GetSelected: (panel) ->
    records = _.filter panel.filelist.getView().getSelectionModel().getSelection(), (record) ->
      if record.get("name") != ".."
        if record.get("is_link") != true
          return true
      return false
    return records

  GetLastSelected: (panel) ->
    record = panel.filelist.getView().getSelectionModel().getLastSelected()
    return record

  SizeFormat: (size) ->
    if size < 1024
      return size + " " + t("bytes")
    else if size < (1024 * 1024)
      return Math.round(((size * 10) / 1024)) / 10 + " " + "Kb";
    else
      return Math.round(((size * 10) / (1024 * 1024))) / 10 + " " + "Mb"

  SetActivePanel: (panel, restore_selection = true, select_default = true) ->
    if FM.Active == panel
      return

    FM.Logger.debug("SetActivePanel() called ", arguments, restore_selection)

    # Saving current selection
    FM.Active.selection = FM.Active.filelist.getView().getSelectionModel().getSelection()
    # FM.Active.getView().getSelectionModel().deselectAll()
    FM.Inactive = FM.Active;
    FM.Active = panel

    FM.Active.addCls('fm-panel-active')
    FM.Active.removeCls('fm-panel-inactive')

    FM.Inactive.addCls('fm-panel-inactive')
    FM.Inactive.removeCls('fm-panel-active')

    if !restore_selection
      if select_default
        FM.helpers.SelectDefault(FM.Active)
      FM.getApplication().fireEvent(FM.Events.main.selectPanel, FM.Active, FM.helpers.GetSelected(FM.Active))
      return

    #Restore selection
    FM.Logger.debug("Restore selection ", FM.Active.selection)

    if FM.Active.selection? and FM.Active.selection.length > 0
      FM.Active.filelist.getView().getSelectionModel().select(FM.Active.selection)
    else
      FM.helpers.SelectDefault(FM.Active)

    FM.getApplication().fireEvent(FM.Events.main.selectPanel, FM.Active, FM.helpers.GetSelected(FM.Active))

  SelectDefault: (panel) ->
    FM.Logger.debug("SelectDefault() ", arguments)

    if panel.filelist.getStore()?
      selection = panel.filelist.getStore().getAt(0)
      if selection?
        panel.filelist.getView().getSelectionModel().select(selection)

  initConstants: () ->
    FM.Session = {}
    FM.Session.HOME = 'home'
    FM.Session.PUBLIC_FTP = 'public_ftp'
    FM.Session.PUBLIC_WEBDAV = 'public_webdav'
    FM.Session.LOCAL_APPLET = 'local_applet'

    FM.Status = {}
    FM.Status.STATUS_WAIT = 'wait'
    FM.Status.STATUS_RUNNING = 'running'
    FM.Status.STATUS_SUCCESS = 'success'
    FM.Status.STATUS_ERROR = 'error'
    FM.Status.STATUS_ABORT = 'abort'

    FM.Time = {}
    FM.Time.REQUEST_DELAY = 2000

    FM.Quota = {}
    FM.Quota.WARNING_PERCENT = 0.95

    FM.File = {}
    FM.File.MAX_SIZE = 5 * 1024 * 1024 # 5Mb

    FM.Regex = {}
    FM.Regex.TextFilesExt = /^(txt|js|php|cpp|c|py|css|rb|tpl|inc|sh|htaccess|htm|html|xhtml|json|sql|php4|php5)$/i
    FM.Regex.TextFilesConf = /^\.[a-z-_A-Z0-9]+$/i

    FM.Regex.ImageFilesExt = /^jpg|png|gif$/i