Ext.define('Ext.ux.window.Window', {
    extend: 'Ext.window.Window',

    /**
    * @cfg {Object} Reference to the taskbar that will house the window control.
    */
    taskBar: {},

    /**
    * @cfg {Boolean} To allow window to be minimized. Defaults to "true". There is no point in having this set to false.
    */
    minimizable: true,

    /**
    * @cfg {Boolean} To animate the window show hide events. Defaults to "false".
    */
    animate: false,

    initComponent: function () {

        Ext.apply(this, {
            taskBar: this.taskBar,
            listeners: {
                render: function() {
                    this.createTaskBarButton();
                },
                scope: this,
                single: true
            }
        });

        this.callParent();
    },

    initEvents: function() {
        Ext.ux.window.Window.superclass.initEvents.apply(this, arguments);

        this.mon(this, 'close', function() {
            this.taskBarButton.destroy();
            this.destroy();
        }, this);

        this.mon(this, 'minimize', function() {
            this.taskBarButton.toggle();
        }, this);

        this.mon(this, 'winshow', function() {
            this.show(this.animate?this.taskBarButton:false);
        });
        this.mon(this, 'winhide', function() {
            this.hide(this.animate?this.taskBarButton:false);
        });
    },

    createTaskBarButton: function() {
        var me = this;
        this.taskBarButton = Ext.create('Ext.button.Button',{
            text: this.title,
            pressed: true,
            enableToggle: true,
            listeners: {
                toggle: function(button, pressed, eOpts) {
                    if(pressed) {
                        me.fireEvent('winshow');
                    } else {
                        me.fireEvent('winhide');
                    }
                }
            }
        });

        this.taskBar.add(this.taskBarButton);
    }
});
