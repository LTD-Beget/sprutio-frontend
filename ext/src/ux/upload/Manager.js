/**
 * The object is responsible for uploading the queue.
 *
 */
Ext.define('Ext.ux.upload.Manager', {
    mixins: {
        observable: 'Ext.util.Observable'
    },

    requires: [
        'Ext.ux.upload.uploader.ExtJsUploader'
    ],

    synchronous: true,
    url: '',
    extraParams: {},
    extraHeaders: {},
    uploadTimeout: 6000,

    constructor: function (config) {
        this.mixins.observable.constructor.call(this);
        this.initConfig(config);

        this.uploader = Ext.create('Ext.ux.upload.uploader.ExtJsUploader', {
            url: this.url,
            scope: this,
            success: this.onUploadSuccess,
            failure: this.onUploadFailure,
            progress: this.onUploadProgress,
            extraParams: this.extraParams,
            extraHeaders: this.extraHeaders,
            timeout: this.uploadTimeout
        });

        this.uploader.on('uploadsuccess', this.onUploadSuccess, this);
        this.uploader.on('uploadfailure', this.onUploadFailure, this);
        this.uploader.on('uploadprogress', this.onUploadProgress, this);

        Ext.apply(this, {
            syncQueue: null,
            currentQueue: null,
            uploadActive: false,
            errorCount: 0
        });
    },

    uploadQueue: function (queue) {
        if (this.uploadActive) {
            return;
        }

        this.startUpload(queue);

        queue.reset();

        if (this.synchronous) {
            this.uploadQueueSync(queue);
            return;
        }

        this.uploadQueueAsync(queue);
    },

    uploadQueueSync: function (queue) {
        this.uploadNextItemSync();
    },

    uploadNextItemSync: function () {
        if (!this.uploadActive) {
            return;
        }

        var item = this.currentQueue.getFirstReadyItem();
        if (!item) {
            return;
        }

        this.uploader.uploadItem(item);
    },

    uploadQueueAsync: function (queue) {
        var i;
        var num = queue.getCount();

        for (i = 0; i < num; i++) {
            this.uploader.uploadItem(queue.getAt(i));
        }
    },

    startUpload: function (queue) {
        this.uploadActive = true;
        this.currentQueue = queue;
        this.fireEvent('beforeupload', this, queue);
    },

    finishUpload: function () {
        this.fireEvent('uploadcomplete', this, this.currentQueue, this.errorCount);
        this.currentQueue = null;
        this.uploadActive = false;
        this.errorCount = 0;
    },

    abortUpload: function () {
        this.uploader.abortUpload();

        this.currentQueue.recoverAfterAbort();

        this.fireEvent('abortupload', this, this.currentQueue);
        this.currentQueue = null;
        this.uploadActive = false;
        this.errorCount = 0;
    },

    afterItemUpload: function (item, info) {
        if (this.synchronous) {
            this.uploadNextItemSync();
        }

        if (this.currentQueue.isLast(item)) {
            this.finishUpload();
        }
    },

    onUploadSuccess: function (item, info) {
        item.setUploaded();
        this.fireEvent('itemuploadsuccess', item, info);
        this.afterItemUpload(item, info);
    },

    onUploadFailure: function (item, info) {
        var message = "Upload error";
        if (info.message !== undefined) {
            message = FM.helpers.ParseErrorMessage(info.message);
        }

        item.setUploadError(message);

        this.fireEvent('itemuploadfailure', item, info);
        this.errorCount++;

        this.afterItemUpload(item, info);
    },

    onUploadProgress: function (item, event) {
        item.setProgress(event.loaded);
    }
});
