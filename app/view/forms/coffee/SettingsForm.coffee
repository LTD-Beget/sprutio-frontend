Ext.define 'FM.view.forms.SettingsForm',
  extend: 'Ext.form.Panel'
  alias: 'widget.settings-form'
  cls: 'fm-settings-form'
  items: []
  bodyStyle:
    background: 'none'
  bodyPadding: 0
  requires: [
    'Ext.ux.form.SearchField'
    'Ext.form.field.Checkbox'
    'Ext.form.Label'
    'Ext.tab.Panel'
  ]
  defaults:
    margin: 0
  initComponent: () ->
    FM.Logger.log('FM.view.forms.SettingsForm init')

    @items = []

    @items.push
      xtype: "tabpanel"
      defaults:
        bodyPadding: "10 15"
        autoScroll: true
      bodyStyle:
        background: 'none'
      tabBar:
        defaults:
          margin: '0'
          flex: 1
      margin: 0
      items: [
        {
          title: t("Editor")
          defaultType: "container"
          bodyStyle:
            background: 'none'
          defaults:
            margin: 0
          items: [
            {
              defaultType: "container"
              layout: "hbox"

              items: [
                {
                  defaultType: "checkbox"
                  defaults: {
                    uncheckedValue: "off"
                    margin: 0
                  }
                  flex: 1
                  items: [
                    {
                      name: "editor_full_line_selection"
                      boxLabel: t("Full line selection")
                    },
                    {
                      name: "editor_highlight_active_line"
                      boxLabel: t("Highlight active line")
                    },
                    {
                      name: "editor_show_invisible"
                      boxLabel: t("Show invisible")
                    },
                    {
                      name: "editor_wrap_lines"
                      boxLabel: t("Wrap lines")
                    },
                    {
                      name: "editor_use_soft_tabs"
                      boxLabel: t("Use soft tabs")
                    },
                    {
                      name: "editor_show_line_numbers"
                      boxLabel: t("Show line numbers")
                    }
                  ]
                },
                {
                  defaultType: "checkboxfield",
                  defaults:
                    uncheckedValue: "off"
                    margin: 0
                  items: [
                    {
                      name: "editor_highlight_selected_word"
                      boxLabel: t("Highlight selected word")
                    },
                    {
                      name: "editor_show_print_margin"
                      boxLabel: t("Show print margin")
                    },
                    {
                      name: "editor_use_autocompletion"
                      boxLabel: t("Use autocompletion")
                    },
                    {
                      name: "editor_enable_emmet"
                      boxLabel: t("Enable Emmet mode")
                    }
                  ]
                }
              ]
            },
            {
              defaultType: "container"
              layout: "hbox"
              margin: "20 0 0 0"
              items: [
                {
                  xtype: "radiogroup"
                  flex: 1
                  columns: 1
                  labelAlign: "top",
                  fieldLabel: t("Code folding"),
                  items: [
                    {
                      name: "editor_code_folding_type"
                      boxLabel: t("manual")
                      inputValue: "manual"
                    },
                    {
                      name: "editor_code_folding_type"
                      boxLabel: t("mark begin")
                      inputValue: "markbegin"
                    },
                    {
                      name: "editor_code_folding_type"
                      boxLabel: t("mark begin and end")
                      inputValue: "markbeginend"
                    }
                  ]
                },
                {
                  defaults:
                    labelAlign: "top"
                  defaultType: "numberfield"
                  items: [
                    {
                      name: "editor_print_margin_size"
                      fieldLabel: t("Print margin size")
                      minValue: 1
                      maxValue: 200
                    },
                    {
                      name: "editor_font_size"
                      fieldLabel: t("Font size")
                      minValue: 6
                      maxValue: 72
                    },
                    {
                      name: "editor_tab_size"
                      fieldLabel: t("Tab size")
                      minValue: 1
                      maxValue: 32
                    }
                  ]
                }
              ]
            },
            {
              layout: "anchor"
              defaults:
                anchor: "100%"
              defaultType: "combobox"
              items: [
                {
                  name: "editor_theme"
                  fieldLabel: t("Theme")
                  labelAlign: "top"
                  editable: false
                  queryMode: "local"
                  valueField: "value"
                  margin: "10 0 0 0"
                  store: Ext.create "Ext.data.ArrayStore",
                    fields: ["value", "text"]
                    data: [
                      ["ambiance", "Ambiance"]
                      ["chrome", "Chrome"]
                      ["clouds", "Clouds"]
                      ["clouds_midnight", "Clouds Midnight"]
                      ["cobalt", "Cobalt"]
                      ["crimson_editor", "Crimson Editor"]
                      ["dawn", "Dawn"]
                      ["dreamweaver", "Dreamweaver"]
                      ["eclipse", "Eclipse"]
                      ["idle_fingers", "idleFingers"]
                      ["kr_theme", "krTheme"]
                      ["merbivore", "Merbivore"]
                      ["merbivore_soft", "Merbivore Soft"]
                      ["mono_industrial", "Mono Industrial"]
                      ["monokai", "Monokai"]
                      ["pastel_on_dark", "Pastel on dark"]
                      ["solarized_dark", "Solarized Dark"]
                      ["solarized_light", "Solarized Light"]
                      ["textmate", "TextMate"]
                      ["twilight", "Twilight"]
                      ["tomorrow", "Tomorrow"]
                      ["tomorrow_night", "Tomorrow Night"]
                      ["tomorrow_night_blue", "Tomorrow Night Blue"]
                      ["tomorrow_night_bright", "Tomorrow Night Bright"]
                      ["tomorrow_night_eighties", "Tomorrow Night 80s"]
                      ["vibrant_ink", "Vibrant Ink"]
                    ]
                }
              ]
            }
          ]
        },
        {
          title: t("Viewer")
          defaultType: "container"
          bodyStyle:
            background: 'none'

          items: [
            {
              defaultType: "container"
              layout: "hbox"
              bodyStyle:
                background: 'none'
              margin: 0
              items: [
                {
                  defaultType: "checkboxfield"
                  defaults: {
                    uncheckedValue: "off"
                    margin: 0
                  }
                  flex: 1
                  items: [
                    {
                      name: "viewer_full_line_selection"
                      boxLabel: t("Full line selection")
                    },
                    {
                      name: "viewer_highlight_active_line"
                      boxLabel: t("Highlight active line")
                    },
                    {
                      name: "viewer_show_invisible"
                      boxLabel: t("Show invisible")
                    },
                    {
                      name: "viewer_wrap_lines"
                      boxLabel: t("Wrap lines")
                    },
                    {
                      name: "viewer_use_soft_tabs"
                      boxLabel: t("Use soft tabs")
                    },
                    {
                      name: "viewer_show_line_numbers"
                      boxLabel: t("Show line numbers")
                    }
                  ]
                },
                {
                  defaultType: "checkboxfield"
                  defaults:
                    uncheckedValue: "off"
                    margin: 0
                  bodyStyle:
                    background: 'none'
                    padding: 0
                  items: [
                    {
                      name: "viewer_highlight_selected_word"
                      boxLabel: t("Highlight selected word")
                    },
                    {
                      name: "viewer_show_print_margin"
                      boxLabel: t("Show print margin")
                    }
                  ]
                }
              ]
            },
            {
              defaultType: "container"
              layout: "hbox"
              bodyStyle:
                background: 'none'
              margin: "20 0 0 0"
              items: [
                {
                  xtype: "radiogroup"
                  flex: 1
                  columns: 1
                  labelAlign: "top"
                  fieldLabel: t("Code folding")
                  bodyStyle:
                    background: 'none'
                    padding: 0
                  items: [
                    {
                      name: "viewer_code_folding_type"
                      boxLabel: t("manual")
                      inputValue: "manual"
                      margin: 0
                    },
                    {
                      name: "viewer_code_folding_type"
                      boxLabel: t("mark begin")
                      inputValue: "markbegin"
                      margin: 0
                    },
                    {
                      name: "viewer_code_folding_type"
                      boxLabel: t("mark begin and end")
                      inputValue: "markbeginend"
                      margin: 0
                    }
                  ]
                },
                {
                  defaults:
                    labelAlign: "top"
                  defaultType: "numberfield"
                  bodyStyle:
                    background: 'none'
                  items: [
                    {
                      name: "viewer_print_margin_size"
                      fieldLabel: t("Print margin size")
                      minValue: 1
                      maxValue: 200
                    },
                    {
                      name: "viewer_font_size"
                      fieldLabel: t("Font size")
                      minValue: 6
                      maxValue: 72
                    },
                    {
                      name: "viewer_tab_size"
                      fieldLabel: t("Tab size")
                      minValue: 1
                      maxValue: 32
                    }
                  ]
                }
              ]
            },
            {
              layout: "anchor"
              defaults:
                anchor: "100%"
              defaultType: "combobox"
              bodyStyle:
                background: 'none'
              items: [
                {
                  name: "viewer_theme"
                  fieldLabel: t("Theme")
                  editable: false
                  labelAlign: "top"
                  queryMode: "local"
                  valueField: "value"
                  margin: "10 0 0 0"
                  store: Ext.create "Ext.data.ArrayStore",
                    fields: ["value", "text"]
                    data: [
                      ["ambiance", "Ambiance"]
                      ["chrome", "Chrome"]
                      ["clouds", "Clouds"]
                      ["clouds_midnight", "Clouds Midnight"]
                      ["cobalt", "Cobalt"]
                      ["crimson_editor", "Crimson Editor"]
                      ["dawn", "Dawn"]
                      ["dreamweaver", "Dreamweaver"]
                      ["eclipse", "Eclipse"]
                      ["idle_fingers", "idleFingers"]
                      ["kr_theme", "krTheme"]
                      ["merbivore", "Merbivore"]
                      ["merbivore_soft", "Merbivore Soft"]
                      ["mono_industrial", "Mono Industrial"]
                      ["monokai", "Monokai"]
                      ["pastel_on_dark", "Pastel on dark"]
                      ["solarized_dark", "Solarized Dark"]
                      ["solarized_light", "Solarized Light"]
                      ["textmate", "TextMate"]
                      ["twilight", "Twilight"]
                      ["tomorrow", "Tomorrow"]
                      ["tomorrow_night", "Tomorrow Night"]
                      ["tomorrow_night_blue", "Tomorrow Night Blue"]
                      ["tomorrow_night_bright", "Tomorrow Night Bright"]
                      ["tomorrow_night_eighties", "Tomorrow Night 80s"]
                      ["vibrant_ink", "Vibrant Ink"]
                    ]
                }
              ]
            }
          ]
        }
      ]

    @callParent(arguments)