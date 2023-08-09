({
    doInit: function (component, event, helper) {
        component.get('v.recordId')!=undefined ? helper.getAllMasterSelection(component, event, helper):'';
    },
    
    onChangeHandler:function(component, event, helper){
        var selectionId = event.getSource().get("v.text");
        var selections = component.get('v.selectionList');
        selections.filter(function(selection) {
            selection.Id == selectionId ? selection.buildertek__Is_Selected__c=true:selection.buildertek__Is_Selected__c=false;
        });
        component.set('v.selectionList',selections);
    },
    
    selectionChange:function(component, event, helper){
        
        
    },
    
    selectAll : function(component, event, helper){
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var Submittals = component.get("v.selectionList");
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
                            Submittals[i].buildertek__Is_Selected__c = true;
                        }
                    }else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false); 
                            var checkbox = component.find("checkContractor")[i].get("v.text"); 
                            var Submittals = component.get("v.selectionList");
                            Submittals[i].buildertek__Is_Selected__c = false;
                        }
                    } 
                } 
            }else{
                var i=0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true); 
                    var checkbox = component.find("checkContractor").get("v.text");  
                    Submittals[i].buildertek__Is_Selected__c = true;
                }else{
                    component.find("checkContractor").set("v.value", false); 
                    var checkbox = component.find("checkContractor").get("v.text"); 
                    var Submittals = component.get("v.selectionList");
                    Submittals[i].buildertek__Is_Selected__c = false;
                } 
            }
        }
        component.set('v.selectionList',Submittals);
    },
    
    next : function(component, event, helper){
        var sObjectList = component.get("v.selectionList");
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
    
    previous : function(component, event, helper){
        var sObjectList = component.get("v.selectionList"); 
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
        $A.get("e.force:closeQuickAction").fire();    
    },
    
    importSelections : function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.loading',true);
        var selectedSelectionId = [];
        var selections =  component.get('v.selectionList');
        if(selections!=undefined ){
            for(var i in selections){
                if(selections[i].buildertek__Is_Selected__c){
                    selectedSelectionId.push(selections[i].Id); 
                }
            }   
        }
        if(selectedSelectionId.length>0){
            helper.importMasterSelections(component, event, helper,selectedSelectionId);            
        }else{
            component.set('v.loading',false);
            toastEvent.setParams({
                "type" : 'error',
                "title": "Error!",
                "message": "Selection Selections"
            });
            toastEvent.fire();
        }
    },
})