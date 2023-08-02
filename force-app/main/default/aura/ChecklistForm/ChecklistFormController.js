({
	doInit : function(component, event, helper) {
        //Site Url Get 
         var url = window.location.href;
         var siteUrl = url.split('?');
         if(siteUrl[0] !='' && siteUrl[0] != undefined){
             component.set("v.siteUrl",siteUrl[0].replace('/buildertek__ChecklistForm','')); 
         }
         else{
             component.set("v.siteUrl",'/');
         }
  
      	var action =component.get("c.getAttachmentData");
             action.setParams({
                 "recordId" : component.get("v.recordId")
            });
             action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){
                    var result = a.getReturnValue();
                     
                     component.set("v.imgUrl",component.get("v.siteUrl")+"/servlet/servlet.FileDownload?file="+result);
                  }
            });
            $A.enqueueAction(action);
        
   		var recId = component.get("v.selectedValue");
      	var action =component.get("c.getQuestions");
        action.setParams({          
             "CheckQuestionId" : recId
        });
         action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                component.set("v.showchecklist",true);
                var result = a.getReturnValue();
                component.set("v.Questions",result);
            }
        });
        $A.enqueueAction(action);
        
        
      	var action3 =component.get("c.getProjectName");
        action3.setParams({          
             "Ids" : component.get("v.recordId")
        });
         action3.setCallback(this,function(c){
            if(c.getState()==='SUCCESS'){
               
                var result = c.getReturnValue();
                debugger;
              //  alert(result)
                if(result != 'error'){
               component.set('v.DynamiccheckListName',result);
                }
            }
             else{
                 console.log(c.getError());
             }
        });
        $A.enqueueAction(action3); 
	},
   
    getcheckboxlist: function(component,event,helper){
        var Questions = component.get("v.Questions");
        var label = event.getSource().get('v.label');
        for(var i=0;i<Questions.length;i++){
            for(var j=0;j<Questions[i].QuestionsInnerclasslist.length;j++){
                if(label == Questions[i].QuestionsInnerclasslist[j].QuestionName){
                    Questions[i].QuestionsInnerclasslist[j].QuestionValues = event.getSource().get('v.value');
                }
            }
            
        }
        component.set("v.Questions",Questions);
    },
    nameOnchange : function(component,event,helper){
        if(component.get("v.DynamiccheckListName") != undefined && component.get("v.DynamiccheckListName") != null && component.get("v.DynamiccheckListName") != ""){
            component.set("v.ischecklistNameError",false);
        }
        else{
            component.set("v.ischecklistNameError",true);
        }
    },
    
    handleClick : function(component,event,helper){
         component.set("v.isDisableButton",false);
     	  component.set("v.Spinner",true);
        var Questions = component.get("v.Questions");  
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = dd + '/' + mm + '/' + yyyy;
      var nameDate = component.get("v.DynamiccheckListName");
        if(nameDate != undefined){
         nameDate = nameDate+'-'+today;
        }
        else{
            nameDate = today;
        }
    component.set("v.DynamiccheckListName",nameDate)
        var action =component.get("c.createchecklistquestion");
         action.setParams({
             "QuestionString" : JSON.stringify(Questions),
             "recordId" : component.get("v.recordId"),
             "checkName" : nameDate
        });
       
         action.setCallback(this,function(a){
          
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue();
               //alert(result);
                if(result == 'Success'){
                    component.set("v.Spinner",false);
                    component.set("v.SuccessMessage",true);
                    
                    /*  Call the apex for email confirmation */
                     var action1 =component.get("c.sendEmail");
                     action1.setCallback(this,function(b){
                         
                         if(b.getState() === "SUCCESS"){
                             
                          //   alert(b.getReturnValue());
                         }
                         
                         
                     });
                    $A.enqueueAction(action1);
                    
                    /* End of Email action */
                }
            }
             else{
                 debugger
                 console.log("Error ",a.getError());
             }
        });
        var getName1 = component.get("v.DynamiccheckListName");
     //   var trimName1 = getName1.trim();
        if(getName1 != undefined && getName1 != null && getName1 != ""){
          
            if(getName1.trim() != ""){
            component.set("v.ischecklistNameError",false);
                $A.enqueueAction(action);
            }
            else{
                 component.set("v.isDisableButton",true);
                component.set("v.Spinner",false);
                 component.set("v.ischecklistNameError",true);
            }
            }else{
              component.set("v.isDisableButton",true);
                component.set("v.Spinner",false);
               
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Checklist name should not null',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                component.set("v.ischecklistNameError",true);
            }
        
        
        //$A.enqueueAction(action);
    },
     closePage : function(component, event, helper) {
    	window.close('/apex/buildertek__Pre_QualProcess_VF');    
    },
    
})