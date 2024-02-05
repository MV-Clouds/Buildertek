({
    convertMapToList: function (map) {
        var list = [];
    
        for (var key in map) {
            if (map.hasOwnProperty(key)) {
                var optionInfo = key.split('__'); // Splitting the key into option id and name
                var optionId = optionInfo[1];
                var optionName = optionInfo[0];
                var contentDocumentLinks = map[key]; // List<ContentDocumentLink>
    
                list.push({
                    optionId: optionId,
                    optionName: optionName,
                    contentDocumentLinks: contentDocumentLinks
                });
            }
        }
    
        return list;
    },

    changeImageHelper: function(component, event, helper, imageId, outerId, next_previus_btn_click) {
        try {
            event.stopPropagation();
            var operation;
            var selectedImageId;
            
    
            if (next_previus_btn_click) {
                operation = event.currentTarget.dataset.name;
                selectedImageId = component.get("v.PreviewImageId");
                var outerId = component.get("v.outerId");
                var imageId = component.get("v.PreviewImageId");
            } else {
                operation = null;
                selectedImageId = imageId;
            }
            const contentDocsList = component.get('v.contentDocsList');
            for (var i in contentDocsList) {
                if (contentDocsList[i].optionId == outerId) {
                    var InnerListValue = contentDocsList[i].contentDocumentLinks;
                    for (var j in InnerListValue) {
                        if (InnerListValue[j].ContentDocumentId == imageId) {
                            if (next_previus_btn_click == true) {
                                if (operation == 'Previous_Image') {
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + InnerListValue[parseInt(j) - 1].ContentDocumentId;
                                    var imageTitle = InnerListValue[parseInt(j) - 1].ContentDocument.Title;
                                    var previewImageId = InnerListValue[parseInt(j) - 1].ContentDocumentId;
                                    helper.changeImageHelper(component, event, helper, previewImageId, outerId, false);
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, previewImageId, outerId);
                                } else if (operation == 'Next_Image') {
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + InnerListValue[parseInt(j) + 1].ContentDocumentId;
                                    var imageTitle = InnerListValue[parseInt(j) + 1].ContentDocument.Title;
                                    var previewImageId = InnerListValue[parseInt(j) + 1].ContentDocumentId;
                                    helper.changeImageHelper(component, event, helper, previewImageId, outerId, false);
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, previewImageId, outerId);
                                }
                            } 
                            else if (next_previus_btn_click == false) {
                                // Check if it's the first image
                                if (j == 0) {
                                    component.set("v.NotFirstImg", false);
                                } else {
                                    component.set("v.NotFirstImg", true);
                                }
    
                                // Check if it's the last image
                                if (j == InnerListValue.length - 1) {
                                    component.set("v.NotLastImg", false);
                                } else {
                                    component.set("v.NotLastImg", true);
                                }
                            }
                        }
                    }
                }
            }
        } catch (error) {
            console.log('error in changeImageHelper : ', error.stack);
        }
    },
    
    
    openCustomPreviewHelper: function(component, event, helper, imageSrc, imageTitle, imageId, outerId){
        component.set("v.PreviewImageSrc", imageSrc);
        component.set("v.PreviewImageTitle", imageTitle);
        component.set("v.PreviewImageId", imageId);
        component.set("v.outerId", outerId);
        component.set("v.PreviewImgSpinner", true);
        component.set("v.Is_ImageHavePreview", true);
        component.set('v.Show_ImagePreview', true);

    },

})