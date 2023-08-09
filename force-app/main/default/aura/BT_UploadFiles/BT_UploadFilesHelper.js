({
	getConfig : function(component, event, helper) {
		var mofa, moi, action;
		
        mofa = component.get("v.mainObjectFieldAPI");
        moi = component.get("v.mainObjectId");
        //alert(mofa);
        //alert(moi);
        action = component.get("c.getConfig");
        action.setParams({
            "mofa": mofa,
            "moi": moi
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.selectedBucket",response.getReturnValue().Name);
                component.set("v.selectedFolder",response.getReturnValue().Id);
                
            }
        });
        $A.enqueueAction(action);
	},
	
	getProjectFiles : function(component, event, helper) {
	    var action = component.get("c.getFiles");
	    action.setParams({
	        "recordId" : component.get("v.mainObjectId"),
	        "objectAPI" : component.get("v.mainObjectFieldAPI")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue(); 
	            component.set("v.filesList", result);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	setFileNameWithExtension: function (att){
    	var extension = '.undefined';
    	var extension;
		if(att.Name.indexOf('.') != -1){
			extension = '.'+att.Name.split('.').pop();
		} else{
			extension = att.Extension;
		}
		if(extension == null || extension == '' || extension == '.'){
			if(att.Extension == null){
				extension = '.undefiled';
			} else{
				extension = att.Extension;
			}
		}
		att.Extension = extension;
		if(att.Name.indexOf('.') != -1){
			if(att.Name.lastIndexOf('.') == att.Name.length - 1){
				att.Name = att.Name.substring(0, att.Name.length-1)+att.Extension;
			}
		} else{
			att.Name = att.Name+att.Extension;
		}
    },
    
    setSuccessActionUrl: function(component, event, helper, att){
    	var action;
    	action = component.get("c.gets3Key");
        action.setParams({});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var s3Data = response.getReturnValue();
                component.set("v.s3AccessKey",s3Data[0]);
                component.set("v.policy",s3Data[1]);
                component.set("v.signedPolicy",s3Data[2]);
                
                window.setTimeout($A.getCallback(function() {
                	$(".fileSubmitForm").submit(function(e) {
                	    //alert('Pavan');
					    e.preventDefault();
					    var input = document.getElementById('fileToUpload');
				    	if(input.files.length > 0 ){
				    		var the_file = input.files[0];
			    		}
			    		
					    var filename = Date.now() + '.' + the_file.name.split('.').pop(); //make file name unique using current time (milliseconds)
					    //$(this).find("input[name=key]").val(filename); //key name 
					    //$(this).find("input[name=Content-Type]").val(the_file.type); //content type
					    
					    var post_url = $(this).attr("action"); //get form action url
					    var form_data = new FormData(this); //Creates new FormData object
					    $.ajax({
					        url : post_url,
					        type: 'post',
					        data : form_data,
					        contentType: false,
					        processData:false,
					        success: function(){
					            
					            //document.getElementById("uploadfilesubmit").click(); 
					            //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
					            //component.get("v.onCancel")();
					            helper.save(component, event, att);
					        }
					    }).done(function(response){ 
					        //alert('Kumar');
					    	/*var mofa, moi, action;
					        mofa = component.get("v.mainObjectFieldAPI");
					        moi = component.get("v.mainObjectId");
					        
					        console.log('fileObjJSON--->',JSON.stringify(att));
					        console.log('mainObjectFieldAPI--->',mofa);
					        console.log('mainObjectId---->',moi);
					        //document.getElementById("uploadfilesubmit").click();
					        //$A.enqueueAction(component.get("c.onCancel"));
					        
					    	action = component.get("c.insertFile"); 
					        action.setParams({
					            "fileObjJSON": JSON.stringify(att),
					            "mainObjectFieldAPI":  mofa, 
					            "mainObjectId": moi
					        });
					        action.setCallback(this, function(response) {
					            //alert('Raju');
					        	console.log(response.getState());
					            if (response.getState() === "SUCCESS") {
					                $A.enqueueAction(component.get("c.onCancel"));
					                //alert('DFL');
					                console.log(response.getReturnValue());
					                var file = response.getReturnValue();
					                component.get("v.onSuccess")(file);
					                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
					                //$A.enqueueAction(component.get("c.onCancel"));
					                //component.get("v.onCancel")();
					                //helper.save(component, event, helper);
					                var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Success!",
                                        "type": 'success',
                                        "message": "File Uploaded Successfully"
                                    });
                                    toastEvent.fire();
                                    window.setTimeout(
                                        $A.getCallback(function() {
                                            $A.get('e.force:refreshView').fire();
                                        }), 2000
                                    );
					            }else if (response.getState() === "ERROR") {
						            var errors = response.getError();
				                    if (errors) {
				                        if (errors[0] && errors[0].message) {
				                            console.log("Error message: " + 
				                                     errors[0].message);
				                        }
				                    } else {
				                        console.log("Unknown error");
				                    }
						        }
					        });
					        $A.enqueueAction(action);*/
					        
					    });
					});
					//$('form.fileSubmitForm').trigger();
					$("form.fileSubmitForm").trigger('submit');
			        //document.getElementById("uploadfilesubmit").click();
			    }), 100);
			    
            }
            
        });
        $A.enqueueAction(action);
    },
    
    save : function(component, event, att){
        var mofa, moi, action;
        mofa = component.get("v.mainObjectFieldAPI");
        moi = component.get("v.mainObjectId");
        
        console.log('fileObjJSON--->',JSON.stringify(att));
        console.log('mainObjectFieldAPI--->',mofa);
        console.log('mainObjectId---->',moi);
        //alert('moi -------> '+moi);
        //document.getElementById("uploadfilesubmit").click();
        //$A.enqueueAction(component.get("c.onCancel"));
        $(document).ready(function(){
            $("#uploadfilesubmit").trigger('click'); 
        });
        window.setTimeout($A.getCallback(function() {
    	action = component.get("c.insertFile"); 
        action.setParams({
            "fileObjJSON": JSON.stringify(att),
            "mainObjectFieldAPI":  mofa, 
            "mainObjectId": moi,
            "selectedFiles" : component.get("v.selectedFiles")
        });
        action.setCallback(this, function(response) {
            //alert('Raju');
        	console.log(response.getState());
            if (response.getState() === "SUCCESS") {
                //$A.enqueueAction(component.get("c.onCancel"));
                //alert('DFL');
                console.log(response.getReturnValue());
                var file = response.getReturnValue();
                //alert('file --------> '+file);
                component.get("v.onSuccess")(file);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                //$A.enqueueAction(component.get("c.onCancel"));
                //component.get("v.onCancel")();
                //helper.save(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "File Uploaded Successfully"
                });
                toastEvent.fire();
                component.get("v.onSuccess")(file);
                /*window.setTimeout(
                    $A.getCallback(function() {
                        $A.get('e.force:refreshView').fire();
                    }), 2000
                );*/
            }else if (response.getState() === "ERROR") {
	            var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
	        }
        });
        $A.enqueueAction(action); 
         }), 100);
    }
})