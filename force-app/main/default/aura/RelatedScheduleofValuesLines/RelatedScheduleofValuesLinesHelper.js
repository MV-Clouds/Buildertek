({
	deleteRecord : function(component, event) {
        component.set("v.isLoading", true);
        var ScheduleOfValuesLineRec = event.getParam('row'); 
       // alert(ScheduleOfValuesLineRec);
        var action = component.get("c.delAccount");
        action.setParams({
            "ScheduleOfValuesLineRec": ScheduleOfValuesLineRec
        });
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);            
            if (response.getState() === "SUCCESS" ) {
                var rows = component.get('v.results');
              //  var rowIndex = rows.indexOf(ScheduleOfValuesLineRec);
              //  rows.splice(rowIndex, 1);
                component.set('v.results', rows);
                this.showToast("Success!","success","The record has been delete successfully.");
                window.setTimeout(
            $A.getCallback(function() {
                window.location.reload();
            }), 2000
        );
                
               
                       // $A.get("e.force:refreshView").fire();
                 
                
            }
            else{
                this.showToast("ERROR","error",JSON.stringify(response.getError())); 
            }
        });
        $A.enqueueAction(action);
    },
    showToast:function(title,type,message){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({"title": title,"type": type,"message": message}).fire();
        }
        else{
            //alert(message);
        }
    }
})