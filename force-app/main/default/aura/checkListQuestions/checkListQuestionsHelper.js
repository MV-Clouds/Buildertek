({
    getlink:function(component,event,helper){
        component.set("v.TextField", "<p><script>alert(this)</script></p><p>{URL}</p>");
    },
    
    GetObjectLabelName:function(component,event,helper){
      // alert("helo uuu");
        var action = component.get("c.getObjectLabelName");
        var obj = component.get("v.CurrentObject");
        //alert("object"+obj);
        action.setParams({
            "ObjAPIName" : obj
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var result = JSON.stringify(response.getReturnValue());
            // alert(result);
                component.set("v.ObjectLabelName",result);
                this.GetObjectFields(component,event,helper);
            }
            
        });
        $A.enqueueAction(action);
        
    },
	GetObjectFields : function(component, event, helper) {
       
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
         var obj = component.get("v.CurrentObject");
        var action = component.get("c.getinitialObjectFields");
        action.setParams({
              "ObjAPIName" : obj,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
            //  alert(Result)
                if(Result.IsSuccess){
                    component.set('v.ShowLevel1',true);
                    component.set('v.InitialObjectFields',Result.WrapperList);
                    var breadcrumbCollection = component.get("v.breadcrumbCollection");
                    var breadcrumb = {};
                    var obj = [];
                   
                    breadcrumb.label= component.get('v.CurrentObjLabelName');
                    breadcrumb.name= component.get('v.ObjectAPIName');   
                    breadcrumb.level = 'Level 0';
                    if(breadcrumbCollection != undefined){
                    	breadcrumbCollection.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', breadcrumbCollection);
                    }
                    else{
                        obj.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', obj);
                    }
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": Result.Message
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
        
    },
    GetFirstLevLookUpObjectFields : function(component, event, helper, FieldDetails) {
     // alert("FieldDetails"+FieldDetails);
        
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.getObjectLabelName");
        action.setParams({
            "ObjAPIName" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
               // alert(JSON.stringify(Result));
               /* if(Result.WrapperList == ''){
                    alert("hai");
                }*/
                if(Result.IsSuccess){
                    component.set('v.ShowLevel1',false);
                    component.set('v.ShowLevel2',true);
                    component.set('v.ShowLevel3',false);
                    component.set('v.ShowLevel4',false);
                    component.set('v.ShowLevel5',false);
                    var breadcrumbCollection = component.get("v.breadcrumbCollection");
                    var breadcrumb = {};
                    var obj = [];
                    breadcrumb.label= FieldDetails;
                    breadcrumb.name= FieldDetails;   
                    breadcrumb.level = 'Level 1';
                    if(breadcrumbCollection != undefined){
                    	breadcrumbCollection.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', breadcrumbCollection);
                    }
                    else{
                        obj.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', obj);
                    }
                    component.set('v.FirstLevSelectedFieldDetails',undefined);
                    component.set('v.SecondLevSelectedFieldDetails',undefined);
                    component.set('v.FirstLevelObjectFields',Result.WrapperList);
                    
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": Result.Message
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
        
    },
    GetFirstLevelFieldDetails : function(component, event, helper, ObjName, FieldDetails) {
		
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.GetFieldDetails");
        action.setParams({
            "ObjectName" : ObjName,
            "FirstField" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
               
                component.set("v.ShowLevel1",true);
                component.set("v.ShowLevel2",false);
                component.set("v.ShowLevel3",false);
                component.set("v.ShowLevel4",false);
                component.set("v.ShowLevel5",false);
                if(component.get("v.parents") != 'yes'){
                	component.set('v.FirstLevSelectedFieldDetails',Result);
                }
                else{
                    component.set('v.FirstLevSelectedFieldDetails','{!'+Result + '}'); 
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
	},
    
    GetSecLevLookUpObjectFields : function(component, event, helper, FieldDetails) {
       //alert("FieldDetails"+FieldDetails);
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.getAllObjectFields");
        action.setParams({
            "ObjAPIName" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
                if(Result.IsSuccess){
                    component.set('v.ShowLevel1',false);
                    component.set('v.ShowLevel2',false);
                    component.set('v.ShowLevel3',true);
                    component.set('v.ShowLevel4',false);
                    component.set('v.ShowLevel5',false);
                    var breadcrumbCollection = component.get("v.breadcrumbCollection");
                    var breadcrumb = {};
                    var obj = [];
                    breadcrumb.label= FieldDetails;
                    breadcrumb.name= FieldDetails;   
                    breadcrumb.level = 'Level 2';
                    
                    if(breadcrumbCollection != undefined){
                    	breadcrumbCollection.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', breadcrumbCollection);
                    }
                    else{
                        obj.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', obj);
                    }
                    component.set('v.FirstLevSelectedFieldDetails',undefined);
                    component.set('v.SecondLevSelectedFieldDetails',undefined);
                    component.set('v.SecondLevelObjectFields',Result.WrapperList);
                    
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": Result.Message
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
        
    },
    GetSecLevelFieldDetails : function(component, event, helper, ObjName, FirstField, FieldDetails) {
		//alert("first");
		//alert(ObjName);
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.GetSecLevelFieldDetailscontroller");
        action.setParams({
            "ObjectName" : ObjName,
            "FirstField" : FirstField,
            "SecondField" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
               // alert(Json.stringify(Result));
                component.set('v.ShowLevel1',false);
                component.set('v.ShowLevel2',true);
                component.set("v.ShowLevel3",false);
                component.set("v.ShowLevel4",false);
                component.set("v.ShowLevel5",false);
                if(component.get("v.parents") != 'yes'){
                	component.set('v.SecondLevSelectedFieldDetails',Result);
                }
                else{
                    component.set('v.SecondLevSelectedFieldDetails','{!'+Result+ '}');
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
	},
    GetThirdLevelFieldDetails : function(component, event, helper, ObjName, FirstField, SecondField, FieldDetails) {
		
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.GetThirdLevelFieldDetails");
        action.setParams({
            "ObjectName" : ObjName,
            "FirstField" : FirstField,
            "SecondField" : SecondField,
            "ThirdField" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
          
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
                component.set('v.ShowLevel1',false);
                component.set('v.ShowLevel2',false);
                component.set("v.ShowLevel3",true);
                component.set("v.ShowLevel4",false);
                component.set("v.ShowLevel5",false);
                
                if(component.get("v.parents") != 'yes'){
                	component.set('v.ThirdLevSelectedFieldDetails',Result);
                }
                else{
                    component.set('v.ThirdLevSelectedFieldDetails','{!'+Result+'}');
                }
                
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
	},
    
    GetThirdLevLookUpObjectFields : function(component, event, helper, FieldDetails) {
      
        var toastEvent = $A.get("e.force:showToast");
        component.set("v.toggleSpinner",true);
        var action = component.get("c.getFinalObjectFields");
        action.setParams({
            "ObjAPIName" : FieldDetails
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.toggleSpinner",false);
                var Result = response.getReturnValue();
                if(Result.IsSuccess){
                    component.set('v.ShowLevel1',false);
                    component.set('v.ShowLevel2',false);
                    component.set("v.ShowLevel3",false);
                    component.set('v.ShowLevel4',true);
                    component.set('v.ShowLevel5',false);
                    var breadcrumbCollection = component.get("v.breadcrumbCollection");
                    var breadcrumb = {};
                    var obj = [];
                    breadcrumb.label= FieldDetails;
                    breadcrumb.name= FieldDetails;   
                    breadcrumb.level = 'Level 3';
                    
                    if(breadcrumbCollection != undefined){
                    	breadcrumbCollection.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', breadcrumbCollection);
                    }
                    else{
                        obj.push(breadcrumb);
                    	component.set('v.breadcrumbCollection', obj);
                    }
                    //component.set('v.FirstLevSelectedFieldDetails',undefined);
                    //component.set('v.SecondLevSelectedFieldDetails',undefined);
                    component.set('v.ThirdLevSelectedFieldDetails',undefined);
                    component.set('v.ThirdLevelObjectFields',Result.WrapperList);
                    
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": Result.Message
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
        
    }, 
    
  
    
    
    
    
    
    
    
    
    
})