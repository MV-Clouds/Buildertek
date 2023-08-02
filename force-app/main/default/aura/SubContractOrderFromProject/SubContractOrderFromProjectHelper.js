({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, 
    getPOListDetails : function(component, event, helper) {
        debugger;
        var action = component.get("c.getPORecListDetails");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.totalPOs", result.totalPOs);
                component.set("v.totalPOAmount", result.totalPOAmount);
                component.set("v.totalPaidAmount", result.totalPaidAmount);
                component.set("v.totalRemainingAmount", result.totalRemainingAmount);
                component.set("v.orderedPercent", result.orderedPercent);
                component.set("v.paidPercent", result.paidPercent);
            } 
        });
        $A.enqueueAction(action);
    },
    
    
    readFiles2 : function(component, event, helper, file,poId){
        debugger;
        var filesList = component.get("v.fileData2");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData2 = {
            'fileName': file.name,
            'fileContent': base64,
            'POId': poId
        }
        // alert(JSON.stringify(fileData2));
        component.get("v.fileData2").push(fileData2);
        component.set("v.fileData2",component.get("v.fileData2"))
        var names = []
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            var name = {};
            name['FileName'] = [];
            name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
            name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
            names.push(name);
        }
        component.set("v.FileNameList",names);
        // alert(JSON.stringify(component.get("v.FileNameList")))
        component.set("v.fileBody", filesList.fileName);
    }
    reader.readAsDataURL(file);
},
 
 sendmails : function(component, event, helper){
    var budgetIds = component.get("v.selectedids");
    //alert('helo'+list);
    component.set("v.Spinner2", true);
    component.set("v.Spinner", true);
    /* var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.masterBudgetsList");
        var budgetIds = [];
         if(budgetsList != null){
	    for(var i=0 ; i < budgetsList.length;i++){
	     if(budgetsList[i].budgetCheck == true){
	                budgetIds.push(budgetsList[i].budgetRecord.Id);
               
           }
	      }
	    }*/
    
    if(budgetIds.length > 0){
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.selectedPOList", false);
            }), 1000);
        console.log(JSON.stringify(component.get("v.fileData2")))
        component.set("v.selectedobjInfo",budgetIds);
        var x = component.get("v.selectedids");
        // alert("x"+x);
        //alert('budgetIds'+budgetIds);
        var action = component.get("c.sendMail"); 
       // alert(budgetIds)
        action.setParams({
            budgetId : budgetIds,
            filedata: JSON.stringify(component.get("v.fileData2"))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //alert(state);
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                if(result.Status === 'Success'){
                    component.set("v.Spinner", false);
                    component.set("v.Spinner2", false);
                    component.set("v.selectedPOList", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": result.Message,
                        "type": 'Success'
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:closeQuickAction").fire();  
                    window.setTimeout(
                        $A.getCallback(function() {
                            //document.location.reload(true);   
                            var action1 = component.get("c.getMasterBudgets");
                            action1.setParams({
                                recId : component.get("v.recordId")
                            });
                            action1.setCallback(this, function(response){
                                var state = response.getState();
                                if(state === "SUCCESS"){
                                    var pageSize = component.get("v.pageSize");
                                    var result = response.getReturnValue();
                                    component.set("v.masterBudgetsList", result);
                                    component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                                    component.set("v.startPage",0);
                                    component.set("v.endPage",pageSize-1);
                                    var PaginationList = [];
                                    for(var i=0; i< pageSize; i++){
                                        if(component.get("v.masterBudgetsList").length> i)
                                            PaginationList.push(result[i]);    
                                    }
                                    component.set('v.PaginationList', PaginationList);
                                    component.set("v.Spinner", false);
                                }else{
                                    component.set("v.Spinner", false);
                                }
                            });
                            $A.enqueueAction(action1);
                        }), 1000
                    );
                }else{
                    component.set("v.Spinner2", false);
                    component.set("v.selectedPOList", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": result.Message,
                        "type": 'Error'
                    });
                    toastEvent.fire();    
                }
            }
            else{
                console.log("Error : "+response.getError());
            }
        });
        $A.enqueueAction(action);
        
    }     
},
    
    
})