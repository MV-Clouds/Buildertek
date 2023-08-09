({
    doInit : function(component, event, helper) {
        var Rec = component.get("v.Record");
        var api = component.get("v.ApiName")
     //   if(api != "Id"){
            if(Rec[api] != undefined){
                component.set("v.showData",Rec[api])
            }
            else{
                component.set("v.showData",null)
         //   }
        }
    }
})