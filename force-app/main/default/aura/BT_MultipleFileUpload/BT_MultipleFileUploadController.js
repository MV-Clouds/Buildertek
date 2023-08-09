({
    getExistingFiles: function (component, event, helper) {
        component.set('v.sObjectId', component.get('v.recordId'));
        // helper.getExistingFiles(component);
    },

    handleUploadFinished: function (component, event, helper) {
        helper.handleUploadFinished(component, event);
    },

    handleCancelUpload: function (component, event, helper) {
        helper.handleCancelUpload(component);
    },

    handleSaveClick: function (component, event, helper) {
        helper.handleSaveClick(component);
    }
})