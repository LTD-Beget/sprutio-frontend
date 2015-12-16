Ext.define 'FM.view.toolbars.EditorTopToolbar',
  extend: 'Ext.toolbar.Toolbar'
  alias: 'widget.editor-top-toolbar'
  cls: 'fm-editor-top-toolbar'
  items: []
  initComponent: () ->
    FM.Logger.log('FM.view.toolbars.EditorTopToolbar')

    @items = []

    @items.push
      text: t("File")
      menu: [
        {
          text: t("Save")
          handler: () =>
            @ownerCt.save()
        },
        {
          text: t("Save in")
          menu:
            items: Ext.Array.map FM.Editor.getEncodings(), (enc) =>
              return {
                text: enc,
                handler: (item) =>
                  @ownerCt.save(item.text)
              }
        },
        "-",
        {
          text: t("Exit")
          handler: () =>
            @ownerCt.exit()
        }
      ]

    @items.push
      text: t("Encoding")
      cls: 'button-menu-encoding'
      menu:
        items: Ext.Array.map FM.Editor.getEncodings(), (enc) =>
          return {
            text: enc
            checked: false
            handler: (item) =>
              @ownerCt.changeEncoding(item.text)
              item.ownerCt.hide()
          }

    @items.push
      text: t("Syntax")
      cls: 'button-menu-syntax'
      menu:
        items: Ext.Array.map FM.Editor.getModes(), (mode) =>
          return {
            text: mode
            checked: false
            handler: (item) =>
              @ownerCt.changeSyntax(item.text)
              item.ownerCt.hide()
          }

    @items.push "->"

    @items.push
      text: t("Search")
      handler: () =>
        @ownerCt.editor.execCommand('find')
        setTimeout () =>
          if @ownerCt.editor.searchBox?
            $('input.ace_search_field', @ownerCt.editor.searchBox.searchBox).attr('placeholder', t("Search for"))
            $('[action=findAll]', @ownerCt.editor.searchBox.searchBox).text(t("All"))
            $('input.ace_search_field', @ownerCt.editor.searchBox.replaceBox).attr('placeholder', t("Replace with"))
            $('[action=replaceAndFindNext]', @ownerCt.editor.searchBox.replaceBox).text(t("Replace"))
            $('[action=replaceAll]', @ownerCt.editor.searchBox.replaceBox).text(t("All"))
            $('[action=toggleRegexpMode]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("RegExp Search"))
            $('[action=toggleCaseSensitive]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("CaseSensitive Search"))
            $('[action=toggleWholeWords]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("Whole Word Search"))
        ,
          100

    @items.push
      text: t("Search and Replace")
      handler: () =>
        @ownerCt.editor.execCommand('replace')
        setTimeout () =>
          if @ownerCt.editor.searchBox?
            $('input.ace_search_field', @ownerCt.editor.searchBox.searchBox).attr('placeholder', t("Search for"))
            $('[action=findAll]', @ownerCt.editor.searchBox.searchBox).text(t("All"))
            $('input.ace_search_field', @ownerCt.editor.searchBox.replaceBox).attr('placeholder', t("Replace with"))
            $('[action=replaceAndFindNext]', @ownerCt.editor.searchBox.replaceBox).text(t("Replace"))
            $('[action=replaceAll]', @ownerCt.editor.searchBox.replaceBox).text(t("All"))
            $('[action=toggleRegexpMode]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("RegExp Search"))
            $('[action=toggleCaseSensitive]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("CaseSensitive Search"))
            $('[action=toggleWholeWords]', @ownerCt.editor.searchBox.searchOptions).attr("title", t("Whole Word Search"))
        ,
          100

    @items.push "-"

    @items.push
      text: t("Settings")
      handler: () ->
        FM.Actions.Settings.execute()

    @callParent(arguments);