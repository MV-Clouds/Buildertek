({
	setPageDataAsPerPagination: function (component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber - 1) * pageSize;
       
        /*for (; x < (pageNumber) * pageSize; x++) {
            if (allData[x]) {
                data.push(allData[x]);
            }
        }
        var items= []
        for(var i=0;i<data.length;i++){
            var obj = {
                key : data[i].buildertek__Phase__c,
                value : data[i]
            }
        }*/
        data = allData
       
        helper.formatDataByGroups(component,event,helper,data);
        helper.generatePageList(component, pageNumber);
    },
  getTableFieldSet: function (component, event, helper) {
       component.set("v.isDuration",false)
        var action = component.get("c.getFieldSet");
      action.setParams({
         sObjectName : "buildertek__Project_Task__c",
        fieldSetName  : "buildertek__Schedule_Item_field_set", // //buildertek__New_Schedule_Item_Field_set
         parentRecordId : component.get("v.recordId")
      })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            for(var i=0;i<fieldSetObj.length;i++){
                if(fieldSetObj[i].name == "buildertek__Duration__c"){
                    component.set("v.isDuration",true)
                }
                if(fieldSetObj[i].name == "buildertek__Finish__c"){
                    component.set("v.isFinish",true)
                }
            }
             helper.getDataTableRespone(component, helper);
           
        })
        $A.enqueueAction(action);
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
       
        
    },
    getScheduleGroups: function (component, event, helper, page) {
        
       
        var schedulerecid =  component.get("v.schedulerecid");
       
        if (component.get("v.recordId")) {
            var action = component.get("c.retrieveGroups");
            action.setStorable({
                ignoreExisting: true
            });
            action.setParams({
                quoteId: component.get("v.recordId"),
                pageNumber: page,
                recordToDisply: 50
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.TotalRecords", result); //This Line has slow performance past 200 objects being loaded.
                    if (result != undefined && result.wrapperList != undefined) {
                        component.set('v.wrapperListLength', result.wrapperList.length - 1);
                    }
                    if (result.groups != undefined) {
                        for (var i in result.groups) {
                            result.groups[i].isSelected = false;
                        }
                    }
                    console.log('total records....' + JSON.stringify(component.get("v.TotalRecords")));
                    component.set("v.columns", result.columns);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    if (result.total == 0) {
                        component.set("v.pages", 1);
                    } else {
                        component.set("v.pages", Math.ceil(result.total / 50));
                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    getDataTableRespone: function (component, helper) {
        debugger;
        var recordId = component.get("v.recordId");
        var action = component.get("c.getDataTableDetails");
        action.setBackground()


        action.setParams({
            objApi: 'buildertek__Project_Task__c',
            fieldSetName: 'buildertek__Schedule_Item_field_set',  // //buildertek__New_Schedule_Item_Field_set
            scheduleid: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('::::::::::::: SUCCESS :::::::::::::' + JSON.stringify(response.getReturnValue().lstOfFieldLabels));
                var records = response.getReturnValue();
                
                var data = response.getReturnValue().lstOfSObjs;

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
                component.set("v.allDataNumbering", response.getReturnValue().lstOfSObjsChild);

             //   component.set("v.scheduleitemlst", scheduleItemsListClone);
                
                //// component.set("v.ProejectrecordId",rows[0].buildertek__Project_ID__c);
                // component.set("v.schedulerecid",rows[0].buildertek__Schedule__c);

                component.set("v.totalPages", Math.ceil(response.getReturnValue().lstOfSObjs.length / component.get("v.pageSize")));
                component.set("v.allData", scheduleItemsListClone);
                
                if(component.get("v.oninitExpandIcon")){
                   component.set("v.currentPageNumber", 1);
                }
                //component.set("v.currentPageNumber", 1);
                //component.set("v.Spinner",false);
                helper.setPageDataAsPerPagination(component, helper);
            } else if (state === 'ERROR') {
                console.log('::::::::::::: ERROR :::::::::::::');
            }
        });
        $A.enqueueAction(action);
    },
    
     deleteRecord: function (component, event,helper) {
         
        var delrecid = component.get("v.isdeleteRow"); 
        
       // var action = component.get("v.deleteAction");//event.getParam('action');
        //var row =  component.get("v.deleteRow");//event.getParam('row');
		component.set("v.deleteConfirmModal",false);
         
        var action = component.get("c.deletescheduleitemrec");
        action.setParams({
            "projecttasks": delrecid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               /* var rows = component.get('v.scheduleitemlst');
                var rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                component.set('v.scheduleitemlst', rows);*/
                component.set("v.deleteConfirmModal", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been delete successfully.",
                    "type": 'success'
                });
                toastEvent.fire();
                
                //$A.get('e.force:refreshView').fire();
                component.set("v.oninitExpandIcon",false)
                component.set("v.dupScheduleItems",component.get("v.scheduleitemlst"))
                helper.getDataTableRespone(component, helper);
                //component.set("v.Spinner",false);
                
                /* component.set("v.deleteAction","");
                component.set("v.deleteRow","");
                component.set("v.Spinner",false);*/
            }
        });
        $A.enqueueAction(action);
    },
  
     viewRecord: function (component, event) {
     
		var recordId = event.currentTarget.dataset.rowid;
           var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
		
	},
  formatDataByGroups : function(component,event,helper,mapData){
        console.log( component.get("v.expandedList"));
        var mapData = component.get("v.allDataNumbering")
        
        let recordsMap = new Map();
        for (var i in mapData) {
            if(mapData[i]['SObjs'].buildertek__Phase__c){
                if (!recordsMap.has(mapData[i]['SObjs'].buildertek__Phase__c)) {
                    recordsMap.set(mapData[i]['SObjs'].buildertek__Phase__c, []);
                }
                recordsMap.get(mapData[i]['SObjs'].buildertek__Phase__c).push(JSON.parse(JSON.stringify(mapData[i])));
            }else{
                if (!recordsMap.has('null')) {
                    recordsMap.set('null', []);
                }
                recordsMap.get('null').push(JSON.parse(JSON.stringify(mapData[i])));
            }
            
        }
      var result = Array.from(recordsMap.entries());
      var groupData = [];
      var duplicateSchedule = component.get("v.dupScheduleItems")
      for(var i in result){
          var newObj = {};
          
          newObj['key'] = result[i][0];
          
          newObj['value'] = result[i][1];
          
        //   newObj['wbs'] = result[i][1]['wbs']
          
          newObj['expanded'] = true; //adding for expand/collapse icons
          
          if(component.get("v.oninitExpandIcon") == false){
              if(duplicateSchedule.length){
                  if(duplicateSchedule[i]){
                      if(duplicateSchedule[i].key == newObj['key']){
                          newObj['expanded'] = duplicateSchedule[i].expanded
                      }
                  }
                  
              }
          }
          
          
          groupData.push(newObj);
      }
      console.log(groupData);
      
      component.set("v.scheduleitemlst",groupData);
      component.set("v.Spinner", false);
      console.log( component.get("v.expandedList"));
      component.set("v.expandedList",component.get("v.expandedList"))
      component.set("v.Show", false);
      component.set("v.isExpand",true);
      component.set("v.ShowTaskOrderSave",false)
      component.set("v.oninitExpandIcon",false)
      
  }
    

})