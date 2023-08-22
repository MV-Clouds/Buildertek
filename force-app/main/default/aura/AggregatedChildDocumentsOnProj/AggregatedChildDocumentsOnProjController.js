({
    doInit : function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
       

        var action=component.get('c.getChildObectName');
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
                        component.set('v.showAttachmentList' , true);
                        component.set('v.attachmentData' , result);

                        const groupedData = result.reduce((result, entry) => {
                            const { ParentId } = entry;
                            
                            if (!result[ParentId]) {
                              result[ParentId] = [];
                            }
                            
                            result[ParentId].push(entry);
                            return result;
                          }, {});
                          
                          console.log(groupedData);
                    }else{
                        component.set('v.showAttachmentList' , false);

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
})