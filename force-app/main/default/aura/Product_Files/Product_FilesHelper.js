({
    changeImageHelper: function(component, event, helper, imageId, next_previus_btn_click){
        event.stopPropagation();
        var operation;
        var imageId;
        if(next_previus_btn_click){
            operation = event.currentTarget.dataset.name;
            imageId = component.get("v.PreviewImageId");
        }
        else{
            operation = null;
            imageId = imageId;
        }

        const div = document.getElementById(imageId);  // This Div use to check-in's Id, contentDocument Id, etc
        const optionFiles = component.get('v.contentDocsList');
        optionFiles.forEach(optionFile =>{
            if(optionFile.Id == div.dataset.cid){
                for(var j = 0; j< optionFiles.length; j++){
                    if(j == div.dataset.cdlindex && optionFiles[j].Id == div.dataset.cdid){
                        
                        if(next_previus_btn_click == true){
                            // Main Next/Previous Logic
                            if(operation == 'Previous_Image'){
                                console.log('Previous_Image');
                                var imageSrc = '/sfc/servlet.shepherd/document/download/' + optionFiles[j - 1].ContentDocumentId;
                                var imageTitle = optionFiles[j - 1].ContentDocument.Title;
                                var imageId = optionFiles[j - 1].ContentDocumentId;
                                helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
                                helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);    // reopen preview div to call 'onload' and 'onerror' method for image
                            }
                            else if(operation == 'Next_Image'){
                                console.log('Next_Image');
                                var imageSrc = '/sfc/servlet.shepherd/document/download/' + optionFiles[j + 1].ContentDocumentId;
                                var imageTitle = optionFiles[j + 1].ContentDocument.Title;
                                var imageId = optionFiles[j + 1].ContentDocumentId;
                                helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
                                helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);    // reopen preview div to call 'onload' and 'onerror' method for image
                            }
                        }
                        else if(next_previus_btn_click == false){
                            // To set Next/Previous Button Visibility for First & last Image
                            if(j == 0){
                                console.log('First_Img');
                                component.set("v.NotFirstImg", false);
                            }
                            else if(j != 0){
                                component.set("v.NotFirstImg", true);
                            }
                            if(j == (optionFiles.length - 1)){
                                component.set("v.NotLastImg", false);
                                console.log('Last_Img');
                            }
                            else if(j != (optionFiles.length - 1)){
                                component.set("v.NotLastImg", true);
                            }
                        }
                    }
                }
            }
        })
    }, 
    openCustomPreviewHelper: function(component, event, helper, imageSrc, imageTitle, imageId){
        component.set("v.PreviewImageSrc", imageSrc);
        console.log('imageSrc',imageSrc);
        component.set("v.PreviewImageTitle", imageTitle);
        component.set("v.PreviewImageId", imageId);
        component.set("v.PreviewImgSpinner", true);
        component.set("v.Is_ImageHavePreview", true);
        component.set('v.Show_ImagePreview', true);

    },
})