/**
 * utils
 */
Ext.define('Ext.ux.Util', {

    statics: {
        clone: function (o) {
            if (!o || 'object' !== typeof o) {
                return o;
            }
            if ('function' === typeof o.clone) {
                return o.clone();
            }

            //console.log('test rec');
            var c = '[object Array]' === Object.prototype.toString.call(o) ? [] : {};
            var p, v;
            //console.log(c);
            for (p in o) {
                if (o.hasOwnProperty(p)) {
                    //console.log('iterate ', p, o);
                    v = o[p];
                    //console.log('v =', v, typeof v);
                    if (v && 'object' === typeof v) {
                        c[p] = Ext.ux.Util.clone(v);
                    }
                    else {
                        c[p] = v;
                    }
                }
            }
            //console.log(c);
            return c;
        }
    }
});
