({
    getCheckInRecords: function (component, next, prev, offset) {
        try {
            component.set("v.Spinner", true);
            var recordId = component.get("v.recordId");
            console.log('recordID for checkins ==>' + recordId);

            if (recordId == null || recordId == undefined) {
                component.set('v.isRecordTabPage', true);
            }

            offset = offset || 0;
            var action = component.get("c.getCheckIns");
            console.log('next => ' + next + ' - prev => ' + prev + ' - off => ' + offset);
            action.setParams({
                "next": next,
                "prev": prev,
                "off": offset,
                "projectId": recordId
            });
            action.setCallback(this, function (res) {
                var state = res.getState();
                if (state == "SUCCESS") {
                    var result = res.getReturnValue();
                    console.log('result ==>' , result);

                    result.checkInList.forEach(element => {
                        console.log('element ==> ',element);
                    });

                    component.set("v.Spinner", false);
                    component.set('v.offset', result.offst);
                    component.set('v.checkIns', result.checkInList);
                    component.set('v.next', result.hasnext);
                    component.set('v.prev', result.hasprev);
                    component.set('v.orgBaseURL', result.orgBaseUrl);

                    if (result.totalPage > 0) {
                        component.set('v.currentPage', (result.offst/5)+1);
                    } else {
                        component.set('v.currentPage', (result.offst/5));
                    }
                    component.set('v.totalPage', result.totalPage);
                }
            });
            $A.enqueueAction(action);

        } catch (error) {
            component.set("v.Spinner", false);
            console.log('Error in getCheckIn ==>');
            console.log(error);
        }
    },

    openMultipleFiles: function(component, event, helper, selectedId) {

        var indexLst = selectedId.split("-");
        console.log('indexLst ==>' + indexLst);
        var fileId = indexLst[0];
        var index = indexLst[1];

        var checkInlist = component.get('v.checkIns');
        var recordList = checkInlist[index].ContentDocumentLinks;
        console.log(recordList);

        var recordFilesId = [];
        for (const res of recordList) {
            recordFilesId.push(res.ContentDocumentId);
        }

        console.log(recordFilesId);
		$A.get('e.lightning:openFiles').fire({
		    recordIds: recordFilesId,
		    selectedRecordId: fileId
		});
	},
    displayImage: function (component, imageLink) {
        console.log('in displayimage');
        // Set the image source and title in the component's attributes
        component.set("v.PreviewImageSrc", imageLink);
        component.set("v.PreviewImageTitle", imageLink.ContentDocument.Title);

        // Optionally, you can also set a loading indicator if needed
        component.set("v.PreviewImgSpinner", true);

        // Assuming you want to reset the loading indicator after a brief delay
        // You can use setTimeout to simulate the loading process
        window.setTimeout(function () {
            // Remove the loading indicator after a delay
            component.set("v.PreviewImgSpinner", false);
        }, 1000); // Adjust the delay as needed
    },

    //  -------------------- New Image Preview --------------
    openCustomPreviewHelper: function(component, event, helper, imageSrc, imageTitle, imageId){
        component.set("v.PreviewImageSrc", imageSrc);
        component.set("v.PreviewImageTitle", imageTitle);
        component.set("v.PreviewImageId", imageId);
        console.log(component.get("v.orgBaseURL"));
        console.log('imgSRC > ', imageSrc);


        component.set("v.PreviewImgSpinner", true);
        component.set("v.Is_ImageHavePreview", true);
        component.set('v.Show_ImagePreview', true);

    },

    changeImageHelper: function(component, event, helper, imageId, next_previus_btn_click){
        // try {
            event.stopPropagation();
            var operation;
            var imageId;
            if(next_previus_btn_click){
                // When Function called from Next/Previous Btn
                operation = event.currentTarget.dataset.name;
                imageId = component.get("v.PreviewImageId");
            }
            else{
                // When Function not called from Next/Previous Btn
                // To set Next/Previous Btn Visibility
                operation = null;
                imageId = imageId;
            }

            const div = document.getElementById(imageId);  // This Div use to check-in's Id, contentDocument Id, etc
            const checkIns = component.get('v.checkIns');

            checkIns.forEach(checkIn =>{
                if(checkIn.Id == div.dataset.cid){
                    for(var j = 0; j< checkIn.ContentDocumentLinks.length; j++){
                        if(j == div.dataset.cdlindex && checkIn.ContentDocumentLinks[j].Id == div.dataset.cdid){
                            
                            if(next_previus_btn_click == true){
                                // Main Next/Previous Logic
                                if(operation == 'Previous_Image'){
                                    console.log('Previous_Image');
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j - 1].ContentDocumentId;
                                    var imageTitle = checkIn.ContentDocumentLinks[j - 1].ContentDocument.Title;
                                    var imageId = checkIn.ContentDocumentLinks[j - 1].ContentDocumentId;
                                    helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);    // reopen preview div to call 'onload' and 'onerror' method for image
                                }
                                else if(operation == 'Next_Image'){
                                    console.log('Next_Image');
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j + 1].ContentDocumentId;
                                    var imageTitle = checkIn.ContentDocumentLinks[j + 1].ContentDocument.Title;
                                    var imageId = checkIn.ContentDocumentLinks[j + 1].ContentDocumentId;
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
                                if(j == (checkIn.ContentDocumentLinks.length - 1)){
                                    component.set("v.NotLastImg", false);
                                    console.log('Last_Img');
                                }
                                else if(j != (checkIn.ContentDocumentLinks.length - 1)){
                                    component.set("v.NotLastImg", true);
                                }
                            }
                            
                        }
                    }
                }
            })
            
        // } catch (error) {
        //     console.log('error >> ', error.stack);
        // }
    },  

    downloadImage_distribution_helper: function(component, event, helper){
        try {
            console.log('apex call');
            var action = component.get("c.GetContentDistrubutionRecord");
            action.setParams({
                'Content_Document_Id' : component.get('v.PreviewImageId')
            })
            action.setCallback(this, function (response){
                console.log('response : ', response.getReturnValue());
                console.log('state ', response.getState());
                if(response.getState() == "SUCCESS"){
                    var Result = response.getReturnValue();
                    if(Result != null){
                        component.set("v.PreviewImgSpinner", true);
                        var a = document.createElement('a');
                        a.href = Result.ContentDownloadUrl;
                        a.download = Result.ContentDownloadUrl;
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);
                        component.set("v.PreviewImgSpinner", false);
                    }
                }

            })
            $A.enqueueAction(action);

        } catch (error) {
            console.log('error in downloadImage_distribution_helper : ', error.stack);
            
        }
    },

    ShareImage_distribution_helper: function(component, event, helper){
        try {
            console.log('apex call');
            var action = component.get("c.GetContentDistrubutionRecord");
            action.setParams({
                'Content_Document_Id' : component.get('v.PreviewImageId')
            })
            action.setCallback(this, function (response){
                console.log('response : ', response.getReturnValue());
                console.log('state ', response.getState());
                if(response.getState() == "SUCCESS"){
                    var Result = response.getReturnValue();
                    if(Result != null){
                        component.set("v.PreviewImgSpinner", true);
                        component.set("v.Open_ShareImg_Modal", true);
                        component.set("v.ShareImg_Link", Result.DistributionPublicUrl);
                        component.set("v.ShareImg_Modal_title", 'Public Share Link');
                        component.set("v.ShareImg_Modal_btn", 'Copy');
                        component.set("v.PreviewImgSpinner", false);
                    }
            }
            })
            $A.enqueueAction(action);

        } catch (error) {
            console.log('error in ShareImage_distribution_helper : ', error.stack);
        }
    }
    //  -------------------- New Image Preview END --------------

})