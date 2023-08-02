({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getMasterProjectTakeoff");
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterprojecttakeofflist", result);
                component.set("v.totalRecords", component.get("v.masterprojecttakeofflist").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.masterprojecttakeofflist").length > i)
                        PaginationList.push(result[i]);
                }
                //alert('PaginationList Length ------> '+PaginationList.length);
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
                console.log('Start Page ----------> ' + component.get("v.startPage"));
                console.log('End Page ----------> ' + component.get("v.endPage"));
            }
        });
        $A.enqueueAction(action);
    },

    handleCheck: function (component, event, helper) {
        debugger;
        var checkbox = event.getSource();
        var Submittals = component.get("v.masterprojecttakeofflist");
        console.log('Submittals::', Submittals);
        /*for(var i=0 ; i < Submittals.length;i++){
            console.log('=========> ',i +' '+ Submittals.length);
            if(Submittals[i].masterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == false){
                Submittals[i].projecttakeoffCheck = true;
                if(Submittals.length > 1){
                    component.find("checkContractor")[i].set("v.value", true);
                }
                else{
                    component.find("checkContractor").set("v.value", true);
                }
            }
            else if(Submittals[i].masterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == true){
                 Submittals[i].projecttakeoffCheck = false;
                 component.find("checkContractors").set("v.value", false);
            }
        }*/

        for (var i = 0; i < Submittals.length; i++) {
            if (Submittals[i].masterprojecttakeoffrecord != null) {
                if (Submittals[i].masterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == false) {
                    Submittals[i].projecttakeoffCheck = true;
                } else if (Submittals[i].masterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == true) {
                    Submittals[i].projecttakeoffCheck = false;
                }
            } else if (Submittals[i].mastermasterprojecttakeoffrecord != null) {
                if (Submittals[i].mastermasterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == false) {
                    Submittals[i].projecttakeoffCheck = true;
                } else if (Submittals[i].mastermasterprojecttakeoffrecord.Id == checkbox.get("v.text") && Submittals[i].projecttakeoffCheck == true) {
                    Submittals[i].projecttakeoffCheck = false;
                }
            }

        }
    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var Submittals = component.get("v.masterprojecttakeofflist");
        var getAllId = component.find("checkContractor");
        if (Submittals != null) {
            if (Submittals.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            Submittals[i].projecttakeoffCheck = true;

                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);

                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            var Submittals = component.get("v.masterprojecttakeofflist");
                            Submittals[i].projecttakeoffCheck = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true);
                    var checkbox = component.find("checkContractor").get("v.text");
                    Submittals[i].projecttakeoffCheck = true;


                } else {
                    component.find("checkContractor").set("v.value", false);

                    var checkbox = component.find("checkContractor").get("v.text");
                    var Submittals = component.get("v.masterprojecttakeofflist");
                    Submittals[i].projecttakeoffCheck = false;

                }
            }
        }

    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    importprojecttakeoff: function (component, event, helper) {
        component.set("v.Spinner", true);
        var takeofflst = component.get("v.masterprojecttakeofflist");
        var takeofflIds = [];
        for (var i = 0; i < takeofflst.length; i++) {
            //alert('projecttakeoffCheck -------> '+takeofflst[i].projecttakeoffCheck);

            if (takeofflst[i].projecttakeoffCheck == true) {
                if (takeofflst[i].mastermasterprojecttakeoffrecord != null) {
                    takeofflIds.push(takeofflst[i].mastermasterprojecttakeoffrecord.Id);
                } else if (takeofflst[i].masterprojecttakeoffrecord != null) {
                    takeofflIds.push(takeofflst[i].masterprojecttakeoffrecord.Id);
                }
            }
        }
        // alert('takeofflines --> '+takeofflIds);
        if (takeofflIds.length > 0) {
            var action = component.get("c.importMasterProjecttakeoffLines");
            action.setParams({
                takeofflIds: takeofflIds,
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result.Status === 'Success') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": result.Message,
                            "type": 'Success'
                        });
                        toastEvent.fire();
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire();
                        window.setTimeout(
                            $A.getCallback(function () {
                                document.location.reload(true);
                            }), 1000
                        );
                    } else {
                        component.set("v.Spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": result.Message,
                            "type": 'Error'
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function () {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Please select at least one Master Project Takeoff',
                        type: 'warning',
                        duration: '1000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }), 1000
            );
        }
    },

    next: function (component, event, helper) {
        var sObjectList = component.get("v.masterprojecttakeofflist");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.masterprojecttakeofflist");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
    },
})