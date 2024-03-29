({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);

        helper.Check_Create_User_Access(component, event, helper);

        var action = component.get("c.getMasterReviews");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'searchKeyword': ''
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log('Quote =>', { result });
                component.set("v.masterReviewsList", result);
                component.set("v.totalRecords", component.get("v.masterReviewsList").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.masterReviewsList").length > i)
                        PaginationList.push(result[i]);
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
                var pag = component.get('v.PaginationList');
                console.log({ pag });

                console.log('Start Page ----------> ' + component.get("v.startPage"));
                console.log('End Page ----------> ' + component.get("v.endPage"));
            }
        });
        $A.enqueueAction(action);
    },

    handleCheck: function (component, event, helper) {
        var checkbox1 = event.getSource().get("v.value");
        var checkbox = event.getSource().get("v.text");
        var Submittals = component.get("v.masterReviewsList");
        var getAllId = component.find("checkContractor");

        for (var i = 0; i < Submittals.length; i++) {
            if (Submittals[i].masterReviewRecord != null) {
                if (Submittals[i].masterReviewRecord.Id == checkbox && Submittals[i].reviewCheck == false) {
                    Submittals[i].reviewCheck = false;
                }
                else if (Submittals[i].masterReviewRecord.Id == checkbox && Submittals[i].reviewCheck == true) {
                    Submittals[i].reviewCheck = true;
                }
            }

        }
    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var Submittals = component.get("v.masterReviewsList");
        var getAllId = component.find("checkContractor");
        if (Submittals != null) {
            if (Submittals.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                }
                else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            Submittals[i].reviewCheck = true;

                        }
                    }
                    else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);
                            var Submittals = component.get("v.masterReviewsList");
                            Submittals[i].reviewCheck = false;
                        }
                    }
                }
            }
            else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true);
                    Submittals[i].reviewCheck = true;


                }
                else {
                    component.find("checkContractor").set("v.value", false);
                    var Submittals = component.get("v.masterReviewsList");
                    Submittals[i].reviewCheck = false;

                }
            }
        }

    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    ImportReview: function (component, event, helper) {
        if (component.get("v.HaveCreateAccess")) {
            component.set("v.Spinner", true);
            var quotesList = component.get("v.masterReviewsList");
            var reviewIds = [];
            for (var i = 0; i < quotesList.length; i++) {
                if (quotesList[i].reviewCheck == true) {
                    if (quotesList[i].masterReviewRecord != null) {
                        reviewIds.push(quotesList[i].masterReviewRecord.Id);
                    }
                }
            }

            if (reviewIds.length > 0) {
                var action = component.get("c.importMasterReviewLines");
                action.setParams({
                    reviewIds: reviewIds,
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Select atleast One Vendor Review record.",
                    "type": 'Error'
                });
                toastEvent.fire();
            }
        }
        else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Create record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },

    next: function (component, event, helper) {
        console.log('Next calling');
        var sObjectList = component.get("v.masterReviewsList");
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
        var sObjectList = component.get("v.masterReviewsList");
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

    onSearch: function (component, event, helper) {
        helper.doSearchHelper(component, event, helper);
    },
})