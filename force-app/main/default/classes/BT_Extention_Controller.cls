public class BT_Extention_Controller{
    public buildertek__RFI__c rfi{get; set;}  
    public BT_Extention_Controller(ApexPages.StandardController sc){
        rfi= (buildertek__RFI__c )sc.getRecord();
    }
    // Other logic here
}