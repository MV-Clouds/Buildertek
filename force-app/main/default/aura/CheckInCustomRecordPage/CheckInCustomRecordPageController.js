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


    //  New Image Preview --------------
    openCustomPreview: function(component, event, helper){
        var imageSrc = event.getSource().get("v.src");
        component.set("v.PreviewImageSrc", imageSrc);
        var imageTitle = event.getSource().get("v.description");
        component.set("v.PreviewImageTitle", imageTitle);
        console.log('description >> ', event.getSource().get("v.description"));

       const img_preview = component.find("img_preview").getElement();
       img_preview.style = 'display : flex; background: rgba(0, 0, 0, 0.8);'
    },

    closeImagePreview : function(component, event, helper){
        const img_preview = component.find("img_preview").getElement();
       img_preview.style = '';
    },

    downloadImage: function(component, event, helper){
        var a = document.createElement('a');
        a.href = component.get("v.PreviewImageSrc");
        a.download = component.get("v.PreviewImageSrc");
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    },

    stopEventPropogation: function(component, event, helper){
        event.stopPropagation();
    }

    //  New Image Preview  END --------------------

})