/**
 * @class Ext.ux.container.SwitchButtonSegment
 * @extends Ext.ux.container.ButtonSegment
 * 
 * @author Harald Hanek (c) 2011-2012
 * @license http://harrydeluxe.mit-license.org
 */

Ext.define('Ext.ux.container.SwitchButtonSegment', {
	extend: 'Ext.ux.container.ButtonSegment',
	alias: 'widget.switchbuttonsegment',

	activeItem: 0,

	constructor: function(config)
	{
        var me = this;
        //console.log('construct', me);

		me.internalDefaults = {
			xtype: 'button',
			toggleGroup: Ext.id(me),
			clickEvent: 'mousedown',
			enableToggle: true,
			allowDepress: false
		};

        config = Ext.apply({}, config, me.internalDefaults);
        //console.log('config = ', config);
		me.callParent([ config ]);
	},
	
	initComponent: function()
	{
		var me = this;
		me.on('beforerender', me.beforeRender, me);
		me.callParent(arguments);

        //console.log('init-done')
	},

	beforeRender: function()
	{
		var me = this;
		me.callParent(arguments);
		me.activeItem = (me.activeItem + 1 > me.items.length) ? 0 : me.activeItem;

		me.items.each(function(el, c)
		{
			// aktiv setzen
			if(me.activeItem == c)
				el.pressed = true;

			me.mon(el, {
				toggle: me.onToggle,
				scope: me
			});

			el.toggleCount = c;
			el.scope = me;

		}, me);
	},

	getActiveItem: function()
	{
		return this.activeItem;
	},

	setActiveItem: function(item)
	{
        //console.log('setActiveItem');
		if(typeof (item) === 'number')
			item = this.items.getAt(item);

		item.toggle(true);
	},

	onToggle: function(btn, state)
	{
        //console.log('toggle');
		var me = this;
		if(state == true)
		{
			me.activeItem = btn.toggleCount;
			me.fireEvent('change', btn);
		}
	},

    privates: {
        applyDefaults: function (c) {
            if (!Ext.isString(c)) {
                c = this.callParent(arguments);
                var d = this.internalDefaults;
                if (c.events) {
                    Ext.applyIf(c.initialConfig, d);
                    Ext.apply(c, d);
                } else {
                    Ext.applyIf(c, d);
                }
            }
            return c;
        }
    }
});