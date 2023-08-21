({
    doInit : function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
       

        var action=component.get('c.getChildObectName');
        action.setParams({
            "projectId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            console.log(response.getError());            
            let state=response.getState();
            if(state == 'SUCCESS'){
                let result=response.getReturnValue();
                console.log(result);

                var objectNameMap = [];

                for(var key in result){
                    if(key.includes('buildertek')){
                        objectNameMap.push({key: key, value: result[key]});
                    }
                }
                component.set('v.childObjectNameMap' ,objectNameMap );
                console.log(component.get('v.childObjectNameMap'));
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();

            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Something went wrong."  
                });
                toastEvent.fire();

                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();

            }
            

        });
        $A.enqueueAction(action);

    },
    handleSectionToggle: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        console.log("active sections name: ", component.find("accordion").get('v.activeSectionName'));
        var getSectionName=component.find("accordion").get('v.activeSectionName');
        if(getSectionName != undefined && getSectionName != ''){
            var action = component.get("c.getAttachement");
            action.setParams({
                "objectName": getSectionName,
                "projectId": component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                console.log(response.getError());            
                let state=response.getState();
                if(state == 'SUCCESS'){
                    let result=response.getReturnValue();
                    console.log(result);
                    component.set('v.attachmentData' , result);
    
                }
                
    
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
            });
            $A.enqueueAction(action);
        }

       
    

    },
    openRecordPage: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordId;
        
        var navService = component.find("navService");
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
    },
    handleObjectChange:function(component, event, helper) {
        var objectName = component.get("v.selectedObj");
        console.log(objectName);

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        if(objectName != undefined && objectName != ''){
            var action = component.get("c.getAttachement");
            action.setParams({
                "objectName": objectName,
                "projectId": component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                console.log(response.getError());            
                let state=response.getState();
                if(state == 'SUCCESS'){
                    let result=response.getReturnValue();
                    console.log(result);
                    if(result != null && result!= undefined && result != ''){
                        component.set('v.attachmentData' , result);
                        
                    }else{

                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
    
                }else{

                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Something went wrong."  
                    });
                    toastEvent.fire();
    
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();

                }
                
            });
            $A.enqueueAction(action);
        }

        
    },

    searchChildObjectName:function(component, event, helper) {
        component.set('v.displayObject', true);
        helper.handleChangeObjectName(component, event, helper);
        event.stopPropagation();
    },

    clickOnChildName:function(component, event, helper) {
        console.log('clickHandlerBudget');
        component.set('v.displayObject', false);
        var objectName = event.currentTarget.dataset.value;
        component.set('v.selectedObjectName', objectName);
        var childObjectNameMap = component.get("v.childObjectNameMap");
        childObjectNameMap.forEach(element => {
            if (objectName == element.key) {
                component.set('v.selectedObjectName', element.value);
            }
        });

        if(objectName != undefined && objectName != ''){
            var action = component.get("c.getAttachement");
            action.setParams({
                "objectName": objectName,
                "projectId": component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {
                console.log(response.getError());            
                let state=response.getState();
                if(state == 'SUCCESS'){
                    let result=response.getReturnValue();
                    console.log(result);
                    if(result != null && result!= undefined && result != ''){
                        component.set('v.attachmentData' , result);
                        
                    }else{
                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();

                    console.log(component.get('v.attachmentData'));
    
                }else{
                    component.set('v.attachmentData' , []);

                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Something went wrong."  
                    });
                    toastEvent.fire();
    
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();

                }
                
            });
            $A.enqueueAction(action);
        }
    },
})
