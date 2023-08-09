({
    doInit: function (component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var action = component.get("c.getMasterPL");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var pageSize = component.get("v.pageSize");
                    var result = response.getReturnValue();
                    console.log('MaterPL From Apex =>', { result });
                    component.set("v.masterPunchList", result);
                    component.set("v.totalRecords", component.get("v.masterPunchList").length);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);

                    for (const res of result) {
                        res["checkVal"] = false;
                    }

                    var PaginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.masterPunchList").length > i) {
                            PaginationList.push(result[i]);
                        }
                    }

                    component.set('v.PaginationList', PaginationList);
                    console.log({ PaginationList });
                    component.set("v.Spinner", false);

                    /*  Map for Checkbox */

                    // var masterPLMap = component.get("v.masterPLCheckMap");
                    var masterPLMap = [];
                    var masterPLList = response.getReturnValue();
                    console.log({ masterPLMap });
                    console.log({ masterPLList });

                    for (const res of masterPLList) {
                        var mapVal = {
                            'Id': res.Id,
                            'flag': false
                        };
                        masterPLMap.push(mapVal);
                    }
                    console.log("after Creating Map ==>");
                    console.log({ masterPLMap });
                    component.set("v.masterPLCheckMap", masterPLMap);

                    /*  Map for Checkbox */

                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            component.set("v.Spinner", false);
            console.log("error in helper doInit Method ==>");
            console.log({ error });
        }
    },

    closeModel: function (component, event, helper) {
        try {
            $A.get("e.force:closeQuickAction").fire();
        } catch (error) {
            console.log("error in Helper closeModel Method");
            console.log({ error });
        }
    },

    previous: function (component, event, helper) {
        try {
            var sObjectList = component.get("v.masterPunchList");
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

            var saCheckVal = true;
            for (const res of Paginationlist) {
                if (res.checkVal == false) {
                    saCheckVal = false;
                }
            }

            component.set("v.allcheckVal", saCheckVal);

            component.set('v.PaginationList', Paginationlist);
        } catch (error) {
            console.log("error in Helper previous Method");
            console.log({ error });
        }
    },

    next: function (component, event, helper) {
        try {
            var sObjectList = component.get("v.masterPunchList");
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

            var saCheckVal = true;
            for (const res of Paginationlist) {
                if (res.checkVal == false) {
                    saCheckVal = false;
                }
            }

            component.set("v.allcheckVal", saCheckVal);



            component.set('v.PaginationList', Paginationlist);
        } catch (error) {
            console.log("error in Helper next Method");
            console.log({ error });
        }
    },

    selectAll: function (component, event, helper) {
        try {
            console.log("select All clicked ==>");

            var checkboxValue = event.getSource().get("v.value");
            console.log("checkbox value ==>" + checkboxValue);

            var masterPLCheckMap = component.get("v.masterPLCheckMap");
            var PaginationList = component.get("v.PaginationList");

            var paglistRecId = [];
            for (const res of PaginationList) {
                paglistRecId.push(res.Id);
            }

            if (checkboxValue == true) {
                for (const res of PaginationList) {
                    res.checkVal = true;

                    for (const resCM of masterPLCheckMap) {
                        if (resCM.Id == res.Id) {
                            resCM.flag = true;
                        }
                    }
                }

            } else if (checkboxValue == false) {
                for (const res of PaginationList) {
                    res.checkVal = false;

                    for (const resCM of masterPLCheckMap) {
                        if (resCM.Id == res.Id) {
                            resCM.flag = false;
                        }
                    }
                }
            }
            component.set("v.PaginationList", PaginationList);
            console.log({ masterPLCheckMap });
            component.set("v.masterPLCheckMap", masterPLCheckMap);



        } catch (error) {
            console.log("error in Helper selectAll Method");
            console.log({ error });
        }
    },

    handleCheck: function (component, event, helper) {
        try {
            var checkboxValue = event.getSource().get("v.value");
            console.log("checkbox value ==>" + checkboxValue);
            var checkboxId = event.getSource().get("v.text");
            console.log("checkbox Id ==>" + checkboxId);
            // var checkBoxAuraId = event.getSource().get("v.data-id");
            // console.log("checkbox AuraId ==>" + checkBoxAuraId);

            var masterPLCheckMap = component.get("v.masterPLCheckMap");
            for (const res of masterPLCheckMap) {
                if (checkboxId == res.Id) {
                    res.flag = checkboxValue;
                }
            }
            console.log({ masterPLCheckMap });
            component.set("v.masterPLCheckMap", masterPLCheckMap);

            var PaginationList = component.get("v.PaginationList");
            var saCheckVal = true;
            for (const res of PaginationList) {
                if (res.checkVal == false) {
                    saCheckVal = false;
                }
            }
            component.set("v.allcheckVal", saCheckVal);

        } catch (error) {
            console.log("error in Helper handleCheck Method");
            console.log({ error });
        }
    },

    importMasterPL: function (component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var recId = component.get("v.recordId");
            console.log("recId ==>" + recId);
            var masterPLCheckMap = component.get("v.masterPLCheckMap");
            var selectedMasterPLIds = [];

            for (const res of masterPLCheckMap) {
                if (res.flag == true) {
                    selectedMasterPLIds.push(res.Id);
                }
            }
            console.log("selectedMasterPLIds ==>" + selectedMasterPLIds);

            if (selectedMasterPLIds.length == 0) {
                component.set("v.Spinner", false);
                /* Toast Message for no Master PL Record Selected */
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Select at Least One Punch List Record.",
                    "type": 'Error'
                });
                toastEvent.fire();
            } else {
                var action = component.get("c.importMasterPLRecords");
                action.setParams({
                    selectedMasterPLIds: selectedMasterPLIds,
                    recId: recId
                });
                action.setCallback(this, function (response) {
                    // var state = response.getState();
                    // if (state === "SUCCESS") {
                    //     var result = response.getReturnValue();
                    //     console.log("result form importMasterPL Apex ==>" + result);
                    // }
                    var toastTitle = '';
                    var toastMsg = '';
                    var toastType = '';

                    var resultFromApex = response.getReturnValue();
                    if (resultFromApex == 'NoChildFound') {
                        toastTitle = "Error!";
                        toastMsg = 'There Where no Punch List Lines for The Selected Punch List';
                        toastType = 'Error';
                    } else if (resultFromApex == 'SuccessfullyInserted') {
                        toastTitle = "Success!";
                        toastMsg = 'Punch List Lines Imported Successfully';
                        toastType = 'Success';
                        $A.get("e.force:closeQuickAction").fire(); // for closing Popup Modal (This component) 
                        window.location.reload(); // reloading page after importing pl Line
                    } else {
                        toastTitle = "Error!";
                        toastMsg = 'Something Went Wrong';
                        toastType = 'Error';
                    }
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": toastTitle,
                        "message": toastMsg,
                        "type": toastType
                    });
                    toastEvent.fire();
                    // // for closing Popup Modal (This component) 
                    // $A.get("e.force:closeQuickAction").fire();
                    // // reloading page after importing pl Line
                    // window.location.reload();
                });
                $A.enqueueAction(action);

            }
        } catch (error) {
            component.set("v.Spinner", false);
            console.log("error in Helper importMasterPL Method");
            console.log({ error });
        }
    }

})