public class QuickbooksConfigController implements Metadata.DeployCallback{

/*------------------------- getQBConfigs ---------------------------*

|  Function getQBConfigs
|
|  Purpose:  This method get the data of the active user and it will
|           use the user's quickbooks details for integration.
|
|  Returns:  qbConfigs object of user data info.
*-------------------------------------------------------------------*/

    @AuraEnabled
    public static buildertek__QuickBooks_Setting__mdt getQBConfigs(){
        buildertek__QuickBooks_Setting__mdt qbConfigs = new buildertek__QuickBooks_Setting__mdt();
        String username = 'QB_'+UserInfo.getUserName();
        List<buildertek__QuickBooks_Setting__mdt> qbConfigList = [SELECT Id,
                                                                  DeveloperName, 
                                                                  MasterLabel, 
                                                                  buildertek__Access_Token__c, 
                                                                  buildertek__Client_Id__c, 
                                                                  buildertek__Client_Secret__c, 
                                                                  buildertek__Refresh_Token__c, 
                                                                  buildertek__Scope__c, 
                                                                  buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt WHERE MasterLabel =: username];
        if(qbconfigList.size() > 0){
            qbConfigs = qbconfigList[0];   
        }else{
            Map<String,Object> mapToUpdate = new Map<String,Object>();
            handleInsertAndUpdate('buildertek__QuickBoooks_Setting.'+username,username,mapToUpdate);
        } 
        return qbConfigs;
    }
    

/*------------------------- authorizeQuickBook ---------------------------*

|  Function authorizeQuickBook
|
|  Purpose:  This function takes client-id,client-secret & scope and returns the custom URL 
|            which will be used for autorization process
|
|  Parameters:
|        (IN = USED TO PASS DATA INTO THIS FUNCTION, 
|         OUT = USED TO PASS DATA OUT OF THIS FUNCTION
|         IN/OUT = USED FOR BOTH PURPOSES.)
|      
|      client_id (IN) -- this parameter brings the client id of the quickbooks 
|                        in use here, which will be usefull for autorization process 
|                      
|      client_secret (IN) -- this parameter brings the client secret of the quickbooks 
|                        in use here, which will be usefull for autorization process 
|                      
|      scope (IN) -- this parameter brings the scope of the quickbooks 
|                        in use here, which will be usefull for autorization process 
|                      
|
|  Returns:  Custom Autoriztion url.
*-------------------------------------------------------------------*/


    @AuraEnabled
    public static string authorizeQuickBook(String client_id,String client_secret,String scope){
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        String url = 'https://appcenter.intuit.com/connect/oauth2?client_id='+client_id+'&scope='+scope+'&redirect_uri=' +
            EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Authorization', 'UTF-8') +
            '&response_type=code&state=' + timestamp;
        return url;
    }
    
    // getPages method returns the list of pages from the ApexPage object
    @AuraEnabled
    public static List<ApexPage> getPages(){
        List<ApexPage> pages = [SELECT MasterLabel, Name, NamespacePrefix FROM ApexPage Order By Name ASC];
        return pages;    
    }
    

/*------------------------- saveSettings ---------------------------*

|  Function saveSettings
|
|  Purpose:  This method take the object from the getQBConfigs method 
|           and store it's field values to the map.
|  Parameters:
|      qbConfigs (IN) --  object which has a user data.  
|                      (IN = USED TO PASS DATA INTO THIS FUNCTION,
|                       OUT = USED TO PASS DATA OUT OF THIS FUNCTION
|                       IN/OUT = USED FOR BOTH PURPOSES.)
|     
*-------------------------------------------------------------------*/

    @AuraEnabled
    public static void saveSettings(buildertek__QuickBooks_Setting__mdt qbConfigs){
        Map<String,Object> mapToUpdate = new Map<String,Object>();
        mapToUpdate.put('buildertek__Access_Token__c',qbConfigs.buildertek__Access_Token__c);
        mapToUpdate.put('buildertek__Client_Id__c',qbConfigs.buildertek__Client_Id__c);
        mapToUpdate.put('buildertek__Client_Secret__c',qbConfigs.buildertek__Client_Secret__c);
        mapToUpdate.put('buildertek__Refresh_Token__c',qbConfigs.buildertek__Refresh_Token__c);
        mapToUpdate.put('buildertek__Scope__c',qbConfigs.buildertek__Scope__c);
        mapToUpdate.put('buildertek__Company_Id__c',qbConfigs.buildertek__Company_Id__c);
        QuickbooksConfigController.handleInsertAndUpdate('buildertek__QuickBooks_Setting.QB_bc_buildertek_com','QB_bc@buildertek.com',mapToUpdate);
        
    }
    
    //META DATA METHODS
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success: '+ result);
        } else {
            System.debug(' fail: '+ result);
        }
    }
    
/*------------------------- handleInsertAndUpdate ---------------------------*

|  Function handleInsertAndUpdate
|
|  Purpose:  This function callout in the saveSettings method and it will set the
|            fullname & label of the customMetaData.
|
|  Parameters:
|        (IN = USED TO PASS DATA INTO THIS FUNCTION, 
|         OUT = USED TO PASS DATA OUT OF THIS FUNCTION
|         IN/OUT = USED FOR BOTH PURPOSES.)
|      
|      fullName (IN) --  parameter get the fullname of the customMetaData 
|                        
|                      
|      label (IN) -- this parameter get the label of the customMetaData 
|                         
|                      
|      fieldWithValuesMap (IN) -- this parameter get the map which is going to  
|                        update later in the method 
|                      
*-------------------------------------------------------------------*/
    
    public static void handleInsertAndUpdate (String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        for (String key: fieldWithValuesMap.keySet()) {
            Metadata.CUstomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        QuickbooksConfigController callback = new QuickbooksConfigController();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer,callback);
    }
}