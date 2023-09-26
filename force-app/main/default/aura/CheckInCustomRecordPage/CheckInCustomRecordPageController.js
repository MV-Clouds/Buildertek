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


    //  -------------------- New Image Preview --------------
    handle_img_click: function(component, event, helper){

        var imageSrc = event.getSource().get("v.src");
        var imageTitle = event.getSource().get("v.description");
        var imageId = event.getSource().get("v.id")

        helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
        helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);

    },

    Handle_imageLoaded: function(component, event, helper){
        console.log('image loaded');
        component.set("v.PreviewImgSpinner", false);
    },
    
    Handle_imageNotLoaded: function(component, event, helper){
        console.log('image not loaded');
        component.set("v.Is_ImageHavePreview", false);
        component.set("v.PreviewImgSpinner", false);

    },

    ChangeImg: function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
        helper.changeImageHelper(component, event, helper, null, true);
    },

    NextImg: function(component, event, helper){
        event.stopPropagation();
    },

    closeImagePreview : function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
    },

    downloadImage: function(component, event, helper){
        component.set("v.PreviewImgSpinner", true);
        var a = document.createElement('a');
        a.href = component.get("v.PreviewImageSrc");
        a.download = component.get("v.PreviewImageSrc");
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        component.set("v.PreviewImgSpinner", false);
    },

    downloadImage_distribution: function(component, event, helper){
        console.log('current preview image id >> ', component.get('v.PreviewImageId'));
        helper.downloadImage_distribution_helper(component, event, helper);
    },

    ShareImage_distribution: function(component, event, helper){
        console.log('Share Image >> ', component.get('v.PreviewImageId'));
        helper.ShareImage_distribution_helper(component, event, helper);
    },

    copy_share_link: function(component, event, helper){
        // Create a temporary textarea element
        var imageShareLink = component.get("v.ShareImg_Link");
        
        const textarea = document.createElement('textarea');
        textarea.value =  imageShareLink;        ;
        document.body.appendChild(textarea);
        textarea.select();
        textarea.setSelectionRange(0, 99999);
        document.execCommand('copy');
        document.body.removeChild(textarea);

        component.set("v.ShareImg_Modal_btn", 'Copied');

        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Copied!",
                    "type": "success",
                    "message": "Public Share Link Copied to Clipborad"  
                }, 1000);
        toastEvent.fire();
    },

    close_ShareImg_Model: function(component, event, helper){
        component.set("v.Open_ShareImg_Modal", false);
        component.set("v.ShareImg_Modal_btn", 'Copy');
    },

    stopEventPropogation: function(component, event, helper){
        event.stopPropagation();
    }

    //  New Image Preview  END --------------------

})