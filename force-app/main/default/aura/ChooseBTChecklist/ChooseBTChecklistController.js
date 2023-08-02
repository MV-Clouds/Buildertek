({
	doInit : function(component, event, helper) {
        
         var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Checklist Configuration"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Checklist Configuration'
        });
    });
        var action =component.get("c.getCheckListCofigRecords");
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
               
                component.set('v.manageView',a.getReturnValue());
                            }
        });
        $A.enqueueAction(action);
        
        
       
		var action =component.get("c.getchecklistObjects");
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
                component.set("v.ChecklistObjects",a.getReturnValue());               
            }
        });
        $A.enqueueAction(action);
       var questionIds = component.get("v.selectedIds");
       // alert(questionIds);
     
        var action =component.get("c.getQuestions");
         
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
              // alert(JSON.stringify(a.getReturnValue()));
                component.set("v.Questions",a.getReturnValue());
                
                setTimeout(function(){
                    
                    var selectedIds = component.get("v.selectedIds")
                  // alert(selectedIds);
                    debugger;
                    if(selectedIds.length > 0){
                    	var result = a.getReturnValue()
                      //component.set("v.Question",a.getReturnValue());
                        for(var i=0;i<result.length;i++){
                            var data = result[i].Id;
                            if(document.getElementById("available") != null && document.getElementById(data) != null){
                            	document.getElementById("available").appendChild(document.getElementById(data)); 
                            }
                        }
                        for(var j=0;j<selectedIds.length;j++){
                             var data = selectedIds[j];
                             if(document.getElementById("Selected") != null && document.getElementById(data) != null)
                             document.getElementById("Selected").appendChild(document.getElementById(data));
                         }
                    }
                },500)
                
            }
        });
        $A.enqueueAction(action);
        
          //Create Pick List  
        var action = component.get("c.getPickValues"); 
        action.setParams({
            "objectName" : 'buildertek__Questions__c',
            "fieldName" : 'buildertek__Question_Type__c'
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue();
                var PicklistArray = [];
                for(var key in result){
                    PicklistArray.push(result[key]);
                }
                component.set("v.PicklistArrayValue",PicklistArray);
                 
            }
        });
        $A.enqueueAction(action);
        
       
	},
    
    checkTheObject : function(component, event, helper) {
    	if(component.get("v.SelectedChecklistObject") !=undefined && component.get("v.SelectedChecklistObject") !='' && component.get("v.SelectedChecklistObject") != '--None--') {
            component.set("v.isRelatedToError",false);
        }else{
            component.set("v.isRelatedToError",true); 
        }
 	},
    checkObjName : function(component, event, helper) {
        
        if(component.get("v.ChecklistName") != "" && component.get("v.ChecklistName") != null && component.get("v.ChecklistName") != undefined){
            component.set("v.ischecklistNameError",false);
        }else{
           component.set("v.ischecklistNameError",true); 
        }
    },
 
 	afterSelect : function(component, event, helper) {
    	if(component.get("v.ChecklistName") !=undefined && component.get("v.ChecklistName") !='') {
            component.set("v.isRelatedToError",false);
        }
 	},
    
     addQuestionsModel : function(component, event, helper) {
    	component.set("v.isQuestionError",false);
	    component.set("v.isOptionError",false);
        component.set("v.isMulti",false);
         component.set("v.OpenQuestion",true);
           
      	var action =component.get("c.getAllGroup");
     	action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
                component.set('v.grouplist',a.getReturnValue());
			}
        });
        $A.enqueueAction(action);
         
        component.set("v.NewQuestion",{'sobjectType':'Questions__c', 
                                       'Options__c': '',
                                       'Customize__c': '',
                                       'Question_Type__c': ''});
    },
    
     deleteQuestionsModel : function(component, event, helper) {
         debugger;
    	component.set("v.isQuestionError",false);
	    component.set("v.isOptionError",false);
        component.set("v.isMulti",false);
         component.set("v.DeleteQuestion",true);
        // alert(JSON.stringify(component.get("v.Questions")));
        
          var questionIds = component.get("v.selectedIds");
      //  alert(questionIds);
           var action =component.get("c.getQuestion");
           action.setParams({
                 "QuestionIds" :  questionIds,
                
            });
         
        action.setCallback(this, function(a){
          //  alert("hai");
           //  alert(a.getState());
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                if(result.length == 0){
                    // alert("1");
                    component.set("v.message",true);
                }else{
                    component.set("v.message",false);
                    component.set("v.QuestionType", result);
                }
            }
        });
        $A.enqueueAction(action);
         
     
       // component.set("v.NewQuestion",{'sobjectType':'Questions__c', 
                                    //   'Options__c': '',
                                      // 'Customize__c': '',
                                      // 'Question_Type__c': ''});
    },
    
    
    saveAndContinue: function(component, event, helper) {  
       
    },
    saveConfigureBack: function(component, event, helper) {
        component.sampleMethod();
        component.set("v.isshow",false);
        component.set("v.isRelatedToError",false);
        component.set("v.ischecklistNameError",false);
         component.set("v.isEditrecord",true);
        $A.get('e.force:refreshView').fire();
        //alert("show"+component.get("v.isshow",false));

        
    },
    
    ChageType :function(component, event, helper) {
        component.set("v.questionType",event.getSource().get('v.value'));
        var newQua=component.get("v.NewQuestion");
        if( newQua.buildertek__Question_Type__c =='Single Select Answer' || newQua.buildertek__Question_Type__c =='Multi Select Answer'){
        component.set("v.isMulti",true);
        }
        else{
             component.set("v.isMulti",false);
        }
        
    },
     ChageTypes :function(component, event, helper) {
        component.set("v.questionType",event.getSource().get('v.value'));
        var newQua=component.get("v.Question");
        if(newQua =='Single Select Answer' || newQua =='Multi Select Answer'){
        component.set("v.isMulti",true);
        }
        else{
             component.set("v.isMulti",false);
        }
        
    },
    
    CancelQuestionsModel :function(component, event, helper) {
         component.set("v.OpenQuestion",false);
         component.set("v.showGroup",false);
        component.set("v.EditQuestion",false);
        component.set("v.groupName",'');
    },
     SaveQuestionsModel :function(component, event, helper) {
         component.set("v.Spinner2",true);
        var Qtype = component.get("v.NewQuestion.buildertek__Question_Type__c");
        var Qtext = component.get("v.NewQuestion.buildertek__Customize__c");
        var opt = component.get("v.NewQuestion.buildertek__Options__c	");
        var errormsg = false;
        component.set("v.isQuestionError",false); 
        component.set("v.isOptionError",false); 
      
        if(Qtext == undefined || Qtext == ''){
            errormsg = true;
            component.set("v.isQuestionError",true);
            component.set("v.Spinner2",false);
        }
         else{
             if(Qtext.trim() == ""){
                   errormsg = true;
            component.set("v.isQuestionError",true);
            component.set("v.Spinner2",false);
             }
         }
        if((opt == undefined || opt == '') && component.get("v.isMulti")){
            
            component.set("v.isOptionError",true); 
            errormsg = true;
            component.set("v.Spinner2",false);
        }
        
        if(errormsg == false){
            
            if(component.get("v.groupName") != null && component.get("v.groupName") != '' && component.get("v.groupName") != undefined){
                component.set("v.selectedgroup",'');
            }
            var action =component.get("c.saveQuestion");
             //component.set("v.Spinner",true);
            action.setParams({
                "QuestionType" : Qtype,
                "QuestionText" : Qtext,
                "Options" : opt,
                "groupname" : component.get("v.groupName"),
                "selectedgroup" : component.get("v.selectedgroup")
            });
            action.setCallback(this, function(a){
                if (a.getState() === "SUCCESS") {
                    console.log(a.getReturnValue().Id);
                    var data = a.getReturnValue().Id;
                    component.set("v.OpenQuestion",false);
                    component.set("v.showGroup",false);
                    var ids = component.get("v.selectedIds");
                    ids.push(data);
                    component.set("v.selectedIds",ids);
                    //component.set("v.selectedIds",data)
                    component.doinits();
                    component.set("v.Spinner2",false);
                    //document.getElementById("Selected").appendChild(document.getElementById(data));
            }
        	});
         $A.enqueueAction(action);
           
        }
    },
    
    
    SavingQuestionsModel :function(component, event, helper) {
          var Qtype = component.get("v.Question");
         var recordid = component.get("v.recordId");//event.currentTarget.title;
       // alert(recordid);
        var Qtext = component.get("v.TextName");
        var opt = component.get("v.option");
        var errormsg = false;
        component.set("v.isQuestionError",false); 
        component.set("v.isOptionError",false); 
        if(Qtext == undefined || Qtext == ''){
            errormsg = true;
            component.set("v.isQuestionError",true); 
        }
        if((opt == undefined || opt == '') && component.get("v.isMulti")){
            
            component.set("v.isOptionError",true); 
            errormsg = true;
        }
        
        if(errormsg == false){
            
            if(component.get("v.groupName") != null && component.get("v.groupName") != '' && component.get("v.groupName") != undefined){
                component.set("v.selectedgroup",'');
            }
            var action =component.get("c.savingQuestion");
             //component.set("v.Spinner",true);
            action.setParams({
                "recordid" : recordid,
                "QuestionType" : Qtype,
                "QuestionText" : Qtext,
                "Options" : opt,
                "groupname" : component.get("v.groupName"),
                "selectedgroup" : component.get("v.selectedgroup")
            });
            action.setCallback(this, function(a){
                if (a.getState() === "SUCCESS") {
                   
                     
                      component.set("v.EditQuestion",false);
                    component.set("v.OpenQuestion",false);
                    component.set("v.showGroup",false);
                   component.doinits();
                     helper.showToast(component,event,helper); 
                    
                    
            }
        	});
         $A.enqueueAction(action);
           
        }
    },
    
        
   
       
    
     MoveToQuestion: function(component, event, helper) {
        var data = event.target.id;
        
        if(event.target.parentNode.getAttribute('id')=='available'){
            	document.getElementById("Selected").appendChild(document.getElementById(data));
        }
        else if(event.target.parentNode.getAttribute('id')=='Selected'){
    		document.getElementById("available").appendChild(document.getElementById(data));
        }
        helper.refreshList(component, event);

   },
    
     AvalQuestions : function(component, event, helper) {
        var input, filter, ul, li, a, i;
        input = document.getElementById("AvailImp");
        filter = input.value.toUpperCase();
        ul = document.getElementById("available");
        li = ul.getElementsByTagName('li');
        
        // Loop through all list items, and hide those who dont match the search query
        for (i = 0; i < li.length; i++) {
            a = li[i];
            if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
        
      
    },
    SelectedQuestions : function(component, event, helper) {
       
        var input, filter, ul, li, a, i;
        input = document.getElementById("selectedImp");
        filter = input.value.toUpperCase();
        ul = document.getElementById("Selected");
        li = ul.getElementsByTagName('li');
        
        // Loop through all list items, and hide those who dont match the search query
        for (i = 0; i < li.length; i++) {
            a = li[i];
            if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }
    },
    
    saveSelectedQuestions: function(component, event, helper) {
       debugger;
         var questionIds = component.get("v.selectedIds");
        /*if(component.get("v.deleteQuestionId")){
           
            var idx = questionIds.indexOf(component.get("v.deleteQuestionId"))
            questionIds.splice(idx,1)
            
            component.set("v.selectedIds",questionIds)
        }*/
        
        // alert(questionIds);
        var name = component.get("v.ChecklistName");       
        var selectedObject = component.get("v.SelectedChecklistObject");
        
        var errormsg = false;
        component.set("v.ischecklistNameError",false); 
        component.set("v.isRelatedToError",false); 
        if(name == undefined || name == ''){
            errormsg = true;
            component.set("v.ischecklistNameError",true); 
        }
        console.log("questionIds"+questionIds);
        if(selectedObject == undefined || selectedObject == '' || selectedObject == '--None--'){
            
            component.set("v.isRelatedToError",true); 
            errormsg = true;
        }
        if(questionIds == undefined || questionIds.length <= 0){
            errormsg = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": " Please Select Questions.",
                "type":"error"
            }); 
            toastEvent.fire();
        }
        if(errormsg == false){
            component.set("v.ischecklistNameError",false); 
            component.set("v.isRelatedToError",false);
        	var action =component.get("c.ChecklistConfiguration");
            component.set("v.Spinner",true);
            //alert(selectedObject);
             action.setParams({
                 "QuestionIds" :  questionIds,
                 "Name" : name,
                 "SelectedObject" : selectedObject,
                 "recordId" : component.get("v.configureId")
            });
            action.setCallback(this, function(a){ 
                if (a.getState() === "SUCCESS") {
                     component.set("v.isshow",false);
                    component.set("v.isEditrecord",true);
                    var result = a.getReturnValue();  
                    component.set("v.Spinner",false);
                   // alert(result);
                    if(result == 'Success'){
                       //component.sampleMethod();
                        component.doinits();
                        if(component.get("v.configureId") == undefined || component.get("v.configureId") == ''){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Checklist Configuration Created Successfully.",
                                "type":"success"
                            });     
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Checklist Configuration Updated Successfully.",
                                "type":"success"
                            }); 
                        }
                        
                       // window.open('/lightning/n/buildertek__BT_CheckList','_self'); 
                        toastEvent.fire();
                         $A.get('e.force:refreshView').fire();
                    }
                    
                }
            });
            $A.enqueueAction(action);
        }
      
        
    

    },
    callUpdateRecord : function(component, event, helper) {
        component.set("v.isshow",true);
        component.set("v.isEditrecord",false);
         
        //alert(event.currentTarget.title);
         var action = component.get("c.geteditRecord");
         action.setParams({
            //"recId" : event.currentTarget.title,
            "recId" : event.target.getAttribute('data-id')
        });
        var result;
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
               //alert('SUCCESS'); 
                result = a.getReturnValue();
                //alert(JSON.stringify(result));
                component.set("v.ChecklistName",result.Name);
                component.set("v.configureId",result.Id);
                
                 component.set("v.SelectedChecklistObject",result.buildertek__Object_Name__c);
                if(result.buildertek__Checklist_Questions__r != undefined && result.buildertek__Checklist_Questions__r != "" && result.buildertek__Checklist_Questions__r != null){
                for(var i=0;i<result.buildertek__Checklist_Questions__r.length;i++){
                    //alert(result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r.Id);
                    if(result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r != undefined){
                    	var data = result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r.Id;
            	     	document.getElementById("Selected").appendChild(document.getElementById(data));
                   		helper.refreshList(component, event);
                    }
                }
                }
            }
        });
        $A.enqueueAction(action);
        
        //component.set("v.SelectedChecklistObject",null);
    },
    
    callDeleteRecord : function(component, event, helper) {
         //component.set("v.deleterecord",event.currentTarget.title);
         component.set("v.deleterecord",event.target.getAttribute('data-id'));
       component.set('v.showConfirmDialog', true);  
        
  
	},
    
    callDeleteQuestion : function(component, event, helper) {
        //component.set("v.deleteQuestionId",event.currentTarget.title);
         var index = event.currentTarget.dataset.index;
        //alert(index);
        component.set("v.deleteIndex",index);
       //alert(component.get("v.selectedIds"))
      
        
        
        component.set("v.deleteQuestionId",event.target.getAttribute('data-id'));
       component.set("v.showConfirmDialogDeleteQuestion",true);
        component.set("v.DeleteQuestion",false);
  
	},
     callEditQuestion : function(component, event, helper) {
         console.log('**************'+event.target.getAttribute('data-id'));
         component.set("v.isQuestionError",false);
	    component.set("v.isOptionError",false);
        component.set("v.isMulti",false);
       // component.set("v.deleteQuestionId",event.currentTarget.title);
       component.set("v.EditQuestion",true);
         
          
        component.set("v.DeleteQuestion",false);
         
         
          //alert(event.currentTarget.title);
     var action = component.get("c.editRecord");
         action.setParams({
            //"recId" : event.currentTarget.title,
            "recId" : event.target.getAttribute('data-id'),
        });
        var result;
        action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
               //alert('SUCCESS'); 
                //var result = JSON.stringify(response.getReturnValue());
                 //alert(JSON.stringify(a.getReturnValue()));
               result = JSON.parse(JSON.stringify(a.getReturnValue()));
             // alert(result.Id);
               
                component.set("v.TextName",result.buildertek__Customize__c);
                component.set("v.Question",result.buildertek__Question_Type__c);
                component.set("v.option",result.buildertek__Options__c);
                //component.set("v.configureId",result.Id);
                component.set("v.recordId",result.Id)
               // alert(result.buildertek__Question_Type__c);
                 if(result.buildertek__Question_Type__c  =='Single Select Answer' || result.buildertek__Question_Type__c  =='Multi Select Answer'){
        component.set("v.isMulti",true);
        }
        else{
             component.set("v.isMulti",false);
        }
        
               
                
                /* component.set("v.SelectedChecklistObject",result.buildertek__Object_Name__c);
                if(result.buildertek__Checklist_Questions__r != undefined && result.buildertek__Checklist_Questions__r != "" && result.buildertek__Checklist_Questions__r != null){
                for(var i=0;i<result.buildertek__Checklist_Questions__r.length;i++){
                    //alert(result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r.Id);
                    if(result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r != undefined){
                    	var data = result.buildertek__Checklist_Questions__r[i].buildertek__Questions__r.Id;
            	     	document.getElementById("Selected").appendChild(document.getElementById(data));
                   		helper.refreshList(component, event);
                    }
                }
                }*/
                 var action = component.get("c.getAllGroup");
                 action.setCallback(this, function(a){
                     
       
                     //alert("ki")
                     if (a.getState() === "SUCCESS") {
                        // alert(a.getState());
                          var result1 = JSON.parse(JSON.stringify(a.getReturnValue()));
                         // alert(result1);
                         component.set("v.grouplist",result1);
                                       component.set("v.selectedgroup",result.buildertek__group_name__c);

                          //component.set("v.grouplist",result.buildertek__group_name__c);
                     }
                 });
                  $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
        
       
       
  
	},
    createChecklist : function(component, event, helper) {
         component.set("v.ChecklistName",'');
        component.set("v.SelectedChecklistObject",'');
        component.set("v.isshow",true);
        
        component.set("v.isEditrecord",false);
        
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
       //alert(component.get("v.OpenQuestion"));
         //alert(component.get("v.DeleteQuestion"));
       
        
         var action = component.get("c.getDeleteRecord");
         action.setParams({
            "recId" : component.get("v.deleterecord"),
        });
         action.setCallback(this, function(a){
            if (a.getState() === "SUCCESS") {
                 var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Checklist Configuration Deleted successfully",
                "type":"success"
            });
            toastEvent.fire();
                component.sampleMethod();
                component.set('v.showConfirmDialog', false);
            }
        });
        $A.enqueueAction(action);
       
        
    },
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
    handleConfirmDialogDeleteQuesYes : function(component, event, helper) {
         var newQuestionList = component.get("v.QuestionType");
        newQuestionList.splice(component.get("v.deleteIndex"),1);
        component.set("v.QuestionType",newQuestionList);
          //component.set("v.Spinner",true);
            var action = component.get("c.getDeleteQuestion");
             action.setParams({
            "recId" : component.get("v.deleteQuestionId"),
            });
             action.setCallback(this, function(a){
                // component.set("v.Spinner",true);
                 //alert(a.getState());
            if (a.getState() === "SUCCESS") {
                 component.sampleMethod();
                //alert(component.get("v.selectedIds"));
                
                var selectedIdss = component.get("v.selectedIds");
                for (var i = 0; i < selectedIdss.length; i++) {
                    if (selectedIdss[i] == component.get("v.deleteQuestionId")) {
                        var spliced = selectedIdss.splice(i, 1);
                    }
                }
                component.set("v.selectedIds",selectedIdss);
                
                
                
                 component.set("v.DeleteQuestion",true);
                //component.set("v.Spinner",true);
                component.set("v.showConfirmDialogDeleteQuestion",false);
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Question Deleted Successfully.",
                                "type":"success"
                            }); 
                  toastEvent.fire();
               
                //alert(component.get("v.Questions").length);
                
                //component.set('v.showConfirmDialog', false);
            }
        });
        $A.enqueueAction(action);
       //component.set('v.showConfirmDialog', true);    
  
	},
     handleConfirmDialogDeleteQuesNo : function(component, event, helper) {
        console.log('No');
          component.set("v.DeleteQuestion",true);
        component.set('v.showConfirmDialogDeleteQuestion', false);
    },
    
    CancelDeleteModel :  function(component, event, helper) {
        component.set("v.DeleteQuestion",false);
        component.set("v.Spinner",false);
    },
    
    AddGroup : function(component, event, helper) {
    	component.set("v.showGroup",true);
    }
})