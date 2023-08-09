({
    // Load current profile picture
    onInit: function(component, event, helper) {
        //alert('onInit');
        helper.loadImage(component, event, helper);
        helper.setResolutionAttributes(component,event,helper);
    },

    autoInit: function(component, event, helper) {
       // alert('autoInit');
        var autoInit = component.get('v.AutoInit');
		helper.setResolutionAttributes(component,event,helper);
        if (autoInit) {
            helper.loadImage(component, event, helper);
            
        }
    },

    imageChanged: function(cmp, event, helper) {
        //responds to onchange event on file input
        var files = cmp.get('v.FileList'),
            previewDiv = cmp.find('previewDiv');
       // console.log('files', files[0]);
        $A.util.addClass(previewDiv, 'slds-hide');
        helper.readFile(cmp, helper, files[0]);
    },

    imageLoaded: function(cmp, event, helper) {
        //responds to onload event on file input
        var previewImage = cmp.find('preview').getElement(),
            height = previewImage.height,
            width = previewImage.width,
            maxHeight = cmp.get('v.MaxHeight'),
            maxWidth = cmp.get('v.MaxWidth'),
            previewDiv = cmp.find('previewDiv'),
            imgSrc = cmp.get('v.imgSrc');

        //console.log('previewImage: ' + previewImage);
       // console.log('height: ' + height);
       // console.log('width: ' + width);

        //only check size if image is from a data URL
        if (imgSrc.startsWith('data')) {
            if (height !== maxHeight || width !== maxWidth) {
                $A.util.addClass(previewDiv, 'slds-hide');
                cmp.set('v.DataUrl', '');
                cmp.set('v.ImageData', '');
                helper.showToast({
                    "title": 'Bad image size: ' + width + ' x ' + height,
                    "message": 'Image should be ' + maxWidth + ' x ' + maxHeight + ' exactly',
                    "type": "error",
                    "mode": "sticky"
                });
                return;
            } else {
                //image is correct size
                var dataURL = cmp.get("v.imgSrc"),
                    imageData = dataURL.split(',')[1];

                cmp.set("v.imageData", imageData);

            }
        }

        $A.util.removeClass(cmp.find('previewDiv'), 'slds-hide');
        $A.util.addClass(cmp.find('uploadWrapper'), 'slds-hide');

    },

    editImage: function(cmp, e, helper) {
        helper.editImage(cmp);
    },

    cancelEditImage: function(cmp, e, helper) {
        helper.cancelEditImage(cmp);
    },

    handleCompanyProfileId: function(component, event, helper) {
        var recordId = event.getParam("recordId");
        component.set("v.recordId", recordId);
        var containerDiv = component.find('container');
        $A.util.removeClass(containerDiv, 'slds-hide');
    },

    imageDataChanged: function(component, event, helper) {

        var files = component.get('v.FileList'),
            imageData = component.get('v.imageData');

        helper.upload(component, files[0], imageData).then(id => {
            component.set('v.contentVersionId', id);
            helper.loadImage(component, event, helper);
            var title = component.get('v.title');
            helper.showToast({
                "title": "Success",
                "message": `${title} Uploaded`,
                "type": "success"
            });
        }).catch(error => {

            helper.showToast({
                "title": "Error",
                "message": error.message,
                "type": "error"
            });
        });
    }


})