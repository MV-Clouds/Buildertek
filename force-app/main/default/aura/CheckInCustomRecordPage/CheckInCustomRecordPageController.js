({
    getCheckInRecords: function (component, event, helper) {
        var next = false;
        var prev = false;
        helper.getCheckInRecords(component, next, prev);
    },

    Next: function (component, event, helper) {
        var next = true;
        var prev = false;
        var offset = component.get("v.offset");
        helper.getCheckInRecords(component, next, prev, offset);
    },
    
    Previous: function (component, event, helper) {
        var next = false;
        var prev = true;
        var offset = component.get("v.offset");
        helper.getCheckInRecords(component, next, prev, offset);
    },

    onImageClick: function (component, event, helper) {
        console.log('image clicked');
        var imageId = event.getSource().get("v.id");
        console.log(imageId);
        helper.openMultipleFiles(component, event, helper, imageId);
    },

    handleCreateCheckIn: function (component, event, helper) {
        component.set('v.isPopupModalOpen', true);
        // helper.handleCreateCheckIn(component, next, prev);
    },

    handleComponentEvent: function (component, event, helper) {
        console.log('childEvent Called');
        component.set('v.isPopupModalOpen', false);
        // helper.handleCreateCheckIn(component, next, prev);
    },

})