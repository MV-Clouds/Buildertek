({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var productCategoryValue = component.get("v.searchCategoryFilter");
        var recId =  component.get("v.recordId");
        var action = component.get("c.getMasterBudgets");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                // alert(JSON.stringify(result));
                console.log(result);
                component.set("v.masterBudgetsList", result);
                // component.set("v.Vendor", result[1].budgetRecord.buildertek__Contractor__r.Name);
                // component.set("v.Vendor", result[1].budgetRecord.buildertek__Group__r.Name);
                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }
                //alert("hai");
                component.set('v.PaginationList', PaginationList);
                // alert(JSON.stringify(PaginationList));
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    searchKeyChange: function(component, event) {
        component.set("v.Spinner", true);
        var list = component.get("v.PaginationList");
        var searchKey = component.find("searchKey").get("v.value");
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey,
            recId : component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.Spinner", false);
            if(searchKey != ''){
                component.set("v.PaginationList",result);
            }
            else{
                var action1 = component.get("c.getMasterBudgets");
                action1.setParams({
                    recId : component.get("v.recordId")
                });
                action1.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        component.set("v.Spinner", false);
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
                    }else{
                        component.set("v.Spinner", false);
                    }
                });
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
        
    },
    searchKeyChange1: function(component, event) {
        component.set("v.Spinner", true);
        var list = component.get("v.PaginationList");
        var searchKey = component.find("searchKey1").get("v.value");
        var action = component.get("c.findByName1");
        action.setParams({
            "searchKey": searchKey,
            recId : component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.Spinner", false);
            if(searchKey != ''){
                component.set("v.PaginationList",result);
            }
            else{
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
            }
        });
        $A.enqueueAction(action);
        
    },
    searchKeyChange2: function(component, event) {
        component.set("v.Spinner", true);
        var list = component.get("v.PaginationList");
        var searchKey = component.find("searchKey2").get("v.value");
        var action = component.get("c.findByName2");
        action.setParams({
            "searchKey": searchKey,
            recId : component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.Spinner", false);
            if(searchKey != ''){
                component.set("v.PaginationList",result);
            }
            else{
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
            }
        });
        $A.enqueueAction(action);
    },
    
    next: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList");
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
        var sObjectList = component.get("v.masterBudgetsList"); 
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
    
    
    handleCheck : function(component, event, helper) {
        var checkbox = event.getSource();
        var Submittals = component.get("v.masterBudgetsList");
        for(var i=0 ; i < Submittals.length;i++){
            if(Submittals[i].budgetRecord != null){
                if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
                    Submittals[i].budgetCheck = true;
                }
                else if(Submittals[i].budgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
                    Submittals[i].budgetCheck = false;
                }    
            }else if(Submittals[i].masterBudgetRecord != null){
                if(Submittals[i].masterBudgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == false){
                    Submittals[i].budgetCheck = true;
                }
                else if(Submittals[i].masterBudgetRecord.Id == checkbox.get("v.text") && Submittals[i].budgetCheck == true){
                    Submittals[i].budgetCheck = false;
                }    
            }  
        }
    },
    
    selectAll : function(component, event, helper) { 
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var Submittals = component.get("v.masterBudgetsList");
        var getAllId = component.find("checkContractor");
        if (getAllId != undefined) {
            if (Submittals.length > 1) {
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                        component.set("v.selectedCount", 1);
                    }else{
                        component.find("checkContractor").set("v.value", false);
                        component.set("v.selectedCount", 0);
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
                            var Submittals = component.get("v.masterBudgetsList");
                            Submittals[i].budgetCheck = false;
                        }
                    } 
                } 
            }else{
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
                    Submittals[i].budgetCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].budgetCheck = false;
                }
            }   
        }
    },
    
    
    closeModel : function(component, event, helper){
        $A.get('e.force:refreshView').fire();   
    },
    
    clear :function(component,event,heplper){
        debugger;
        event.stopPropagation();
        event.preventDefault();
        var selectedPillId = event.getSource().get("v.name");
        var selectedPillIndex = selectedPillId.split("_")[0];
        var selectedPillPo = selectedPillId.split("_")[1];
        var allFileList = component.get("v.fileData2");
        var AllPillsList = component.get("v.selectedfilesFill"); 
        
        /*for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Name == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.selectedfilesFill", AllPillsList);
            }  
        }*/
        
        for(var i = 0; i < allFileList.length; i++){
            if(allFileList[i].POId == selectedPillPo && i == Number(selectedPillIndex)){
                allFileList.splice(i, 1);
                //component.set("v.selectedfilesFill", AllPillsList);
            }  
        }
        component.set("v.fileData2",allFileList);
        var names = []
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            var name = {};
            name['FileName'] = [];
            name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
            name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
            names.push(name);
        }
        component.set("v.FileNameList",names);
    },
    
    confirmOrderPO : function(component, event, helper){
        debugger;
        var vendor =  component.get("v.Vendor");
        component.set("v.Spinner", true);
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.masterBudgetsList");
        var budgetIds = [];
        if(budgetsList != null){
            for(var i=0 ; i < budgetsList.length;i++){
                if(budgetsList[i].budgetCheck == true){
                    budgetIds.push(budgetsList[i].budgetRecord.Id);
                }
            }
        }
        if(budgetIds.length > 0){
            console.log( JSON.stringify(component.get("v.fileData2")))
            component.set("v.selectedobjInfo",budgetIds);
            var action = component.get("c.createPO");  
            action.setParams({
                budgetIds : budgetIds,
                recordId : component.get("v.recordId"),
                fileData : JSON.stringify(component.get("v.fileData2"))
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var result = response.getReturnValue(); 
                    //alert( 'kkk'+JSON.stringify(result));
                    console.log("Result oooo : ",JSON.stringify(result))
                    var y = [];
                    if(result != null && result != undefined){
                        for(let i=0;i<result.length;i++){
                            y.push(result[i].Id)
                        }
                        //alert(y)
                        component.set("v.Spinner", false);
                        component.set("v.Spinner2", false);
                        component.set("v.selectedPOList", false);
                        component.set("v.selectedobj", result[0].buildertek__Sub_Contract__c);
                        component.set("v.selectedids", y);
                        var list = component.get("v.selectedids");
                        //alert('hai'+list.length);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'Purchase Order Created Successfully',
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                        helper.sendmails(component, event, helper);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        if(result.length > 1){
                             component.set("v.Spinner", false);
                            $A.get('e.force:refreshView').fire();
                            //alert(result.length)
                            //alert("not")
                            var homeEvent = $A.get("e.force:navigateToObjectHome");
                            homeEvent.setParams({
                                "scope": "buildertek__Purchase_Order__c"
                            });
                            homeEvent.fire();
                        }
                        else{
                             component.set("v.Spinner", false);
                            $A.get('e.force:refreshView').fire();
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": result[0].Id,
                                "slideDevName": "related"
                            });
                            navEvt.fire();
                        }
                        // }else{
                        //alert("helo");
                        // }
                        $A.get("e.force:closeQuickAction").fire();  
                    }else{
                        component.set("v.Spinner", false);
                        component.set("v.Spinner2", false);
                        component.set("v.selectedPOList", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error",
                            "type": 'Error'
                        });
                        toastEvent.fire();    
                    }
                }
                else{
                    console.log("Error : ",response.getError())
                }
            });
            $A.enqueueAction(action);  
        }
    },
    
    
    orderPO : function(component, event, helper){
        debugger;
        var record  = component.get("v.recordId");
        var select = component.get("v.selectedobjInfo");
        var budgetsList = component.get("v.masterBudgetsList");
        var aa = component.get("v.SelectedPurchaseOrders");
        var budgetIds = [];
        if(budgetsList != null){
            for(var i=0 ; i < budgetsList.length;i++){
                if(budgetsList[i] != null){
                    //  alert("helo");
                    if(budgetsList[i].budgetCheck == true){
                        budgetIds.push(budgetsList[i].budgetRecord);
                        //  alert('mmmmmmmm'+budgetIds.push(budgetsList[i].budgetRecord.Id));
                    } 
                }
            }
        }
        /*  if(budgetsList != null){
            
            for(var i=0 ; i < budgetsList.length;i++){
                for(var j=0;j<budgetsList[i].length;j++){
                    if(budgetsList[i] != null){
                        if(budgetsList[i].budgetCheck == true){
                            budgetIds.push(budgetsList[i].budgetRecord.Id);
                        }
                    }
                }
            }
        }*/
        console.log("Ids -------------------> "+JSON.stringify(budgetIds));
        component.set("v.SelectedPurchaseOrders", budgetIds);
        // alert(aa);
        //  alert(JSON.stringify(component.set("v.SelectedPurchaseOrders", budgetIds)));
        if(budgetIds.length > 0){
            // alert("hhh");
            component.set("v.selectedPOList", true);  
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least 1 Sub-Contract.',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire(); 
        } 
    },
    
    closePOListPopUp : function(component, event, helper){
        debugger;
        component.set("v.selectedPOList", false);
        component.set("v.fileData2", []);
        var selectedHeaderCheck = component.find("checkContractors").get("v.value");
        var Submittals = component.get("v.masterBudgetsList");
        var getAllId = component.find("checkContractor");
        if (getAllId != undefined) {
            if (Submittals.length > 0) {
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkContractor").set("v.value", true); 
                        component.set("v.selectedCount", 1);
                    }else{
                        component.find("checkContractor").set("v.value", false);
                        component.set("v.selectedCount", 0);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            component.find("checkContractor")[i].set("v.checked", false); 
                        }
                        /* for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered'){
                                    Submittals[i].poRecInner[j].budgetCheck = false; 
                                }
                                
                            }
                        }*/
                    } 
                    else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            component.find("checkContractor")[i].set("v.checked", false); 
                        }
                        /*for(var i=0;i<Submittals.length;i++){
                            for (var j = 0; j < Submittals[i].poRecInner.length; j++){
                                if(Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered'){
                                    Submittals[i].poRecInner[j].budgetCheck = false; 
                                } 
                            }
                        }*/
                    } 
                } 
            }else{
                var i = 0;
                if (selectedHeaderCheck == true) { 
                    component.find("checkContractor").set("v.value", true); 
                    component.set("v.selectedCount", 1);
                    Submittals[i].budgetCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    component.set("v.selectedCount", 0);
                    Submittals[i].budgetCheck = false;
                }
            }   
        }
        component.set("v.masterBudgetsList",Submittals)
        component.find("checkContractors").set("v.value", false);  
    },
    
    handleFilesChange2 : function(component, event, helper) {
        debugger;
        var fileName = "No File Selected..";  
        var fileCount = event.target.files;
        var POId = event.currentTarget.dataset.index;
        var files='';
        var names =[];
        //alert(POId)
        var filedata = component.get("v.FileLabelList");
        if (fileCount.length > 0) {
            component.set("v.uploadFile", true);
            for (var i = 0; i < fileCount.length; i++) 
            {
                fileName = fileCount[i]["name"];
                if(files == ''){
                    files = fileName;
                }else{
                    files = files+','+fileName;
                }
                helper.readFiles2(component, event, helper, fileCount[i],event.currentTarget.dataset.index);
            }
        }
        component.set("v.fileName2", files);	
        
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        console.log(event.getSource().get("v.files"))
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    
})