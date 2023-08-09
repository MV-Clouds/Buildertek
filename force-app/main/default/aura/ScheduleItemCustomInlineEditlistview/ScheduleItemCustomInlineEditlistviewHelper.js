({


    toastMsg: function (strType, strMessage) {

        var showToast = $A.get("e.force:showToast");
        showToast.setParams({

            message: strMessage,
            type: strType,
            mode: 'sticky'

        });
        showToast.fire();

    },

    setPageDataAsPerPagination: function (component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber - 1) * pageSize;
        //creating data-table data
        for (; x < (pageNumber) * pageSize; x++) {
            if (allData[x]) {
                data.push(allData[x]);
            }
        }
        component.set("v.scheduleitemlst", data);
        var groupByData = component.get("v.scheduleitemlst");
        helper.formatDataByGroups(component,event,helper,groupByData);
        helper.generatePageList(component, pageNumber);
    },

    generatePageList: function (component, pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if (totalPages > 1) {
            if (totalPages <= 10) {
                var counter = 2;
                for (; counter < (totalPages); counter++) {
                    pageList.push(counter);
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
        /*var interval = window.setInterval(
            $A.getCallback(function() {
                console.log(' from component with id ' + component.getGlobalId());
                //$A.get('e.force:refreshView').fire();
                // code to execute periodically goes here
            }), 2000
        );   
        component.set("v.setIntervalId", interval) ;   */
    },

    viewRecord: function (component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    deleteRecord: function (component, event) {
        var action = component.get("v.deleteAction");//event.getParam('action');
        var row =  component.get("v.deleteRow");//event.getParam('row');
		component.set("v.deleteConfirmModal",false);
        var action = component.get("c.deletescheduleitemrec");
        
        action.setParams({
            "projecttasks": row.Id
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = component.get('v.scheduleitemlst');
                var rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                component.set('v.scheduleitemlst', rows);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been delete successfully.",
                    "type": 'success'
                });
                toastEvent.fire();
                component.set("v.deleteAction","");
                component.set("v.deleteRow","");
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    editRecord: function (component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
        $A.get('e.force:refreshView').fire();
        //helper.fetchscheduleitems(component, helper); 
    },
    getDataTableRespone: function (component, helper) {
        debugger;
        var recordId = component.get("v.recordId");
        var action = component.get("c.getDataTableDetails");
        action.setParams({
            objApi: 'buildertek__Project_Task__c',
            fieldSetName: 'buildertek__Schedule_Item_field_set',
            scheduleid: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('::::::::::::: SUCCESS :::::::::::::' + JSON.stringify(response.getReturnValue().lstOfFieldLabels));
                var records = response.getReturnValue();

                var actions = [
                    {
                        label: 'Edit',
                        name: 'edit'
                    },
                    {
                        label: 'Delete',
                        name: 'delete'
                    },
                    {
                        label: 'View',
                        name: 'view'
                    }
                ];
                var columns = [];
                 var columns1 = [];
                var columns2 = [];
                
                if (records.lstOfFieldLabels.length > 0) {
                    for (var i = 0; i < records.lstOfFieldLabels.length; i++) {
						//alert('hii'+records.lstOfFieldLabels[i].fieldName);
                        if(records.lstOfFieldLabels[i].fieldName != 'buildertek__Phase__c'){
                        if (records.lstOfFieldLabels[i].type != 'reference') {
                            // alert(records.lstOfFieldLabels[i].fieldName);
                            var type = '';
                            if (records.lstOfFieldLabels[i].type == 'date') {
                                type = 'date-local';
                            } else {
                                type = records.lstOfFieldLabels[i].type;
                            }
                            var rec = {
                                label: records.lstOfFieldLabels[i].label,
                                fieldName: records.lstOfFieldLabels[i].fieldName,
                                type: type,
                                editable: true
                            }
                        } else {
                            var fieldLink = records.lstOfFieldLabels[i].fieldName + 'link';
                            var rec = {
                                label: records.lstOfFieldLabels[i].label,
                                fieldName: fieldLink,
                                type: 'url',
                                typeAttributes: {
                                    label: {
                                        fieldName: records.lstOfFieldLabels[i].fieldName
                                    },
                                    target: '_blank'
                                }
                            }
                        }
                        columns.push(rec);
                             }
                    }
                    
                    columns.push({
                        type: 'action',
                        typeAttributes: {
                            rowActions: actions
                        }
                    });
          
                    /*columns.push ({
                        type: "button",
                        initialWidth: 80,
                        typeAttributes: {
                            // label: 'View',
                            name: 'edit',
                            title: 'Edit',
                            disabled: false,
                            value: 'edit',
                            iconPosition: 'left',
                            iconName: 'utility:edit' 
                        },cellAttributes: {
                            style: 'background : yellowgreen;'
                        }
                    });
                     columns.push ({
                        type: "button",
                        initialWidth: 80,
                        typeAttributes: {
                            // label: 'View',
                            name: 'add',
                            title: 'Add',
                            disabled: false,
                            value: 'add',
                            iconPosition: 'left',
                            iconName: 'utility:add' 
                        },
                    });
                    columns.push ({
                        type: "button",initialWidth: 80, typeAttributes: {
                            name: 'delete',
                            title: 'Delete',
                            disabled: false,
                            value: 'delete',
                            iconName: 'utility:delete'
                        }
                    });
                    columns.push ({
                        type: "button",initialWidth: 80, typeAttributes: {
                                 name: 'view',
                                 title: 'View',
                                 disabled: false,
                                 value: 'view',
                                 iconName: 'utility:preview'
                        }
                    });*/
                
                    //});
                    }
                component.set("v.mycolumns", columns);
                console.log('::::::::::::: SUCCESS ::::columns:::::::::' + JSON.stringify(columns));
                var data = response.getReturnValue().lstOfSObjs;
                for (var i = 0; i < response.getReturnValue().lstOfSObjs.length; i++) {
                    var row = data[i];
                    if (row.buildertek__Contractor_Resource__r) {
                        row.buildertek__Contractor_Resource__clink = '/' + row.buildertek__Contractor_Resource__c;
                        row.buildertek__Contractor_Resource__c = row.buildertek__Contractor_Resource__r.Name;

                    }
                    if (row.buildertek__Contractor__r) {
                        row.buildertek__Contractor__clink = '/' + row.buildertek__Contractor__c;
                        row.buildertek__Contractor__c = row.buildertek__Contractor__r.Name;

                    }
                    if (row.buildertek__Cost_Code__r) {
                        row.buildertek__Cost_Code__clink = '/' + row.buildertek__Cost_Code__c;
                        row.buildertek__Cost_Code__c = row.buildertek__Cost_Code__r.Name;

                    }
                    if (row.buildertek__Resource__r) {
                        row.buildertek__Resource__clink = '/' + row.buildertek__Resource__c;
                        row.buildertek__Resource__c = row.buildertek__Resource__r.Name;

                    }
                    if (row.buildertek__Dependency__r) {
                        row.buildertek__Dependency__clink = '/' + row.buildertek__Dependency__c;
                        row.buildertek__Dependency__c = row.buildertek__Dependency__r.Name;

                    }
                    if (row.buildertek__Project__r) {
                        row.buildertek__Project__clink = '/' + row.buildertek__Project__c;
                        row.buildertek__Project__c = row.buildertek__Project__r.Name;

                    }
                    if (row.buildertek__Purchase_Order__r) {
                        row.buildertek__Purchase_Order__clink = '/' + row.buildertek__Purchase_Order__c;
                        row.buildertek__Purchase_Order__c = row.buildertek__Purchase_Order__r.Name;

                    }
                    if (row.buildertek__Trade_Type__r) {
                        row.buildertek__Trade_Type__clink = '/' + row.buildertek__Trade_Type__c;
                        row.buildertek__Trade_Type__c = row.buildertek__Trade_Type__r.Name;

                    }
                    if(row.buildertek__Completion__c){
                        row.buildertek__Completion__c = (Number(row.buildertek__Completion__c)/100);
                    }
                }

                var scheduleItemsList = [];
                var scheduleItemsListClone = [];
                let scheduleItemsMap = new Map();
                let taskMap = new Map();
                for (var i in data) {
                    if (data[i].Id != undefined && data[i].buildertek__Milestone__c != undefined && !data[i].buildertek__Milestone__c) {
                        scheduleItemsList.push(data[i]);
                       // taskMap.set(data[i].buildertek__Phase__c, i);
                       taskMap.set(data[i].buildertek__Phase__c, scheduleItemsList.length-1);
                    } else if (data[i].Id != undefined && data[i].buildertek__Milestone__c != undefined && data[i].buildertek__Milestone__c) {
                        scheduleItemsMap.set(data[i].buildertek__Phase__c, data[i]);
                    }
                }
                for (var i = 0; i < scheduleItemsList.length; i++) {
                    if (scheduleItemsList[i] != undefined && scheduleItemsList[i].Id != undefined) {
                        scheduleItemsListClone.push(scheduleItemsList[i]);
                        if (taskMap.has(scheduleItemsList[i].buildertek__Phase__c) && i == taskMap.get(scheduleItemsList[i].buildertek__Phase__c) && scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c) != undefined) {
                            scheduleItemsListClone.push(scheduleItemsMap.get(scheduleItemsList[i].buildertek__Phase__c));
                            scheduleItemsMap.delete(scheduleItemsList[i].buildertek__Phase__c);
                        }
                    }
                }
                for (const [key, value] of scheduleItemsMap.entries()) {
                    if (value != undefined) {
                        scheduleItemsListClone.push(value);
                    }
                }

                component.set("v.scheduleitemlst", scheduleItemsListClone);
                
                //// component.set("v.ProejectrecordId",rows[0].buildertek__Project_ID__c);
                // component.set("v.schedulerecid",rows[0].buildertek__Schedule__c);

                component.set("v.totalPages", Math.ceil(response.getReturnValue().lstOfSObjs.length / component.get("v.pageSize")));
                component.set("v.allData", scheduleItemsListClone);
                component.set("v.currentPageNumber", 1);
                component.set("v.Spinner",false);
                helper.setPageDataAsPerPagination(component, helper);
            } else if (state === 'ERROR') {
                console.log('::::::::::::: ERROR :::::::::::::');
            }
        });
        $A.enqueueAction(action);
    },
    formatDataByGroups : function(component,event,helper,mapData){
       // alert('hiii');
       // 
       
        if(component.find('expandCollapeseAllBtn')){
            if(component.find('expandCollapeseAllBtn').get('v.iconName')){
                var scheduleId =  component.get("v.recordId");
                var tabId = component.get("v.currentTab")
                if(tabId){
                    var spanEle = document.getElementsByClassName(tabId+' expandAllBtn_'+scheduleId);
                    if(spanEle[0]){
                        spanEle[0].style.display="inline-block";
                    }
                    if(document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0]){
                        document.getElementsByClassName(tabId+' CollapeseAllBtn_'+scheduleId)[0].style.display="none";
                    } 
                }
                component.find('expandCollapeseAllBtn').set("v.title", "Expand All");
                component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
            }
        }
        
        
        let recordsMap = new Map();
        for (var i in mapData) {
            if(mapData[i].buildertek__Phase__c){
               // alert('mapData[i].buildertek__Phase__c'+mapData[i].buildertek__Phase__c);
                if (!recordsMap.has(mapData[i].buildertek__Phase__c)) {
                    recordsMap.set(mapData[i].buildertek__Phase__c, []);
                }
                recordsMap.get(mapData[i].buildertek__Phase__c).push(JSON.parse(JSON.stringify(mapData[i])));
            }else{
               // alert('mapData[i].buildertek__Phase__c%%')
                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                if (!recordsMap.has('No Phase')) {
                    recordsMap.set('No Phase', []);
                }
                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                recordsMap.get('No Phase').push(JSON.parse(JSON.stringify(mapData[i])));
                //console.log(recordsMap.get("No vendor"))
    		}
   
		}
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for(var i in result){
            var newObj = {};
           /* if(result[i][0].indexOf('(#&%*)') > -1){
                alert('&&&');
                newObj['groupName'] = result[i][0].split('(#&%*)')[1];
            }else{*/
               // alert('****');
                newObj['groupName'] = result[i][0];
           // alert('result[i][0]'+result[i][0].length);
           // }
            newObj['groupData'] = result[i][1];
           // alert('result[i][1]'+result[i][1].length);
           // newObj['selectedRows'] = [];
          /*  var res = result[i][1];
            var totalsObj = {};
            var grandPOtotal = 0;
            var grandPaidAmounttotal = 0;
            var grandPOBalancetotal = 0;
            for(var j=0; j< res.length; j++){
                   grandPOtotal = grandPOtotal + res[j].buildertek__PO_Total__c;
                   grandPaidAmounttotal = grandPaidAmounttotal + res[j].buildertek__Paid_Amount__c;
                   grandPOBalancetotal = grandPOBalancetotal + res[j].buildertek__PO_Balance__c;
             }
            totalsObj['Name'] = 'Totals'
            totalsObj['linkName'] = 'Totals'
            //totalsObj['Vendorname'] = 'Totals'
            totalsObj['buildertek__PO_Total__c'] = grandPOtotal;
             totalsObj['buildertek__Paid_Amount__c'] = grandPaidAmounttotal;
            totalsObj['buildertek__PO_Balance__c'] = grandPOBalancetotal
            
            newObj['groupData'].push(totalsObj);
            //newObj['groupDataTotals'] = [grandPOtotal, grandPaidAmounttotal, grandPOBalancetotal];*/
            groupData.push(newObj);
        }
        console.log(groupData);
        component.set("v.dataByGroup",groupData);
        component.set("v.Spinner", false);
    }


})