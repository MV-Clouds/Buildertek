({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
         
        var myPageRef = component.get("v.pageReference");
        var recordId = component.get("v.recordId");
        // var recordId = myPageRef.state.buildertek__parentId;
        //alert('recordId in doinit'+recordId);
        var action = component.get("c.getMasterVendorReviews");
        action.setParams({
            recordId : recordId //component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            console.log(response.getError());
            console.log({state});

            var state = response.getState();
            if(state === "SUCCESS"){
                //  alert(state);
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterVendorReviewList", result);
                component.set("v.totalRecords", component.get("v.masterVendorReviewList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterVendorReviewList").length> i)
                        PaginationList.push(result[i]);    
                }
                //alert('PaginationList Length ------> '+PaginationList.length);
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
               
            }
        });
        $A.enqueueAction(action);
    },
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();  
        var Submittals = component.get("v.masterVendorReviewList");
        for(var i=0 ; i < Submittals.length;i++){
            if(Submittals[i].budgetRecord != null){
                if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
                    Submittals[i].budgetCheck = true;
                }
                else if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
                    Submittals[i].budgetCheck = false;
                }    
            }
            
        }
    },
    selectAll : function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var Submittals = component.get("v.masterVendorReviewList");
        var getAllId = component.find("checkContractor"); 
        if(Submittals != null){
            if(Submittals.length > 1){
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                    }else{
                        component.find("checkContractor").set("v.value", false);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true); 
                            var checkbox = component.find("checkContractor")[i].get("v.text");  
                            Submittals[i].budgetCheck = true;
                            
                        }
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            
                            var checkbox = component.find("checkContractor")[i].get("v.text"); 
                            var Submittals = component.get("v.masterVendorReviewList");
                            Submittals[i].budgetCheck = false;
                        }
                    } 
                } 
            }
            else{
                var i=0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    var checkbox = component.find("checkContractor").get("v.text");  
                    Submittals[i].budgetCheck = true;
                    
                    
                } 
                else{
                    component.find("checkContractor").set("v.value", false); 
                    
                    var checkbox = component.find("checkContractor").get("v.text"); 
                    var Submittals = component.get("v.masterVendorReviewList");
                    Submittals[i].budgetCheck = false;
                    
                } 
            }
        }
        
    },
    
    
    importBudget : function(component, event, helper){
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var budgetsList = component.get("v.masterVendorReviewList");
        console.log('masterVendorReviewList ---------> '+JSON.stringify(budgetsList));
        var budgetIds = [];
        for(var i=0 ; i < budgetsList.length;i++){
            if(budgetsList[i].budgetCheck == true){
                if(budgetsList[i].masterBudgetRecord != null){
                    budgetIds.push(budgetsList[i].masterBudgetRecord.Id);    
                }else if(budgetsList[i].budgetRecord != null){
                    budgetIds.push(budgetsList[i].budgetRecord.Id);    
                }
            }
        }
        console.log("budget IDs",budgetIds);
        if(budgetIds.length > 0){
            var action = component.get("c.importMasterVenderReviewLines"); 
            var myPageRef = component.get("v.pageReference");
            var recordId = component.get("v.recordId");
            console.log("record Id" , recordId);
            action.setParams({
                budgetIds : budgetIds,
                recordId : recordId
                
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    // var workspaceAPI = component.find("workspace");
                    // workspaceAPI.getFocusedTabInfo().then(function (response) {
                    //     var focusedTabId = response.tabId;
                    //     workspaceAPI.closeTab({
                    //         tabId: focusedTabId
                    //     });
                    // }).catch(function (error) {
                    //     console.log('Error', JSON.stringify(error));
                    // }); 
                    var result = response.getReturnValue(); 
                    if(result.Status === 'Success'){
                        setTimeout(function () {
                        if(result.Ids.length == 1){
                            $A.get("e.force:navigateToSObject").setParams({
                                "recordId": result.Ids[0],
                                "slideDevName": "detail"
                            }).fire();
                        }else{
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": '/lightning/r/buildertek__Vendor_Review__c/'+recordId+'/related/buildertek__Vendor_Scorecards__r/view'
                            });
                            urlEvent.fire();
                            $A.get("e.force:refreshView").fire();
                    
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": result.Message,
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                        component.set("v.Spinner", false);
                            component.set("v.showMessage", false);
                       // $A.get("e.force:closeQuickAction").fire();  
                            }, 200);
                        }else{
                            component.set("v.Spinner", false);
                            component.set("v.showMessage", false);
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
            }else{
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Please select atleast one Vendor Review record',
                    "type": 'Error',
                    "duration": '10000',
                    "mode": 'dismissible'
                });   
            }
        },
    
    next: function (component, event, helper) {
        var sObjectList = component.get("v.masterVendorReviewList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.masterVendorReviewList"); 
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    closeModel : function(component, event, helper){
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.closeTab({tabId: focusedTabId});
        // })
        
        // .catch(function(error) {
        //     console.log(error);
        // });
        $A.get("e.force:closeQuickAction").fire();
        // window.setTimeout(
        //     $A.getCallback(function () {
        //         $A.get('e.force:refreshView').fire();
        //     }), 1000
        // );
    },
})