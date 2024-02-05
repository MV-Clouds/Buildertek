({
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);
        var orgId = $A.get("$SObjectType.CurrentUser.Id");
        var baseUrl = window.location.protocol + '//' + window.location.hostname + '/' + orgId.substring(0, 15);
        console.log('Organization Base URL: ' + baseUrl);
        component.set('v.orgBaseURL', baseUrl);
        
        var action = component.get("c.getProductFiles");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', {state});
            var result = response.getReturnValue();
            console.log('Result =>', {result});
            if (result.status == 'success') {
                component.set("v.contentDocsList", result.contentLink);
                console.log(component.get("v.contentDocsList"));
            }else if(result.status == 'There Are No Product.'){
                component.set("v.message", 'Please assign Product to the Selection Option.');
            }else if(result.status == 'There Are No Files.') {
                component.set("v.message", 'There are no option images for this Selection Option.');  
            }else{
                component.set("v.message", 'Something went wrong while fetching option images.'); 
            }
        });
        $A.enqueueAction(action);
    },
    handle_img_click: function(component, event, helper){

        var clickedDiv = event.currentTarget;
        var imageSrc = clickedDiv.getAttribute('data-src');
        var imageId = clickedDiv.getAttribute('id');
        var imageTitle = clickedDiv.getAttribute('data-description');
        
        helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
        helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);

    },
    stopEventPropogation: function(component, event, helper){
        event.stopPropagation();
    },
    closeImagePreview : function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
    },
    Handle_imageLoaded: function(component, event, helper){
        console.log('image loaded');
        component.set("v.PreviewImgSpinner", false);
    },
    
    Handle_imageNotLoaded: function(component, event, helper){
        console.log('image not loaded');
        component.set("v.Is_ImageHavePreview", false);
        component.set("v.PreviewImgSpinner", false);

    },
    ChangeImg: function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
        helper.changeImageHelper(component, event, helper, null, true);
    },
})