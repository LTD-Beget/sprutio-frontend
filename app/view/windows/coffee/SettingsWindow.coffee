Ext.define 'FM.view.windows.SettingsWindow',
  extend: 'Ext.ux.window.Window'
  requires: [
    'FM.view.forms.SettingsForm'
  ]
  alias: 'widget.settings-window'
  title: t("Settings")
  cls: 'fm-settings-window'
  animate: true
  constrain: true
  layout: 'fit'
  bodyPadding: 0
  width: 400
  resizable: false
  maximizable: false
  modal: false
  border: false
  items: [
    {
      xtype: 'settings-form'
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
        FM.Logger.debug('FM.view.windows.SettingsWindow beforeshow() called', @, arguments)

        # Editor form settings init
        Ext.ComponentQuery.query('numberfield[name=editor_print_margin_size]', @)[0].setValue(FM.Editor.settings.print_margin_size)
        Ext.ComponentQuery.query('numberfield[name=editor_font_size]', @)[0].setValue(FM.Editor.settings.font_size)
        Ext.ComponentQuery.query('numberfield[name=editor_tab_size]', @)[0].setValue(FM.Editor.settings.tab_size)

        Ext.ComponentQuery.query('checkbox[name=editor_full_line_selection]', @)[0].setValue(FM.Editor.settings.full_line_selection)
        Ext.ComponentQuery.query('checkbox[name=editor_highlight_active_line]', @)[0].setValue(FM.Editor.settings.highlight_active_line)
        Ext.ComponentQuery.query('checkbox[name=editor_show_invisible]', @)[0].setValue(FM.Editor.settings.show_invisible)
        Ext.ComponentQuery.query('checkbox[name=editor_wrap_lines]', @)[0].setValue(FM.Editor.settings.wrap_lines)
        Ext.ComponentQuery.query('checkbox[name=editor_use_soft_tabs]', @)[0].setValue(FM.Editor.settings.use_soft_tabs)
        Ext.ComponentQuery.query('checkbox[name=editor_show_line_numbers]', @)[0].setValue(FM.Editor.settings.show_line_numbers)
        Ext.ComponentQuery.query('checkbox[name=editor_highlight_selected_word]', @)[0].setValue(FM.Editor.settings.highlight_selected_word)
        Ext.ComponentQuery.query('checkbox[name=editor_show_print_margin]', @)[0].setValue(FM.Editor.settings.show_print_margin)
        Ext.ComponentQuery.query('checkbox[name=editor_use_autocompletion]', @)[0].setValue(FM.Editor.settings.use_autocompletion)
        Ext.ComponentQuery.query('checkbox[name=editor_enable_emmet]', @)[0].setValue(FM.Editor.settings.enable_emmet)

        Ext.ComponentQuery.query('radio[name=editor_code_folding_type]', @)[0].setValue(FM.Editor.settings.code_folding_type)
        Ext.ComponentQuery.query('combobox[name=editor_theme]', @)[0].setValue(FM.Editor.settings.theme)

        # Viewer form settings init
        Ext.ComponentQuery.query('numberfield[name=viewer_print_margin_size]', @)[0].setValue(FM.Viewer.settings.print_margin_size)
        Ext.ComponentQuery.query('numberfield[name=viewer_font_size]', @)[0].setValue(FM.Viewer.settings.font_size)
        Ext.ComponentQuery.query('numberfield[name=viewer_tab_size]', @)[0].setValue(FM.Viewer.settings.tab_size)

        Ext.ComponentQuery.query('checkbox[name=viewer_full_line_selection]', @)[0].setValue(FM.Viewer.settings.full_line_selection)
        Ext.ComponentQuery.query('checkbox[name=viewer_highlight_active_line]', @)[0].setValue(FM.Viewer.settings.highlight_active_line)
        Ext.ComponentQuery.query('checkbox[name=viewer_show_invisible]', @)[0].setValue(FM.Viewer.settings.show_invisible)
        Ext.ComponentQuery.query('checkbox[name=viewer_wrap_lines]', @)[0].setValue(FM.Viewer.settings.wrap_lines)
        Ext.ComponentQuery.query('checkbox[name=viewer_use_soft_tabs]', @)[0].setValue(FM.Viewer.settings.use_soft_tabs)
        Ext.ComponentQuery.query('checkbox[name=viewer_show_line_numbers]', @)[0].setValue(FM.Viewer.settings.show_line_numbers)
        Ext.ComponentQuery.query('checkbox[name=viewer_highlight_selected_word]', @)[0].setValue(FM.Viewer.settings.highlight_selected_word)
        Ext.ComponentQuery.query('checkbox[name=viewer_show_print_margin]', @)[0].setValue(FM.Viewer.settings.show_print_margin)

        Ext.ComponentQuery.query('radio[name=viewer_code_folding_type]', @)[0].setValue(FM.Viewer.settings.code_folding_type)
        Ext.ComponentQuery.query('combobox[name=viewer_theme]', @)[0].setValue(FM.Viewer.settings.theme)

  initComponent: () ->
    FM.Logger.debug('FM.view.windows.SettingsWindow initComponent() called', arguments)

    @save_btn = Ext.create 'Ext.button.Button',
      text: t("Save")
      cls: 'fm-button-settings-save'
      disabled: false
      scope: @
      ctrl: true
      enter: true
      handler: (button, e) =>
        FM.Logger.debug("Save setting save handler called()", arguments, @)
        if @save?

          editor_settings = {
            print_margin_size: Ext.ComponentQuery.query('numberfield[name=editor_print_margin_size]', @)[0].getValue()
            font_size: Ext.ComponentQuery.query('numberfield[name=editor_font_size]', @)[0].getValue()
            tab_size: Ext.ComponentQuery.query('numberfield[name=editor_tab_size]', @)[0].getValue()
            full_line_selection: Ext.ComponentQuery.query('checkbox[name=editor_full_line_selection]', @)[0].getValue()
            highlight_active_line: Ext.ComponentQuery.query('checkbox[name=editor_highlight_active_line]', @)[0].getValue()
            show_invisible: Ext.ComponentQuery.query('checkbox[name=editor_show_invisible]', @)[0].getValue()
            wrap_lines: Ext.ComponentQuery.query('checkbox[name=editor_wrap_lines]', @)[0].getValue()
            use_soft_tabs: Ext.ComponentQuery.query('checkbox[name=editor_use_soft_tabs]', @)[0].getValue()
            show_line_numbers: Ext.ComponentQuery.query('checkbox[name=editor_show_line_numbers]', @)[0].getValue()
            highlight_selected_word: Ext.ComponentQuery.query('checkbox[name=editor_highlight_selected_word]', @)[0].getValue()
            show_print_margin: Ext.ComponentQuery.query('checkbox[name=editor_show_print_margin]', @)[0].getValue()
            use_autocompletion: Ext.ComponentQuery.query('checkbox[name=editor_use_autocompletion]', @)[0].getValue()
            enable_emmet: Ext.ComponentQuery.query('checkbox[name=editor_enable_emmet]', @)[0].getValue()
            code_folding_type: Ext.ComponentQuery.query('radio[name=editor_code_folding_type]', @)[0].getGroupValue()
            theme: Ext.ComponentQuery.query('combobox[name=editor_theme]', @)[0].getValue()
          }

          viewer_settings = {
            print_margin_size: Ext.ComponentQuery.query('numberfield[name=viewer_print_margin_size]', @)[0].getValue()
            font_size: Ext.ComponentQuery.query('numberfield[name=viewer_font_size]', @)[0].getValue()
            tab_size: Ext.ComponentQuery.query('numberfield[name=viewer_tab_size]', @)[0].getValue()
            full_line_selection: Ext.ComponentQuery.query('checkbox[name=viewer_full_line_selection]', @)[0].getValue()
            highlight_active_line: Ext.ComponentQuery.query('checkbox[name=viewer_highlight_active_line]', @)[0].getValue()
            show_invisible: Ext.ComponentQuery.query('checkbox[name=viewer_show_invisible]', @)[0].getValue()
            wrap_lines: Ext.ComponentQuery.query('checkbox[name=viewer_wrap_lines]', @)[0].getValue()
            use_soft_tabs: Ext.ComponentQuery.query('checkbox[name=viewer_use_soft_tabs]', @)[0].getValue()
            show_line_numbers: Ext.ComponentQuery.query('checkbox[name=viewer_show_line_numbers]', @)[0].getValue()
            highlight_selected_word: Ext.ComponentQuery.query('checkbox[name=viewer_highlight_selected_word]', @)[0].getValue()
            show_print_margin: Ext.ComponentQuery.query('checkbox[name=viewer_show_print_margin]', @)[0].getValue()
            code_folding_type: Ext.ComponentQuery.query('radio[name=viewer_code_folding_type]', @)[0].getGroupValue()
            theme: Ext.ComponentQuery.query('combobox[name=viewer_theme]', @)[0].getValue()
          }

          @save button, @, e,
            editor_settings: editor_settings
            viewer_settings: viewer_settings

    @cancel_btn = Ext.create 'Ext.button.Button',
      cls: 'fm-button-settings-cancel'
      scope: @
      text: t("Cancel")
      disabled: false
      handler: (button, e) =>
        FM.Logger.debug("Save setting Cancel handler called()", arguments, @)
        @cancelled = true
        if @cancel?
          @cancel(button, @, e)
        else
          @close()

    @buttons = [@save_btn, @cancel_btn]
    @preset = [@save_btn, @cancel_btn]  # <-- WTF @buttons is null after init, so will use @preset

    FM.Logger.debug('init done', @, @buttons, @preset)
    @callParent(arguments)