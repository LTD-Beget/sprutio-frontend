Ext.define 'FM.view.forms.ChangeAttributesForm',
  extend: 'Ext.form.Panel'
  alias: 'widget.change-attributes-form'
  cls: 'fm-change-attributes-form'
  items: []
  bodyStyle:
    background: 'none'
  requires: [
    'Ext.form.RadioGroup'
    'Ext.form.field.Text'
    'Ext.form.field.Radio'
  ]
  initComponent: () ->
    FM.Logger.log('FM.view.forms.ChangeAttributesForm init')

    @items = []

    @items.push
      xtype: 'checkboxgroup'
      layout:
        type: 'hbox'
        align: 'middle'
      bodyStyle:
        background: 'none'
      defaults:
        flex: 1
      bodyPadding: '3 0 3 0'
      fieldLabel: t("Owner Permissions")
      labelAlign: 'top'
      labelCls: 'label-bold'
      margin: '0 0 10 0'
      items: [
        {
          xtype: 'checkbox'
          boxLabel: t("Read")
          name: 'owner-read'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Write")
          name: 'owner-write'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Execute")
          name: 'owner-execute'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        }
      ]

    @items.push
      xtype: 'checkboxgroup'
      layout:
        type: 'hbox'
        align: 'middle'
      bodyStyle:
        background: 'none'
      defaults:
        flex: 1
      bodyPadding: '3 0 3 0'
      fieldLabel: t("Group Permissions")
      labelAlign: 'top'
      labelCls: 'label-bold'
      margin: '0 0 10 0'
      items: [
        {
          xtype: 'checkbox'
          boxLabel: t("Read")
          name: 'group-read'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Write")
          name: 'group-write'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Execute")
          name: 'group-execute'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        }
      ]

    @items.push
      xtype: 'checkboxgroup'
      layout:
        type: 'hbox'
        align: 'middle'
      bodyStyle:
        background: 'none'
      defaults:
        flex: 1
      bodyPadding: '3 0 3 0'
      fieldLabel: t("Public Permissions")
      labelAlign: 'top'
      labelCls: 'label-bold'
      margin: '0 0 10 0'
      items: [
        {
          xtype: 'checkbox'
          boxLabel: t("Read")
          name: 'public-read'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Write")
          name: 'public-write'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        },
        {
          xtype: 'checkbox'
          boxLabel: t("Execute")
          name: 'public-execute'
          padding: '5 0 5 0'
          listeners:
            change: (field, newValue, oldValue) =>
              @chmodAttributeHandler(field, newValue, oldValue)
        }
      ]

    @items.push
      xtype: 'textfield'
      name: 'chmod-code'
      labelStyle: 'width:120px'
      fieldLabel: t("Digital Value")
      allowBlank: false
      minLength: 0
      maxLength: 3
      enforceMaxLength: 3
      regex: /^[0-7]{3}$/
      regexText: t("Incorrect chmod value")
      listeners:
        change: (field, newValue, oldValue) =>
          @chmodCodeHandler(field, newValue, oldValue)

    @items.push
      xtype: 'checkbox'
      boxLabel: t("Recurse into subfolders")
      name: 'apply-recursively'
      margin: '10 0 0 0'
      listeners:
        change: (field, newValue) =>
          if newValue == true
            Ext.ComponentQuery.query('radiogroup[cls=recursive-mode-group]', @)[0].setDisabled(false)
          else
            Ext.ComponentQuery.query('radiogroup[cls=recursive-mode-group]', @)[0].setDisabled(true)

    @items.push
      xtype: 'radiogroup'
      cls: 'recursive-mode-group'
      margin: '5 0 0 0'
      disabled: true
      columns: 1,
      items: [
        {
          boxLabel: t("Apply to all files and directories")
          name: 'recursive-mode'
          inputValue: 'all'
          checked: true
        },
        {
          boxLabel: t("Apply to files only")
          name: 'recursive-mode'
          inputValue: 'files'
        },
        {
          boxLabel: t("Apply to directories only")
          name: 'recursive-mode'
          inputValue: 'dirs'
        }
      ]

    @callParent(arguments)

  chmodAttributeHandler: (field, newValue, oldValue) ->
    FM.Logger.debug('chmodAttributeHandler() called', arguments, @)

    owner_read = (if Ext.ComponentQuery.query('checkbox[name=owner-read]', @)[0].checked then 1 else 0) * 4
    owner_write = (if Ext.ComponentQuery.query('checkbox[name=owner-write]', @)[0].checked then 1 else 0) * 2
    owner_execute = (if Ext.ComponentQuery.query('checkbox[name=owner-execute]', @)[0].checked then 1 else 0) * 1

    group_read = (if Ext.ComponentQuery.query('checkbox[name=group-read]', @)[0].checked then 1 else 0) * 4
    group_write = (if Ext.ComponentQuery.query('checkbox[name=group-write]', @)[0].checked then 1 else 0) * 2
    group_execute = (if Ext.ComponentQuery.query('checkbox[name=group-execute]', @)[0].checked then 1 else 0) * 1

    public_read = (if Ext.ComponentQuery.query('checkbox[name=public-read]', @)[0].checked then 1 else 0) * 4
    public_write = (if Ext.ComponentQuery.query('checkbox[name=public-write]', @)[0].checked then 1 else 0) * 2
    public_execute = (if Ext.ComponentQuery.query('checkbox[name=public-execute]', @)[0].checked then 1 else 0) * 1

    chmod_code = (owner_read + owner_write + owner_execute).toString() + (group_read + group_write + group_execute).toString() + (public_read + public_write + public_execute).toString()

    FM.Logger.debug("Chmod code = ",chmod_code)

    chmod_regexp = /^[0-7]{3}$/

    if not chmod_regexp.test(chmod_code)
      FM.Logger.error('chmod not valid: ' + chmod_code)
      @ownerCt.chmod_btn.setDisabled(true)
      return

    Ext.ComponentQuery.query('textfield[name=chmod-code]', @)[0].setValue(chmod_code)
    @ownerCt.chmod_btn.setDisabled(false)

  chmodCodeHandler: (field, newValue, oldValue) ->
    FM.Logger.debug('chmodCodeHandler() called', arguments, @)

    chmod_regexp = /^[0-7]{3}$/

    if !chmod_regexp.test(newValue)
      FM.Logger.error('chmod code not valid: ' + newValue)
      @ownerCt.chmod_btn.setDisabled(true)
      return

    strValue = newValue.toString();

    owner_right = FM.helpers.ConvertToBinary(strValue[0]).toString()
    group_right = FM.helpers.ConvertToBinary(strValue[1]).toString()
    public_right = FM.helpers.ConvertToBinary(strValue[2]).toString()

    FM.Logger.debug('Owner right: ' + owner_right)
    FM.Logger.debug('Group right: ' + group_right)
    FM.Logger.debug('Public right: ' + public_right)

    # Here "0" or "1" casts to boolean
    Ext.ComponentQuery.query('checkbox[name=owner-read]', @)[0].setValue(Boolean(parseInt(owner_right[0])))
    Ext.ComponentQuery.query('checkbox[name=owner-write]', @)[0].setValue(Boolean(parseInt(owner_right[1])))
    Ext.ComponentQuery.query('checkbox[name=owner-execute]', @)[0].setValue(Boolean(parseInt(owner_right[2])))

    Ext.ComponentQuery.query('checkbox[name=group-read]', @)[0].setValue(Boolean(parseInt(group_right[0])))
    Ext.ComponentQuery.query('checkbox[name=group-write]', @)[0].setValue(Boolean(parseInt(group_right[1])))
    Ext.ComponentQuery.query('checkbox[name=group-execute]', @)[0].setValue(Boolean(parseInt(group_right[2])))

    Ext.ComponentQuery.query('checkbox[name=public-read]', @)[0].setValue(Boolean(parseInt(public_right[0])))
    Ext.ComponentQuery.query('checkbox[name=public-write]', @)[0].setValue(Boolean(parseInt(public_right[1])))
    Ext.ComponentQuery.query('checkbox[name=public-execute]', @)[0].setValue(Boolean(parseInt(public_right[2])))

    @ownerCt.chmod_btn.setDisabled(false)