({
    setResolutionAttributes : function(component, event, helper) {
        //alert('Hi in setresolution');
        var action = component.get("c.getResolutionValues"),
            recordId = component.get("v.recordId");
        action.setParams({
            recordId: recordId           
        });
		
         action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var imageResolution = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log(imageResolution);
                component.set("v.MaxHeight",imageResolution.Height__c);
                component.set("v.MaxWidth",imageResolution.Width__c);
               // var a = imageResolution.Height__c;                
            }
            else if (state === 'ERROR') {

                var errors = response.getError();

                helper.showToast({
                    "title": 'Error',
                    "message": errors[0].message,
                    "type": "error",
                    "mode": "sticky"
                });

            }
              });
        $A.enqueueAction(action);
    },
    loadImage: function(component, event, helper) {

        var action = component.get("c.getImage"),
            recordId = component.get("v.recordId"),
            title = component.get("v.title");
        //
        action.setParams({
            parentId: recordId,
            title: title
        });

        action.setCallback(this, function(a) {
            var state = a.getState();

            if (state === 'SUCCESS') {

                var contentVersionId = a.getReturnValue();

                if (contentVersionId) {
                    var prefix = component.get('v.prefixURL')
                    component.set('v.imgSrc', prefix + contentVersionId);
                    $A.util.removeClass(component.find('previewDiv'), 'slds-hide');
                    $A.util.addClass(component.find('uploadWrapper'), 'slds-hide');
                }
                return;
            } else if (state === 'ERROR') {

                var errors = a.getError();

                helper.showToast({
                    "title": 'Error',
                    "message": errors[0].message,
                    "type": "error",
                    "mode": "sticky"
                });

            }


        });
        $A.enqueueAction(action);
    },
    readFile: function(component, helper, file) {
        // console.log('file');
        // console.log(file);
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            // deal with non-images
        }
        var reader = new FileReader();
        reader.onload = function(e) {

            var dataURL = e.target.result,
                imageData = dataURL.split(',')[1];

            component.set("v.imgSrc", dataURL);

        };
        reader.readAsDataURL(file);
    },

    upload: function(component, file, base64Data) {

        return new Promise(
            $A.getCallback((resolve, reject) => {
                var action = component.get("c.saveFile");
                action.setParams({
                    parentId: component.get("v.recordId"),
                    title: component.get("v.title"),
                    fileName: file.name,
                    base64Data: base64Data,
                    contentType: file.type
                });
                action.setCallback(this, (response) => {
                    var state = response.getState();

                    if (state === 'SUCCESS') {

                        component.set("v.message", "Image uploaded");
                        console.log('uploaded');
                        resolve(response.getReturnValue());

                    } else if (state === 'ERROR') {

                        var errors = response.getError();

                        console.error('error uploading:', errors[0]);
                        reject(errors[0]);

                    }

                });
                component.set("v.message", "Uploading...");
                console.log('uploading...');
                $A.enqueueAction(action);
            })
        );
    },

    showToast: function(params) {
        return new Promise($A.getCallback((resolve, reject) => {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(params);
            toastEvent.fire();
            resolve();
        }));
    },

    editImage: function(cmp) {
        $A.util.addClass(cmp.find('previewDiv'), 'slds-hide');
        $A.util.removeClass(cmp.find('uploadWrapper'), 'slds-hide');
        $A.util.removeClass(cmp.find('cancelEdit'), 'slds-hide');
    },

    cancelEditImage: function(cmp) {
        $A.util.removeClass(cmp.find('previewDiv'), 'slds-hide');
        $A.util.addClass(cmp.find('uploadWrapper'), 'slds-hide');
        $A.util.addClass(cmp.find('cancelEdit'), 'slds-hide');
    }

})