public class QBException extends Exception{

    Public static void QB_response(Integer StatusCode, String ResponseBody, String classname, String methodname){
        try {

            buildertek__Quickbook_Log__c error = new buildertek__Quickbook_Log__c();
            
            error.buildertek__Status_Code__c = StatusCode;
            error.buildertek__Response_Body__c = ResponseBody;
            error.buildertek__Class_Name__c = classname;
            error.buildertek__Method_Name__c = methodname;
    
            insert error;
            
        } catch (Exception e) {
            System.debug('Error in QB_response ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber());
        }
    }
}