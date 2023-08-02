({
    doInit : function(component, event, helper) {
        component.set("v.IsselectOptionScreen",true);
        var dbAction = component.get("c.getsubject");
        dbAction.setParams({
            recordId : component.get("v.recordId"),
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
				component.set("v.subject", response.getReturnValue());
                component.set("v.sublist", response.getReturnValue());
            }
            
        });
        $A.enqueueAction(dbAction);
        
        component.set("v.ShowLevel1",true);
        
        //Site Url Get 
        function getCookie(cname) {
            var name = cname + "=";
            var ca = document.cookie.split(';');
            
            for(var i=0; i<ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1);
                if (c.indexOf(name) == 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        }
        //clear Cookies function
        function unsetCookie(cname) {
            document.cookie = cname+ '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
        }
        
        var siteUrl=getCookie('siteUrl');  
        
        if(siteUrl !='' && siteUrl != undefined){
            component.set("v.siteUrl",siteUrl);
        }
        else{
            
            component.set("v.siteUrl",'/');
        }
        //clear cookie
        unsetCookie('siteUrl');
        
        var action =component.get("c.getAttachmentData");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue();
               // alert(result);
                component.set("v.imgUrl",component.get("v.siteUrl")+"servlet/servlet.FileDownload?file="+result);
                // component.set("v.TextField",component.get("v.siteUrl")+result);
                
            }
        });
        $A.enqueueAction(action);
       // var userName = component.get("v.selectedValue");
        var action =component.get("c.getCheckListConfigurationData");
        console.log('%%%%%'+component.get("v.recordId"));
        // alert('recordId'+component.get("v.recordId"));
        action.setParams({
            "recordId" : component.get("v.recordId")
            
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                //     alert(a.getState());
                var result = a.getReturnValue();
               if(result.length==0){
                   // alert("1");
                   component.set("v.message",true);
                  
                    
                     /* var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "please enter the question",
                "type":"error"
            });
            toastEvent.fire();*/
                    
                }else{
                    component.set("v.message",false);
                 // alert('result length'+result.length);
                  //alert('returnValue'+result);
                
                console.log('@@@@@@@@@@@@@'+JSON.stringify(result));
                  console.log('##3333####'+JSON.stringify(result.ObjectName));
                
                if(result != ''){
                      // alert('working');
                    component.set("v.CurrentObject",result[0].ObjectName);
                    component.set("v.ObjectAPIName",result[0].ObjectName);
                    component.set("v.CurrentObjLabelName",result[0].ObjectLabel);
                    component.set("v.options",result);
                  
                    helper.GetObjectLabelName(component, event, helper);// dont delete
                }
                
                } 
            }
        });
        $A.enqueueAction(action);
        
        // var recordId = component.get("v.selectedValue");
        var action1 =component.get("c.signaturetext");
        action1.setParams({          
           // "CheckQuestionIds" : recordId
        });
        action1.setCallback(this,function(a){
            //component.set("v.Spinner",false);
            if(a.getState()==='SUCCESS'){
                 //if(component.get("v.TextField") == null){
                //component.set("v.showchecklist",true);
                var result = a.getReturnValue();
              
                //alert(result);
               // component.set("v.Questions",result);
               //console.log(component.find('richtextarea'))
                //component.set("v.TextField",result);
                component.set("v.TextField",'');
            }
        });
        $A.enqueueAction(action1);
        
        
    },
    closeModel: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    onChangevalue : function(component,event,helper){
        component.set("v.Spinner",true);
        var recId = component.get("v.selectedValue");
       // alert(recId);
        var action =component.get("c.getQuestions");
        action.setParams({          
            "CheckQuestionId" : recId
        });
        action.setCallback(this,function(a){
            component.set("v.Spinner",false);
            if(a.getState()==='SUCCESS'){
                if(component.get("v.selectedValue") == ""){
                     component.set("v.showchecklist",false);
                }else{
                    component.set("v.showchecklist",true);
                    var result = a.getReturnValue();
                    if(result.length > 0){
                        
                        
                        var action3 =component.get("c.getProjectName");
                        action3.setParams({          
                            "Ids" : component.get("v.recordId")
                        });
                        action3.setCallback(this,function(c){
                            if(c.getState()==='SUCCESS'){
                                
                                var result = c.getReturnValue();
                                debugger;
                             //   alert(result)
                                if(result != 'error'){
                                    component.set('v.DynamiccheckListName',result);
                                }
                            }
                        });
                        $A.enqueueAction(action3); 
                        
                        
                        component.set("v.Questions",result); 
                    }else{
                        component.set("v.showchecklist",false);
                        //component.set("v.SuccessMessage",true);

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : '',
                            message:'No Questions to display',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    
                    
                }
                
                //component.set("v.subject",QuestionsInnerclass.QuestionName);
            }
        });
        $A.enqueueAction(action);
        var action =component.get("c.getEmailFieldsList");
        action.setParams({          
            "recId" :component.get("v.recordId")
        });
        action.setCallback(this,function(a){
            component.set("v.Spinner",false);
            if(a.getState()==='SUCCESS'){
                var result = JSON.stringify(a.getReturnValue());
                //alert(result);
                component.set("v.EmailFieldList",result);
            }
        });
        $A.enqueueAction(action);
        
         var recordId = component.get("v.selectedValue");
        var subjects = component.get("v.sublist");
      //  alert(recordId);
        if(recordId != '' ){
            
         var subjects = component.get("v.sublist");
        var action3 =component.get("c.getvalues");
        action3.setParams({          
            "CheckQuestionIds" : recordId,
            "sub" : subjects
        });
        action3.setCallback(this,function(a){
            component.set("v.Spinner",false);
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue();
                var checklistname = result.split(":");
               
               component.set("v.checklistName",checklistname[1]);
                
                component.set("v.subject",result);
            }
        
        });
            
        $A.enqueueAction(action3);
        }
        else{
           
         var dbAction = component.get("c.getsubject");
        dbAction.setParams({
            recordId : component.get("v.recordId"),
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				component.set("v.subject", response.getReturnValue());
                component.set("v.sublist", response.getReturnValue());
            }
        });
        $A.enqueueAction(dbAction);
           // component.get("v.subject");
            
        }
    },
    
    /*getcheckboxlist: function(component,event,helper){
        var Questions = component.get("v.Questions");
        var label = event.getSource().get('v.label');
        for(var i=0;i<Questions.length;i++){
            if(label == Questions[i].QuestionName){
                Questions[i].QuestionValues = event.getSource().get('v.value');
            }
        }
    },*/
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
    
    handleClick : function(component,event,helper){
        var Questions = component.get("v.Questions");
        console.log(JSON.stringify(Questions));
        
        var action =component.get("c.createchecklistquestion");
        action.setParams({
            "QuestionString" : JSON.stringify(Questions),
            "recordId" : component.get("v.recordId"),
            "checkName" : component.get("v.checklistName")
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue(); 
             
               
               
            }
        });
        $A.enqueueAction(action);
    },
    
    sendchecklists: function(component,event,helper){
       
        
        var lookup = component.get("v.selectedFieldValue");
        var ar = lookup.split("--");
        var lookupfield = ar[0];
        var iserror = false;
        var EmailResult;
        var SelectChecklistval = component.get("v.selectedValue");
        
        //if(EmailResult != undefined && EmailResult != null && EmailResult != ""){}
         
        if((component.get("v.Email") == undefined || component.get("v.Email") == '') 
           && (component.get("v.selectedFieldValue") == undefined || component.get("v.selectedFieldValue") == '')
          && (component.get("v.SelectedContactId") == "" || component.get("v.SelectedContactId") == undefined || component.get("v.SelectedContactId") == null)){ 
            //alert("hjj");
            iserror = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter an email address or select an email recipient.",
                "type":"error"
            });
            toastEvent.fire();
        }else if(component.get("v.selectedFieldValue") != undefined && (component.get("v.selectedFieldValue") != '') && lookupfield.includes(">")){
            //alert("hai");
            iserror = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Select a valid email field",
                "type":"error"
            });
            toastEvent.fire();          
        }else if(!component.get("v.TextField").includes("{URL}")){
                // alert("hai"+"v.TextField");
                iserror = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please enter the URL text in email body",
                    "type":"error"
                });
                toastEvent.fire();   
            }else if(component.get("v.TextField") == undefined || component.get("v.TextField") == '' || component.get("v.TextField") == null ){
                    // alert("hai");
                    // alert("hai"+"v.TextField");
                    iserror = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please enter email body",
                        "type":"error"
                    });
                    toastEvent.fire();   
                }else if(SelectChecklistval == undefined || SelectChecklistval == '' || SelectChecklistval == null ){
                    iserror = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please Select Checklist",
                        "type":"error"
                    });
                    toastEvent.fire();   
                }
        
        if(iserror == false){
            /*alert(component.get("v.SelectedContactId"));
            alert(component.get("v.SelectedContactEmail"));*/
            console.log(component.get("v.SelectedContactId"));
            console.log(component.get("v.SelectedContactEmail"));
            var action =component.get("c.validateEmail");
            action.setParams({
                "isparent" : component.get("v.IsParent"),
                "recordId" : component.get("v.recordId"),
                "FieldName" : lookupfield,
                "parentObj" : component.get("v.SelectedparentObject"),
            });
            action.setCallback(this,function(a){
               // alert(a.getState());
               // alert(a.getReturnValue());
                if(a.getState()==='SUCCESS'){
                   
                    var EmailResult = a.getReturnValue();
                   
                   if((component.get("v.Email") == null || component.get("v.Email") == undefined || component.get("v.Email") == '') && (EmailResult == undefined || EmailResult == null || EmailResult == "") && (component.get("v.SelectedContactId") == null || component.get("v.SelectedContactId") == "") ){ 
                        
                         var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please enter an email address or select an email recipient.",
                                "type":"error"
                            });
                            toastEvent.fire();
                    } else if(component.get("v.SelectedContactEmail") == null 
                                && component.get("v.SelectedContactId") != null){

                           var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please enter an email address or select an email recipient.",
                                "type":"error"
                            });
                            toastEvent.fire();
                       
                    }
                    else{
                      // alert("call");
                        component.set("v.Spinner",true);
                        var Parenttrue = component.get("v.IsParent");
                        var apiname = component.get("v.selectedFieldValue");
                        var myArr = apiname.split("--");
                        var recId = component.get("v.selectedValue");
                        var action =component.get("c.sendchecklist");
                        var fieldName = myArr[0];
                      // alert(fieldName);
                        //alert(component.get("v.SelectedparentObject"));
                        //alert(Parenttrue);
                        action.setParams({
                            "checklistId" : recId,
                            "recordId" : component.get("v.recordId"),
                            "FieldName" : fieldName,
                            "Email": component.get("v.Email"),
                            "isparent" : Parenttrue,
                            "parentObj" : component.get("v.SelectedparentObject"),
                            "recipient" : component.get("v.recepientName"),
                            "text"  : component.get("v.TextField"),
                            "Url" : component.get("v.Url"),
                            "subject":component.get("v.subject"),
                            "contactEmail" : component.get("v.SelectedContactEmail"),
                            "selectCheckListName" : component.get("v.checklistName")
                        });
                        action.setCallback(this,function(a){
                            component.set("v.Spinner",false);
                            
                            if(a.getState()==='SUCCESS'){
                                var result = a.getReturnValue();   
                                if(result == 'Success'){
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Success!",
                                        "message": "Checklist Sent Successfully.",
                                        "type":"success"
                                    });
                                    
                                    var navEvent = $A.get("e.force:navigateToSObject");
                                    navEvent.setParams({
                                        recordId: component.get("v.recordId"),
                                        slideDevName: "detail"
                                    });
                                    navEvent.fire();    
                                    toastEvent.fire();
                                    
                                }else{
                                    //alert("error"+result);
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "message": result,
                                        "type":"error"
                                    });
                                    
                                    var navEvent = $A.get("e.force:navigateToSObject");
                                    navEvent.setParams({
                                        recordId: component.get("v.recordId"),
                                        slideDevName: "detail"
                                    });
                                    navEvent.fire();
                                    toastEvent.fire();
                                }
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }
                }  
            });
            $A.enqueueAction(action);
            
            
            
        }
        
        
        
    },
    
    cancel: function(component,event,helper){
        
        component.set("v.IssendEmailScreen",false);
        component.set("v.IsselectOptionScreen",true);
        component.set("v.IsImpersonScreen",false);
        /*var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();*/
    },
    onemailfieldChange: function(component,event,helper){
        
        
    },
    FirstLevelSelectChange:function(component, event, helper){
       // alert("first level level@@");
       // alert(component.get("v.selectedFieldValue"));
        var FieldDetails = component.get("v.selectedFieldValue");
       //  alert(FieldDetails);
        var ObjName = component.get('v.ObjectAPIName');
        var LokUpApiName = FieldDetails.split('-')[1];
        component.set("v.SelectedparentObject",FieldDetails.split('-')[0]);
        // alert(FieldDetails);
        //alert("LokUpApiName"+LokUpApiName);
        var ApiName = FieldDetails.split('-')[0];
        var LabelName = FieldDetails.split('-')[2];
       // alert(LabelName);
        component.set('v.FirstLevField',ApiName);
        if(LabelName != '' && LabelName != undefined && LabelName.includes('>')){
            helper.GetFirstLevLookUpObjectFields(component, event, helper, LokUpApiName);
            component.set("v.SaveButtonDisabled",true);
            component.set("v.AddRowButtonDisabled",true);
        }else{
            
            helper.GetFirstLevelFieldDetails(component, event, helper, ObjName, FieldDetails);
            component.set("v.SaveButtonDisabled",false);
            component.set("v.AddRowButtonDisabled",false);
        }
    },
    
    GetSecLevelSelectedField : function(component, event, helper){
      //  alert("QQQQQ"+component.get("v.selectedFieldValue"));
        var FieldDetails = component.get("v.selectedFieldValue");
      //  alert(FieldDetails);
        component.set("v.IsParent",true);
      // alert(component.get("v.IsParent"));
        var ObjName = component.get('v.ObjectAPIName');
        var LokUpApiName = FieldDetails.split('-')[1];
        var ApiName = FieldDetails.split('-')[0];
        var FirstField = component.get('v.FirstLevField');
        var LabelName = FieldDetails.split('-')[2];
        
        component.set('v.SecondLevField',ApiName);
        //if(LabelName.includes('>')){
        //helper.GetSecLevLookUpObjectFields(component, event, helper, LokUpApiName);
        component.set("v.SaveButtonDisabled",true);
        component.set("v.AddRowButtonDisabled",true);
        // }else{
        helper.GetSecLevelFieldDetails(component, event, helper, ObjName, FirstField, FieldDetails);
        
        component.set("v.SaveButtonDisabled",false);
        component.set("v.AddRowButtonDisabled",false);
        //}
    },
    GetThirdLevelSelectedField : function(component, event, helper){
        
        var FieldDetails = component.get("v.ThirdSelectedValue");
        var ObjName = component.get('v.ObjectAPIName');
        var LokUpApiName = FieldDetails.split('-')[1];
        var ApiName = FieldDetails.split('-')[0];
        var FirstField = component.get('v.FirstLevField');
        var SecondField = component.get('v.SecondLevField');
        var LabelName = FieldDetails.split('-')[2];
        component.set('v.ThirdLevField',ApiName);
        
        if(LabelName.includes('>')){
            helper.GetThirdLevLookUpObjectFields(component, event, helper, LokUpApiName);
            component.set("v.SaveButtonDisabled",true);
            component.set("v.AddRowButtonDisabled",true);
        }
        else{
            helper.GetThirdLevelFieldDetails(component, event, helper, ObjName, FirstField, SecondField, FieldDetails);
            component.set("v.SaveButtonDisabled",false);
            component.set("v.AddRowButtonDisabled",false);
        }
    },
    navigateTo: function(component,event,helper){
        //component.set("v.selectedValue","");
        component.set("v.SecondSelectedValue","");
        component.set("v.ThirdSelectedValue","");
        component.set("v.FourthSelectedValue","");
       // component.set("v.selectedFieldValue","")
        
        
        component.set("v.ToCcBccPicklistVal","To");
        component.set("v.TextRefPicklistVal","Reference");
        var level = event.getSource().get("v.name")
        
        var bread = component.get('v.breadcrumbCollection');
        //alert("bread"+JSON.stringify(bread));
        
        
        
        var number = level.split(' ')[1];
        
        for(var i=0;i<bread.length-number-1;i++){
            bread.pop();
            
        }
        component.set('v.breadcrumbCollection',bread);
        if(number == 0){
            component.set("v.ShowLevel1",true);
            component.set("v.ShowLevel2",false);
            component.set("v.ShowLevel3",false);
            component.set("v.ShowLevel4",false);
        }
        else if(number == 1 ){
            component.set("v.ShowLevel1",false);
            component.set("v.ShowLevel2",true);
            component.set("v.ShowLevel3",false);
            component.set("v.ShowLevel4",false);
        }
            else if(number == 2 ){
                component.set("v.ShowLevel1",false);
                component.set("v.ShowLevel2",false);
                component.set("v.ShowLevel3",true);
                component.set("v.ShowLevel4",false);
            }
                else if(number == 3 ){
                    component.set("v.ShowLevel1",false);
                    component.set("v.ShowLevel2",false);
                    component.set("v.ShowLevel3",false);
                    component.set("v.ShowLevel4",true);
                }
        
        
        component.set("v.toAddRowListExist", true);
        
    },
    handleComponentEvent : function(component,event,helper){
        var valueFromChild = event.getParam("message");
        if(valueFromChild == ""){
            component.set("v.SelectedContactEmail","");
        }
        component.set("v.SelectedContactId",valueFromChild);
        var action = component.get("c.getContactEmail");
        action.setParams({
              "ContactrecordId" : valueFromChild,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var Result = response.getReturnValue();
                component.set("v.SelectedContactEmail",Result);
                
            }else{
                
            }
        });
        if(component.get("v.SelectedContactId") != ""){
            $A.enqueueAction(action);
        }
        
        
    },
       handleChangeButtonGroup:function(component, event, helper){
       
        var auraIdField = event.getSource().getLocalId();
        // console.log(auraIdField);
        console.log(component.find(auraIdField).get("v.value"));
          
        component.set("v.checkBoxValue",component.find(auraIdField).get("v.value"));
    },
        isNext:function(component, event, helper){
        
        var optionSelected = component.get("v.checkBoxValue");
        
        if(optionSelected == 'option1'){
            
            component.set("v.IsselectOptionScreen",false);
            component.set("v.IssendEmailScreen",true);
            helper.getlink(component, event, helper); 
        }else if(optionSelected == 'option2'){
            component.set("v.IsselectOptionScreen",false);
            component.set("v.IsImpersonScreen",true);
        }else if(optionSelected == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please Select an Option',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }
        
        
    },
        handleClick : function(component,event,helper){
     
            debugger;
     component.set("v.isButtonDisabled",false);
        var Questions = component.get("v.Questions");  
            console.log("Questions : ",JSON.stringify(Questions))
            console.log("Length : ",Questions.length)
        component.set("v.Spinner",true);
            
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            
            today = dd + '/' + mm + '/' + yyyy;
            var nameDate = component.get("v.DynamiccheckListName");
            if(nameDate != undefined){
            var nameDate = nameDate+'-'+today;
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
               //alert( JSON.stringify(result));
                if(result == 'Success'){
                    component.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "Checklist Submitted Successfully."
                    });
                    toastEvent.fire();
                
                    /*  Call the apex for email confirmation */
                   /*    var action2 =component.get("c.sendEmail");
                  
                     action2.setCallback(this,function(b){
                     
                         if(b.getState() === "SUCCESS"){
                             
                             alert(b.getReturnValue());
                         }
                         
                         
                     });
                    $A.enqueueAction(action2); */
                    
                    /* End of Email action */
                    var ac1 = component.get("c.closeEditPopup1")
                    $A.enqueueAction(ac1) 
                   // component.set("v.SuccessMessage",true);
                }
            }
        });
            if(component.get("v.DynamiccheckListName") != undefined && component.get("v.DynamiccheckListName") != null && component.get("v.DynamiccheckListName") != ""){
                $A.enqueueAction(action);
            }else{
                 component.set("v.isButtonDisabled",true);
                component.set("v.Spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Checklist name should not be null',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            } 
          //$A.enqueueAction(action);  
        
    },
    closeEditPopup1 : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
      handleDeleteRecord: function(component,event,helper){
          var breadcrumbCollection = component.get("v.breadcrumbCollection");
           var FieldDetails = component.get("v.selectedFieldValue");
        var ObjName = component.get('v.ObjectAPIName');
          component.set("v.ShowLevel1",true);
          component.set("v.ShowLevel2",false);
          component.set("v.ShowLevel3",false);
          component.set("v.ShowLevel4",false);
          component.set("v.ShowLevel5",false);
          /*var breadcrumb = {};
          breadcrumb.level = 'Level 1';
          alert ( JSON.stringify(breadcrumb));
          var bread ={};
          bread.level = 'Level 0';
          alert( JSON.stringify(bread));
          alert( JSON.stringify(breadcrumbCollection));
          if(breadcrumbCollection.level = 'Level 1'){
              alert("hai");
              component.set('v.breadcrumbCollection', bread);
          }*/
      component.set('v.breadcrumbCollection', '');
          component.set("v.isReference",true);
           component.set("v.selectedFieldValue",'');
           helper.GetFirstLevelFieldDetails(component, event, helper, ObjName, FieldDetails);
          
          
        
    },
    
    first : function(component,event,helper){
    
        var getObj = component.get('v.breadcrumbCollection')
      //  alert(getObj)
        console.log(getObj)
      //  component.set('v.FirstLevelObjectFields','')
   // component.set('v.breadcrumbCollection','')
        if(getObj.length == 2){
            getObj.pop();
             component.set('v.isReference',false)
               component.set('v.isReference',true)
               component.set('v.ShowLevel2',false)
                 component.set('v.ShowLevel1',true)
               
               
                  component.set("v.selectedFieldValue",'');
             //   component.set('v.ShowLevel1',false)
            //   component.set('v.ShowLevel1',true)
        }
     //   alert(component.get('v.breadcrumbCollection'));
       
        //  component.set('v.ShowLevel2',true)
    
    }
    
})