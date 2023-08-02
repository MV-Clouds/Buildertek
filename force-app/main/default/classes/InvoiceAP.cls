public class InvoiceAP {

    public static void main()
    {
        buildertek__Account_Payable_Clone__c a = [select buildertek__AP_Number__c from buildertek__Account_Payable_Clone__c where id = 'a4o1K000000MyMaQAK'];
        System.debug(a.buildertek__AP_Number__c);
    }
}