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
})