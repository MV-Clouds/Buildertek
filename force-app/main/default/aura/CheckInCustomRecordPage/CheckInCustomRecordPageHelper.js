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

    chaneImageHelper: function(component, event, helper){
        try {
            event.stopPropagation();
            var operation;
            if(event.currentTarget){
                operation = event.currentTarget.dataset.name;
            }
            else{
                operation = null;
            }

            var imageId = component.get("v.PreviewImageId");
            const div = document.getElementById(imageId);

            const checkIns = component.get('v.checkIns');

            checkIns.forEach(checkIn =>{
                if(checkIn.Id == div.dataset.cid){
                    for(var j = 0; j< checkIn.ContentDocumentLinks.length; j++){
                        if(j == div.dataset.cdlindex && checkIn.ContentDocumentLinks[j].Id == div.dataset.cdid){
                            if(j != 0){
                                if(operation == 'Previous_Image'){
                                    component.set("v.NotFirstImg", true);

                                    var PreviewImageSrc = component.get("v.orgBaseURL") + '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j - 1].ContentDocumentId;
                                    component.set("v.PreviewImageSrc", PreviewImageSrc);
                                    component.set("v.PreviewImageId", checkIn.ContentDocumentLinks[j - 1].ContentDocumentId);
                                    component.set("v.PreviewImageTitle", checkIn.ContentDocumentLinks[j - 1].ContentDocument.Title);
                                    console.log('current Image >> ', JSON.parse(JSON.stringify(checkIn.ContentDocumentLinks[j-1].ContentDocument)));
                                }
                            }
                            else{
                                component.set("v.NotFirstImg", false);
                            }
                            if(j != (checkIn.ContentDocumentLinks.length - 1)){
                                if(operation == 'Next_Image'){
                                    component.set("v.NotLastImg", true);

                                    var PreviewImageSrc = component.get("v.orgBaseURL") + '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j + 1].ContentDocumentId;
                                    component.set("v.PreviewImageSrc", PreviewImageSrc);
                                    component.set("v.PreviewImageId", checkIn.ContentDocumentLinks[j + 1].ContentDocumentId);
                                    component.set("v.PreviewImageTitle", checkIn.ContentDocumentLinks[j + 1].ContentDocument.Title);
                                    console.log('current Image >> ', JSON.parse(JSON.stringify(checkIn.ContentDocumentLinks[j+1].ContentDocument)));

                                }
                            }
                            else{
                                component.set("v.NotLastImg", false);
                            }
                        }
                    }
                }
            })
                    
            console.log('dataset.cid> ', div.dataset.cid);
            console.log('dataset.cdid> ', div.dataset.cdid);
            console.log('dataset.cdlindex> ', div.dataset.cdlindex);
            
        } catch (error) {
            console.log('error >> ', error.stack);
        }
    }
})