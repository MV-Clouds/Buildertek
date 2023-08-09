({
    getRecords: function (component, event, helper, pageNumber, pageSize) {
        var action = component.get("c.retrieveRecords");
        action.setParams({
            recordId: component.get('v.recordId'),
            pageSize: pageSize,
            pageNumber: pageNumber
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var list = response.getReturnValue().records;
                var totalRecords = response.getReturnValue().recordCount;
                for (var i in list) {
                    if (list[i].isSelected == undefined) {
                        list[i].isSelected = false;
                    }
                }
                component.set('v.listOfRecords', list);
                component.set("v.pageNumber", pageNumber);
                component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.recordEnd", (list.length + 3) * pageNumber);
                component.set("v.totalPages", Math.ceil(list.length / totalRecords));
                component.set('v.totalRecords', totalRecords);
                if (totalRecords < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    importRecords: function (component, event, helper, recordToImport) {
        debugger;
        var baseURL = component.get("v.baseURLs");
        var recordId = component.get("v.recordId");
        var action = component.get("c.importMasterRecords");
        action.setParams({
            projectId: recordId,
            listOfIds: recordToImport
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                component.set('v.isLoading', false);
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     mode: 'sticky',
                //     title: 'Success',
                //     message: 'Warranty Imported Successfully!',
                //     type: 'success',
                //     duration: '10000',
                //     mode: 'dismissible'
                // });
                // toastEvent.fire();
                window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Project__c/' + escape(recordId) + '/view', '_self');
            } else {
                component.set('v.isLoading', false);
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     mode: 'sticky',
                //     title: 'Error!',
                //     message: 'Something Went Wrong!',
                //     type: 'error',
                //     duration: '10000',
                //     mode: 'dismissible'
                // });
                // toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

})