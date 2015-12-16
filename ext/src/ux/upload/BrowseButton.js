/**
 * A "browse" button for selecting multiple files for upload.
 *
 */
Ext.define('Ext.ux.upload.BrowseButton', {
    extend: 'Ext.form.field.File',
    buttonOnly: true,
    cls: 'x-browse-btn',
    iconCls: 'ux-mu-icon-action-browse',
    triggerWrapCls: 'wrap',
    buttonText: 'Browse...',
    buttonConfig: {
        iconCls: 'ux-mu-icon-action-browse',
        text: 'Browse...',
        margin: '0 5 0 0'
    },

    initComponent: function () {
        this.on('afterrender', function () {
            /*
             * Fixing the issue when adding an icon to the button - the text does not render properly. OBSOLETE - from
             * ExtJS v4.1 the internal implementation has changed, there is no button object anymore.
             */
            if (this.iconCls) {
                // this.button.removeCls('x-btn-icon');
                // var width = this.button.getWidth();
                // this.setWidth(width);
            }

            // Allow picking multiple files at once.
            this.fileInputEl.dom.setAttribute('multiple', '1');
        }, this);

        this.on('change', function (field, value, options) {
            //field, value, options
            var files = this.fileInputEl.dom.files;
            if (files && files.length > 0) {
                this.fireEvent('fileselected', this, files);
            }
        }, this);

        this.callParent(arguments);
    },

    // OBSOLETE - the method is not used by the superclass anymore
    createFileInput: function () {
        this.callParent(arguments);
        this.fileInputEl.dom.setAttribute('multiple', '1');
    }
});