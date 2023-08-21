({
    handleChangeObjectName : function(component, event, helper) {

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
                // component.set('v.loaded', false);


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
})
