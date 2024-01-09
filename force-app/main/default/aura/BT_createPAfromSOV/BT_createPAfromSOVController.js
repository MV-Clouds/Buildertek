({
    doInit : function(component, event, helper) {
        try {
            var action = component.get("c.GetRelatedPaymanetApp");
            action.setParams({
                SOVid : component.get("v.recordId")
            })
            action.setCallback(this, function (response){
                var result = response.getReturnValue();
                console.log(' GetRelatedPaymanetApp apex result : ', result);
            })
        } catch (error) {
            console.log('Error in Doint : ', error.stack);
            
        }
    }
})
