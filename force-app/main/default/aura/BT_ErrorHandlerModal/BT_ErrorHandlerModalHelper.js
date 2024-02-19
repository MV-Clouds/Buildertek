({
    ErrorModalChange_Helper : function(component, event, helper, isErrorModal) {
        if(isErrorModal == false){
            var errorContainer = document.getElementsByClassName("errorContainer");
            if(errorContainer.length > 0){
              errorContainer[0].classList.remove("fadeIn");
              window.setTimeout( function() {
                component.set("v.isErrorModal", false);
              }, 100);
            }
            else{
              component.set("v.isErrorModal", false);
            }
          }
          else if(isErrorModal == true){
            component.set("v.isErrorModal", true);
  
            window.setTimeout(function(){
              var errorContainer = document.getElementsByClassName("errorContainer");
              if(errorContainer.length > 0){
                errorContainer[0].classList.add("fadeIn");
              }
            },100);
          }
    }
})
